import Foundation
import Security
import CommonCrypto
import Secrets

final actor DPoPService {
    // MARK: - Singleton
    static let shared = DPoPService()

    // MARK: - Dependencies
    private let dateProvider: () -> Date

    // MARK: - Keychain
    private let keyTag: Data = "org.wxyc.dpop.ec256".data(using: .utf8)!
    private var cachedPrivateKey: SecKey?

    // MARK: - Access Token Cache
    private var cachedAccessToken: String?
    private var accessTokenExpiry: Date?
    private let defaultTokenTTLSeconds: TimeInterval = 3600

    // MARK: - Init
    init(dateProvider: @escaping () -> Date = Date.init) {
        self.dateProvider = dateProvider
    }

    // MARK: - Public API

    /// Call this once on app start to warm up keys and token
    func prepare() async {
        _ = try? await ensureValidAccessToken()
    }

    /// Attaches Authorization and DPoP headers to a request
    /// Reads URL and method from the URLRequest
    func attachHeaders(to request: inout URLRequest) async throws {
        guard let urlString = request.url?.absoluteString else {
            throw NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "URLRequest missing URL"])
        }
        let method = request.httpMethod ?? "GET"

        // Ensure we have a valid access token
        do {
            let bearer = try await ensureValidAccessToken()
            
            // Create DPoP token for this specific request
            let dpop = try generateDPoPToken(uri: urlString, method: method)
            
            request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
            request.setValue(dpop, forHTTPHeaderField: "DPoP")
        } catch {
            print(error)
            print(error)
        }
    }

    /// Deletes all stored data including cached tokens and private keys
    /// Use this for debugging, testing, or when you need to reset the DPoP state
    func clearAllData() throws {
        // Clear in-memory caches
        cachedAccessToken = nil
        accessTokenExpiry = nil
        cachedPrivateKey = nil
        
        // Delete the private key from Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: keyTag
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw NSError(
                domain: "DPoP",
                code: Int(status),
                userInfo: [
                    NSLocalizedDescriptionKey: "Failed to delete private key from Keychain",
                    NSUnderlyingErrorKey: NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
                ]
            )
        }
    }

    // MARK: - Access Token Lifecycle

    private func ensureValidAccessToken() async throws -> String {
        if let token = cachedAccessToken, let expiry = accessTokenExpiry, dateProvider() < expiry {
            return token
        }
        let token = try await fetchAccessToken()
        return token
    }

    /// Fetch a new access token from the service using DPoP
    private func fetchAccessToken() async throws -> String {
        // Ensure persistent key exists so JWK/jkt stays stable across launches
        _ = try getOrCreatePrivateKey()

        let url = await ConfigurationService.shared.dpopTokenEndpointURL

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Attach DPoP proof only (no Authorization header yet)
        let dpop = try generateDPoPToken(uri: url.absoluteString, method: "POST")
        req.setValue(dpop, forHTTPHeaderField: "DPoP")
        print(req)

        let (data, response) = try await URLSession.shared.data(for: req)
        guard let http = response as? HTTPURLResponse else {
            throw NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "No HTTP response"])
        }
        guard http.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "<no body>"
            throw NSError(domain: "DPoP", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "Token endpoint failed: \(body)"])
        }

        let obj = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dict = obj as? [String: Any],
              let token = dict["access_token"] as? String else {
            throw NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Malformed token response"])
        }
        let expiresIn = (dict["expires_in"] as? TimeInterval) ?? defaultTokenTTLSeconds
        // Add a small skew to avoid edge expiry
        let skew: TimeInterval = 30
        cachedAccessToken = token
        accessTokenExpiry = dateProvider().addingTimeInterval(max(0, expiresIn - skew))
        return token
    }

    // MARK: - Token Generation

    private func generateDPoPToken(uri: String, method: String) throws -> String {
        // 1) Get or create persistent EC P-256 key pair from Keychain
        let privateKey = try getOrCreatePrivateKey()
        let publicKey = try generateECPublicKey(from: privateKey)

        // 2) Create JWK from public key (x and y coordinates, base64url-encoded)
        let jwk = try createJWK(from: publicKey)

        // 3) Build header and payload
        let now = Int(dateProvider().timeIntervalSince1970)
        let header: [String: Any] = [
            "typ": "dpop+jwt",
            "alg": "ES256",
            "jwk": jwk
        ]
        let payload: [String: Any] = [
            "htu": uri,
            "htm": method,
            "iat": now,
            "exp": now + 600, // 10 minutes
            "jti": "dpop-\(UUID().uuidString)"
            // NOTE: We intentionally omit 'ath' to avoid binding to an access token
        ]

        // 4) Encode (no signature validation server-side currently)
        let headerData = try JSONSerialization.data(withJSONObject: header)
        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        let headerB64 = base64URLEncode(headerData)
        let payloadB64 = base64URLEncode(payloadData)
        let signature = "unsigned"
        return "\(headerB64).\(payloadB64).\(signature)"
    }

    // MARK: - Helpers

    private func base64URLEncode(_ data: Data) -> String {
        let str = data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
        return str
    }

    private func getOrCreatePrivateKey() throws -> SecKey {
        // Return cached key if available
        if let key = cachedPrivateKey {
            return key
        }

        // Try to find existing key in Keychain
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: keyTag,
            kSecReturnRef as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            let key = item as! SecKey
            cachedPrivateKey = key
            return key
        }

        // Create a new persistent key
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyTag,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw error?.takeRetainedValue() ?? NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to generate EC private key"])
        }

        cachedPrivateKey = key
        return key
    }

    private func generateECPublicKey(from privateKey: SecKey) throws -> SecKey {
        guard let pub = SecKeyCopyPublicKey(privateKey) else {
            throw NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to derive EC public key"])
        }
        return pub
    }

    private func createJWK(from publicKey: SecKey) throws -> [String: Any] {
        var error: Unmanaged<CFError>?
        guard let pubDataCF = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            throw error?.takeRetainedValue() ?? NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to export public key data"])
        }
        let pubData = pubDataCF as Data

        // For EC public keys, iOS returns ANSI X9.63 format: 0x04 || X || Y (65 bytes total)
        // where X and Y are 32-byte coordinates for P-256
        guard pubData.count == 65, pubData.first == 0x04 else {
            throw NSError(domain: "DPoP", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unexpected EC public key format"])
        }
        let x = pubData[1...32]
        let y = pubData[33...64]
        let xB64 = base64URLEncode(Data(x))
        let yB64 = base64URLEncode(Data(y))

        return [
            "kty": "EC",
            "crv": "P-256",
            "x": xB64,
            "y": yB64
        ]
    }
}

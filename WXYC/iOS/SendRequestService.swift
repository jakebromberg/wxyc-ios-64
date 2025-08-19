import Foundation
import Logger
import PostHog

final actor SendRequestService {
    // MARK: - Singleton
    static let shared = SendRequestService()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Public API
    
    /// Sends a message to the server with DPoP authentication
    /// - Parameter message: The message to send
    /// - Throws: Error if the request fails
    func sendMessageToServer(message: String) async throws {
        let url = await ConfigurationService.shared.requestEndpointURL
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Payload expected by backend
        let body: [String: Any] = ["message": message]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }
        req.httpBody = jsonData
        
        // Attach DPoP + Authorization headers (Authorization uses benign placeholder)
        do {
            try await DPoPService.shared.attachHeaders(to: &req)
        } catch {
            Log(.error, "Failed to attach DPoP headers: \(error)")
            await PostHogSDK.shared.capture(
                "DPoP header attachment failed",
                context: "SendRequestService",
                additionalData: [
                    "error": error.localizedDescription,
                    "environment": ConfigurationService.shared.environmentName,
                ])
            throw error
        }
        
        await PostHogSDK.shared.capture(
            "Request sent",
            context: "SendRequestService",
            additionalData: [
                "message": message,
                "endpoint": "/request",
                "environment": ConfigurationService.shared.environmentName,
            ]
        )
        
        do {
            let (data, response) = try await URLSession.shared.data(for: req)
            if let response = response as? HTTPURLResponse {
                Log(.info, "Response status code: \(response.statusCode)")
                if response.statusCode == 200 {
                    // Optionally parse response
                    if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let ok = obj["success"] as? Bool, ok
                    {
                        Log(.info, "Song request submitted successfully")
                        await PostHogSDK.shared.capture(
                            "Song request success", context: "SendRequestService",
                            additionalData: ["environment": ConfigurationService.shared.environmentName])
                    }
                } else if response.statusCode == 401 {
                    Log(.error, "DPoP validation failed - authentication error")
                    await PostHogSDK.shared.capture(
                        "DPoP validation failed", context: "SendRequestService",
                        additionalData: ["environment": ConfigurationService.shared.environmentName])
                }
            }
        } catch {
            Log(.error, "Error sending request: \(error)")
            await PostHogSDK.shared.capture(
                error: error, context: "SendRequestService",
                additionalData: ["environment": ConfigurationService.shared.environmentName])
        }
    }
}

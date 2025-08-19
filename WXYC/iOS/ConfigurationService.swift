import Foundation
import Secrets

final actor ConfigurationService {
    // MARK: - Singleton
    static let shared = ConfigurationService()
    
    // MARK: - Init
    private init() {}
    
    // MARK: - Environment Detection
    
    /// Returns the base URL for API requests based on build configuration
    var apiBaseURL: URL {
        #if TESTING
        // For testing builds, use localhost
        return URL(string: "http://localhost:8080")!
        #else
        // For all other builds (debug/release), use production API
        return URL(string: Secrets.apiBaseUrl)!
        #endif
    }
    
    /// Returns the full URL for the request endpoint
    var requestEndpointURL: URL {
        return apiBaseURL.appendingPathComponent("request")
    }
    
    /// Returns the full URL for the DPoP token endpoint
    var dpopTokenEndpointURL: URL {
        return apiBaseURL.appendingPathComponent("token/dpop")
    }
    
    /// Returns the current environment name for logging and analytics
    var environmentName: String {
        #if TESTING
        return "Testing"
        #else
        return "Production"
        #endif
    }
}


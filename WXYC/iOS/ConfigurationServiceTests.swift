import XCTest
@testable import WXYC

final class ConfigurationServiceTests: XCTestCase {
    
    func testConfigurationServiceSingleton() async {
        let service1 = ConfigurationService.shared
        let service2 = ConfigurationService.shared
        
        XCTAssertTrue(service1 === service2, "ConfigurationService should be a singleton")
    }
    
    func testEnvironmentName() async {
        let service = ConfigurationService.shared
        let environment = await service.environmentName
        
        #if TESTING
        XCTAssertEqual(environment, "Testing", "Environment should be Testing when TESTING flag is set")
        #else
        XCTAssertEqual(environment, "Production", "Environment should be Production when TESTING flag is not set")
        #endif
    }
    
    func testAPIBaseURL() async {
        let service = ConfigurationService.shared
        let baseURL = await service.apiBaseURL
        
        #if TESTING 
        XCTAssertEqual(baseURL.absoluteString, "http://localhost:8080", "Base URL should be localhost when TESTING flag is set")
        #else
        XCTAssertEqual(baseURL.absoluteString, "https://api.wxyc.org", "Base URL should be production API when TESTING flag is not set")
        #endif
    }
    
    func testRequestEndpointURL() async {
        let service = ConfigurationService.shared
        let requestURL = await service.requestEndpointURL
        
        #if TESTING
        XCTAssertEqual(requestURL.absoluteString, "http://localhost:8080/request", "Request endpoint should be localhost when TESTING flag is set")
        #else
        XCTAssertEqual(requestURL.absoluteString, "https://api.wxyc.org/request", "Request endpoint should be production API when TESTING flag is not set")
        #endif
    }
    
    func testDPoPTokenEndpointURL() async {
        let service = ConfigurationService.shared
        let dpopURL = await service.dpopTokenEndpointURL
        
        #if TESTING
        XCTAssertEqual(dpopURL.absoluteString, "http://localhost:8080/token/dpop", "DPoP token endpoint should be localhost when TESTING flag is set")
        #else
        XCTAssertEqual(dpopURL.absoluteString, "https://api.wxyc.org/token/dpop", "DPoP token endpoint should be production API when TESTING flag is not set")
        #endif
    }
}


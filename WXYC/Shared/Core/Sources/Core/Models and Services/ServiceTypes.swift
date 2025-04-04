import Foundation

public extension TimeInterval {
    static let distantFuture = Date.distantFuture.timeIntervalSince1970
    static let oneDay = 60.0 * 60.0 * 24.0
    static let thirtyDays = oneDay * 30.0
}

/// `NowPlayingService` will throw one of these errors, depending
enum ServiceError: String, LocalizedError, Codable {
    case noResults
    case noNewData
}

protocol WebSession: Sendable {
    func data(from url: URL) async throws -> Data
}

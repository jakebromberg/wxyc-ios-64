//
//  PlaylistServiceRaceConditionTests.swift
//  Playlist
//
//  Unit tests to verify PlaylistService doesn't start multiple fetch tasks
//
//  Created by Jake Bromberg on 11/25/25.
//  Copyright © 2025 WXYC. All rights reserved.
//

import Testing
import Foundation
@testable import Playlist
@testable import Caching

// MARK: - Mock Cache for Tests

/// In-memory cache for isolated test execution (race condition tests)
final class RaceConditionTestMockCache: Cache, @unchecked Sendable {
    private var dataStorage: [String: Data] = [:]
    private var metadataStorage: [String: CacheMetadata] = [:]
    private let lock = NSLock()

    func metadata(for key: String) -> CacheMetadata? {
        lock.lock()
        defer { lock.unlock() }
        return metadataStorage[key]
    }
    
    func data(for key: String) -> Data? {
        lock.lock()
        defer { lock.unlock() }
        return dataStorage[key]
    }

    func set(_ data: Data?, metadata: CacheMetadata, for key: String) {
        lock.lock()
        defer { lock.unlock() }
        if let data = data {
            dataStorage[key] = data
            metadataStorage[key] = metadata
        } else {
            remove(for: key)
        }
    }
    
    func remove(for key: String) {
        lock.lock()
        defer { lock.unlock() }
        dataStorage.removeValue(forKey: key)
        metadataStorage.removeValue(forKey: key)
    }

    func allMetadata() -> [(key: String, metadata: CacheMetadata)] {
        lock.lock()
        defer { lock.unlock() }
        return metadataStorage.map { ($0.key, $0.value) }
    }

    func clearAll() {
        lock.lock()
        defer { lock.unlock() }
        dataStorage.removeAll()
        metadataStorage.removeAll()
    }
    
    func totalSize() -> Int64 {
        lock.lock()
        defer { lock.unlock() }
        return dataStorage.values.reduce(0) { $0 + Int64($1.count) }
    }
}

/// Mock fetcher for tracking concurrency in race condition tests
actor ConcurrentTrackingMockFetcher: PlaylistFetcherProtocol {
    var activeFetchCount: Int = 0
    var maxConcurrentFetches: Int = 0
    var totalFetchCount: Int = 0
    
    /// Continuations waiting for a fetch to complete
    private var fetchCompletionContinuations: [CheckedContinuation<Void, Never>] = []

    /// Returns a non-empty playlist so broadcasts happen
    private let testPlaylist = Playlist(
        playcuts: [
            Playcut(
                id: 1,
                hour: 1000,
                chronOrderID: 1,
                songTitle: "Test Song",
                labelName: nil,
                artistName: "Test Artist",
                releaseTitle: nil
            )
        ],
        breakpoints: [],
        talksets: []
    )

    func fetchPlaylist() async -> Playlist {
        // Track entry into fetch
        activeFetchCount += 1
        totalFetchCount += 1
        maxConcurrentFetches = max(maxConcurrentFetches, activeFetchCount)

        // Simulate network delay to increase race window
        try? await Task.sleep(for: .milliseconds(50))

        // Track exit from fetch
        activeFetchCount -= 1

        // Notify any waiters that a fetch completed
        let continuations = fetchCompletionContinuations
        fetchCompletionContinuations.removeAll()
        for continuation in continuations {
            continuation.resume()
        }

        return testPlaylist
    }

    func reset() {
        activeFetchCount = 0
        maxConcurrentFetches = 0
        totalFetchCount = 0
    }

    /// Wait for at least one fetch to complete
    func waitForFetch() async {
        await withCheckedContinuation { continuation in
            fetchCompletionContinuations.append(continuation)
        }
    }
}

@Suite("PlaylistService Race Condition Tests")
struct PlaylistServiceRaceConditionTests {

    @Test("Concurrent observers start only one fetch task", .timeLimit(.minutes(1)))
    func concurrentObserversStartOnlyOneFetchTask() async throws {
        // Given: A playlist service with a mock fetcher
        let tracker = ConcurrentTrackingMockFetcher()
        let service = PlaylistService(
            fetcher: tracker,
            interval: 10.0, // Long interval - we only care about the first fetch
            cacheCoordinator: CacheCoordinator(cache: RaceConditionTestMockCache())
        )
        
        // When: Many observers subscribe concurrently and consume values
        let observerCount = 50
        var tasks: [Task<Playlist?, Never>] = []
        for _ in 0..<observerCount {
            let task = Task {
                var iterator = service.updates().makeAsyncIterator()
                // Consume first value - this waits for the fetch to complete
                return await iterator.next()
            }
            tasks.append(task)
        }

        // Wait for all observers to receive their first value
        // This ensures the fetch has completed
        for task in tasks {
            _ = await task.value
        }

        // Then: Only one fetch task should have been running at any point
        let maxConcurrent = await tracker.maxConcurrentFetches
        let totalFetches = await tracker.totalFetchCount

        // Cancel all tasks to trigger cleanup
        for task in tasks {
            task.cancel()
        }

        #expect(
            maxConcurrent == 1,
            "Expected only 1 concurrent fetch, but found \(maxConcurrent). This indicates multiple fetch tasks were started."
        )
        #expect(
            totalFetches == 1,
            "Expected only 1 total fetch, but found \(totalFetches)."
        )
    }

    @Test("Fetch task stops when all observers disconnect", .timeLimit(.minutes(1)))
    func fetchTaskStopsWhenAllObserversDisconnect() async throws {
        let tracker = ConcurrentTrackingMockFetcher()
        let service = PlaylistService(
            fetcher: tracker,
            interval: 0.1, // Short interval to test multiple fetches
            cacheCoordinator: CacheCoordinator(cache: RaceConditionTestMockCache())
        )

        // Create some observers that consume one value then exit
        var tasks: [Task<Playlist?, Never>] = []
        for _ in 0..<5 {
            let task = Task {
                var iterator = service.updates().makeAsyncIterator()
                // Consume one value then exit (which disconnects this observer)
                return await iterator.next()
            }
            tasks.append(task)
        }

        // Wait for all observers to receive their first value
        for task in tasks {
            _ = await task.value
        }

        // Record the fetch count after initial fetches complete
        let fetchCountAfterInitial = await tracker.totalFetchCount

        // All observers have exited their for-await loops, so the service
        // should have no continuations and should stop fetching.
        // Wait for any in-flight fetch to complete and give cleanup time.
        try await Task.sleep(for: .milliseconds(150))

        // Reset the counter to track only new fetches
        await tracker.reset()

        // Wait longer than multiple fetch intervals
        try await Task.sleep(for: .milliseconds(300))

        // Verify no more fetches occurred after all observers disconnected
        let fetchesAfterDisconnect = await tracker.totalFetchCount
        #expect(
            fetchesAfterDisconnect == 0,
            "Expected no fetches after all observers disconnected, but found \(fetchesAfterDisconnect). Initial fetches were \(fetchCountAfterInitial)."
        )
    }

    @Test("Observers receive initial value", .timeLimit(.minutes(1)))
    func observersReceiveInitialValue() async throws {
        let tracker = ConcurrentTrackingMockFetcher()
        let service = PlaylistService(
            fetcher: tracker,
            interval: 1.0,
            cacheCoordinator: CacheCoordinator(cache: RaceConditionTestMockCache())
        )

        // Use a Task to properly manage the stream lifecycle
        let task = Task {
            var iterator = service.updates().makeAsyncIterator()
            return await iterator.next()
        }

        // Should receive a value (will wait for first fetch since cache is empty)
        let firstValue = await task.value
        #expect(firstValue != nil, "Expected to receive initial playlist value")

        // Cancel the task to ensure cleanup
        task.cancel()

        // Give the service time to clean up
        try await Task.sleep(for: .milliseconds(100))
    }
}

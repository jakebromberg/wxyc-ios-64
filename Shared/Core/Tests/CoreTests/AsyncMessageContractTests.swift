//
//  AsyncMessageContractTests.swift
//  Core
//
//  Parameterized behavioral contract tests for AsyncMessage implementations.
//  These tests verify that the backport (AsyncNotificationMessage) and native
//  (NotificationCenter.AsyncMessage) implementations exhibit identical behavior.
//
//  Created by Claude on 01/18/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Testing
import Foundation
@testable import Core

/// Identifies which AsyncMessage implementation to test.
enum AsyncMessageImplementation: String, CaseIterable, CustomTestStringConvertible {
    case backport
    case native

    var testDescription: String { rawValue }
}

@Suite("AsyncMessage Behavioral Contract", .serialized)
struct AsyncMessageContractTests {

    // MARK: - Post and Receive

    @Test("Message can be posted and received", arguments: AsyncMessageImplementation.allCases)
    func postAndReceive(implementation: AsyncMessageImplementation) async {
        let center = NotificationCenter()
        let expectedData = "test-data-\(implementation.rawValue)"

        switch implementation {
        case .backport:
            await verifyPostAndReceiveBackport(center: center, expectedData: expectedData)
        case .native:
            guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) else { return }
            await verifyPostAndReceiveNative(center: center, expectedData: expectedData)
        }
    }

    private func verifyPostAndReceiveBackport(center: NotificationCenter, expectedData: String) async {
        var task: Task<String?, Never>!

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            task = Task<String?, Never> {
                for await message in center.messages(for: BackportAsyncTestMessage.self, onSubscribed: {
                    continuation.resume()
                }) {
                    return message.data
                }
                return nil
            }
        }

        center.post(BackportAsyncTestMessage(data: expectedData), subject: nil as AsyncTestSubject?)

        let received = await task.value
        #expect(received == expectedData)
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    private func verifyPostAndReceiveNative(center: NotificationCenter, expectedData: String) async {
        let subject = AsyncTestSubject()

        let task = Task<String?, Never> {
            for await message in center.messages(for: NativeAsyncTestMessage.self) {
                return message.data
            }
            return nil
        }

        // Brief yield to allow the observer to register
        await Task.yield()

        center.post(NativeAsyncTestMessage(data: expectedData), subject: subject)

        let received = await task.value
        #expect(received == expectedData)
    }

    // MARK: - Multiple Messages in Order

    @Test("Multiple messages are received in order", arguments: AsyncMessageImplementation.allCases)
    func multipleMessages(implementation: AsyncMessageImplementation) async {
        let center = NotificationCenter()
        let messages = ["first", "second", "third"]

        switch implementation {
        case .backport:
            await verifyMultipleMessagesBackport(center: center, messages: messages)
        case .native:
            guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) else { return }
            await verifyMultipleMessagesNative(center: center, messages: messages)
        }
    }

    private func verifyMultipleMessagesBackport(center: NotificationCenter, messages: [String]) async {
        var task: Task<[String], Never>!

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            task = Task {
                var received: [String] = []
                for await message in center.messages(for: BackportAsyncTestMessage.self, onSubscribed: {
                    continuation.resume()
                }) {
                    received.append(message.data)
                    if received.count == messages.count {
                        break
                    }
                }
                return received
            }
        }

        for msg in messages {
            center.post(BackportAsyncTestMessage(data: msg), subject: nil as AsyncTestSubject?)
        }

        let received = await task.value
        #expect(received == messages)
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    private func verifyMultipleMessagesNative(center: NotificationCenter, messages: [String]) async {
        let subject = AsyncTestSubject()

        let task = Task {
            var received: [String] = []
            for await message in center.messages(for: NativeAsyncTestMessage.self) {
                received.append(message.data)
                if received.count == messages.count {
                    break
                }
            }
            return received
        }

        await Task.yield()

        for msg in messages {
            center.post(NativeAsyncTestMessage(data: msg), subject: subject)
        }

        let received = await task.value
        #expect(received == messages)
    }

    // MARK: - Subject Filtering

    @Test("Subject filtering works correctly", arguments: AsyncMessageImplementation.allCases)
    func subjectFiltering(implementation: AsyncMessageImplementation) async {
        let center = NotificationCenter()
        let targetSubject = AsyncTestSubject()
        let otherSubject = AsyncTestSubject()

        switch implementation {
        case .backport:
            await verifySubjectFilteringBackport(
                center: center,
                targetSubject: targetSubject,
                otherSubject: otherSubject
            )
        case .native:
            guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) else { return }
            await verifySubjectFilteringNative(
                center: center,
                targetSubject: targetSubject,
                otherSubject: otherSubject
            )
        }
    }

    private func verifySubjectFilteringBackport(
        center: NotificationCenter,
        targetSubject: AsyncTestSubject,
        otherSubject: AsyncTestSubject
    ) async {
        var task: Task<String?, Never>!

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            task = Task<String?, Never> {
                for await message in center.messages(
                    of: targetSubject,
                    for: BackportAsyncTestMessage.self,
                    onSubscribed: { continuation.resume() }
                ) {
                    return message.data
                }
                return nil
            }
        }

        // Post to other subject first - should be ignored
        center.post(BackportAsyncTestMessage(data: "wrong"), subject: otherSubject)

        // Post to target subject - should be received
        center.post(BackportAsyncTestMessage(data: "correct"), subject: targetSubject)

        let received = await task.value
        #expect(received == "correct")
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    private func verifySubjectFilteringNative(
        center: NotificationCenter,
        targetSubject: AsyncTestSubject,
        otherSubject: AsyncTestSubject
    ) async {
        let task = Task<String?, Never> {
            for await message in center.messages(of: targetSubject, for: NativeAsyncTestMessage.self) {
                return message.data
            }
            return nil
        }

        await Task.yield()

        // Post to other subject first - should be ignored
        center.post(NativeAsyncTestMessage(data: "wrong"), subject: otherSubject)

        // Post to target subject - should be received
        center.post(NativeAsyncTestMessage(data: "correct"), subject: targetSubject)

        let received = await task.value
        #expect(received == "correct")
    }

    // MARK: - makeMessage Validation

    @Test("makeMessage returns nil for invalid notification", arguments: AsyncMessageImplementation.allCases)
    func makeMessageReturnsNil(implementation: AsyncMessageImplementation) {
        switch implementation {
        case .backport:
            let invalidNotification = Notification(
                name: BackportAsyncTestMessage.name,
                object: nil,
                userInfo: nil
            )
            let message = BackportAsyncTestMessage.makeMessage(invalidNotification)
            #expect(message == nil)

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let invalidNotification = Notification(
                    name: NativeAsyncTestMessage.name,
                    object: nil,
                    userInfo: nil
                )
                let message = NativeAsyncTestMessage.makeMessage(invalidNotification)
                #expect(message == nil)
            }
        }
    }

    // MARK: - makeNotification Validation

    @Test("makeNotification creates valid notification", arguments: AsyncMessageImplementation.allCases)
    func makeNotificationCreatesValidNotification(implementation: AsyncMessageImplementation) {
        let subject = AsyncTestSubject()

        switch implementation {
        case .backport:
            let message = BackportAsyncTestMessage(data: "test")
            let notification = BackportAsyncTestMessage.makeNotification(message, object: subject)

            #expect(notification.name == BackportAsyncTestMessage.name)
            #expect(notification.object as AnyObject? === subject)
            #expect(notification.userInfo?["data"] as? String == "test")

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let message = NativeAsyncTestMessage(data: "test")
                let notification = NativeAsyncTestMessage.makeNotification(message, object: subject)

                #expect(notification.name == NativeAsyncTestMessage.name)
                #expect(notification.object as AnyObject? === subject)
                #expect(notification.userInfo?["data"] as? String == "test")
            }
        }
    }

    // MARK: - Round-Trip Conversion

    @Test("Message survives round-trip conversion", arguments: AsyncMessageImplementation.allCases)
    func roundTripConversion(implementation: AsyncMessageImplementation) {
        let subject = AsyncTestSubject()
        let originalData = "round-trip-data"

        switch implementation {
        case .backport:
            let original = BackportAsyncTestMessage(data: originalData)
            let notification = BackportAsyncTestMessage.makeNotification(original, object: subject)
            let reconstructed = BackportAsyncTestMessage.makeMessage(notification)

            #expect(reconstructed != nil)
            #expect(reconstructed?.data == originalData)

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let original = NativeAsyncTestMessage(data: originalData)
                let notification = NativeAsyncTestMessage.makeNotification(original, object: subject)
                let reconstructed = NativeAsyncTestMessage.makeMessage(notification)

                #expect(reconstructed != nil)
                #expect(reconstructed?.data == originalData)
            }
        }
    }
}

// MARK: - Test Fixtures

/// Shared subject type for both implementations.
final class AsyncTestSubject: Sendable {}

/// Test message conforming to the backport protocol.
struct BackportAsyncTestMessage: AsyncNotificationMessage, Sendable {
    typealias Subject = AsyncTestSubject

    static var name: Notification.Name { .init("Core.BackportAsyncTestMessage") }

    let data: String

    static func makeMessage(_ notification: Notification) -> Self? {
        guard let data = notification.userInfo?["data"] as? String else { return nil }
        return Self(data: data)
    }

    static func makeNotification(_ message: Self, object: Subject?) -> Notification {
        Notification(name: name, object: object, userInfo: ["data": message.data])
    }
}

/// Test message conforming to the native iOS 26 protocol.
@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
struct NativeAsyncTestMessage: NotificationCenter.AsyncMessage, Sendable {
    typealias Subject = AsyncTestSubject

    static var name: Notification.Name { .init("Core.NativeAsyncTestMessage") }

    let data: String

    static func makeMessage(_ notification: Notification) -> Self? {
        guard let data = notification.userInfo?["data"] as? String else { return nil }
        return Self(data: data)
    }

    static func makeNotification(_ message: Self, object: Subject?) -> Notification {
        Notification(name: name, object: object, userInfo: ["data": message.data])
    }
}

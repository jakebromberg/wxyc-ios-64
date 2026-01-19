//
//  MainActorMessageContractTests.swift
//  Core
//
//  Parameterized behavioral contract tests for MainActorMessage implementations.
//  These tests verify that the backport (MainActorNotificationMessage) and native
//  (NotificationCenter.MainActorMessage) implementations exhibit identical behavior.
//
//  Created by Claude on 01/18/26.
//  Copyright © 2026 WXYC. All rights reserved.
//

import Testing
import Foundation
@testable import Core

/// Identifies which MainActorMessage implementation to test.
enum MainActorMessageImplementation: String, CaseIterable, CustomTestStringConvertible {
    case backport
    case native

    var testDescription: String { rawValue }
}

@Suite("MainActorMessage Behavioral Contract", .serialized)
struct MainActorMessageContractTests {

    // MARK: - Post and Receive via addObserver

    @Test("Message can be posted and received via addObserver", arguments: MainActorMessageImplementation.allCases)
    @MainActor
    func postAndReceiveViaObserver(implementation: MainActorMessageImplementation) async {
        let center = NotificationCenter()
        let expectedTitle = "observer-title-\(implementation.rawValue)"

        switch implementation {
        case .backport:
            await verifyObserverBackport(center: center, expectedTitle: expectedTitle)
        case .native:
            guard #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) else { return }
            await verifyObserverNative(center: center, expectedTitle: expectedTitle)
        }
    }

    @MainActor
    private func verifyObserverBackport(center: NotificationCenter, expectedTitle: String) async {
        let received = AsyncStream<String>.makeStream()

        let token = center.addMainActorObserver(
            for: BackportMainActorTestMessage.self
        ) { message in
            received.continuation.yield(message.title)
            received.continuation.finish()
        }

        center.post(BackportMainActorTestMessage(title: expectedTitle), subject: nil as MainActorTestSubject?)

        var receivedTitle: String?
        for await title in received.stream {
            receivedTitle = title
            break
        }

        #expect(receivedTitle == expectedTitle)
        center.removeObserver(token)
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    @MainActor
    private func verifyObserverNative(center: NotificationCenter, expectedTitle: String) async {
        let subject = MainActorTestSubject()
        let received = AsyncStream<String>.makeStream()

        let token = center.addObserver(
            of: subject,
            for: NativeMainActorTestMessage.self
        ) { message in
            received.continuation.yield(message.title)
            received.continuation.finish()
        }

        center.post(NativeMainActorTestMessage(title: expectedTitle), subject: subject)

        var receivedTitle: String?
        for await title in received.stream {
            receivedTitle = title
            break
        }

        #expect(receivedTitle == expectedTitle)
        center.removeObserver(token)
    }

    // MARK: - Subject Filtering via addObserver

    @Test("Subject filtering works correctly", arguments: MainActorMessageImplementation.allCases)
    @MainActor
    func subjectFiltering(implementation: MainActorMessageImplementation) async {
        let center = NotificationCenter()
        let targetSubject = MainActorTestSubject()
        let otherSubject = MainActorTestSubject()

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

    @MainActor
    private func verifySubjectFilteringBackport(
        center: NotificationCenter,
        targetSubject: MainActorTestSubject,
        otherSubject: MainActorTestSubject
    ) async {
        let received = AsyncStream<String>.makeStream()

        let token = center.addMainActorObserver(
            of: targetSubject,
            for: BackportMainActorTestMessage.self
        ) { message in
            received.continuation.yield(message.title)
            received.continuation.finish()
        }

        // Post to other subject first - should be ignored
        center.post(BackportMainActorTestMessage(title: "wrong"), subject: otherSubject)

        // Post to target subject - should be received
        center.post(BackportMainActorTestMessage(title: "correct"), subject: targetSubject)

        var receivedTitle: String?
        for await title in received.stream {
            receivedTitle = title
            break
        }

        #expect(receivedTitle == "correct")
        center.removeObserver(token)
    }

    @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
    @MainActor
    private func verifySubjectFilteringNative(
        center: NotificationCenter,
        targetSubject: MainActorTestSubject,
        otherSubject: MainActorTestSubject
    ) async {
        let received = AsyncStream<String>.makeStream()

        let token = center.addObserver(
            of: targetSubject,
            for: NativeMainActorTestMessage.self
        ) { message in
            received.continuation.yield(message.title)
            received.continuation.finish()
        }

        // Post to other subject first - should be ignored
        center.post(NativeMainActorTestMessage(title: "wrong"), subject: otherSubject)

        // Post to target subject - should be received
        center.post(NativeMainActorTestMessage(title: "correct"), subject: targetSubject)

        var receivedTitle: String?
        for await title in received.stream {
            receivedTitle = title
            break
        }

        #expect(receivedTitle == "correct")
        center.removeObserver(token)
    }

    // MARK: - makeMessage Validation

    @Test("makeMessage returns nil for invalid notification", arguments: MainActorMessageImplementation.allCases)
    @MainActor
    func makeMessageReturnsNil(implementation: MainActorMessageImplementation) {
        switch implementation {
        case .backport:
            let invalidNotification = Notification(
                name: BackportMainActorTestMessage.name,
                object: nil,
                userInfo: nil
            )
            let message = BackportMainActorTestMessage.makeMessage(invalidNotification)
            #expect(message == nil)

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let invalidNotification = Notification(
                    name: NativeMainActorTestMessage.name,
                    object: nil,
                    userInfo: nil
                )
                let message = NativeMainActorTestMessage.makeMessage(invalidNotification)
                #expect(message == nil)
            }
        }
    }

    // MARK: - makeNotification Validation

    @Test("makeNotification creates valid notification", arguments: MainActorMessageImplementation.allCases)
    @MainActor
    func makeNotificationCreatesValidNotification(implementation: MainActorMessageImplementation) {
        let subject = MainActorTestSubject()

        switch implementation {
        case .backport:
            let message = BackportMainActorTestMessage(title: "test")
            let notification = BackportMainActorTestMessage.makeNotification(message, object: subject)

            #expect(notification.name == BackportMainActorTestMessage.name)
            #expect(notification.object as AnyObject? === subject)
            #expect(notification.userInfo?["title"] as? String == "test")

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let message = NativeMainActorTestMessage(title: "test")
                let notification = NativeMainActorTestMessage.makeNotification(message, object: subject)

                #expect(notification.name == NativeMainActorTestMessage.name)
                #expect(notification.object as AnyObject? === subject)
                #expect(notification.userInfo?["title"] as? String == "test")
            }
        }
    }

    // MARK: - Round-Trip Conversion

    @Test("Message survives round-trip conversion", arguments: MainActorMessageImplementation.allCases)
    @MainActor
    func roundTripConversion(implementation: MainActorMessageImplementation) {
        let subject = MainActorTestSubject()
        let originalTitle = "round-trip-title"

        switch implementation {
        case .backport:
            let original = BackportMainActorTestMessage(title: originalTitle)
            let notification = BackportMainActorTestMessage.makeNotification(original, object: subject)
            let reconstructed = BackportMainActorTestMessage.makeMessage(notification)

            #expect(reconstructed != nil)
            #expect(reconstructed?.title == originalTitle)

        case .native:
            if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
                let original = NativeMainActorTestMessage(title: originalTitle)
                let notification = NativeMainActorTestMessage.makeNotification(original, object: subject)
                let reconstructed = NativeMainActorTestMessage.makeMessage(notification)

                #expect(reconstructed != nil)
                #expect(reconstructed?.title == originalTitle)
            }
        }
    }
}

// MARK: - Test Fixtures

/// Shared subject type for both implementations.
final class MainActorTestSubject: Sendable {}

/// Test message conforming to the backport protocol.
struct BackportMainActorTestMessage: MainActorNotificationMessage, Sendable {
    typealias Subject = MainActorTestSubject

    nonisolated static var name: Notification.Name { .init("Core.BackportMainActorTestMessage") }

    let title: String

    static func makeMessage(_ notification: sending Notification) -> Self? {
        guard let title = notification.userInfo?["title"] as? String else { return nil }
        return Self(title: title)
    }

    @MainActor
    static func makeNotification(_ message: Self, object: Subject?) -> Notification {
        Notification(name: name, object: object, userInfo: ["title": message.title])
    }
}

/// Test message conforming to the native iOS 26 protocol.
@available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *)
struct NativeMainActorTestMessage: NotificationCenter.MainActorMessage, Sendable {
    typealias Subject = MainActorTestSubject

    nonisolated static var name: Notification.Name { .init("Core.NativeMainActorTestMessage") }

    let title: String

    static func makeMessage(_ notification: Notification) -> Self? {
        guard let title = notification.userInfo?["title"] as? String else { return nil }
        return Self(title: title)
    }

    @MainActor
    static func makeNotification(_ message: Self, object: Subject?) -> Notification {
        Notification(name: name, object: object, userInfo: ["title": message.title])
    }
}

//
//  EventBroadcasterDebuggingTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import XCTest

@testable import Events

final internal class EventBroadcasterDebuggingTests: XCTestCase {
  internal func test_EventBroadcaster_debugDescription_empty() {
    // Given
    let eb = EventBroadcaster()

    // When
    let description = eb.debugDescription()

    // Then
    XCTAssertTrue(description.contains("No active subscriptions"))
  }

  internal func test_EventBroadcaster_debugDescription_withSubscriptions() {
    // Given
    let eb = EventBroadcaster()
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event2", handler: dummyClosure)

    // When
    let description = eb.debugDescription()

    // Then
    XCTAssertTrue(description.contains("event1"))
    XCTAssertTrue(description.contains("event2"))
    XCTAssertTrue(description.contains("Active event types: 2"))
  }

  internal func test_EventBroadcaster_statistics() {
    // Given
    let eb = EventBroadcaster()
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event2", handler: dummyClosure)

    // When
    let stats = eb.statistics()

    // Then
    XCTAssertEqual(stats["totalEventTypes"] as? Int, 2)
    XCTAssertEqual(stats["totalSubscribers"] as? Int, 3)

    let eventTypes = stats["eventTypes"] as? [String] ?? []
    XCTAssertTrue(eventTypes.contains("event1"))
    XCTAssertTrue(eventTypes.contains("event2"))
  }

  internal func test_LoggingEventDispatcher_logsDispatches() {
    // Given
    var loggedMessages: [String] = []
    let logger: (String) -> Void = { message in
      loggedMessages.append(message)
    }

    let baseDispatcher = DispatchQueueEventDispatcher.EventDispatcher()
    let loggingDispatcher = LoggingEventDispatcher(
      wrapping: baseDispatcher,
      logger: logger
    )

    let eb = EventBroadcaster(eventDispatcher: loggingDispatcher)
    let eventType = "testEvent"

    var handlerCalled = false
    let _ = eb.subscribe(to: eventType) { _ in
      handlerCalled = true
    }

    // When
    eb.broadcast(Event(eventType: eventType))

    // Then
    XCTAssertTrue(handlerCalled)
    XCTAssertEqual(loggedMessages.count, 1)
    XCTAssertTrue(loggedMessages[0].contains(eventType))
  }

  internal func test_EventBroadcaster_enableDebugLogging() {
    // Given
    let eb = EventBroadcaster()
    var loggedMessages: [String] = []

    // When
    let result = eb.enableDebugLogging { message in
      loggedMessages.append(message)
    }

    // Then
    XCTAssertTrue(result === eb)  // Should return self for chaining
    XCTAssertTrue(loggedMessages.count > 0)  // Should log initialization
  }
}

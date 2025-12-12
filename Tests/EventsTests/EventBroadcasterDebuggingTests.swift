//
//  EventBroadcasterDebuggingTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Testing

@testable import Events

@Suite("EventBroadcaster Debugging Tests")
struct EventBroadcasterDebuggingTests {
  @Test("debugDescription shows no subscriptions when empty")
  func debugDescriptionEmpty() {
    // Given
    let eb = EventBroadcaster()

    // When
    let description = eb.debugDescription()

    // Then
    #expect(description.contains("No active subscriptions"))
  }

  @Test("debugDescription shows subscriptions when present")
  func debugDescriptionWithSubscriptions() {
    // Given
    let eb = EventBroadcaster()
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event2", handler: dummyClosure)

    // When
    let description = eb.debugDescription()

    // Then
    #expect(description.contains("event1"))
    #expect(description.contains("event2"))
    #expect(description.contains("Active event types: 2"))
  }

  @Test("statistics returns correct counts")
  func statistics() {
    // Given
    let eb = EventBroadcaster()
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    let _ = eb.subscribe(to: "event2", handler: dummyClosure)

    // When
    let stats = eb.statistics()

    // Then
    #expect(stats["totalEventTypes"] as? Int == 2)
    #expect(stats["totalSubscribers"] as? Int == 3)

    let eventTypes = stats["eventTypes"] as? [String] ?? []
    #expect(eventTypes.contains("event1"))
    #expect(eventTypes.contains("event2"))
  }

  @Test("LoggingEventDispatcher logs dispatches")
  func loggingEventDispatcherLogsDispatches() {
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
    #expect(handlerCalled)
    #expect(loggedMessages.count == 1)
    #expect(loggedMessages[0].contains(eventType))
  }

  @Test("enableDebugLogging returns self for chaining")
  func enableDebugLogging() {
    // Given
    let eb = EventBroadcaster()
    var loggedMessages: [String] = []

    // When
    let result = eb.enableDebugLogging { message in
      loggedMessages.append(message)
    }

    // Then
    #expect(result === eb)  // Should return self for chaining
    #expect(loggedMessages.count > 0)  // Should log initialization
  }
}

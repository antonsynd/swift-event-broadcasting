//
//  EventBroadcasterAsyncTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import XCTest

@testable import Events

final internal class EventBroadcasterAsyncTests: XCTestCase {
  internal func test_EventBroadcaster_nextEvent() async {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"

    // When
    Task {
      try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1 seconds
      eb.broadcast(Event(eventType: eventType))
    }

    let event = await eb.nextEvent(for: eventType)

    // Then
    XCTAssertEqual(event.eventType, eventType)
  }

  internal func test_EventBroadcaster_events_stream() async {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var receivedEvents: [Event] = []

    // When
    Task {
      var count = 0
      for await event in eb.events(for: eventType) {
        receivedEvents.append(event)
        count += 1
        if count >= 3 {
          break
        }
      }
    }

    // Give the stream time to set up
    try? await Task.sleep(nanoseconds: 50_000_000)

    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))

    // Give time for events to be processed
    try? await Task.sleep(nanoseconds: 100_000_000)

    // Then
    XCTAssertEqual(receivedEvents.count, 3)
    XCTAssertTrue(receivedEvents.allSatisfy { $0.eventType == eventType })
  }

  internal func test_EventBroadcaster_events_cancellation() async {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"

    // When
    let initialCount = eb.subscriberCount(for: eventType)

    let task = Task {
      for await _ in eb.events(for: eventType) {
        // Never breaks naturally
      }
    }

    // Give time for subscription
    try? await Task.sleep(nanoseconds: 50_000_000)

    let subscribedCount = eb.subscriberCount(for: eventType)

    task.cancel()

    // Give time for cleanup
    try? await Task.sleep(nanoseconds: 50_000_000)

    let finalCount = eb.subscriberCount(for: eventType)

    // Then
    XCTAssertEqual(initialCount, 0)
    XCTAssertEqual(subscribedCount, 1)
    XCTAssertEqual(finalCount, 0)
  }
}

//
//  EventBroadcasterAsyncTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import XCTest

@testable import Events

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
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
    let expectation = XCTestExpectation(description: "Received 3 events")
    var receivedEvents: [Event] = []

    // When
    Task {
      var count = 0
      for await event in eb.events(for: eventType) {
        receivedEvents.append(event)
        count += 1
        if count >= 3 {
          expectation.fulfill()
          break
        }
      }
    }

    // Give the stream time to set up
    try? await Task.sleep(nanoseconds: 50_000_000)

    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))

    // Wait for the expectation to be fulfilled
    await fulfillment(of: [expectation], timeout: 2.0)

    // Then
    XCTAssertEqual(receivedEvents.count, 3)
    XCTAssertTrue(receivedEvents.allSatisfy { $0.eventType == eventType })
  }

  internal func test_EventBroadcaster_events_cancellation() async {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    let subscriptionReady = XCTestExpectation(description: "Subscription ready")

    // When
    let initialCount = eb.subscriberCount(for: eventType)

    let task = Task {
      var first = true
      for await _ in eb.events(for: eventType) {
        if first {
          subscriptionReady.fulfill()
          first = false
        }
        // Never breaks naturally
      }
    }

    // Give time for subscription to be set up
    try? await Task.sleep(nanoseconds: 100_000_000)

    let subscribedCount = eb.subscriberCount(for: eventType)

    // Send an event to confirm subscription is working
    eb.broadcast(Event(eventType: eventType))
    await fulfillment(of: [subscriptionReady], timeout: 2.0)

    task.cancel()

    // Give time for cleanup - use a retry loop for reliability
    var finalCount = eb.subscriberCount(for: eventType)
    for _ in 0..<10 where finalCount != 0 {
      try? await Task.sleep(nanoseconds: 50_000_000)
      finalCount = eb.subscriberCount(for: eventType)
    }

    // Then
    XCTAssertEqual(initialCount, 0)
    XCTAssertEqual(subscribedCount, 1)
    XCTAssertEqual(finalCount, 0)
  }
}

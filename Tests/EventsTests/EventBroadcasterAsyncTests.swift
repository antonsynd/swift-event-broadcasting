//
//  EventBroadcasterAsyncTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Testing

@testable import Events

@Suite("EventBroadcaster Async Tests")
struct EventBroadcasterAsyncTests {
  @Test("nextEvent awaits and receives event")
  func nextEvent() async {
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
    #expect(event.eventType == eventType)
  }

  @Test("events stream receives multiple events")
  func eventsStream() async throws {
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
    try await Task.sleep(nanoseconds: 50_000_000)

    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))

    // Wait for events to be processed
    try await Task.sleep(nanoseconds: 200_000_000)

    // Then
    #expect(receivedEvents.count == 3)
    #expect(receivedEvents.allSatisfy { $0.eventType == eventType })
  }

  @Test("events stream cleans up on cancellation")
  func eventsCancellation() async throws {
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

    // Give time for subscription to be set up
    try await Task.sleep(nanoseconds: 100_000_000)

    let subscribedCount = eb.subscriberCount(for: eventType)

    task.cancel()

    // Give time for cleanup - use a retry loop for reliability
    var finalCount = eb.subscriberCount(for: eventType)
    for _ in 0..<10 where finalCount != 0 {
      try await Task.sleep(nanoseconds: 50_000_000)
      finalCount = eb.subscriberCount(for: eventType)
    }

    // Then
    #expect(initialCount == 0)
    #expect(subscribedCount == 1)
    #expect(finalCount == 0)
  }
}

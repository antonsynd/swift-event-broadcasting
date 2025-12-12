//
//  EventBroadcasterConvenienceTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Testing

@testable import Events

@Suite("EventBroadcaster Convenience Tests")
struct EventBroadcasterConvenienceTests {
  @Test("once handler fires only once")
  func once() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var callCount = 0

    // When
    eb.once(to: eventType) { _ in
      callCount += 1
    }

    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))
    eb.broadcast(Event(eventType: eventType))

    // Then
    #expect(callCount == 1)
  }

  @Test("subscribe with filter only receives matching events")
  func subscribeWithFilter() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var receivedEvents: [Event] = []

    // When
    let _ = eb.subscribe(
      to: eventType,
      filter: { event in
        (event as? TypedEvent<Int>)?.payload ?? 0 > 5
      }
    ) { event in
      receivedEvents.append(event)
    }

    eb.broadcast(TypedEvent(eventType: eventType, payload: 3))
    eb.broadcast(TypedEvent(eventType: eventType, payload: 7))
    eb.broadcast(TypedEvent(eventType: eventType, payload: 10))
    eb.broadcast(TypedEvent(eventType: eventType, payload: 2))

    // Then
    #expect(receivedEvents.count == 2)
  }

  @Test("subscribe with map transforms events")
  func subscribeWithMap() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var receivedValues: [String] = []

    // When
    let _ = eb.subscribe(
      to: eventType,
      map: { event -> String? in
        guard let typed = event as? TypedEvent<Int> else { return nil }
        return "Value: \(typed.payload)"
      }
    ) { value in
      receivedValues.append(value)
    }

    eb.broadcast(TypedEvent(eventType: eventType, payload: 42))
    eb.broadcast(Event(eventType: eventType))  // Non-typed, should be filtered
    eb.broadcast(TypedEvent(eventType: eventType, payload: 100))

    // Then
    #expect(receivedValues == ["Value: 42", "Value: 100"])
  }

  @Test("subscriberCount returns correct count")
  func subscriberCount() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"

    // When/Then
    #expect(eb.subscriberCount(for: eventType) == 0)

    let _ = eb.subscribe(to: eventType, handler: dummyClosure)
    #expect(eb.subscriberCount(for: eventType) == 1)

    let _ = eb.subscribe(to: eventType, handler: dummyClosure)
    #expect(eb.subscriberCount(for: eventType) == 2)

    // Object subscribers also create an event subscriber internally,
    // so this adds two more to the count (one ObjectSubscriber and one EventSubscriber)
    eb.subscribe(TestEnum.ABC, to: eventType, with: dummyClosure)
    #expect(eb.subscriberCount(for: eventType) == 4)
  }

  @Test("subscribedEventTypes returns all subscribed event types")
  func subscribedEventTypes() {
    // Given
    let eb = EventBroadcaster()

    // When/Then
    #expect(eb.subscribedEventTypes() == [])

    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    #expect(eb.subscribedEventTypes() == ["event1"])

    let _ = eb.subscribe(to: "event2", handler: dummyClosure)
    #expect(eb.subscribedEventTypes() == ["event1", "event2"])

    eb.subscribe(TestEnum.ABC, to: "event3", with: dummyClosure)
    #expect(eb.subscribedEventTypes() == ["event1", "event2", "event3"])
  }

  @Test("unsubscribeAll from event type removes all handlers for that type")
  func unsubscribeAllFromEventType() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var callCount = 0

    // When
    let _ = eb.subscribe(to: eventType) { _ in callCount += 1 }
    let _ = eb.subscribe(to: eventType) { _ in callCount += 1 }
    eb.subscribe(TestEnum.ABC, to: eventType) { _ in callCount += 1 }

    eb.unsubscribeAll(from: eventType)
    eb.broadcast(Event(eventType: eventType))

    // Then
    #expect(callCount == 0)
    #expect(eb.subscriberCount(for: eventType) == 0)
  }

  @Test("unsubscribeAll removes all handlers")
  func unsubscribeAll() {
    // Given
    let eb = EventBroadcaster()
    var callCount = 0

    // When
    let _ = eb.subscribe(to: "event1") { _ in callCount += 1 }
    let _ = eb.subscribe(to: "event2") { _ in callCount += 1 }
    eb.subscribe(TestEnum.ABC, to: "event3") { _ in callCount += 1 }

    eb.unsubscribeAll()

    eb.broadcast(Event(eventType: "event1"))
    eb.broadcast(Event(eventType: "event2"))
    eb.broadcast(Event(eventType: "event3"))

    // Then
    #expect(callCount == 0)
    #expect(eb.subscribedEventTypes() == [])
  }
}

//
//  EventBroadcasterConvenienceTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import XCTest

@testable import Events

final internal class EventBroadcasterConvenienceTests: XCTestCase {
  internal func test_EventBroadcaster_once() {
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
    XCTAssertEqual(callCount, 1)
  }

  internal func test_EventBroadcaster_subscribeWithFilter() {
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
    XCTAssertEqual(receivedEvents.count, 2)
  }

  internal func test_EventBroadcaster_subscribeWithMap() {
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
    XCTAssertEqual(receivedValues, ["Value: 42", "Value: 100"])
  }

  internal func test_EventBroadcaster_subscriberCount() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"

    // When/Then
    XCTAssertEqual(eb.subscriberCount(for: eventType), 0)

    let _ = eb.subscribe(to: eventType, handler: dummyClosure)
    XCTAssertEqual(eb.subscriberCount(for: eventType), 1)

    let _ = eb.subscribe(to: eventType, handler: dummyClosure)
    XCTAssertEqual(eb.subscriberCount(for: eventType), 2)

    // Object subscribers also create an event subscriber internally,
    // so this adds two more to the count (one ObjectSubscriber and one EventSubscriber)
    eb.subscribe(TestEnum.ABC, to: eventType, with: dummyClosure)
    XCTAssertEqual(eb.subscriberCount(for: eventType), 4)
  }

  internal func test_EventBroadcaster_subscribedEventTypes() {
    // Given
    let eb = EventBroadcaster()

    // When/Then
    XCTAssertEqual(eb.subscribedEventTypes(), [])

    let _ = eb.subscribe(to: "event1", handler: dummyClosure)
    XCTAssertEqual(eb.subscribedEventTypes(), ["event1"])

    let _ = eb.subscribe(to: "event2", handler: dummyClosure)
    XCTAssertEqual(eb.subscribedEventTypes(), ["event1", "event2"])

    eb.subscribe(TestEnum.ABC, to: "event3", with: dummyClosure)
    XCTAssertEqual(eb.subscribedEventTypes(), ["event1", "event2", "event3"])
  }

  internal func test_EventBroadcaster_unsubscribeAll_fromEventType() {
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
    XCTAssertEqual(callCount, 0)
    XCTAssertEqual(eb.subscriberCount(for: eventType), 0)
  }

  internal func test_EventBroadcaster_unsubscribeAll() {
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
    XCTAssertEqual(callCount, 0)
    XCTAssertEqual(eb.subscribedEventTypes(), [])
  }
}

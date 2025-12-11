//
//  TypedEventTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import XCTest

@testable import Events

final internal class TypedEventTests: XCTestCase {
  struct TestPayload {
    let value: String
  }

  internal func test_TypedEvent_payload() {
    // Given
    let payload = TestPayload(value: "test")
    let eventType = "testEvent"

    // When
    let event = TypedEvent(eventType: eventType, payload: payload)

    // Then
    XCTAssertEqual(event.eventType, eventType)
    XCTAssertEqual(event.payload.value, "test")
  }

  internal func test_EventBroadcaster_typedSubscribe() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var receivedPayload: TestPayload?

    // When
    let _ = eb.subscribe(to: eventType) {
      (event: TypedEvent<TestPayload>) in
      receivedPayload = event.payload
    }

    let payload = TestPayload(value: "hello")
    eb.broadcast(TypedEvent(eventType: eventType, payload: payload))

    // Then
    XCTAssertEqual(receivedPayload?.value, "hello")
  }

  internal func test_EventBroadcaster_typedSubscribe_withObject() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var receivedPayload: TestPayload?

    // When
    eb.subscribe(TestEnum.ABC, to: eventType) {
      (event: TypedEvent<TestPayload>) in
      receivedPayload = event.payload
    }

    let payload = TestPayload(value: "world")
    eb.broadcast(TypedEvent(eventType: eventType, payload: payload))

    // Then
    XCTAssertEqual(receivedPayload?.value, "world")
  }

  internal func test_EventBroadcaster_typedSubscribe_ignoresNonTypedEvents() {
    // Given
    let eb = EventBroadcaster()
    let eventType = "testEvent"
    var callCount = 0

    // When
    let _ = eb.subscribe(to: eventType) {
      (event: TypedEvent<TestPayload>) in
      callCount += 1
    }

    // Broadcast non-typed event
    eb.broadcast(Event(eventType: eventType))

    // Then
    XCTAssertEqual(callCount, 0)
  }
}

//
//  TypedEventTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Testing

@testable import Events

@Suite("TypedEvent Tests")
struct TypedEventTests {
  struct TestPayload {
    let value: String
  }

  @Test("TypedEvent stores and returns payload")
  func payload() {
    // Given
    let payload = TestPayload(value: "test")
    let eventType = "testEvent"

    // When
    let event = TypedEvent(eventType: eventType, payload: payload)

    // Then
    #expect(event.eventType == eventType)
    #expect(event.payload.value == "test")
  }

  @Test("EventBroadcaster typed subscribe receives typed events")
  func typedSubscribe() {
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
    #expect(receivedPayload?.value == "hello")
  }

  @Test("EventBroadcaster typed subscribe with object receives typed events")
  func typedSubscribeWithObject() {
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
    #expect(receivedPayload?.value == "world")
  }

  @Test("EventBroadcaster typed subscribe ignores non-typed events")
  func typedSubscribeIgnoresNonTypedEvents() {
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
    #expect(callCount == 0)
  }
}

//
//  EventTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Testing

@testable import Events

@Suite("Event Tests")
struct EventTests {
  @Test("Event eventType returns correct value")
  func eventType() {
    // If
    let e = Event(eventType: "test")

    // When/then
    #expect(e.eventType == "test")
  }

  @Test("Event.ET creates namespaced event type")
  func eventET() {
    // If/when/then
    #expect(Event.ET("test") == "Event:test")
  }

  @Test("Event subclass eventType returns correct value")
  func eventSubclassEventType() {
    // If
    let e = TestEvent()

    // When/then
    #expect(e.eventType == "TestEvent:foo")
  }

  @Test("Event subclass ET creates namespaced event type")
  func eventSubclassET() {
    // If/when/then
    #expect(TestEvent.ET("foo") == "TestEvent:foo")
  }
}

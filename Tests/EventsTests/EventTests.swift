//
//  EventTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import XCTest

@testable import Events

final class EventTests: XCTestCase {
  func test_Event_eventType() {
    // If
    let e = Event(eventType: "test")

    // When/then
    XCTAssertEqual(e.eventType, "test")
  }

  func test_Event_ET() {
    // If/when/then
    XCTAssertEqual(Event.ET("test"), "Event:test")
  }

  func test_EventSubclass_eventType() {
    // If
    let e = TestEvent()

    // When/then
    XCTAssertEqual(e.eventType, "TestEvent:foo")
  }

  func test_EventSubclass_ET() {
    // If/when/then
    XCTAssertEqual(TestEvent.ET("foo"), "TestEvent:foo")
  }
}

//
//  EventSubscribersTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import XCTest

@testable import Events

final internal class EventSubscribersTests: XCTestCase {
  internal func test_EventSubscribers_add_HasIncreasingSubscriberId() {
    // If
    let es = EventSubscribers()

    // When/then
    for i: UInt in 0..<10 {
      XCTAssertEqual(es.add(dummyClosure), i)
    }
  }

  internal func test_EventSubscribers_remove_NonExistentSubscriberIdIsFalse() {
    // If
    let es = EventSubscribers()
    let id = es.add(dummyClosure)

    // When/then
    XCTAssertFalse(es.remove(id + 1))
  }

  internal func test_EventSubscribers_remove_ExistingSubscriberIdIsTrue() {
    // If
    let es = EventSubscribers()
    var id: EventSubscriberId = es.add(dummyClosure)
    id = es.add(dummyClosure)

    // When/then
    XCTAssertTrue(es.remove(id - 1))
  }

  internal func test_EventSubscribers_forEach() {
    // If
    let e = Event(eventType: "foo")
    var result: Int = 0

    let es = EventSubscribers()
    var _: Any = es.add { (_: Event) in result += 1 }
    _ = es.add { (_: Event) in result += 2 }
    _ = es.add { (_: Event) in result += 3 }
    _ = es.remove(1)

    // When
    es.forEach { $0(e) }

    // Then
    XCTAssertEqual(result, 4)
  }
}

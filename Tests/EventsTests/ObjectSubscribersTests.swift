//
//  ObjectSubscribersTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import XCTest

@testable import Events

final class ObjectSubscribersTests: XCTestCase {
  func test_ObjectSubscribers_add_AnyHashable() {
    // If
    let os = ObjectSubscribers()
    let someArray = [1, 2, 3]
    let someHashable = TestHashable()

    // When/then
    // It's valid to add subscribers with same subscriber id. ObjectSubscribers
    // doesn't care about the validity. It's up to the EventBroadcaster to
    // handle this.
    os.add(0, withId: 0)
    os.add(someArray, withId: 0)
    os.add(TestEnum.ABC, withId: 1)
    os.add(someHashable, withId: 1)
  }

  func test_ObjectSubscribers_remove_NonExistentSubscriber() {
    // If
    let os = ObjectSubscribers()

    // When/then
    XCTAssertNil(os.remove(0))
  }

  func test_ObjectSubscribers_remove_ExistingSubscriber() {
    // If
    let os = ObjectSubscribers()
    os.add(0, withId: 0)
    os.add(0, withId: 3)
    os.add(0, withId: 6)

    // When
    let actualIds: Set<EventSubscriberId>? = os.remove(0)
    let expectedIds: Set<EventSubscriberId> = [0, 3, 6]

    // Then
    XCTAssertNotNil(actualIds)
    XCTAssertEqual(actualIds!, expectedIds)
  }
}

//
//  ObjectSubscribersTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Testing

@testable import Events

@Suite("ObjectSubscribers Tests")
struct ObjectSubscribersTests {
  @Test("add accepts any hashable subscriber")
  func addAnyHashable() {
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

  @Test("remove returns nil for non-existent subscriber")
  func removeNonExistentSubscriber() {
    // If
    let os = ObjectSubscribers()

    // When/then
    #expect(os.remove(0) == nil)
  }

  @Test("remove returns subscriber IDs for existing subscriber")
  func removeExistingSubscriber() {
    // If
    let os = ObjectSubscribers()
    os.add(0, withId: 0)
    os.add(0, withId: 3)
    os.add(0, withId: 6)

    // When
    let actualIds: Set<EventSubscriberId>? = os.remove(0)
    let expectedIds: Set<EventSubscriberId> = [0, 3, 6]

    // Then
    #expect(actualIds != nil)
    #expect(actualIds == expectedIds)
  }
}

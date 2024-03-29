//
//  EventBroadcasterTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 5/17/23.
//

import XCTest

@testable import Events

final internal class EventBroadcasterTests: XCTestCase {
  internal func test_EventBroadcaster_unsubscribe_NonExistentEventType() {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    XCTAssertFalse(eb.unsubscribe(id: id, from: TestEvent.BAR))
  }

  internal func test_EventBroadcaster_unsubscribe_NonExistentSubscriberId() {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    XCTAssertFalse(eb.unsubscribe(id: id + 10, from: TestEvent.FOO))
  }

  internal func
    test_EventBroadcaster_unsubscribe_ExistingSubscriberIdAndEventType()
  {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    XCTAssertTrue(eb.unsubscribe(id: id, from: TestEvent.FOO))
  }

  internal func
    test_EventiBroadcaster_unsubscribe_SubscriberAndNonExistentEventType()
  {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    XCTAssertFalse(
      eb.unsubscribe(subscriber: TestEnum.ABC, from: TestEvent.BAR)
    )
  }

  internal func test_EventBroadcaster_unsubscribe_NonExistentSubscriber() {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    XCTAssertFalse(
      eb.unsubscribe(subscriber: TestEnum.XYZ, from: TestEvent.FOO)
    )
  }

  internal func
    test_EventBroadcaster_unsubscribe_ExistingSubscriberAndEventType()
  {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    XCTAssertTrue(eb.unsubscribe(subscriber: TestEnum.ABC, from: TestEvent.FOO))
  }

  internal func test_EventBroadcaster_broadcast() {
    // If
    let eb = EventBroadcaster()
    var actualMessages: [String] = []

    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO) { (_: Event) in
      actualMessages.append("abcHandler_FOO")
    }
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO) { (_: Event) in
      actualMessages.append("jklHandler_FOO")
    }
    eb.subscribe(TestEnum.ABC, to: TestEvent.BAR) { (_: Event) in
      actualMessages.append("abcHandler_BAR")
    }
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO) { (_: Event) in
      actualMessages.append("abcHandler_FOO_2")
    }

    // When
    eb.broadcast(TestEvent())

    // Then
    let expectedMessages = [
      "abcHandler_FOO",
      "jklHandler_FOO",
      "abcHandler_FOO_2",
    ]

    XCTAssertEqual(actualMessages, expectedMessages)
  }
}

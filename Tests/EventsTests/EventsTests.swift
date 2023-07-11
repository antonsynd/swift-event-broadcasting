//
//  EventsTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 5/17/23.
//

import XCTest

@testable import Events

final class EventsTests: XCTestCase {
  final class TestEvent: Event {
    static let FOO = TestEvent.ET("foo")
    static let BAR = TestEvent.ET("bar")

    init() {
      super.init(eventType: TestEvent.FOO)
    }
  }

  enum TestEnum {
    case ABC
    case JKL
    case XYZ
  }

  final class TestHashable: NSObject {
  }

  private let dummyClosure = { (e: Event) in return }

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

  func test_EventSubscribers_add_HasIncreasingSubscriberId() {
    // If
    let es = EventSubscribers()

    // When/then
    for i: UInt in 0..<10 {
      XCTAssertEqual(es.add(dummyClosure), i)
    }
  }

  func test_EventSubscribers_remove_NonExistentSubscriberIdIsFalse() {
    // If
    let es = EventSubscribers()
    let id = es.add(dummyClosure)

    // When/then
    XCTAssertFalse(es.remove(id + 1))
  }

  func test_EventSubscribers_remove_ExistingSubscriberIdIsTrue() {
    // If
    let es = EventSubscribers()
    var id: EventSubscriberId = es.add(dummyClosure)
    id = es.add(dummyClosure)

    // When/then
    XCTAssertTrue(es.remove(id - 1))
  }

  func test_EventSubscribers_forEach() {
    // If
    let e = Event(eventType: "foo")
    var result: Int = 0

    let es = EventSubscribers()
    var _: Any = es.add { (_: Event) in result += 1 }
    _ = es.add { (_: Event) in result += 2 }
    _ = es.add { (_: Event) in result += 3 }
    _ = es.remove(1)

    // When
    try! es.forEach { $0(e) }

    // Then
    XCTAssertEqual(result, 4)
  }

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

  func test_EventBroadcaster_unsubscribe_NonExistentEventType() {
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

  func test_EventBroadcaster_unsubscribe_NonExistentSubscriberId() {
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

  func test_EventBroadcaster_unsubscribe_ExistingSubscriberIdAndEventType() {
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

  func test_EventBroadcaster_unsubscribe_SubscriberAndNonExistentEventType() {
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

  func test_EventBroadcaster_unsubscribe_NonExistentSubscriber() {
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

  func test_EventBroadcaster_unsubscribe_ExistingSubscriberAndEventType() {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    XCTAssertTrue(eb.unsubscribe(subscriber: TestEnum.ABC, from: TestEvent.FOO))
  }

  func test_EventBroadcaster_broadcast() {
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
    try! eb.broadcast(TestEvent())

    // Then
    let expectedMessages = [
      "abcHandler_FOO",
      "jklHandler_FOO",
      "abcHandler_FOO_2",
    ]

    XCTAssertEqual(actualMessages, expectedMessages)
  }
}

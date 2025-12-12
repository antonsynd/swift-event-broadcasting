//
//  EventBroadcasterTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 5/17/23.
//

import Testing

@testable import Events

@Suite("EventBroadcaster Tests")
struct EventBroadcasterTests {
  @Test("unsubscribe by ID returns false for non-existent event type")
  func unsubscribeNonExistentEventType() {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    #expect(eb.unsubscribe(id: id, from: TestEvent.BAR) == false)
  }

  @Test("unsubscribe by ID returns false for non-existent subscriber ID")
  func unsubscribeNonExistentSubscriberId() {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    #expect(eb.unsubscribe(id: id + 10, from: TestEvent.FOO) == false)
  }

  @Test(
    "unsubscribe by ID returns true for existing subscriber ID and event type"
  )
  func unsubscribeExistingSubscriberIdAndEventType() {
    // If
    let eb = EventBroadcaster()
    var _ = eb.subscribe(to: TestEvent.FOO, handler: dummyClosure)
    let id: EventSubscriberId = eb.subscribe(
      to: TestEvent.FOO,
      handler: dummyClosure
    )
    _ = eb.subscribe(to: TestEvent.BAR, handler: dummyClosure)

    // When/then
    #expect(eb.unsubscribe(id: id, from: TestEvent.FOO) == true)
  }

  @Test("unsubscribe by subscriber returns false for non-existent event type")
  func unsubscribeSubscriberAndNonExistentEventType() {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    #expect(
      eb.unsubscribe(subscriber: TestEnum.ABC, from: TestEvent.BAR) == false
    )
  }

  @Test("unsubscribe by subscriber returns false for non-existent subscriber")
  func unsubscribeNonExistentSubscriber() {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    #expect(
      eb.unsubscribe(subscriber: TestEnum.XYZ, from: TestEvent.FOO) == false
    )
  }

  @Test(
    "unsubscribe by subscriber returns true for existing subscriber and event type"
  )
  func unsubscribeExistingSubscriberAndEventType() {
    // If
    let eb = EventBroadcaster()
    eb.subscribe(TestEnum.JKL, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.ABC, to: TestEvent.FOO, with: dummyClosure)
    eb.subscribe(TestEnum.XYZ, to: TestEvent.BAR, with: dummyClosure)

    // When/then
    #expect(
      eb.unsubscribe(subscriber: TestEnum.ABC, from: TestEvent.FOO) == true
    )
  }

  @Test("broadcast delivers events to handlers in order")
  func broadcast() {
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

    #expect(actualMessages == expectedMessages)
  }
}

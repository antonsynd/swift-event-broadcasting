//
//  EventSubscribersTests.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Testing

@testable import Events

@Suite("EventSubscribers Tests")
struct EventSubscribersTests {
  @Test("add returns increasing subscriber IDs")
  func addHasIncreasingSubscriberId() {
    // If
    let es = EventSubscribers()

    // When/then
    for i: UInt in 0..<10 {
      #expect(es.add(dummyClosure) == i)
    }
  }

  @Test("remove returns false for non-existent subscriber ID")
  func removeNonExistentSubscriberIdIsFalse() {
    // If
    let es = EventSubscribers()
    let id = es.add(dummyClosure)

    // When/then
    #expect(es.remove(id + 1) == false)
  }

  @Test("remove returns true for existing subscriber ID")
  func removeExistingSubscriberIdIsTrue() {
    // If
    let es = EventSubscribers()
    var id: EventSubscriberId = es.add(dummyClosure)
    id = es.add(dummyClosure)

    // When/then
    #expect(es.remove(id - 1) == true)
  }

  @Test("forEach iterates over all handlers")
  func forEach() {
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
    #expect(result == 4)
  }
}

//
//  EventDispatcherTests.swift
//
//
//  Created by Anton Nguyen on 11/7/23.
//

import XCTest

@testable import Events

final internal class NoOpEventDispatcher: EventDispatching {
  public func dispatch(
    _ event: Event,
    using eventHandler: @escaping EventHandler
  ) {
    // No-op
  }
}

final internal class EventDispatcherTests: XCTestCase {
  private var handlerExecutionCount: Int = 0

  private func incrementExecutionCountHandler(_ event: Event) {
    handlerExecutionCount += 1
  }

  internal override func setUp() {
    handlerExecutionCount = 0
  }

  internal func test_DefaultEventDispatcher_implicit_dispatch_AllEvents() {
    // If
    let eb = EventBroadcaster()
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    XCTAssertEqual(handlerExecutionCount, 2)
  }

  internal func test_DefaultEventDispatcher_explicit_dispatch_AllEvents() {
    // If
    let eb = EventBroadcaster(eventDispatcher: getDefaultEventDispatcher())
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    XCTAssertEqual(handlerExecutionCount, 2)
  }

  internal func test_NoOpEventDispatcher_dispatch_NoEvents() {
    // If
    let eb = EventBroadcaster(eventDispatcher: NoOpEventDispatcher())
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    XCTAssertEqual(handlerExecutionCount, 0)
  }

}

//
//  EventDispatcherTests.swift
//
//
//  Created by Anton Nguyen on 11/7/23.
//

import Testing

@testable import Events

final class NoOpEventDispatcher: EventDispatching {
  public func dispatch(
    _ event: Event,
    using eventHandler: @escaping EventHandler
  ) {
    // No-op
  }
}

@Suite("EventDispatcher Tests")
struct EventDispatcherTests {
  @Test("Default dispatcher (implicit) dispatches matching events")
  func defaultEventDispatcherImplicitDispatchAllEvents() {
    // If
    var handlerExecutionCount = 0
    let incrementExecutionCountHandler: EventHandler = { _ in
      handlerExecutionCount += 1
    }

    let eb = EventBroadcaster()
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    #expect(handlerExecutionCount == 2)
  }

  @Test("Default dispatcher (explicit) dispatches matching events")
  func defaultEventDispatcherExplicitDispatchAllEvents() {
    // If
    var handlerExecutionCount = 0
    let incrementExecutionCountHandler: EventHandler = { _ in
      handlerExecutionCount += 1
    }

    let eb = EventBroadcaster(eventDispatcher: getDefaultEventDispatcher())
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    #expect(handlerExecutionCount == 2)
  }

  @Test("NoOp dispatcher dispatches no events")
  func noOpEventDispatcherDispatchNoEvents() {
    // If
    var handlerExecutionCount = 0
    let incrementExecutionCountHandler: EventHandler = { _ in
      handlerExecutionCount += 1
    }

    let eb = EventBroadcaster(eventDispatcher: NoOpEventDispatcher())
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.BAR, handler: incrementExecutionCountHandler)
    _ = eb.subscribe(to: TestEvent.FOO, handler: incrementExecutionCountHandler)

    // When
    eb.broadcast(TestEvent())

    // Then
    #expect(handlerExecutionCount == 0)
  }
}

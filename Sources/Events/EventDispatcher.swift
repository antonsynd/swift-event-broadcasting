//
//  EventDispatching.swift
//
//
//  Created by Anton Nguyen on 11/5/23.
//

import Foundation

// @brief A protocol that defines an event dispatcher. An event dispatcher
// must respond to events broadcasted by an EventBroadcaster and invoke
// the corresponding eventHandler with the event. The actual scheduling of
// the invocation is up to the event dispatcher to determine, e.g. via a
// single ditpach queue, or something more complex.
public protocol EventDispatching {
  func dispatch(
    _ event: Event,
    using eventHandler: @escaping EventHandler
  )
}

public func getDefaultEventDispatcher() -> EventDispatching {
  return DispatchQueueEventDispatcher.EventDispatcher()
}

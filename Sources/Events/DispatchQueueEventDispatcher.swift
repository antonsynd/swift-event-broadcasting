//
//  DispatchQueueEventDispatcher.swift
//
//
//  Created by Anton Nguyen on 11/7/23.
//

import Foundation

// @brief Dispatches events via a single dispatch queue.
final public class DispatchQueueEventDispatcher: EventDispatching {
  private let eventQueue = DispatchQueue.global()
  private static var instance: DispatchQueueEventDispatcher?

  private init() {}

  public static func EventDispatcher() -> DispatchQueueEventDispatcher {
    if let actualInstance = instance {
      return actualInstance
    }

    let newInstance = DispatchQueueEventDispatcher()
    instance = newInstance

    return newInstance
  }

  public func dispatch(
    _ event: Event,
    using eventHandler: @escaping EventHandler
  ) {
    eventQueue.sync {
      eventHandler(event)
    }
  }
}

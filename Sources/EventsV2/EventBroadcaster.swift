//
//  EventBroadcaster.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 6/25/24.
//

import Foundation

public typealias EventSubscriberId = UInt

public protocol EventBroadcasting<T> {
  associatedtype T

  func subscribe(handler: @escaping (T) -> Void) -> EventSubscriberId

  func unsubscribe(id subscriberId: EventSubscriberId) -> Bool

  func clear() -> [EventSubscriberId]

  func broadcast(_ message: T)
}

open class EventBroadcaster<T>: EventBroadcasting<T> {
  public init() {
  }

  public func subscribe(
    handler: @escaping (T) -> Void
  )
    -> EventSubscriberId
  {
    return 0
  }

  public func unsubscribe(
    id subscriberId: EventSubscriberId
  )
    -> Bool
  {
    return false
  }

  public func clear() -> [EventSubscriberId] {
    return []
  }

  public func broadcast(_ message: T) {
  }
}

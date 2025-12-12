//
//  EventBroadcaster.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Foundation

/// An event handler that subscribes to an event type and is invoked
/// when its event broadcaster broadcasts an event with that type.
public typealias EventHandler = (Event) -> Void

/// A subscriber ID returned by certain methods that subscribe an
/// event handler to an event broadcaster. When a handler has been subscribed
/// with an associated subscriber ID, that ID must be used to unsubscribe the handler.
public typealias EventSubscriberId = UInt

/// Protocol that allows a class or struct to provide event broadcasting
/// capabilities by keeping an internal instance of `EventBroadcaster` and
/// delegating the protocol methods to that instance.
public protocol EventBroadcasting {
  /// Subscribes a handler to an event type, returning a new subscriber ID.
  ///
  /// - Parameters:
  ///   - eventType: The type of event to subscribe to.
  ///   - handler: The handler to invoke when the event is broadcast.
  /// - Returns: A subscriber ID that must be used to unsubscribe the handler.
  func subscribe(to eventType: EventType, handler: @escaping EventHandler)
    -> EventSubscriberId

  /// Subscribes a handler to an event type using an object as a proxy for the subscriber ID.
  ///
  /// - Parameters:
  ///   - subscriber: An opaque object to associate with this subscription.
  ///   - eventType: The type of event to subscribe to.
  ///   - handler: The handler to invoke when the event is broadcast.
  func subscribe(
    _ subscriber: AnyHashable,
    to eventType: EventType,
    with handler: @escaping EventHandler
  )

  /// Unsubscribes all handlers for an event type associated with a subscriber.
  ///
  /// - Parameters:
  ///   - subscriber: The subscriber object whose handlers should be removed.
  ///   - eventType: The event type to unsubscribe from.
  /// - Returns: `true` if any handlers were unsubscribed, `false` otherwise.
  func unsubscribe(subscriber: AnyHashable, from eventType: EventType)
    -> Bool

  /// Unsubscribes the handler for a subscriber ID from an event type.
  ///
  /// - Parameters:
  ///   - subscriberId: The subscriber ID returned from `subscribe(to:handler:)`.
  ///   - eventType: The event type to unsubscribe from.
  /// - Returns: `true` if a handler was unsubscribed, `false` otherwise.
  func unsubscribe(
    id subscriberId: EventSubscriberId,
    from eventType: EventType
  )
    -> Bool

  /// Broadcasts an event to all handlers subscribed to its event type.
  ///
  /// Handlers are executed in subscription order.
  ///
  /// - Parameter event: The event to broadcast.
  func broadcast(_ event: Event)
}

/// Base class that can be subclassed directly to provide event broadcasting capabilities.
open class EventBroadcaster: EventBroadcasting {
  internal var typeToSubscribers: [EventType: EventSubscribers] = [:]
  internal var typeToObjectSubscribers: [EventType: ObjectSubscribers] = [:]
  private let eventDispatcher: EventDispatching

  public init(eventDispatcher: EventDispatching? = nil) {
    if let actualEventDispatcher = eventDispatcher {
      self.eventDispatcher = actualEventDispatcher
    }
    else {
      self.eventDispatcher = getDefaultEventDispatcher()
    }
  }

  public func subscribe(
    to eventType: EventType,
    handler: @escaping EventHandler
  )
    -> EventSubscriberId
  {
    var eventSubscribers: EventSubscribers? = typeToSubscribers[eventType]

    if eventSubscribers == nil {
      eventSubscribers = EventSubscribers()
      typeToSubscribers[eventType] = eventSubscribers
    }

    return eventSubscribers!.add(handler)
  }

  public func subscribe(
    _ subscriber: AnyHashable,
    to eventType: EventType,
    with handler: @escaping EventHandler
  ) {
    var objectSubscribers: ObjectSubscribers? = typeToObjectSubscribers[
      eventType
    ]

    if objectSubscribers == nil {
      objectSubscribers = ObjectSubscribers()
      typeToObjectSubscribers[eventType] = objectSubscribers
    }

    let subscriberId: EventSubscriberId = subscribe(
      to: eventType,
      handler: handler
    )

    objectSubscribers!.add(subscriber, withId: subscriberId)
  }

  public func unsubscribe(subscriber: AnyHashable, from eventType: EventType)
    -> Bool
  {
    if let objectSubscribers: ObjectSubscribers = typeToObjectSubscribers[
      eventType
    ] {
      if let subscriberIds: Set<EventSubscriberId> = objectSubscribers.remove(
        subscriber
      ) {
        var unsubscribedSomething: Int = 0

        for subscriberId: EventSubscriberId in subscriberIds {
          unsubscribedSomething |=
            unsubscribe(id: subscriberId, from: eventType) ? 1 : 0
        }

        return unsubscribedSomething == 1
      }
    }

    return false
  }

  public func unsubscribe(
    id subscriberId: EventSubscriberId,
    from eventType: EventType
  )
    -> Bool
  {
    if let eventSubscribers: EventSubscribers = typeToSubscribers[eventType] {
      return eventSubscribers.remove(subscriberId)
    }

    return false
  }

  public func broadcast(_ event: Event) {
    if let eventSubscribers: EventSubscribers = typeToSubscribers[
      event.eventType
    ] {
      eventSubscribers.forEach { (eventHandler: @escaping EventHandler) in
        eventDispatcher.dispatch(event, using: eventHandler)
      }
    }
  }
}

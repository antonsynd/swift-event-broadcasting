//
//  Event.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 5/11/23.
//

import Collections
import Foundation

// @brief An event type, indicating a particular situation or use case of an
// event.
public typealias EventType = String

// @brief An event. This can be subclassed to provide interfaces with data
// relevant to the event being broadcast.
public class Event {
  let eventType: EventType

  init(eventType: EventType) {
    self.eventType = eventType
  }

  // @brief Convenience method to prepend the class name to an event type
  // string to prevent name clashes. Optional, but recommended.
  static func ET(_ eventType: String) -> EventType {
    return "\(String(describing: self)):\(eventType)"
  }
}

// @brief An event handler, that subscribes to an event type and is invoked
// when its event broadcaster broadcasts an event with that type.
public typealias EventHandler = (Event) -> Void

// @brief A subscriber id, returned by certain methods that subscribe an
// event handler to an event broadcaster. When a handler has been subscribed
// with an associated subscriber id, the subscriber id must be used to
// unsubscribe the handler.
public typealias EventSubscriberId = UInt

// @brief Maintains subscriber id to event handler relations, and controls
// the distribution of new subscriber ids. Used by the EventBroadcaster to
// keep track of subscribers for a particular event type.
internal class EventSubscribers {
  private var nextSubscriberId: EventSubscriberId = 0
  // TODO: Replace with DefaultDictionary
  private var subscribers: OrderedDictionary<EventSubscriberId, EventHandler> =
    [:]

  func add(_ handler: @escaping EventHandler) -> EventSubscriberId {
    let currentSubscriberId: EventSubscriberId = nextSubscriberId
    nextSubscriberId += 1

    subscribers[currentSubscriberId] = handler

    return currentSubscriberId
  }

  func remove(_ subscriber: EventSubscriberId) -> Bool {
    subscribers.removeValue(forKey: subscriber) != nil
  }

  func forEach(_ body: (@escaping EventHandler) throws -> Void) throws {
    try subscribers.values.forEach(body)
  }
}

// @brief Maintains object subscribers to subscriber id relations. Used by
// the EventBroadcaster to keep track of object subscribers for a particular
// event type.
internal class ObjectSubscribers {
  // TODO: Replace with DefaultDictionary
  private var objectsToIds: [AnyHashable: Set<EventSubscriberId>] = [:]

  func add(_ subscriber: AnyHashable, withId id: EventSubscriberId) {
    if objectsToIds.contains(where: { $0.key == subscriber }) {
      objectsToIds[subscriber]!.insert(id)
    }
    else {
      objectsToIds[subscriber] = [id]
    }
  }

  func remove(_ subscriber: AnyHashable) -> Set<EventSubscriberId>? {
    return objectsToIds.removeValue(forKey: subscriber)
  }
}

// @brief Protocol that allows a class or struct to provide event broadcasting
// capabilities by keeping an internal instance of EventBroadcaster and
// delegating the protocol methods to that instance.
public protocol EventBroadcasting {
  // @brief Subscribes @p handler to @p eventType, returning a new subscriber
  // id. The subscriber id must be used to unsubscribe the handler.
  func subscribe(to eventType: EventType, handler: @escaping EventHandler)
    -> EventSubscriberId

  // @brief Subscribes @p handler to @p eventType using @p subscriber as
  // an opaque proxy for the subscriber id. @p subscriber must be used to
  // unsubscribe the handler.
  func subscribe(
    _ subscriber: AnyHashable,
    to eventType: EventType,
    with handler: @escaping EventHandler
  )

  // @brief Unsubscribes all handlers for @p eventType associated with
  // @p subscriber. Returns true if any handlers were unsubscribed, false
  // otherwise.
  func unsubscribe(subscriber: AnyHashable, from eventType: EventType)
    -> Bool

  // @brief Unsubscribes the handler for @p subscriberId from @p eventType.
  // Returns true if a handler was unsubscribed, false otherwise.
  func unsubscribe(
    id subscriberId: EventSubscriberId,
    from eventType: EventType
  )
    -> Bool

  // @brief Broadcasts @p event to all handlers subscribed to
  // @p event.eventType. Handlers are executed in subscription order. If any
  // handler throws, subsequent handlers will not execute.
  // TODO: Accept a callback to invoke if a handler throws.
  func broadcast(_ event: Event) throws
}

// @brief Base class that can be subclassed directly.
public class EventBroadcaster: EventBroadcasting {
  private var typeToSubscribers: [EventType: EventSubscribers] = [:]
  private var typeToObjectSubscribers: [EventType: ObjectSubscribers] = [:]

  private static let eventQueue = DispatchQueue(label: "com.miod.events")

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

  public func broadcast(_ event: Event) throws {
    if let eventSubscribers: EventSubscribers = typeToSubscribers[
      event.eventType
    ] {
      try eventSubscribers.forEach { (eventHandler: @escaping EventHandler) in
        EventBroadcaster.eventQueue.sync {
          eventHandler(event)
        }
      }
    }
  }
}

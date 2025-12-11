//
//  EventBroadcaster+Convenience.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

// @brief Extension providing convenience methods for common event
// subscription patterns.
extension EventBroadcaster {
  // @brief Subscribes to an event type and automatically unsubscribes after
  // the first event is received.
  // @param eventType The type of event to subscribe to
  // @param handler The handler to invoke once
  public func once(to eventType: EventType, handler: @escaping EventHandler) {
    var subscriberId: EventSubscriberId?

    subscriberId = subscribe(to: eventType) { event in
      if let id = subscriberId {
        _ = self.unsubscribe(id: id, from: eventType)
      }
      handler(event)
    }
  }

  // @brief Subscribes to an event type with a filter predicate.
  // The handler will only be invoked for events that pass the filter.
  // @param eventType The type of event to subscribe to
  // @param filter A predicate that determines if the handler should be invoked
  // @param handler The handler to invoke for filtered events
  // @return A subscriber id for later unsubscription
  public func subscribe(
    to eventType: EventType,
    filter: @escaping (Event) -> Bool,
    handler: @escaping EventHandler
  ) -> EventSubscriberId {
    return subscribe(to: eventType) { event in
      if filter(event) {
        handler(event)
      }
    }
  }

  // @brief Subscribes to an event type with a mapping function.
  // The handler receives the result of applying the map function to events.
  // @param eventType The type of event to subscribe to
  // @param map A function that transforms events
  // @param handler The handler to invoke with transformed events
  // @return A subscriber id for later unsubscription
  public func subscribe<T>(
    to eventType: EventType,
    map: @escaping (Event) -> T?,
    handler: @escaping (T) -> Void
  ) -> EventSubscriberId {
    return subscribe(to: eventType) { event in
      if let mapped = map(event) {
        handler(mapped)
      }
    }
  }

  // @brief Unsubscribes all handlers for a specific event type.
  // @param eventType The type of event to unsubscribe from
  public func unsubscribeAll(from eventType: EventType) {
    typeToSubscribers.removeValue(forKey: eventType)
    typeToObjectSubscribers.removeValue(forKey: eventType)
  }

  // @brief Unsubscribes all handlers for all event types.
  public func unsubscribeAll() {
    typeToSubscribers.removeAll()
    typeToObjectSubscribers.removeAll()
  }

  // @brief Returns the number of subscribers for a specific event type.
  // @param eventType The type of event to count subscribers for
  // @return The number of subscribers, or 0 if none exist
  public func subscriberCount(for eventType: EventType) -> Int {
    var count = 0

    if let eventSubscribers = typeToSubscribers[eventType] {
      count += eventSubscribers.count()
    }

    if let objectSubscribers = typeToObjectSubscribers[eventType] {
      count += objectSubscribers.count()
    }

    return count
  }

  // @brief Returns all event types that currently have subscribers.
  // @return A set of event types with active subscriptions
  public func subscribedEventTypes() -> Set<EventType> {
    let subscriberTypes = Set(typeToSubscribers.keys)
    let objectSubscriberTypes = Set(typeToObjectSubscribers.keys)
    return subscriberTypes.union(objectSubscriberTypes)
  }
}

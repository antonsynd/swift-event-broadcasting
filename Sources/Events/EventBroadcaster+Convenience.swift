//
//  EventBroadcaster+Convenience.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

/// Extension providing convenience methods for common event subscription patterns.
extension EventBroadcaster {
  /// Subscribes to an event type and automatically unsubscribes after
  /// the first event is received.
  ///
  /// - Parameters:
  ///   - eventType: The type of event to subscribe to.
  ///   - handler: The handler to invoke once.
  public func once(to eventType: EventType, handler: @escaping EventHandler) {
    var didFire = false
    var subscriberId: EventSubscriberId?

    subscriberId = subscribe(to: eventType) { [self] event in
      guard !didFire else { return }
      didFire = true
      if let id = subscriberId {
        _ = self.unsubscribe(id: id, from: eventType)
      }
      handler(event)
    }
  }

  /// Subscribes to an event type with a filter predicate.
  ///
  /// The handler will only be invoked for events that pass the filter.
  ///
  /// - Parameters:
  ///   - eventType: The type of event to subscribe to.
  ///   - filter: A predicate that determines if the handler should be invoked.
  ///   - handler: The handler to invoke for filtered events.
  /// - Returns: A subscriber ID for later unsubscription.
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

  /// Subscribes to an event type with a mapping function.
  ///
  /// The handler receives the result of applying the map function to events.
  ///
  /// - Parameters:
  ///   - eventType: The type of event to subscribe to.
  ///   - map: A function that transforms events.
  ///   - handler: The handler to invoke with transformed events.
  /// - Returns: A subscriber ID for later unsubscription.
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

  /// Unsubscribes all handlers for a specific event type.
  ///
  /// - Parameter eventType: The type of event to unsubscribe from.
  public func unsubscribeAll(from eventType: EventType) {
    typeToSubscribers.removeValue(forKey: eventType)
    typeToObjectSubscribers.removeValue(forKey: eventType)
  }

  /// Unsubscribes all handlers for all event types.
  public func unsubscribeAll() {
    typeToSubscribers.removeAll()
    typeToObjectSubscribers.removeAll()
  }

  /// Returns the number of subscribers for a specific event type.
  ///
  /// - Parameter eventType: The type of event to count subscribers for.
  /// - Returns: The number of subscribers, or 0 if none exist.
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

  /// Returns all event types that currently have subscribers.
  ///
  /// - Returns: A set of event types with active subscriptions.
  public func subscribedEventTypes() -> Set<EventType> {
    let subscriberTypes = Set(typeToSubscribers.keys)
    let objectSubscriberTypes = Set(typeToObjectSubscribers.keys)
    return subscriberTypes.union(objectSubscriberTypes)
  }
}

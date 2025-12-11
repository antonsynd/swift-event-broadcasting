//
//  TypedEvent.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

// @brief A protocol for events that carry typed payloads.
// Conforming types can provide type-safe access to event data.
public protocol EventPayload {
  associatedtype PayloadType

  var payload: PayloadType { get }
}

// @brief A generic event that carries a typed payload.
// This allows for type-safe event handling without casting.
open class TypedEvent<T>: Event, EventPayload {
  public typealias PayloadType = T

  public let payload: T

  public init(eventType: EventType, payload: T) {
    self.payload = payload
    super.init(eventType: eventType)
  }
}

// @brief Type-safe event handler that receives typed events
public typealias TypedEventHandler<T> = (TypedEvent<T>) -> Void

// @brief Extension to EventBroadcaster that provides type-safe event handling
extension EventBroadcaster {
  // @brief Subscribes a typed handler to an event type, automatically
  // casting events to the specified typed event.
  // @param eventType The type of events to subscribe to
  // @param handler The typed handler to invoke with events
  // @return A subscriber id for later unsubscription
  public func subscribe<T>(
    to eventType: EventType,
    handler: @escaping TypedEventHandler<T>
  ) -> EventSubscriberId {
    return subscribe(to: eventType) { event in
      guard let typedEvent = event as? TypedEvent<T> else {
        return
      }
      handler(typedEvent)
    }
  }

  // @brief Subscribes a typed handler using an object subscriber.
  // @param subscriber The object to associate with this subscription
  // @param eventType The type of events to subscribe to
  // @param handler The typed handler to invoke with events
  public func subscribe<T>(
    _ subscriber: AnyHashable,
    to eventType: EventType,
    with handler: @escaping TypedEventHandler<T>
  ) {
    subscribe(subscriber, to: eventType) { event in
      guard let typedEvent = event as? TypedEvent<T> else {
        return
      }
      handler(typedEvent)
    }
  }
}

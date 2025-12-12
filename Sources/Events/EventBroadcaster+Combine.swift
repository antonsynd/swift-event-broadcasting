//
//  EventBroadcaster+Combine.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

#if canImport(Combine)
  import Combine
  import Foundation

  /// Extension to `EventBroadcaster` that provides Combine `Publisher` support.
  @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
  extension EventBroadcaster {
    /// Creates a Combine `Publisher` that emits events of the specified type.
    ///
    /// The publisher will continue emitting events until all subscriptions are
    /// cancelled or the broadcaster is deallocated.
    ///
    /// - Parameter eventType: The type of events to publish.
    /// - Returns: A publisher that emits events matching the specified type.
    public func publisher(for eventType: EventType) -> AnyPublisher<
      Event, Never
    > {
      let subject = PassthroughSubject<Event, Never>()

      let subscriberId = self.subscribe(to: eventType) { event in
        subject.send(event)
      }

      return
        subject
        .handleEvents(receiveCancel: { [weak self] in
          guard let self = self else { return }
          _ = self.unsubscribe(id: subscriberId, from: eventType)
        })
        .eraseToAnyPublisher()
    }

    /// Creates a type-safe Combine `Publisher` for typed events.
    ///
    /// Only events that can be cast to `TypedEvent<T>` will be emitted.
    ///
    /// - Parameter eventType: The type of events to publish.
    /// - Returns: A publisher that emits `TypedEvent<T>` instances.
    public func typedPublisher<T>(for eventType: EventType) -> AnyPublisher<
      TypedEvent<T>, Never
    > {
      return publisher(for: eventType)
        .compactMap { $0 as? TypedEvent<T> }
        .eraseToAnyPublisher()
    }
  }
#endif

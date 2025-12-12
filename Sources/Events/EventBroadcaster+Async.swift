//
//  EventBroadcaster+Async.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

/// Extension to `EventBroadcaster` that provides async/await support
/// for event subscription using `AsyncStream`.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension EventBroadcaster {
  /// Creates an `AsyncStream` that yields events of the specified type.
  ///
  /// The stream will continue until it is cancelled or the broadcaster is deallocated.
  ///
  /// - Parameter eventType: The type of events to stream.
  /// - Returns: An `AsyncStream` that yields events matching the specified type.
  public func events(for eventType: EventType) -> AsyncStream<Event> {
    AsyncStream { continuation in
      let subscriberId = self.subscribe(to: eventType) { event in
        continuation.yield(event)
      }

      continuation.onTermination = { @Sendable _ in
        _ = self.unsubscribe(id: subscriberId, from: eventType)
      }
    }
  }

  /// Waits for the next event of the specified type.
  ///
  /// - Parameter eventType: The type of event to wait for.
  /// - Returns: The next event of the specified type.
  public func nextEvent(for eventType: EventType) async -> Event {
    await withCheckedContinuation { continuation in
      var hasResumed = false
      var subscriberId: EventSubscriberId?

      subscriberId = self.subscribe(to: eventType) { [self] event in
        guard !hasResumed else { return }
        hasResumed = true
        if let id = subscriberId {
          _ = self.unsubscribe(id: id, from: eventType)
        }
        continuation.resume(returning: event)
      }
    }
  }
}

//
//  EventBroadcaster+Async.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

// @brief Extension to EventBroadcaster that provides async/await support
// for event subscription using AsyncStream.
extension EventBroadcaster {
  // @brief Creates an AsyncStream that yields events of the specified type.
  // The stream will continue until it is cancelled or the broadcaster is
  // deallocated.
  // @param eventType The type of events to stream
  // @return An AsyncStream that yields Events matching the specified type
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

  // @brief Waits for the next event of the specified type.
  // @param eventType The type of event to wait for
  // @return The next Event of the specified type
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

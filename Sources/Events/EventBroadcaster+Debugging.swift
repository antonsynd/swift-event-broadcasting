//
//  EventBroadcaster+Debugging.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 12/11/24.
//

import Foundation

// @brief Extension providing debugging and logging utilities for event
// broadcasting.
extension EventBroadcaster {
  // @brief Options for controlling debug output
  public struct DebugOptions: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// Log when events are broadcast
    public static let logBroadcasts = DebugOptions(rawValue: 1 << 0)
    /// Log when handlers are subscribed
    public static let logSubscriptions = DebugOptions(rawValue: 1 << 1)
    /// Log when handlers are unsubscribed
    public static let logUnsubscriptions = DebugOptions(rawValue: 1 << 2)
    /// Log event payload details (if available)
    public static let logPayloads = DebugOptions(rawValue: 1 << 3)

    /// Log all activities
    public static let all: DebugOptions = [
      .logBroadcasts, .logSubscriptions, .logUnsubscriptions, .logPayloads,
    ]
  }

  // @brief Enables debug mode for the event broadcaster. Currently logs
  // initialization only. For detailed event flow logging, use LoggingEventDispatcher
  // when creating the broadcaster.
  // @param options Reserved for future use
  // @param logger A custom logging function (defaults to print)
  // @return The broadcaster instance for chaining
  //
  // Note: For comprehensive logging of broadcasts and subscriptions, wrap your
  // dispatcher with LoggingEventDispatcher:
  //   let dispatcher = LoggingEventDispatcher(wrapping: baseDispatcher)
  //   let broadcaster = EventBroadcaster(eventDispatcher: dispatcher)
  @discardableResult
  public func enableDebugLogging(
    options: DebugOptions = .all,
    logger: @escaping (String) -> Void = { print($0) }
  ) -> Self {
    let timestamp = { () -> String in
      let formatter = DateFormatter()
      formatter.dateFormat = "HH:mm:ss.SSS"
      return formatter.string(from: Date())
    }

    logger(
      "[\(timestamp())] EventBroadcaster: Debug logging enabled (use LoggingEventDispatcher for event flow logging)"
    )

    return self
  }

  // @brief Gets a detailed description of the current state of the
  // broadcaster, including all subscribed event types and their
  // subscriber counts.
  // @return A formatted string describing the broadcaster state
  public func debugDescription() -> String {
    var description = "EventBroadcaster State:\n"

    let types = subscribedEventTypes()

    if types.isEmpty {
      description += "  No active subscriptions\n"
    }
    else {
      description += "  Active event types: \(types.count)\n"

      for eventType in types.sorted() {
        let count = subscriberCount(for: eventType)
        description += "    - \(eventType): \(count) subscriber(s)\n"
      }
    }

    return description
  }

  // @brief Prints a detailed debug description to stdout
  public func printDebugInfo() {
    print(debugDescription())
  }

  // @brief Returns statistics about the broadcaster's current state
  // @return A dictionary with various statistics
  public func statistics() -> [String: Any] {
    let types = subscribedEventTypes()
    var totalSubscribers = 0

    for eventType in types {
      totalSubscribers += subscriberCount(for: eventType)
    }

    return [
      "totalEventTypes": types.count,
      "totalSubscribers": totalSubscribers,
      "eventTypes": Array(types),
    ]
  }
}

// @brief A debugging event dispatcher that logs all dispatch operations.
// Useful for troubleshooting event flow.
public class LoggingEventDispatcher: EventDispatching {
  private let wrappedDispatcher: EventDispatching
  private let logger: (String) -> Void

  public init(
    wrapping dispatcher: EventDispatching,
    logger: @escaping (String) -> Void = { print($0) }
  ) {
    self.wrappedDispatcher = dispatcher
    self.logger = logger
  }

  public func dispatch(
    _ event: Event,
    using eventHandler: @escaping EventHandler
  ) {
    let timestamp = DateFormatter.localizedString(
      from: Date(),
      dateStyle: .none,
      timeStyle: .medium
    )

    logger(
      "[\(timestamp)] Dispatching event: \(event.eventType) (type: \(type(of: event)))"
    )

    wrappedDispatcher.dispatch(event, using: eventHandler)
  }
}

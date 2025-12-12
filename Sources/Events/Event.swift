//
//  Event.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Foundation

/// An event type, indicating a particular situation or use case of an event.
public typealias EventType = String

/// An event that can be subclassed to provide interfaces with data
/// relevant to the event being broadcast.
open class Event {
  public let eventType: EventType

  public init(eventType: EventType) {
    self.eventType = eventType
  }

  /// Convenience method to prepend the class name to an event type string
  /// to prevent name clashes. Optional, but recommended.
  ///
  /// - Parameter eventType: The event type string to namespace.
  /// - Returns: A namespaced event type in the format `"ClassName:eventType"`.
  public static func ET(_ eventType: String) -> EventType {
    return "\(String(describing: self)):\(eventType)"
  }
}

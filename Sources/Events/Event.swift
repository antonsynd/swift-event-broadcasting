//
//  Event.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Foundation

// @brief An event type, indicating a particular situation or use case of an
// event.
public typealias EventType = String

// @brief An event. This can be subclassed to provide interfaces with data
// relevant to the event being broadcast.
open class Event {
  let eventType: EventType

  public init(eventType: EventType) {
    self.eventType = eventType
  }

  // @brief Convenience method to prepend the class name to an event type
  // string to prevent name clashes. Optional, but recommended.
  public static func ET(_ eventType: String) -> EventType {
    return "\(String(describing: self)):\(eventType)"
  }
}

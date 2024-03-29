//
//  EventSubscribers.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 5/11/23.
//

import Collections
import Foundation

// @brief Maintains subscriber id to event handler relations, and controls
// the distribution of new subscriber ids. Used by the EventBroadcaster to
// keep track of subscribers for a particular event type.
internal class EventSubscribers {
  private var nextSubscriberId: EventSubscriberId = 0
  private var subscribers: OrderedDictionary<EventSubscriberId, EventHandler> =
    [:]

  internal func add(_ handler: @escaping EventHandler) -> EventSubscriberId {
    let currentSubscriberId: EventSubscriberId = nextSubscriberId
    nextSubscriberId += 1

    subscribers[currentSubscriberId] = handler

    return currentSubscriberId
  }

  internal func remove(_ subscriber: EventSubscriberId) -> Bool {
    subscribers.removeValue(forKey: subscriber) != nil
  }

  internal func forEach(_ body: (@escaping EventHandler) -> Void) {
    subscribers.values.forEach(body)
  }
}

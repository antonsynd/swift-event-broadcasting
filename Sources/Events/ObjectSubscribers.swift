//
//  ObjectSubscribers.swift
//  swift-event-broadcasting
//
//  Created by Anton Nguyen on 11/2/23.
//

import Foundation

// @brief Maintains object subscribers to subscriber id relations. Used by
// the EventBroadcaster to keep track of object subscribers for a particular
// event type.
internal class ObjectSubscribers {
  private var objectsToIds: [AnyHashable: Set<EventSubscriberId>] = [:]

  internal func add(_ subscriber: AnyHashable, withId id: EventSubscriberId) {
    objectsToIds[subscriber, default: []].insert(id)
  }

  internal func remove(_ subscriber: AnyHashable) -> Set<EventSubscriberId>? {
    return objectsToIds.removeValue(forKey: subscriber)
  }
}

# swift-event-broadcasting

Event handling implementation for Swift.

## Basics

An event broadcaster is an object that extends `EventBroadcaster` or implements
the `EventBroadcasting` protocol. It broadcasts events to subscribers via
`broadcast()`.

Subscribers are event handlers (callback functions). They are subscribed to
event broadcasters via the `subscribe()` method on the event broadcaster.

When an event is broadcasted via an event broadcaster's `broadcast()` method,
all event handlers for that event's type are invoked synchronously in the order
in which they were subscribed in a separate execution queue (which doesn't
block the main thread).

## How to

### Create an event broadcaster

Extend `EventBroadcaster` or implement the `EventBroadcasting` protocol:

```swift
import Events

class GPSService: EventBroadcaster {
}

class GPSServiceAlternate: EventBroadcasting {
  private let broadcaster: EventBroadcaster = EventBroadcaster()
  
  func subscribe(...) { broadcaster.subscribe(...) }
  ...
  func broadcast(...) { broadcaster.broadcast(...) }
}
```
### Subscribe to an event broadcaster

Subscribe with an event type, the event handler as a closure, and
optionally an associated `AnyHashable`.

Without an `AnyHashable`, a `SubscriberId` will be returned. If you intend on
unsubscribing (removing) the event handler, then you should store the
subscriber id to call `unsubscribe()` later.

```swift
let gpsService = GPSService()

// Subscribe
let subscriberId = gpsService.subscribe(to: "locationUpdate") {
  print("location updated")
}

// Broadcast
gpsService.broadcast(Event(eventType: "locationUpdate))
// prints "location updated"

// Unsubscribe
gpsService.unsubscribe(id: subscriberId, from: "locationUpdate")
```

With an `AnyHashable`, no subscriber id will be returned. To unsubscribe, pass
the same `AnyHashable`.

```swift
let gpsService = GPSService()
let someHashable: AnyHashable = ...

// Subscribe
gpsService.subscribe(someHashable, to: "locationUpdate") {
  print("location updated")
}

// Broadcast
gpsService.broadcast(Event(eventType: "locationUpdate))
// prints "location updated"

// Unsubscribe
gpsService.unsubscribe(subscriber: someHashable, from: "locationUpdate")
```

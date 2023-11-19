# swift-event-broadcasting

![macOS (latest), Swift 5.8 workflow badge](https://github.com/antonsynd/swift-event-broadcasting/actions/workflows/macos_latest_swift_5_8.yml/badge.svg)
![Ubuntu (latest), Swift 5.8 workflow badge](https://github.com/antonsynd/swift-event-broadcasting/actions/workflows/ubuntu_latest_swift_5_8.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fantonsynd%2Fswift-event-broadcasting%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/antonsynd/swift-event-broadcasting)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fantonsynd%2Fswift-event-broadcasting%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/antonsynd/swift-event-broadcasting)

swift-event-broadcasting is a library for creating and observing events. It is
similar in function to the `events` module in Node.js.

Here, an `EventBroadcaster` is the analogue of Node.js `EventEmitter`, and an
event subscriber is the analogue of an event handler.

## Features

* "Set it and forget it" event subscription
* Support for broadcasting multiple event types
* Hassle-free unsubscribe mechanism for `Hashable` subscribers 
* Fully customizable event queueing and dispatching

## Quick start 

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
gpsService.broadcast(Event(eventType: "locationUpdate"))
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
gpsService.broadcast(Event(eventType: "locationUpdate"))
// prints "location updated"

// Unsubscribe
gpsService.unsubscribe(subscriber: someHashable, from: "locationUpdate")
```

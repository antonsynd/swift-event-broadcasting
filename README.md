# swift-event-broadcasting

![macOS (latest), Swift 6.1 workflow badge](https://github.com/antonsynd/swift-event-broadcasting/actions/workflows/macos_latest_swift_6_1.yml/badge.svg)
![Ubuntu (latest), Swift 6.1 workflow badge](https://github.com/antonsynd/swift-event-broadcasting/actions/workflows/ubuntu_latest_swift_6_1.yml/badge.svg)
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
* **Type-safe events** with generic payload support
* **Async/await** integration with AsyncStream
* **Combine** support with Publisher APIs
* **Convenience methods**: `once`, `filter`, `map`, and more
* **Debugging utilities**: logging, introspection, and statistics
* Subscriber counting and introspection utilities

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
let subscriberId = gpsService.subscribe(to: "locationUpdate") { event in
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
gpsService.subscribe(someHashable, to: "locationUpdate") { event in
  print("location updated")
}

// Broadcast
gpsService.broadcast(Event(eventType: "locationUpdate"))
// prints "location updated"

// Unsubscribe
gpsService.unsubscribe(subscriber: someHashable, from: "locationUpdate")
```

## Advanced Features

### Type-Safe Events

Use `TypedEvent` for compile-time type safety with event payloads:

```swift
// Define a custom event type
struct LocationData {
  let latitude: Double
  let longitude: Double
}

let eventType = "locationUpdate"

// Subscribe with type safety
gpsService.subscribe(to: eventType) { (event: TypedEvent<LocationData>) in
  print("Location: \(event.payload.latitude), \(event.payload.longitude)")
}

// Broadcast with typed data
let location = LocationData(latitude: 37.7749, longitude: -122.4194)
gpsService.broadcast(TypedEvent(eventType: eventType, payload: location))
```

### Async/Await Support

Stream events using modern Swift concurrency:

```swift
// Stream all events of a type
Task {
  for await event in gpsService.events(for: "locationUpdate") {
    print("Received event: \(event)")
  }
}

// Wait for a single event
Task {
  let event = await gpsService.nextEvent(for: "locationUpdate")
  print("Got event: \(event)")
}
```

### Combine Integration

Use Combine publishers for reactive programming:

```swift
import Combine

// Create a publisher for events
let cancellable = gpsService.publisher(for: "locationUpdate")
  .sink { event in
    print("Received: \(event)")
  }

// Type-safe publisher
let typedCancellable = gpsService.typedPublisher(for: "locationUpdate")
  .map { (event: TypedEvent<LocationData>) in event.payload }
  .sink { location in
    print("Location: \(location.latitude), \(location.longitude)")
  }
```

### Convenience Methods

#### One-time subscription

```swift
// Subscribe to receive only the first event
gpsService.once(to: "locationUpdate") { event in
  print("First location update received")
}
```

#### Filtered subscription

```swift
// Only receive events that match a condition
gpsService.subscribe(
  to: "locationUpdate",
  filter: { event in
    guard let typed = event as? TypedEvent<LocationData> else { return false }
    return typed.payload.latitude > 0
  }
) { event in
  print("Northern hemisphere location: \(event)")
}
```

#### Mapped subscription

```swift
// Transform events before handling
gpsService.subscribe(
  to: "locationUpdate",
  map: { event -> String? in
    guard let typed = event as? TypedEvent<LocationData> else { return nil }
    return "\(typed.payload.latitude),\(typed.payload.longitude)"
  }
) { coordinates in
  print("Coordinates: \(coordinates)")
}
```

### Introspection and Cleanup

```swift
// Check subscriber count
let count = gpsService.subscriberCount(for: "locationUpdate")
print("Subscribers: \(count)")

// Get all event types with subscribers
let types = gpsService.subscribedEventTypes()
print("Active event types: \(types)")

// Remove all subscribers for an event type
gpsService.unsubscribeAll(from: "locationUpdate")

// Remove all subscribers for all events
gpsService.unsubscribeAll()
```

## Custom Event Dispatching

Customize how events are dispatched by providing your own `EventDispatching` implementation:

```swift
class CustomDispatcher: EventDispatching {
  func dispatch(_ event: Event, using eventHandler: @escaping EventHandler) {
    // Custom dispatching logic
    DispatchQueue.main.async {
      eventHandler(event)
    }
  }
}

let service = GPSService(eventDispatcher: CustomDispatcher())
```

## Debugging and Introspection

### Debug Logging

Enable debug logging to see what's happening with your events:

```swift
let service = GPSService()

// Enable debug logging with default options (logs everything)
service.enableDebugLogging()

// Or customize what gets logged
service.enableDebugLogging(options: [.logBroadcasts, .logSubscriptions])

// Custom logger
service.enableDebugLogging { message in
    os_log("%{public}@", log: .default, type: .debug, message)
}
```

### Debug Information

Get detailed information about broadcaster state:

```swift
// Print debug info to console
service.printDebugInfo()

// Get debug description as string
let description = service.debugDescription()

// Get statistics dictionary
let stats = service.statistics()
print("Total subscribers: \(stats["totalSubscribers"]!)")
print("Event types: \(stats["eventTypes"]!)")
```

### Logging Event Dispatcher

Wrap any dispatcher with logging:

```swift
let baseDispatcher = DispatchQueueEventDispatcher.EventDispatcher()
let loggingDispatcher = LoggingEventDispatcher(wrapping: baseDispatcher) { message in
    print("Event: \(message)")
}

let service = GPSService(eventDispatcher: loggingDispatcher)
```

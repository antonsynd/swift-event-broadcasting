# Migration Guide

This guide helps you adopt the new features in swift-event-broadcasting while maintaining compatibility with existing code.

## Good News: Zero Breaking Changes

All new features are **additive only**. Your existing code will continue to work without any changes. You can adopt new features incrementally.

## Migrating to Type-Safe Events

### Before (Still Supported)

```swift
class LocationEvent: Event {
    let latitude: Double
    let longitude: Double
    
    init(lat: Double, lon: Double) {
        self.latitude = lat
        self.longitude = lon
        super.init(eventType: "locationUpdate")
    }
}

service.subscribe(to: "locationUpdate") { event in
    if let locationEvent = event as? LocationEvent {
        print("\(locationEvent.latitude), \(locationEvent.longitude)")
    }
}
```

### After (Recommended)

```swift
struct Location {
    let latitude: Double
    let longitude: Double
}

// Use TypedEvent for better type safety
service.subscribe(to: "locationUpdate") { (event: TypedEvent<Location>) in
    // No casting needed!
    print("\(event.payload.latitude), \(event.payload.longitude)")
}

service.broadcast(TypedEvent(eventType: "locationUpdate", payload: location))
```

### Benefits
- No manual casting required
- Compile-time type checking
- Better code completion in Xcode
- Safer refactoring

## Migrating to Async/Await

### Before (Callback-based)

```swift
var subscriberId: EventSubscriberId?

func startListening() {
    subscriberId = service.subscribe(to: "message") { event in
        self.handleMessage(event)
        
        if self.shouldStop {
            if let id = self.subscriberId {
                self.service.unsubscribe(id: id, from: "message")
            }
        }
    }
}
```

### After (Async/Await)

```swift
func startListening() async {
    for await event in service.events(for: "message") {
        handleMessage(event)
        
        if shouldStop {
            break  // Automatically unsubscribes
        }
    }
}
```

### Benefits
- Cleaner async code
- Automatic cleanup
- No manual subscriber ID management
- Better error handling with Swift's structured concurrency

## Migrating to Combine

### Before (Callback-based)

```swift
var subscriberIds: [EventSubscriberId] = []

func setupSubscriptions() {
    let id1 = service.subscribe(to: "event1") { event in
        self.handle1(event)
    }
    
    let id2 = service.subscribe(to: "event2") { event in
        self.handle2(event)
    }
    
    subscriberIds.append(contentsOf: [id1, id2])
}

func cleanup() {
    for id in subscriberIds {
        service.unsubscribe(id: id, from: "event1")
        service.unsubscribe(id: id, from: "event2")
    }
}
```

### After (Combine)

```swift
var cancellables = Set<AnyCancellable>()

func setupSubscriptions() {
    service.publisher(for: "event1")
        .sink { [weak self] in self?.handle1($0) }
        .store(in: &cancellables)
    
    service.publisher(for: "event2")
        .sink { [weak self] in self?.handle2($0) }
        .store(in: &cancellables)
}

// Automatic cleanup when cancellables are released
```

### Benefits
- Standard Combine operators available
- Automatic memory management
- Easy to combine multiple streams
- Built-in backpressure handling

## Using Convenience Methods

### One-Time Events

#### Before
```swift
var subscriberId: EventSubscriberId?

subscriberId = service.subscribe(to: "appLaunched") { event in
    self.doInitialization()
    
    if let id = self.subscriberId {
        self.service.unsubscribe(id: id, from: "appLaunched")
    }
}
```

#### After
```swift
service.once(to: "appLaunched") { event in
    doInitialization()
}  // Automatically unsubscribes after first event
```

### Filtered Events

#### Before
```swift
service.subscribe(to: "scoreUpdate") { event in
    guard let scoreEvent = event as? ScoreEvent else { return }
    
    if scoreEvent.score > 100 {
        self.handleHighScore(scoreEvent)
    }
}
```

#### After
```swift
service.subscribe(
    to: "scoreUpdate",
    filter: { event in
        guard let scoreEvent = event as? ScoreEvent else { return false }
        return scoreEvent.score > 100
    }
) { event in
    handleHighScore(event)
}
```

### Cleanup

#### Before
```swift
// No built-in way to check subscriber count
// Manual tracking needed

// Manual cleanup of each subscriber
for id in subscriberIds {
    service.unsubscribe(id: id, from: eventType)
}
```

#### After
```swift
// Check how many subscribers exist
let count = service.subscriberCount(for: "myEvent")

// Get all active event types
let types = service.subscribedEventTypes()

// Remove all subscribers at once
service.unsubscribeAll(from: "myEvent")

// Or remove everything
service.unsubscribeAll()
```

## Combining Old and New Approaches

You can mix and match approaches based on your needs:

```swift
class MyService: EventBroadcaster {
    // Legacy callback-based API (still works)
    func subscribeToUpdates(handler: @escaping EventHandler) -> EventSubscriberId {
        return subscribe(to: "update", handler: handler)
    }
    
    // New async API
    func updateStream() -> AsyncStream<Event> {
        return events(for: "update")
    }
    
    // New Combine API
    @available(macOS 10.15, iOS 13.0, *)
    func updatePublisher() -> AnyPublisher<Event, Never> {
        return publisher(for: "update")
    }
}
```

## Best Practices

### When to Use Each Approach

**Callbacks** (Original API)
- Simple, one-off subscriptions
- When you need explicit control over subscription lifecycle
- When targeting older platforms without async/await

**Async/Await**
- Sequential event processing
- When working with Swift Concurrency
- Modern apps targeting iOS 15+/macOS 12+

**Combine**
- Complex event stream transformations
- When already using Combine in your app
- Need for backpressure or advanced operators

**Type-Safe Events**
- Any time you want compile-time type safety
- When refactoring with confidence
- New code (highly recommended)

### Memory Management

#### With Callbacks
```swift
class MyViewController {
    var subscriberIds: [EventSubscriberId] = []
    
    deinit {
        // Manual cleanup required
        subscriberIds.forEach { id in
            service.unsubscribe(id: id, from: "event")
        }
    }
}
```

#### With Async/Await
```swift
class MyViewController {
    var eventTask: Task<Void, Never>?
    
    func startListening() {
        eventTask = Task {
            for await event in service.events(for: "event") {
                // Process event
            }
        }
    }
    
    deinit {
        eventTask?.cancel()  // Automatic cleanup
    }
}
```

#### With Combine
```swift
class MyViewController {
    var cancellables = Set<AnyCancellable>()
    
    func startListening() {
        service.publisher(for: "event")
            .sink { self.handle($0) }
            .store(in: &cancellables)
    }
    
    // Automatic cleanup when cancellables are released
}
```

## Incremental Migration Strategy

1. **Start with new code**: Use new features for all new event subscriptions
2. **Add convenience methods**: Replace manual cleanup patterns with `once`, `unsubscribeAll`, etc.
3. **Adopt type safety**: Gradually convert custom Event subclasses to TypedEvent
4. **Modernize with async**: Convert callback-based code to async/await where it makes sense
5. **Integrate Combine**: If using Combine elsewhere, switch event subscriptions to publishers

## Questions?

If you have questions about migration or encounter issues, please open an issue on GitHub.

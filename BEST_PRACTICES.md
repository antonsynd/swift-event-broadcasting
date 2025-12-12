# Best Practices

This guide provides recommendations for using swift-event-broadcasting effectively in production applications.

## Event Design

### Use Descriptive Event Types

```swift
// ❌ Avoid: Generic or unclear names
static let update = "update"
static let change = "change"
static let event1 = "event1"

// ✅ Good: Clear, specific names
static let userProfileUpdated = "userProfileUpdated"
static let networkConnectionLost = "networkConnectionLost"
static let purchaseCompleted = "purchaseCompleted"
```

### Namespace Event Types

```swift
// ✅ Use Event.ET() to avoid conflicts
class UserService: EventBroadcaster {
    static let loggedIn = Event.ET("loggedIn")
    // Produces: "UserService:loggedIn"
}

class AdminService: EventBroadcaster {
    static let loggedIn = Event.ET("loggedIn")
    // Produces: "AdminService:loggedIn"
}
```

### Use Type-Safe Events

```swift
// ❌ Avoid: Casting in handlers
service.subscribe(to: "update") { event in
    if let myEvent = event as? MyEvent {
        // Handle event
    }
}

// ✅ Good: Type-safe from the start
service.subscribe(to: "update") { (event: TypedEvent<MyData>) in
    let data = event.payload  // No casting needed
}
```

### Keep Payloads Immutable

```swift
// ✅ Use structs or immutable classes
struct UserUpdatePayload {
    let userId: String
    let timestamp: Date
    let changes: [String: Any]
}

// ❌ Avoid: Mutable state in payloads
class UserUpdatePayload {
    var userId: String
    var processed: Bool = false  // Can be modified by handlers
}
```

## Subscription Management

### Choose the Right Subscription Method

```swift
// ✅ For short-lived subscriptions
func viewDidLoad() {
    service.once(to: "initial") { event in
        // Called only once
    }
}

// ✅ For object-based cleanup
func viewDidLoad() {
    service.subscribe(self, to: "update") { event in
        // Handle event
    }
}

func viewWillDisappear() {
    service.unsubscribe(subscriber: self, from: "update")
}

// ✅ For async code
Task {
    for await event in service.events(for: "update") {
        // Handle event
        if shouldStop { break }  // Automatic cleanup
    }
}

// ✅ For Combine pipelines
service.publisher(for: "update")
    .sink { event in /* handle */ }
    .store(in: &cancellables)  // Automatic cleanup
```

### Always Clean Up Long-Lived Subscriptions

```swift
class MyService {
    private var subscriberIds: [EventSubscriberId] = []

    func start() {
        let id = broadcaster.subscribe(to: "event") { event in
            // Handle event
        }
        subscriberIds.append(id)
    }

    func stop() {
        subscriberIds.forEach { id in
            broadcaster.unsubscribe(id: id, from: "event")
        }
        subscriberIds.removeAll()
    }

    deinit {
        stop()
    }
}
```

### Avoid Memory Leaks with Weak References

```swift
// ❌ Strong reference cycle
class ViewController {
    let service = Service()

    func setup() {
        service.subscribe(to: "event") { event in
            self.handleEvent(event)  // Strong reference to self
        }
    }
}

// ✅ Use weak references
class ViewController {
    let service = Service()

    func setup() {
        service.subscribe(to: "event") { [weak self] event in
            self?.handleEvent(event)
        }
    }
}
```

## Performance

### Use Filtering at Subscribe Time

```swift
// ❌ Less efficient: Filter in every handler
service.subscribe(to: "allEvents") { event in
    if event.someCondition {
        // Handle
    }
}

// ✅ Better: Filter at subscription
service.subscribe(
    to: "allEvents",
    filter: { $0.someCondition }
) { event in
    // Handle only matching events
}
```

### Batch Multiple Updates

```swift
// ❌ Broadcasting many events rapidly
func updateItems(_ items: [Item]) {
    for item in items {
        broadcast(TypedEvent(eventType: "itemUpdated", payload: item))
    }
}

// ✅ Batch updates when possible
func updateItems(_ items: [Item]) {
    broadcast(TypedEvent(eventType: "itemsUpdated", payload: items))
}
```

### Use Appropriate Dispatchers

```swift
// ✅ Main queue for UI updates
class UIService: EventBroadcaster {
    init() {
        super.init(eventDispatcher: MainQueueDispatcher())
    }
}

// ✅ Background queue for heavy processing
class DataProcessor: EventBroadcaster {
    init() {
        super.init(eventDispatcher: BackgroundDispatcher())
    }
}

// ✅ Synchronous for testing
let testService = Service(eventDispatcher: SyncDispatcher())
```

## Thread Safety

### Understanding EventBroadcaster's Threading Model

`EventBroadcaster` is **not thread-safe by default**. The internal subscriber dictionaries are not protected by locks, so concurrent modifications from multiple threads can cause crashes or undefined behavior.

```swift
// ❌ UNSAFE: Concurrent access from multiple queues
class UnsafeService {
    let broadcaster = EventBroadcaster()

    func backgroundTask() {
        DispatchQueue.global().async {
            // Modifying subscribers from background queue
            _ = self.broadcaster.subscribe(to: "event") { _ in }
        }
    }

    func mainTask() {
        DispatchQueue.main.async {
            // Simultaneously modifying from main queue - RACE CONDITION!
            self.broadcaster.unsubscribeAll()
        }
    }
}
```

### Safe Patterns for Multi-Threaded Use

**Option 1: Serialize all access through a single queue**

```swift
// ✅ Safe: All access serialized through a dedicated queue
class ThreadSafeService {
    private let broadcaster = EventBroadcaster()
    private let queue = DispatchQueue(label: "com.myapp.broadcaster")

    func subscribe(to eventType: EventType, handler: @escaping EventHandler) -> EventSubscriberId {
        queue.sync {
            broadcaster.subscribe(to: eventType, handler: handler)
        }
    }

    func broadcast(_ event: Event) {
        queue.sync {
            broadcaster.broadcast(event)
        }
    }

    func unsubscribe(id: EventSubscriberId, from eventType: EventType) {
        queue.sync {
            _ = broadcaster.unsubscribe(id: id, from: eventType)
        }
    }
}
```

**Option 2: Use main thread for all broadcaster operations**

```swift
// ✅ Safe: All operations on main thread
class MainThreadService: EventBroadcaster {
    override func subscribe(to eventType: EventType, handler: @escaping EventHandler) -> EventSubscriberId {
        assert(Thread.isMainThread, "Must be called on main thread")
        return super.subscribe(to: eventType, handler: handler)
    }

    override func broadcast(_ event: Event) {
        if Thread.isMainThread {
            super.broadcast(event)
        } else {
            DispatchQueue.main.async {
                super.broadcast(event)
            }
        }
    }
}
```

**Option 3: Subscribe once at setup, broadcast from anywhere**

If subscriptions are established during initialization and never change, you only need to synchronize broadcasts:

```swift
// ✅ Safe: Static subscriptions, synchronized broadcasts
class StaticSubscriptionService {
    private let broadcaster: EventBroadcaster
    private let broadcastQueue = DispatchQueue(label: "com.myapp.broadcast")

    init() {
        broadcaster = EventBroadcaster()

        // All subscriptions happen once during init (single-threaded)
        _ = broadcaster.subscribe(to: "dataUpdated") { event in
            // Handle event
        }
    }

    func broadcast(_ event: Event) {
        broadcastQueue.sync {
            broadcaster.broadcast(event)
        }
    }
}
```

### Be Aware of Dispatch Contexts

```swift
// Event handlers may run on different threads
service.subscribe(to: "event") { event in
    // This might not be on the main thread!
    // ❌ Don't do this:
    self.label.text = "Updated"

    // ✅ Do this:
    DispatchQueue.main.async {
        self.label.text = "Updated"
    }
}
```

### Use Thread-Safe Data Structures

```swift
// ✅ Protect shared state
class SafeCounter {
    private let queue = DispatchQueue(label: "counter")
    private var _count = 0

    var count: Int {
        queue.sync { _count }
    }

    func increment() {
        queue.sync { _count += 1 }
    }
}
```

## Error Handling

### Don't Let Handlers Throw

```swift
// ❌ Throwing handlers can break event processing
service.subscribe(to: "event") { event in
    try someThrowingFunction()  // Dangerous!
}

// ✅ Handle errors within the handler
service.subscribe(to: "event") { event in
    do {
        try someThrowingFunction()
    } catch {
        logger.error("Failed to process event: \(error)")
    }
}
```

### Use Event Broadcasting for Errors

```swift
class Service: EventBroadcaster {
    static let errorOccurred = Event.ET("errorOccurred")

    func performOperation() {
        do {
            try riskyOperation()
        } catch {
            broadcast(TypedEvent(
                eventType: Service.errorOccurred,
                payload: error
            ))
        }
    }
}
```

## Testing

### Use Synchronous Dispatchers

```swift
class SyncDispatcher: EventDispatching {
    func dispatch(_ event: Event, using handler: @escaping EventHandler) {
        handler(event)  // Synchronous execution
    }
}

func testEventHandling() {
    let service = Service(eventDispatcher: SyncDispatcher())

    var received: Event?
    service.subscribe(to: "test") { event in
        received = event
    }

    service.broadcast(Event(eventType: "test"))

    XCTAssertNotNil(received)  // Executes synchronously
}
```

### Mock Event Broadcasters

```swift
protocol EventService {
    func subscribe(to eventType: EventType, handler: @escaping EventHandler) -> EventSubscriberId
    func broadcast(_ event: Event)
}

class MockEventService: EventService {
    var broadcastedEvents: [Event] = []

    func subscribe(to eventType: EventType, handler: @escaping EventHandler) -> EventSubscriberId {
        return 0
    }

    func broadcast(_ event: Event) {
        broadcastedEvents.append(event)
    }
}
```

### Test Event Order

```swift
func testEventOrder() {
    let service = EventBroadcaster(eventDispatcher: SyncDispatcher())
    var received: [String] = []

    service.subscribe(to: "test") { _ in received.append("first") }
    service.subscribe(to: "test") { _ in received.append("second") }

    service.broadcast(Event(eventType: "test"))

    XCTAssertEqual(received, ["first", "second"])
}
```

## Debugging

### Enable Logging During Development

```swift
#if DEBUG
service.enableDebugLogging()
#endif
```

### Use Statistics for Monitoring

```swift
// Monitor subscription health
func checkHealth() {
    let stats = service.statistics()
    let count = stats["totalSubscribers"] as? Int ?? 0

    if count > 100 {
        logger.warning("High subscriber count: \(count)")
    }
}
```

### Add Custom Event Descriptions

```swift
class MyEvent: Event {
    let data: MyData

    init(data: MyData) {
        self.data = data
        super.init(eventType: MyEvent.ET("dataChanged"))
    }

    // Add for better debugging
    var debugDescription: String {
        "MyEvent(data: \(data))"
    }
}
```

## Architecture

### Separate Concerns

```swift
// ✅ Good: Service broadcasts, view controller observes
class DataService: EventBroadcaster {
    func updateData() {
        // Do work
        broadcast(TypedEvent(eventType: "dataUpdated", payload: newData))
    }
}

class ViewController {
    func viewDidLoad() {
        dataService.subscribe(to: "dataUpdated") { [weak self] event in
            self?.refreshUI()
        }
    }
}

// ❌ Avoid: Tight coupling
class ViewController {
    func viewDidLoad() {
        dataService.onDataUpdated = { [weak self] in
            self?.refreshUI()
        }
    }
}
```

### Use Events for Cross-Module Communication

```swift
// Module A
class AuthModule: EventBroadcaster {
    static let userLoggedIn = Event.ET("userLoggedIn")
}

// Module B (doesn't depend on Module A internals)
authModule.subscribe(to: AuthModule.userLoggedIn) { event in
    // React to auth changes
}
```

### Don't Overuse Events

```swift
// ❌ Events for everything leads to complexity
service.broadcast(Event(eventType: "aboutToValidate"))
service.broadcast(Event(eventType: "validating"))
service.broadcast(Event(eventType: "validated"))
service.broadcast(Event(eventType: "aboutToSave"))
// ...

// ✅ Events for significant state changes
service.broadcast(Event(eventType: "savingStarted"))
service.broadcast(Event(eventType: "savingCompleted"))
service.broadcast(Event(eventType: "savingFailed"))
```

## Summary

- Use type-safe events with descriptive names
- Clean up subscriptions to avoid memory leaks
- Choose the right subscription method for your use case
- Be aware of threading and dispatch contexts
- Handle errors gracefully within handlers
- Use synchronous dispatchers for predictable testing
- Enable debug logging during development
- Keep your architecture clean and decoupled

Following these practices will help you build robust, maintainable applications with swift-event-broadcasting.

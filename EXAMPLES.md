# Examples

This document provides comprehensive examples of using swift-event-broadcasting.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Type-Safe Events](#type-safe-events)
- [Async/Await Integration](#asyncawait-integration)
- [Combine Integration](#combine-integration)
- [Convenience Methods](#convenience-methods)
- [Custom Dispatching](#custom-dispatching)
- [Real-World Examples](#real-world-examples)

## Basic Usage

### Simple Event Broadcasting

```swift
import Events

// Create a service that broadcasts events
class NotificationService: EventBroadcaster {
    static let notificationReceived = "notificationReceived"
    
    func simulateNotification() {
        broadcast(Event(eventType: NotificationService.notificationReceived))
    }
}

// Subscribe to events
let service = NotificationService()

let subscriberId = service.subscribe(to: NotificationService.notificationReceived) { event in
    print("Notification received!")
}

// Broadcast an event
service.simulateNotification()

// Unsubscribe when done
service.unsubscribe(id: subscriberId, from: NotificationService.notificationReceived)
```

### Object-Based Subscription

```swift
class ViewController {
    let service = NotificationService()
    
    func viewDidLoad() {
        // Subscribe using self as the subscriber identifier
        service.subscribe(self, to: NotificationService.notificationReceived) { event in
            print("View controller received notification")
        }
    }
    
    func viewWillDisappear() {
        // Unsubscribe using self
        service.unsubscribe(subscriber: self, from: NotificationService.notificationReceived)
    }
}
```

## Type-Safe Events

### Creating and Using Typed Events

```swift
import Events

// Define your data structures
struct User {
    let id: String
    let name: String
}

struct UserEvent {
    static let userLoggedIn = "userLoggedIn"
    static let userLoggedOut = "userLoggedOut"
}

// Create a typed event
let user = User(id: "123", name: "John Doe")
let loginEvent = TypedEvent(eventType: UserEvent.userLoggedIn, payload: user)

// Subscribe with type safety
let service = EventBroadcaster()

service.subscribe(to: UserEvent.userLoggedIn) { (event: TypedEvent<User>) in
    print("User logged in: \(event.payload.name)")
}

// Broadcast the typed event
service.broadcast(loginEvent)
```

### Custom Event Classes

```swift
// Create a custom event class
class LocationEvent: Event {
    struct Location {
        let latitude: Double
        let longitude: Double
    }
    
    static let locationUpdated = LocationEvent.ET("locationUpdated")
    
    let location: Location
    
    init(location: Location) {
        self.location = location
        super.init(eventType: LocationEvent.locationUpdated)
    }
}

// Use it
service.subscribe(to: LocationEvent.locationUpdated) { event in
    if let locationEvent = event as? LocationEvent {
        print("Location: \(locationEvent.location)")
    }
}
```

## Async/Await Integration

### Streaming Events

```swift
import Events

Task {
    let service = NotificationService()
    var eventCount = 0
    
    // Stream events continuously
    for await event in service.events(for: NotificationService.notificationReceived) {
        print("Received event: \(event)")
        eventCount += 1
        
        // Break after receiving 3 events
        if eventCount >= 3 {
            break
        }
    }
}
```

### Waiting for Single Events

```swift
Task {
    let service = NotificationService()
    
    // Wait for the next event
    let event = await service.nextEvent(for: NotificationService.notificationReceived)
    print("Got event: \(event)")
    
    // Continue with other work
}
```

### Multiple Concurrent Streams

```swift
Task {
    let service = EventBroadcaster()
    
    async let event1 = service.nextEvent(for: "event1")
    async let event2 = service.nextEvent(for: "event2")
    
    // Wait for both events
    let (e1, e2) = await (event1, event2)
    print("Got both events: \(e1), \(e2)")
}
```

## Combine Integration

### Basic Publisher

```swift
import Combine
import Events

let service = NotificationService()
var cancellables = Set<AnyCancellable>()

service.publisher(for: NotificationService.notificationReceived)
    .sink { event in
        print("Received: \(event)")
    }
    .store(in: &cancellables)
```

### Type-Safe Publisher

```swift
struct Message {
    let text: String
}

let eventType = "messageReceived"

service.typedPublisher(for: eventType)
    .map { (event: TypedEvent<Message>) in event.payload }
    .sink { message in
        print("Message: \(message.text)")
    }
    .store(in: &cancellables)
```

### Combining Multiple Event Streams

```swift
let publisher1 = service.publisher(for: "event1")
let publisher2 = service.publisher(for: "event2")

publisher1.merge(with: publisher2)
    .sink { event in
        print("Received from either stream: \(event)")
    }
    .store(in: &cancellables)
```

### Advanced Combine Operators

```swift
service.typedPublisher(for: "locationUpdate")
    .map { (event: TypedEvent<Location>) in event.payload }
    .filter { $0.latitude > 0 }  // Northern hemisphere only
    .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
    .removeDuplicates { $0.latitude == $1.latitude && $0.longitude == $1.longitude }
    .sink { location in
        print("Unique location update: \(location)")
    }
    .store(in: &cancellables)
```

## Convenience Methods

### One-Time Subscription

```swift
let service = EventBroadcaster()

// Subscribe to receive only the first event
service.once(to: "appLaunched") { event in
    print("App launched for the first time in this session")
    // This handler will not be called again
}
```

### Filtered Subscriptions

```swift
struct Score {
    let value: Int
}

// Only receive high scores
service.subscribe(
    to: "scoreUpdate",
    filter: { event in
        guard let typed = event as? TypedEvent<Score> else { return false }
        return typed.payload.value > 100
    }
) { event in
    print("High score: \(event)")
}
```

### Mapped Subscriptions

```swift
// Transform events before handling
service.subscribe(
    to: "userUpdate",
    map: { event -> String? in
        guard let typed = event as? TypedEvent<User> else { return nil }
        return typed.payload.name
    }
) { userName in
    print("User name: \(userName)")
}
```

### Cleanup and Introspection

```swift
// Check subscriber count
let count = service.subscriberCount(for: "someEvent")
print("Number of subscribers: \(count)")

// Get all active event types
let types = service.subscribedEventTypes()
print("Active event types: \(types)")

// Remove all subscribers for an event
service.unsubscribeAll(from: "someEvent")

// Remove all subscribers for all events
service.unsubscribeAll()
```

## Custom Dispatching

### Main Queue Dispatcher

```swift
class MainQueueDispatcher: EventDispatching {
    func dispatch(_ event: Event, using eventHandler: @escaping EventHandler) {
        DispatchQueue.main.async {
            eventHandler(event)
        }
    }
}

let service = EventBroadcaster(eventDispatcher: MainQueueDispatcher())
```

### Background Queue Dispatcher

```swift
class BackgroundDispatcher: EventDispatching {
    private let queue = DispatchQueue(label: "com.myapp.events", qos: .background)
    
    func dispatch(_ event: Event, using eventHandler: @escaping EventHandler) {
        queue.async {
            eventHandler(event)
        }
    }
}
```

### Synchronous Dispatcher (for testing)

```swift
class SynchronousDispatcher: EventDispatching {
    func dispatch(_ event: Event, using eventHandler: @escaping EventHandler) {
        eventHandler(event)
    }
}

// Use in tests for predictable behavior
let testService = EventBroadcaster(eventDispatcher: SynchronousDispatcher())
```

## Real-World Examples

### GPS Service with Location Updates

```swift
import Events
import CoreLocation

class GPSService: EventBroadcaster {
    struct LocationData {
        let coordinate: CLLocationCoordinate2D
        let timestamp: Date
    }
    
    static let locationUpdated = "locationUpdated"
    
    func updateLocation(_ coordinate: CLLocationCoordinate2D) {
        let data = LocationData(coordinate: coordinate, timestamp: Date())
        broadcast(TypedEvent(eventType: GPSService.locationUpdated, payload: data))
    }
}

// Usage with Combine
import Combine

class MapViewController {
    let gpsService = GPSService()
    var cancellables = Set<AnyCancellable>()
    
    func setupLocationTracking() {
        gpsService.typedPublisher(for: GPSService.locationUpdated)
            .map { $0.payload }
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] location in
                self?.updateMap(with: location.coordinate)
            }
            .store(in: &cancellables)
    }
    
    func updateMap(with coordinate: CLLocationCoordinate2D) {
        // Update map UI
    }
}
```

### WebSocket Message Handler

```swift
class WebSocketService: EventBroadcaster {
    static let messageReceived = "messageReceived"
    static let connectionStatusChanged = "connectionStatusChanged"
    
    enum ConnectionStatus {
        case connected
        case disconnected
        case error(Error)
    }
    
    func handleMessage(_ message: String) {
        broadcast(TypedEvent(eventType: WebSocketService.messageReceived, payload: message))
    }
    
    func updateConnectionStatus(_ status: ConnectionStatus) {
        broadcast(TypedEvent(eventType: WebSocketService.connectionStatusChanged, payload: status))
    }
}

// Usage with async/await
Task {
    let ws = WebSocketService()
    
    // Handle messages in a stream
    for await event in ws.events(for: WebSocketService.messageReceived) {
        if let typed = event as? TypedEvent<String> {
            print("Message: \(typed.payload)")
            // Process message
        }
    }
}
```

### Game Event System

```swift
class GameEventSystem: EventBroadcaster {
    struct PlayerScored {
        let playerId: String
        let points: Int
    }
    
    struct LevelCompleted {
        let level: Int
        let timeElapsed: TimeInterval
    }
    
    static let playerScored = "playerScored"
    static let levelCompleted = "levelCompleted"
    static let gameOver = "gameOver"
    
    func playerScored(playerId: String, points: Int) {
        broadcast(TypedEvent(
            eventType: GameEventSystem.playerScored,
            payload: PlayerScored(playerId: playerId, points: points)
        ))
    }
    
    func completeLevel(_ level: Int, timeElapsed: TimeInterval) {
        broadcast(TypedEvent(
            eventType: GameEventSystem.levelCompleted,
            payload: LevelCompleted(level: level, timeElapsed: timeElapsed)
        ))
    }
}

// Multiple subscribers
let game = GameEventSystem()

// UI updates
game.subscribe(to: GameEventSystem.playerScored) { (event: TypedEvent<GameEventSystem.PlayerScored>) in
    updateScoreUI(points: event.payload.points)
}

// Analytics
game.subscribe(to: GameEventSystem.levelCompleted) { (event: TypedEvent<GameEventSystem.LevelCompleted>) in
    logAnalytics(level: event.payload.level, time: event.payload.timeElapsed)
}

// Achievements
game.subscribe(
    to: GameEventSystem.playerScored,
    filter: { event in
        guard let typed = event as? TypedEvent<GameEventSystem.PlayerScored> else { return false }
        return typed.payload.points >= 1000
    }
) { event in
    unlockAchievement("HighScorer")
}
```

### State Management System

```swift
class AppStateManager: EventBroadcaster {
    enum AppState {
        case launching
        case active
        case background
        case terminated
    }
    
    static let stateChanged = "stateChanged"
    
    private(set) var currentState: AppState = .launching {
        didSet {
            broadcast(TypedEvent(eventType: AppStateManager.stateChanged, payload: currentState))
        }
    }
    
    func transitionTo(_ newState: AppState) {
        currentState = newState
    }
}

// Usage
let stateManager = AppStateManager()

// Subscribe to state changes
stateManager.subscribe(to: AppStateManager.stateChanged) { (event: TypedEvent<AppStateManager.AppState>) in
    switch event.payload {
    case .launching:
        initializeServices()
    case .active:
        resumeOperations()
    case .background:
        pauseOperations()
    case .terminated:
        cleanup()
    }
}
```

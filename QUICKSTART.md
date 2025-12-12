# Quick Start Guide

Get started with swift-event-broadcasting in minutes!

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/antonsynd/swift-event-broadcasting", from: "1.0.0")
]
```

Or in Xcode: File → Add Package Dependencies → Enter repository URL

## Your First Event Broadcaster

### Step 1: Create a Broadcaster

```swift
import Events

class ChatService: EventBroadcaster {
    static let messageReceived = "messageReceived"
    
    func sendMessage(_ text: String) {
        // Send message to server...
        
        // Broadcast event to subscribers
        broadcast(TypedEvent(eventType: ChatService.messageReceived, payload: text))
    }
}
```

### Step 2: Subscribe to Events

```swift
let chat = ChatService()

// Subscribe to messages
chat.subscribe(to: ChatService.messageReceived) { (event: TypedEvent<String>) in
    print("New message: \(event.payload)")
}

// Send a message
chat.sendMessage("Hello, world!")
// Output: New message: Hello, world!
```

### Step 3: Clean Up (Optional)

```swift
// Automatic cleanup with object-based subscription
class ChatViewController {
    let chat = ChatService()
    
    func viewDidLoad() {
        chat.subscribe(self, to: ChatService.messageReceived) { event in
            // Handle message
        }
    }
    
    func viewWillDisappear() {
        chat.unsubscribe(subscriber: self, from: ChatService.messageReceived)
    }
}
```

## Common Patterns

### Pattern 1: Type-Safe Events

```swift
struct User {
    let name: String
    let email: String
}

class AuthService: EventBroadcaster {
    static let userLoggedIn = "userLoggedIn"
    
    func login(user: User) {
        broadcast(TypedEvent(eventType: AuthService.userLoggedIn, payload: user))
    }
}

// Type-safe subscription
auth.subscribe(to: AuthService.userLoggedIn) { (event: TypedEvent<User>) in
    print("Welcome, \(event.payload.name)!")
}
```

### Pattern 2: Async/Await

```swift
Task {
    for await event in chat.events(for: ChatService.messageReceived) {
        if let typed = event as? TypedEvent<String> {
            await processMessage(typed.payload)
        }
    }
}
```

### Pattern 3: Combine

```swift
import Combine

var cancellables = Set<AnyCancellable>()

chat.typedPublisher(for: ChatService.messageReceived)
    .map { $0.payload }
    .sink { message in
        print("Got: \(message)")
    }
    .store(in: &cancellables)
```

### Pattern 4: One-Time Events

```swift
// Subscribe to receive only the first event
service.once(to: "appLaunched") { event in
    performInitialization()
}
```

### Pattern 5: Filtered Events

```swift
// Only receive important messages
chat.subscribe(
    to: ChatService.messageReceived,
    filter: { event in
        guard let typed = event as? TypedEvent<String> else { return false }
        return typed.payload.contains("important")
    }
) { event in
    showNotification(event)
}
```

## Tips for Success

### 1. Use String Constants for Event Types

```swift
class MyService: EventBroadcaster {
    // Good: Type-safe string constants
    static let dataUpdated = "dataUpdated"
    static let errorOccurred = "errorOccurred"
    
    // Even better: Use Event.ET() to namespace
    static let dataUpdated = Event.ET("dataUpdated")
    // Produces: "Event:dataUpdated"
}
```

### 2. Prefer Type-Safe Events

```swift
// Instead of:
broadcast(Event(eventType: "userUpdate"))

// Do this:
broadcast(TypedEvent(eventType: "userUpdate", payload: user))
```

### 3. Clean Up Subscriptions

```swift
// For short-lived objects, use object-based subscription
chat.subscribe(self, to: event) { ... }

// For long-lived objects, store subscriber IDs
let id = chat.subscribe(to: event) { ... }
// Later: chat.unsubscribe(id: id, from: event)

// Or use async/await for automatic cleanup
Task {
    for await event in chat.events(for: event) {
        // Automatically cleaned up when Task is cancelled
    }
}
```

### 4. Debug Issues

```swift
// Enable logging to see what's happening
service.enableDebugLogging()

// Check subscriber counts
print("Subscribers: \(service.subscriberCount(for: "myEvent"))")

// Print full debug info
service.printDebugInfo()
```

### 5. Custom Dispatching

```swift
// Dispatch on main queue for UI updates
class MainQueueDispatcher: EventDispatching {
    func dispatch(_ event: Event, using handler: @escaping EventHandler) {
        DispatchQueue.main.async {
            handler(event)
        }
    }
}

let service = MyService(eventDispatcher: MainQueueDispatcher())
```

## Next Steps

- Read [EXAMPLES.md](EXAMPLES.md) for real-world use cases
- Check [README.md](README.md) for complete API documentation
- See [MIGRATION.md](MIGRATION.md) if you're upgrading from an older version
- Read [CONTRIBUTING.md](CONTRIBUTING.md) if you want to contribute

## Need Help?

- Open an issue on GitHub
- Check existing issues for solutions
- Read the documentation

Happy event broadcasting! 🎉

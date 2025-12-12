# Copilot Instructions for swift-event-broadcasting

## Project Overview

This is a Swift package providing a Node.js-style event broadcasting system. Core abstractions:
- **`EventBroadcaster`**: Central class for subscribing/broadcasting (analogous to Node's `EventEmitter`)
- **`Event`**: Base event class with `eventType: String` identifier
- **`TypedEvent<T>`**: Generic subclass for type-safe payloads
- **`EventDispatching`**: Protocol for custom dispatch strategies (default: `DispatchQueueEventDispatcher`)

## Architecture Patterns

### Extension-based Feature Organization
Features are organized as extensions in separate files:
- `Sources/Events/EventBroadcaster+Async.swift` - `AsyncStream`, `nextEvent(for:)`
- `Sources/Events/EventBroadcaster+Combine.swift` - Combine `Publisher` support
- `Sources/Events/EventBroadcaster+Convenience.swift` - `once`, `filter`, `map`
- `Sources/Events/EventBroadcaster+Debugging.swift` - logging, stats

When adding features, create a new `EventBroadcaster+<Feature>.swift` extension file.

### Subscription Pattern
Two subscription approaches coexist:
1. **ID-based**: `subscribe(to:handler:)` returns `EventSubscriberId` for unsubscribing
2. **Object-based**: `subscribe(_:to:with:)` uses `AnyHashable` subscriber as key

Internal tracking uses:
- `typeToSubscribers: [EventType: EventSubscribers]` - ID-based handlers
- `typeToObjectSubscribers: [EventType: ObjectSubscribers]` - object-to-ID mapping

### Event Type Namespacing
Use `Event.ET(_:)` to namespace event types by class name:
```swift
class GPSEvent: Event {
    static let locationUpdate = GPSEvent.ET("locationUpdate")  // "GPSEvent:locationUpdate"
}
```

## Build & Test Commands

```bash
swift build           # Build the package
swift test            # Run all tests
swift-format -i -r .  # Format code (required before PR)
swift-format lint -r . # Check formatting
```

## Code Conventions

- **Doc comments**: Use `///` style for documentation comments (Swift standard)
- **Testing framework**: Swift Testing (`import Testing`) with `@Suite` and `@Test` attributes
- **Test naming**: Use descriptive `@Test("description")` labels
- **Test structure**: Use `// Given`, `// When`, `// Then` or `// If`, `// When/then` comments
- **Test assertions**: Use `#expect()` for soft assertions, `#require()` for hard assertions
- **Test utilities**: Shared fixtures in `Tests/EventsTests/EventsTestsUtils.swift`
- **Conditional compilation**: Use `#if canImport(Combine)` for platform-specific features

## Key Abstractions to Understand

| Type | Purpose |
|------|---------|
| `EventSubscriberId` | `UInt` alias for tracking subscriptions |
| `EventType` | `String` alias for event identifiers |
| `EventHandler` | `(Event) -> Void` closure type |
| `EventSubscribers` | Internal ordered dict of ID→handler (uses `Collections.OrderedDictionary`) |
| `ObjectSubscribers` | Maps `AnyHashable` objects to their subscriber IDs |

## Dependencies

- `apple/swift-collections` (1.0.0..<2.0.0) - provides `OrderedDictionary` for handler ordering

## Platform Requirements

- Swift 5.8+, Swift 6.1 for CI
- Combine features require macOS 10.15+/iOS 13.0+

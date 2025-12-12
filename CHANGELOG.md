# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Async/Await Support
- `events(for:)` - Stream events continuously using AsyncStream
- `nextEvent(for:)` - Wait for the next event of a specific type
- Automatic cleanup when async streams are cancelled

#### Type-Safe Events
- `TypedEvent<T>` - Generic event class with typed payloads
- `EventPayload` protocol for type-safe event handling
- Type-safe `subscribe` methods that automatically cast events
- Compile-time type safety for event data

#### Combine Integration
- `publisher(for:)` - Create Combine publishers from event streams
- `typedPublisher(for:)` - Type-safe Combine publishers
- Automatic cleanup when publishers are cancelled
- Full integration with Combine operators

#### Convenience Methods
- `once(to:handler:)` - Subscribe to receive only the first event
- `subscribe(to:filter:handler:)` - Subscribe with event filtering
- `subscribe(to:map:handler:)` - Subscribe with event transformation
- `unsubscribeAll(from:)` - Remove all subscribers for a specific event type
- `unsubscribeAll()` - Remove all subscribers from all events
- `subscriberCount(for:)` - Get the number of subscribers for an event type
- `subscribedEventTypes()` - Get all event types with active subscriptions

#### Documentation
- Comprehensive README with advanced usage examples
- New EXAMPLES.md with real-world use cases including:
  - GPS service with location tracking
  - WebSocket message handling
  - Game event system
  - State management patterns
- Detailed API documentation in source files

#### Testing
- 14 new tests covering all new features
- Async/await test suite (3 tests)
- Type-safe events test suite (4 tests)
- Convenience methods test suite (7 tests)

### Changed
- Made internal subscriber dictionaries accessible to extensions
- Added `count()` methods to internal subscriber managers

### Developer Experience Improvements
- More ergonomic APIs with Swift's modern concurrency features
- Better discoverability through comprehensive documentation
- Type safety reduces runtime errors
- Cleaner code with convenience methods
- Better integration with popular frameworks (Combine)

## [1.0.0] - 2023

### Added
- Initial release
- Event broadcasting and subscription
- Object-based subscription with `AnyHashable`
- Custom event dispatching support
- Thread-safe event handling via dispatch queues

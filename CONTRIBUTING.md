# Contributing to swift-event-broadcasting

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to swift-event-broadcasting.

## Code of Conduct

Be respectful and constructive in all interactions. We're here to build something useful together.

## How Can I Contribute?

### Reporting Bugs

Before creating a bug report, please check existing issues to avoid duplicates.

When filing a bug report, include:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Swift version and platform (macOS, iOS, etc.)
- Code samples demonstrating the issue

### Suggesting Enhancements

Enhancement suggestions are welcome! Please:
- Use a clear, descriptive title
- Provide a detailed description of the proposed feature
- Explain why this feature would be useful
- Include code examples showing how it would be used

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add or update tests as needed
5. Ensure all tests pass (`swift test`)
6. Format your code (`swift-format -i -r .`)
7. Commit your changes (`git commit -m 'Add amazing feature'`)
8. Push to the branch (`git push origin feature/amazing-feature`)
9. Open a Pull Request

## Development Setup

### Prerequisites

- Swift 5.8 or later
- Xcode 14.0 or later (for macOS development)

### Building the Project

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Formatting Code

This project uses [swift-format](https://github.com/apple/swift-format) for code formatting.

```bash
# Format all Swift files
swift-format -i -r .

# Check formatting
swift-format lint -r .
```

The project's formatting rules are defined in `.swift-format.json`.

## Code Style Guidelines

### General Principles

- Prefer clarity over cleverness
- Write self-documenting code
- Add comments for complex logic
- Follow existing patterns in the codebase

### Naming Conventions

- Use descriptive names for types, functions, and variables
- Follow Swift naming conventions:
  - `UpperCamelCase` for types
  - `lowerCamelCase` for functions and variables
  - Clear, full words over abbreviations

### Code Organization

- Group related functionality using `// MARK:` comments
- Keep files focused on a single responsibility
- Use extensions to organize code by functionality

### Documentation

- Add doc comments to all public APIs using `///` or `/** ... */`
- Include code examples in documentation for complex features
- Update README.md when adding new features

Example:

```swift
/// Subscribes to an event type and automatically unsubscribes after
/// the first event is received.
///
/// - Parameters:
///   - eventType: The type of event to subscribe to
///   - handler: The handler to invoke once
///
/// - Example:
///   ```swift
///   service.once(to: "appLaunched") { event in
///       print("First launch!")
///   }
///   ```
public func once(to eventType: EventType, handler: @escaping EventHandler) {
    // Implementation
}
```

## Testing Guidelines

### Test Coverage

- All new features must include tests
- Aim for high test coverage
- Test both success and failure cases
- Test edge cases

### Test Naming

Use descriptive test names that explain what is being tested:

```swift
func test_EventBroadcaster_once_CallsHandlerOnlyOnce()
func test_TypedEvent_WithInvalidType_ReturnsNil()
```

### Test Structure

Follow the Given-When-Then pattern:

```swift
func test_FeatureName_Scenario() {
    // Given (setup)
    let broadcaster = EventBroadcaster()
    var callCount = 0
    
    // When (action)
    broadcaster.once(to: "test") { _ in
        callCount += 1
    }
    broadcaster.broadcast(Event(eventType: "test"))
    broadcaster.broadcast(Event(eventType: "test"))
    
    // Then (assertion)
    XCTAssertEqual(callCount, 1)
}
```

## Feature Development Process

### 1. Discuss First

For significant features:
- Open an issue to discuss the feature
- Get feedback from maintainers
- Agree on the approach before coding

### 2. Design API

- Keep APIs simple and intuitive
- Follow Swift best practices
- Maintain consistency with existing APIs
- Consider backwards compatibility

### 3. Implement

- Write clean, well-documented code
- Follow the code style guidelines
- Keep changes focused and minimal

### 4. Test

- Write comprehensive tests
- Test on multiple platforms if relevant
- Ensure all existing tests still pass

### 5. Document

- Update README.md if needed
- Add or update code examples
- Update CHANGELOG.md
- Consider adding to EXAMPLES.md

## Commit Message Guidelines

Write clear, meaningful commit messages:

```
Add async/await support for event streaming

- Implement events(for:) method using AsyncStream
- Add nextEvent(for:) for single event waiting
- Include automatic cleanup on cancellation
- Add comprehensive tests for async functionality
```

- Use present tense ("Add feature" not "Added feature")
- Start with a verb ("Add", "Fix", "Update", "Remove")
- Keep first line under 72 characters
- Add detailed description after blank line if needed
- Reference issues when relevant (#123)

## Release Process

Maintainers handle releases. The process:

1. Update version numbers
2. Update CHANGELOG.md
3. Create git tag
4. Create GitHub release
5. Update documentation

## Questions?

Feel free to:
- Open an issue for questions
- Start a discussion
- Reach out to maintainers

## Recognition

Contributors will be acknowledged in:
- Git commit history
- Release notes
- GitHub contributors page

Thank you for contributing to swift-event-broadcasting!

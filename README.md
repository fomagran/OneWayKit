<img width="280" alt="OneWay" src="https://github.com/user-attachments/assets/8346bb30-d959-40e4-bacb-3a69f2d62815" />    

# OneWayKit ♻️   

<p align="center">
    <img alt="release" src="https://img.shields.io/github/v/release/fomagran/OneWayKit?logo=swift&color=orange">
    <img alt="license" src="https://img.shields.io/badge/Swift-5.9-orange.svg">
    <img alt="license" src="https://img.shields.io/badge/iOS-13.0-blue.svg">
    <img alt="license" src="https://img.shields.io/badge/license-MIT-purple.svg">
</p>

**OneWayKit** is a reactive unidirectional architecture library built with Combine.
It allows you to update the state based on user actions and reflect those changes in the view seamlessly.
The library is designed to be simple and easy to integrate into any feature of your application.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Key Features](#key-features)
    1. [Tracer](#tracer)
    2. [Global](#global)
- [Examples](#examples)
- [Installation](#installation)
- [References](#references)
- [Author](#author)
- [License](#license)

## Basic Usage

#### 1. State, Action, Updater, and Middleware are defined through ViewFeature.

### ViewFeature

**ViewFeature** defines four key components:   
- State: Represents the state of the view.   
- Action: Captures user interactions.   
- Updater: Updates the state based on actions.   

```swift
struct TimerFeature: ViewFeature {
    
    struct State: ViewState {
        var currentTime: Float = 0
        var isStarted: Bool = false
        var interval: TimeInterval = 0.1
    }
    
    enum Action: ViewAction {
        case start
        case add
        case tapRightButton
        case toggleStart
    }
    
    static var updater: Updater = { state, action in
        var newState = state
        switch action {
            
        case .add:
            newState.currentTime += Float(state.interval)
            
        case .toggleStart:
            newState.isStarted.toggle()
            
        default: break
        }
        
        return newState
    }
}
```

### Middleware

**Middleware** plays a key role in handling asynchronous tasks by processing actions from a specific feature and emitting desired actions. Using Combine, it can also emit periodic actions, and subscriptions can be canceled using the ``cancel(for:)`` method.

``` swift
final class TimerMiddleware: Middleware {
    
    func send(_ action: ViewAction, currentState: any ViewState) -> AnyPublisher<ViewAction, Never> {
        guard let currentState = currentState as? TimerFeature.State else {
            return Empty().eraseToAnyPublisher()
        }
        
        switch action as? TimerFeature.Action {
            
        case .start:
            return Timer.publish(every: currentState.interval, on: .main, in: RunLoop.Mode.common)
                 .autoconnect()
                 .map { _ in
                     TimerFeature.Action.add
                 }
                 .eraseToAnyPublisher()
            
        case .tapRightButton:
            if currentState.isStarted {
                return Publishers.Merge(
                    Just(TimerFeature.Action.cancel(for: TimerFeature.Action.start)),
                    Just(TimerFeature.Action.toggleStart)
                )
                .eraseToAnyPublisher()
            } else {
                return Publishers.Merge(
                    Just(TimerFeature.Action.start),
                    Just(TimerFeature.Action.toggleStart)
                )
                .eraseToAnyPublisher()
            }
            
        default:
            return Empty().eraseToAnyPublisher()
        }
    }
}
```

#### 2. Now, we use the previously defined ViewFeature to create a **OneWay** that represents the unidirectional flow of the view, set the initial state, and inject middlewares for side effects.

```swift
final class TimerViewController: UIViewController {
    
    private let oneway = OneWay<TimerFeature>(initialState: .init(), middlewares: [TimerMiddleWare()])
    ...
```
#### 3. Subscribe to the state of OneWay to bind and update the UI accordingly when changes occur.

```swift
    private func setupOneWay() {
        oneway.statePublisher
            .map { String(format: "%.1f", $0.currentTime) }
            .assign(to: \.text, on: timeLabel)
            .store(in: &cancellables)
        
        oneway.statePublisher
            .map { $0.isStarted }
            .removeDuplicates()
            .sink { [weak self] isStarted in
                self?.navigationItem.rightBarButtonItem?.title = isStarted ? "Stop" : "Start"
            }
            .store(in: &cancellables)
    }
```
#### 4. Send actions corresponding to user interactions.

```swift
    @objc private func tapLeftButton() {
        oneway.send(.left)
    }
    
    @objc private func tapRightButton() {
        oneway.send(.right)
    }
    
    @objc private func tapUpButton() {
        oneway.send(.up)
    }
    
    @objc private func tapDownButton() {
        oneway.send(.down)
    }
```

## Key Features

1. #### Tracer

When creating onewaykit, set the context first.
```swift
    private lazy var oneway = OneWay<TracerFeature>(
        initialState:
            .init(
                position: .init(x: view.center.x, y: view.center.y),
                size: .init(width: 100, height: 100)
            ),
        context: TracerViewController.self
    )
```

If you want to track actions and state changes, you can use shouldTrace to trace them when sending actions, as shown below:
```swift
    @objc private func tapLeftButton() {
        oneway.send(.left, shouldTrace: true)
    }
```

By setting shouldTrace to true, you can observe events that capture the context, action, and how the state changes as a result, as shown below:   

<img width="299" alt="스크린샷 2024-12-24 오후 11 31 19" src="https://github.com/user-attachments/assets/6c3580fa-8435-44cf-9f7e-13e90521d181" />

2. #### Global

First, register the ViewFeature to be used globally and set the initial state.

```swift
   GlobalOneWay.registerState(feature: GlobalFeature.self, initialState: .init())
```
Then, you can subscribe to and use the state of the desired global feature.

```swift
        GlobalOneWay.state(feature: GlobalFeature.self)?
            .map { $0.backgroundColor }
            .sink { [weak self] in
                self?.titleLabel.backgroundColor = $0
            }
            .store(in: &cancellables)
```

You can also send actions to the global feature, of course.
```swift
GlobalOneWay.send(feature: GlobalFeature.self, .setBackgroundColor(.white))
```
## Examples

<table>
  <tr>
    <td>
      <a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/ToDo">
        <img src="https://github.com/user-attachments/assets/bfbb7ea3-4d8d-45f0-bcbd-b659d93d0fe7" width="180" height="380">
        <h4><a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/ToDo">To Do Example </a></h4>
                <p>This project allows you to add a To-Do List and learn how to detect child actions and update the parent view accordingly.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Timer">
        <img src="https://github.com/user-attachments/assets/777ff10a-027b-469b-ba81-647146c3bbb8" width="180" height="380">
        <h4><a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Timer">Timer Example</a></h4>
                <p>This project allows you to learn how to implement a timer asynchronously using Middleware and handle cancellation of subscribed events.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Tracer">
        <img src="https://github.com/user-attachments/assets/7df1dd91-a3d2-4e7d-8165-7a53430ec567" width="180" height="380">
        <h4><a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Tracer">Tracer Example </a></h4>
                <p>This project allows you to learn how to detect triggered actions and track state changes accordingly.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Global">
        <img src="https://github.com/user-attachments/assets/391a4e1a-c470-4f9b-8e27-9df4c5db4f2a" width="180" height="380">
        <h4><a href="https://github.com/fomagran/OneWayKitDemo/tree/main/OneWayKitDemo/Global">Global Example </a></h4>
                <p>This project allows you to create a global feature, subscribe to it from multiple views, and dispatch actions accordingly.</p>
      </a>
    </td>
  </tr>
</table>

## Installation

You can install **OneWayKit** via [Swift Package Manager](https://swift.org/package-manager/) by adding the following line to your `Package.swift`:

```swift
import PackageDescription

let package = Package(
    [...]
    dependencies: [
        .package(url: "https: github.com/fomagran/OneWayKit", from: "1.2.0"),
    ]
)
```

## References
The following projects have greatly inspired the creation of OneWayKit.

- [Redux](https://github.com/facebook/flux](https://github.com/reduxjs/redux))
- [ReactorKit](https://github.com/ReactorKit/ReactorKit)
- [ReSwift](https://github.com/ReactorKit/ReactorKit](https://github.com/ReSwift/ReSwift))
- [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture)

## Author

Fomagran, fomagran@icloud.com

## License

This library is released under the MIT license. See [LICENSE](LICENSE) for details.

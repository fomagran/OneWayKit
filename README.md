<img width="280" alt="OneWay" src="https://github.com/user-attachments/assets/8346bb30-d959-40e4-bacb-3a69f2d62815" />

# OneWayKit ♻️   

**OneWayKit** is a reactive unidirectional architecture library built with Combine.
It allows you to update the state based on user actions and reflect those changes in the view seamlessly.
The library is designed to be simple and easy to integrate into any feature of your application.

## Table of Contents

- [Basic Usage](#basic-usage)
- [Key Feature](#key-feature)
- [Example](#example)
- [Installation](#installation)
- [License](#license)

## Basic Usage

#### 1. State, Action, Updater, and Middleware are defined through ViewFeature.

### ViewFeature

**ViewFeature** defines four key components:   
- State: Represents the state of the view.   
- Action: Captures user interactions.   
- Updater: Updates the state based on actions.   
- Middleware: Handles asynchronous operations in between.

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
    
    static var middlewares: [Middleware]? = [TimerMiddleware()]
    
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

#### 2. Now, we use the previously defined ViewFeature to create a **OneWay** that represents the unidirectional flow of the view and set the initial state.

```swift
final class TimerViewController: UIViewController {
    
    private let oneway = OneWay<TimerFeature>(initialState: .init())
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
# Examples

<table>
  <tr>
    <td>
      <a href="https://github.com/user-attachments/assets/bfbb7ea3-4d8d-45f0-bcbd-b659d93d0fe7">
        <img src="https://github.com/user-attachments/assets/bfbb7ea3-4d8d-45f0-bcbd-b659d93d0fe7" width="180" height="380">
        <h4><a href="https://github.com/user-attachments/assets/bfbb7ea3-4d8d-45f0-bcbd-b659d93d0fe7">To Do Example </a></h4>
                <p>This project allows you to add a To-Do List and learn how to detect child actions and update the parent view accordingly.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/user-attachments/assets/777ff10a-027b-469b-ba81-647146c3bbb8">
        <img src="https://github.com/user-attachments/assets/777ff10a-027b-469b-ba81-647146c3bbb8" width="180" height="380">
        <h4><a href="https://github.com/user-attachments/assets/777ff10a-027b-469b-ba81-647146c3bbb8">Timer Example</a></h4>
                <p>This project allows you to learn how to implement a timer asynchronously using Middleware and handle cancellation of subscribed events.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/user-attachments/assets/7df1dd91-a3d2-4e7d-8165-7a53430ec567">
        <img src="https://github.com/user-attachments/assets/7df1dd91-a3d2-4e7d-8165-7a53430ec567" width="180" height="380">
        <h4><a href="https://github.com/user-attachments/assets/7df1dd91-a3d2-4e7d-8165-7a53430ec567">Tracer Example </a></h4>
                <p>This project allows you to learn how to detect triggered actions and track state changes accordingly.</p>
      </a>
    </td>
    <td>
      <a href="https://github.com/user-attachments/assets/391a4e1a-c470-4f9b-8e27-9df4c5db4f2a">
        <img src="https://github.com/user-attachments/assets/391a4e1a-c470-4f9b-8e27-9df4c5db4f2a" width="180" height="380">
        <h4><a href="https://github.com/user-attachments/assets/391a4e1a-c470-4f9b-8e27-9df4c5db4f2a">Global Example </a></h4>
                <p>This project allows you to create a global feature, subscribe to it from multiple views, and dispatch actions accordingly.</p>
      </a>
    </td>
  </tr>
</table>

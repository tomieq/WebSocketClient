# WebSocketClient

This macOS / iOS library is a convenient class wrapper that enables websocket connections.

### Installation via Swift Package Manager
```swift

```

### Sample usage:

```swift
import WebSocketClient

let websocketClient = WebsocketClient(onStatusChange: { status in
    switch status {
    case .connected:
        print("Connected")
        websocketClient.send("your data to be sent")
    case .disconnected:
        print("Disconnected")
    }
}, onReceive: { text in
    print("Received: \(text)")
})
self.websocketClient.logger = { log in
    print(log)
}
self.websocketClient.connect(url: "http://domain.com/websocket")
```

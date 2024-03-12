import Foundation

public class WebsocketClient: NSObject {
    private var webSocket: URLSessionWebSocketTask?
    private var serverUrl: String?
    private var connectionId = -1

    private var connectionStatus: WebsocketClientStatus = .disconnected {
        didSet {
            self.onStatusChange?(self.connectionStatus)
        }
    }
    public var status: WebsocketClientStatus {
        get {
            self.connectionStatus
        }
    }
    private var onReceive: ((String) -> Void)?
    private var onStatusChange: ((WebsocketClientStatus) -> Void)?
    public var logger: ((String) -> Void)?

    public init(onStatusChange: @escaping (WebsocketClientStatus) -> Void, onReceive: @escaping (String) -> Void) {
        self.onStatusChange = onStatusChange
        self.onReceive = onReceive
        super.init()
    }

    public func connect(url: String) {
        self.closeSocket()
        self.serverUrl = url
        self.openWebSocket()
    }

    public func disconnect() {
        self.webSocket?.cancel(with: .goingAway, reason: nil)
    }

    public func send(_ text: String) {
        self.logger?("Sending: \(text)")
        self.webSocket?.send(.string(text)) { [weak self] error in
            if let error = error {
                self?.logger?("Error sending command: \(error)")
                self?.connectionStatus = .disconnected
            }
        }
    }

    private func openWebSocket() {
        if let serverUrl = self.serverUrl, let url = URL(string: serverUrl) {
            self.logger?("Opening websocket connection to \(serverUrl)")
            let request = URLRequest(url: url, timeoutInterval: 8)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            let webSocket = session.webSocketTask(with: request)
            self.webSocket = webSocket
            self.setupReceiver()
            self.webSocket?.resume()
        } else {
            self.webSocket = nil
            self.connectionStatus = .disconnected
        }
    }

    private func setupReceiver() {
        self.webSocket?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                self.logger?("Websocket error \(error)")
                self.connectionStatus = .disconnected
            case .success(let webSocketTaskMessage):
                switch webSocketTaskMessage {
                case .string(let text):
                    self.logger?("Received string \(text)")
                    self.onReceive?(text)
                    self.setupReceiver()
                case .data(let data):
                    self.logger?("Received data: \(data)")
                    self.setupReceiver()
                default:
                    self.logger?("Failed. Received unknown data format. Expected String")
                }
            }
        })
    }

    private func closeSocket() {
        self.webSocket?.cancel(with: .goingAway, reason: nil)
        if self.connectionStatus != .disconnected {
            self.connectionStatus = .disconnected
        }
        self.webSocket = nil
    }
}

extension WebsocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        self.logger?("Websocket connected.")
        self.connectionStatus = .connected
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.logger?("Websocket closed with code: \(closeCode)")
        self.webSocket = nil
        self.connectionStatus = .disconnected
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error {
            self.logger?("Received error \(error)")
        }
        self.webSocket = nil
        self.connectionStatus = .disconnected
    }
}

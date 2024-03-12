import XCTest
@testable import WebSocketClient

final class WebSocketClientTests: XCTestCase {
    func testEchoConnection() throws {
        let connection = expectation(description: "Connected")
        let transfer = expectation(description: "Data received")
        let client = WebsocketClient(onStatusChange: { status in
            XCTAssertEqual(status, .connected)
            connection.fulfill()
        }, onReceive: { txt in
            XCTAssertEqual(txt, "Hello")
            transfer.fulfill()
        })
        client.logger = { log in
            print(log)
        }
        DispatchQueue.global().async {
            client.connect(url: "wss://ws.postman-echo.com/raw")
        }
        wait(for: [connection], timeout: 3)
        client.send("Hello")
        wait(for: [transfer], timeout: 1)
    }
}

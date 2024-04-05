//
//  Websocket.swift
//  SummaryAI
//
//  Created by 超方 on 2024/4/2.
//

import Foundation

@MainActor
@Observable
class Websocket: NSObject, URLSessionWebSocketDelegate {
    
    private var urlSession: URLSession?
    var wsTask: URLSessionWebSocketTask?
    var message: String = ""
    
    init(_ url: String) {
        super.init()
        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        self.wsTask = urlSession!.webSocketTask(with: URL(string: url)!)
    }
    
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("WebSocket connected")
    }
    
    nonisolated func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("WebSocket disconnected")
    }
    
    func send(_ jsonString: String, errorWrapper: @escaping (_: Error)->Void) {
        wsTask?.send(.string(jsonString)) { error in
            if let error = error {
                print("Websocket.send() failed")
                errorWrapper(error)
            }
        }
    }
    
    func receive(action: @escaping (_: String) -> Void) {
        // expecting {"type": "result", "answer": "summary content"}
        wsTask?.receive( completionHandler: { result in
            switch result {
            case .failure(let error):
                print("WebSocket received an error: \(error)")
                self.wsTask?.cancel()
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received text: \(text)")
                    if let data = text.data(using: .utf8) {
                        do {
                            if let dict = try JSONSerialization.jsonObject(with: data) as? NSDictionary {
                                if let type = dict["type"] as? String {
                                    if type == "result" {
                                        if let answer = dict["answer"] as? String {
                                            action(answer)
                                        } else {
                                            self.wsTask?.cancel()
                                        }
                                    } else {
                                        self.receive(action: action)
                                    }
                                }
                            }
                        } catch {
                            print("Invalid Json string received.")
                            self.wsTask?.cancel()
                        }
                    }
                case .data(let data):
                    print("Received data: \(data)")
                    self.wsTask?.cancel()
                @unknown default:
                    print("Unknown data")
                    self.wsTask?.cancel()
                }
            }
        })
    }
    
    func resume() {
        wsTask?.resume()
    }
    
    func cancel() {
        wsTask?.cancel(with: .goingAway, reason: nil)
    }
}

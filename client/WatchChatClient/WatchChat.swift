//
//  WatchChat.swift
//  WatchChatClient Watch App
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation
import Combine

class WatchChat {
    static let shared = WatchChat()
    
    private var responseSubject = PassthroughSubject<String, Never>()
    private var responseSubscriber: AnyCancellable? = nil
    
    private init() {}
    
    func startChatStream() {
        WatchConnectivityImpl.shared.startChatStream()
    }
    
    func chatStreamMsg(_ msg: String) {
        WatchConnectivityImpl.shared.chatStreamMsg(msg)
    }
    
    func stopChatStream() {
        WatchConnectivityImpl.shared.stopChatStream()
    }
    
    func addResponseSink(_ sinkFunction: @escaping (String) -> Void) {
        responseSubscriber = responseSubject.sink(receiveValue: sinkFunction)
    }
    
    func newResponse(_ msg: String) {
        responseSubject.send(msg)
    }
}

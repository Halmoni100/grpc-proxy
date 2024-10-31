//
//  WatchChatServic.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation

class WatchChatService {
    static let shared = WatchChatService()
    
    enum State {
        case idle
        case streaming
    }
    
    private var state: State = .idle
    
    private init() {}
    
    func startStreaming() {
        switch self.state {
        case .idle:
            ChatService.shared.startChatStream() { response in
                self.sendResponseToWatch(response.msg)
            }
            state = .streaming
        default: break
        }
    }
    
    func stream(_ msg: String) {
        switch self.state {
        case .streaming:
            ChatService.shared.streamChatMsg(msg)
        default: break
        }
    }
    
    func stopStreaming() {
        switch self.state {
        case .streaming:
            ChatService.shared.stopChatStream()
            state = .idle
        default: break
        }
    }
    
    private func sendResponseToWatch(_ msg: String) {
        
    }
}
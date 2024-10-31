//
//  ChatViewModel.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation

enum ChatClientState {
    case noStream, one, two, three, success
}

class ChatViewModel: ObservableObject {
    @Published var chatSuccess: Bool = false
    
    private var mutex = DispatchSemaphore(value: 1)
    private var state: ChatClientState = .one
    private var successTimer: Timer?
    
    init() {}
    
    func chat() {
        mutex.wait()
        
        if let timer = successTimer {
            timer.invalidate()
        }
        state = .one
        DispatchQueue.main.async { [self] in
            chatSuccess = false
            objectWillChange.send()
        }
        
        ChatService.shared.startChatStream { [self] response in
            mutex.wait()
            
            print("ChatService got response")
            
            switch state {
            case .noStream, .success:
                break;
            case .one:
                if response.msg == "one_ack" {
                    state = .two
                    ChatService.shared.streamChatMsg("two")
                } else {
                    ChatService.shared.stopChatStream()
                    state = .noStream
                }
            case .two:
                if response.msg == "two_ack" {
                    state =  .three
                    ChatService.shared.streamChatMsg("three")
                } else {
                    ChatService.shared.stopChatStream()
                    state = .noStream
                }
            case .three:
                if response.msg == "three_ack" {
                    state = .success
                    DispatchQueue.main.async { [self] in
                        chatSuccess = true
                        objectWillChange.send()
                    }
                    if let timer = successTimer {
                        timer.invalidate()
                    }
                    DispatchQueue.main.async {
                        self.successTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false) {
                                [self] timer in
                            mutex.wait()
                            state = .noStream
                            DispatchQueue.main.async { [self] in
                                chatSuccess = false
                                objectWillChange.send()
                            }
                            mutex.signal()
                        }
                    }
                    ChatService.shared.stopChatStream()
                } else {
                    ChatService.shared.stopChatStream()
                    state = .noStream
                }
            }
            
            mutex.signal()
        }
        
        ChatService.shared.streamChatMsg("one")
        
        mutex.signal()
    }
}

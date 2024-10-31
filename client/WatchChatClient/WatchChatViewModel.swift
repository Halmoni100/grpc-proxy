//
//  WatchChatViewModel.swift
//  WatchChatClient Watch App
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation

enum WatchChatClientState {
    case noStream, one, two, three, success
}

class WatchChatViewModel: ObservableObject {
    @Published var chatSuccess: Bool = false
    @Published var canChat: Bool = false
    
    private var mutex = DispatchSemaphore(value: 1)
    private var state: WatchChatClientState = .one
    private var successTimer: Timer?
    
    init() {
        WatchConnectivityImpl.shared.addIsActiveSink { isActive in
            DispatchQueue.main.async { [self] in
                canChat = isActive
                objectWillChange.send()
            }
        }
        
        WatchChat.shared.addResponseSink { response in
            self.react(toMsg: response)
        }
    }
    
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
        
        WatchChat.shared.chatStreamMsg("one")
        
        mutex.signal()
    }
    
    private func react(toMsg msg: String) {
        mutex.wait()
        
        switch state {
        case .noStream, .success:
            break;
        case .one:
            if msg == "one_ack" {
                state = .two
                WatchChat.shared.chatStreamMsg("two")
            } else {
                WatchChat.shared.stopChatStream()
                state = .noStream
            }
        case .two:
            if msg == "two_ack" {
                state =  .three
                WatchChat.shared.chatStreamMsg("three")
            } else {
                WatchChat.shared.stopChatStream()
                state = .noStream
            }
        case .three:
            if msg == "three_ack" {
                state = .success
                DispatchQueue.main.async { [self] in
                    chatSuccess = true
                    objectWillChange.send()
                }
                if let timer = successTimer {
                    timer.invalidate()
                }
                successTimer = Timer(timeInterval: 2, repeats: false) { [self] timer in
                    mutex.wait()
                    state = .noStream
                    DispatchQueue.main.async { [self] in
                        chatSuccess = false
                        objectWillChange.send()
                    }
                    mutex.signal()
                }
                WatchChat.shared.stopChatStream()
            } else {
                WatchChat.shared.stopChatStream()
                state = .noStream
            }
        }
        
        mutex.signal()
    }
}

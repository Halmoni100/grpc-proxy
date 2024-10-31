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
    }
}

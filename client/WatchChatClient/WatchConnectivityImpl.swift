//
//  WatchConnectivity.swift
//  WatchChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation
import WatchConnectivity

final class WatchConnectivityImpl: NSObject {
    static let shared = WatchConnectivityImpl()
    
    override private init() {
        super.init()
    }
    
    func activateSession() {
        guard WCSession.isSupported() else {
            return
        }
        
        WCSession.default.delegate = self
        WCSession.default.activate()
    }
}

extension WatchConnectivityImpl: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        <#code#>
    }
    
}

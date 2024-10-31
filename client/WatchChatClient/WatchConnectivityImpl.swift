//
//  WatchConnectivity.swift
//  WatchChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation
import WatchConnectivity
import Combine

final class WatchConnectivityImpl: NSObject {
    static let shared = WatchConnectivityImpl()
    
    private var isActiveSubject = CurrentValueSubject<Bool, Never>(false)
    private var isActiveSubscribers = [AnyCancellable]()
    
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
    
    func addIsActiveSink(_ sinkFunction: @escaping (Bool) -> Void) {
        isActiveSubscribers.append(isActiveSubject.sink(receiveValue: sinkFunction))
    }
    
    func canSend() -> Bool {
        if WCSession.default.activationState == .activated,
           WCSession.default.isCompanionAppInstalled {
            return true
        } else {
            isActiveSubject.send(false)
            return false
        }
    }
    
    func startChatStream() {
        guard canSend() else {
            return
        }
        
        WCSession.default.sendMessage([Connectivity.SEND_START_CHAT : ""], replyHandler: nil)
    }
    
    func chatStreamMsg(_ msg: String) {
        guard canSend() else {
            return
        }
        
        WCSession.default.sendMessage([Connectivity.SEND_CHAT_MSG : msg], replyHandler: nil)
    }
    
    func stopChatStream() {
        guard canSend() else {
            return
        }
        
        WCSession.default.sendMessage([Connectivity.SEND_STOP_CHAT : ""], replyHandler: nil)
    }
}

extension WatchConnectivityImpl: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        if activationState == .activated {
            isActiveSubject.send(true)
        } else if activationState == .inactive || activationState == .notActivated {
            isActiveSubject.send(false)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        if !session.isReachable {
            isActiveSubject.send(false)
        } else {
            isActiveSubject.send(true)
        }
    }
}

//
//  IosConnectivity.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import Foundation
import WatchConnectivity

final class IosConnectivityImpl: NSObject {
    static let shared = IosConnectivityImpl()
    
    override private init() {
        super.init()
    }
    
    func activateSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            guard WCSession.isSupported() else {
                return
            }
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func canSend() -> Bool {
        if WCSession.default.activationState == .activated,
           WCSession.default.isWatchAppInstalled {
            return true
        } else {
            return false
        }
    }
    
    private func sendApplicationContext(iosRunning: Bool) {
        guard canSend() else {
            return
        }
        do {
            try WCSession.default.updateApplicationContext([Connectivity.SEND_APPLICATION_CONTEXT : iosRunning])
        } catch {
            print("Failed to send application context.  Error: \(error)")
        }
    }
    
    func sendChatResponse(_ msg: String) {
        guard canSend() else {
            return
        }
        
        WCSession.default.sendMessage([Connectivity.SEND_CHAT_RESPONSE : msg], replyHandler: nil)
    }
}

extension IosConnectivityImpl: WCSessionDelegate  {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if message.keys.contains(Connectivity.SEND_START_CHAT) {
            WatchChatService.shared.startStreaming()
        } else if message.keys.contains(Connectivity.SEND_CHAT_MSG) {
            guard let msg = message[Connectivity.SEND_CHAT_MSG] as? String else { return }
            WatchChatService.shared.stream(msg)
        } else if message.keys.contains(Connectivity.SEND_STOP_CHAT) {
            WatchChatService.shared.stopStreaming()
        }
    }
    
}


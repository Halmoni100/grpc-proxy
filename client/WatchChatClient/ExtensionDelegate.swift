//
//  ExtensionDelegate.swift
//  WatchChatClient
//
//  Created by Christopher Hong on 10/31/24.
//

import WatchKit
import Combine

class ExtensionDelegate: NSObject, WKApplicationDelegate {
    override init() {
        super.init()
        WatchConnectivityImpl.shared.activateSession()
    }
}

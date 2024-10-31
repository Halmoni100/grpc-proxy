//
//  WatchChatClientApp.swift
//  WatchChatClient Watch App
//
//  Created by Christopher Hong on 10/31/24.
//

import SwiftUI

@main
struct WatchChatClient_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor private var extensionDelegate: ExtensionDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: WatchChatViewModel())
        }
    }
}

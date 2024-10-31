//
//  ChatClientApp.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/30/24.
//

import SwiftUI

@main
struct ChatClientApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    private let connectivity = IosConnectivityImpl.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView(model: ChatViewModel())
        }
        .onChange(of: scenePhase, initial: true) { oldPhase, newPhase in
            if newPhase == .active {
                connectivity.activateSession()
            }
        }
    }
}

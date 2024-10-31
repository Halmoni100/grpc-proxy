//
//  ContentView.swift
//  WatchChatClient Watch App
//
//  Created by Christopher Hong on 10/31/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: WatchChatViewModel
    
    var body: some View {
        getMainView()
    }
    
    @ViewBuilder
    private func getMainView() -> some View {
        if model.canChat {
            getActiveView()
        } else {
            getInactiveView()
        }
    }
    
    private func getInactiveView() -> some View {
        Text("Disconnected from iPhone; is iOS app open?")
    }
     
    private func getActiveView() -> some View {
        VStack {
            getSuccessView()
            Button(action: beginChat) {
                Text("Begin chat")
            }
        }
    }
    
    func beginChat() {
        DispatchQueue.global(qos: .userInitiated).async {
            model.chat()
        }
    }
    
    @ViewBuilder
    private func getSuccessView() -> some View {
        if model.chatSuccess {
            Text("Success!")
                .foregroundStyle(.red)
        } else {
            Text("Waiting...")
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ContentView(model: WatchChatViewModel())
}

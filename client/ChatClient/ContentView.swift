//
//  ContentView.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: ChatViewModel
    
    var body: some View {
        VStack {
            getSuccessView()
            Button(action: beginChat) {
                Text("Begin chat")
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func getSuccessView() -> some View {
        if model.chatSuccess {
            Text("Success!")
                .foregroundStyle(.green)
        } else {
            Text("Waiting...")
                .foregroundStyle(.gray)
        }
    }
    
    func beginChat() {
        DispatchQueue.global(qos: .userInitiated).async {
            model.chat()
        }
    }
}

#Preview {
    ContentView(model: ChatViewModel())
}

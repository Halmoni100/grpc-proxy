//
//  ContentView.swift
//  ChatClient
//
//  Created by Christopher Hong on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            Button(action: beginChat) {
                Text("Begin chat")
            }
        }
        .padding()
    }
    
    func beginChat() {
    
    }
}

#Preview {
    ContentView()
}

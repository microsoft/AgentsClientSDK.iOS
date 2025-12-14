//
//  MainContent.swift
//  TextWithAdaptiveCardClientApp
//
//  Created by Prachi Pachankar on 15/12/25.
//

import SwiftUI
import AgentsClientSDK

struct MainContent: View {
    @ObservedObject var client: ClientSDK
    @Binding var showChat: Bool
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
            }
            
            if client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showChat,
                    appearance: .modern
                )
            }
        }
    }
}

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
        ZStack(alignment: .topLeading) {
            // Main content
            // Background image
            Image("DemoApp")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            // Chat component overlay
            if client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showChat,
                    appearance: .modern,
                )
            }
        }
        .ignoresSafeArea()
    }
}

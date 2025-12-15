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
            VStack(spacing: 20) {
                Text("Agents Client SDK Sample App - Text with Adaptive Card")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
            
            // Chat component overlay
            if client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showChat,
                    appearance: .modern,
                )
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

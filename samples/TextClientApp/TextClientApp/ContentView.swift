//
//  ContentView.swift
//  Demo
//
//  Created by Riddhi Tharewal on 14/04/25.
//


import SwiftUI
import AgentsClientSDK
//import AdaptiveCards
import SafariServices
import Combine


// contentview
struct ContentView: View {
    @StateObject var viewModel = AgentsClientSdk.shared
    @State private var showChat = false
    @State private var appSettings: AppSettings?

    
    // Function to load AppSettings from appsettings.json
    private func loadAppSettings() -> AppSettings? {
        guard let url = Bundle.main.url(forResource: "appsettings", withExtension: "json") else {
            print("Could not find appsettings.json file in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let appSettings = try JSONDecoder().decode(AppSettings.self, from: data)
            return appSettings
        } catch {
            print("Error loading or parsing appsettings.json: \(error)")
            return nil
        }
    }
    
    var body: some View {
        ZStack {
            if(!viewModel.userToken.isEmpty){
                // Show main app window after SDK authentication
                MainAppView(viewModel: viewModel, showChat: $showChat)
            }
        }
        .onAppear {
            self.appSettings = loadAppSettings()
            // Always initialize SDK first
            try! viewModel.initSDK(appSettings: self.appSettings!)
        }
       
    }
    
}

// MARK: - Main App View
struct MainAppView: View {
    @ObservedObject var viewModel: AgentsClientSdk
    @Binding var showChat: Bool
    var body: some View {
        ZStack {
            // Background image
            Image("appbackground") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            ZStack(alignment: .top) {
                // Welcome text at the top
                VStack(alignment: .leading, spacing: 0) {
                    Text("Welcome to the TextClientApp")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("This app uses the AgentsClientSDK, enabling you to explore its multimodal features.")
                        .foregroundColor(.white)
                        .padding(.top, 7)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // Chat overlay
                if showChat {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        ChatView(viewModel: viewModel, showChat: $showChat)
                            .frame(
                                width: UIScreen.main.bounds.width * 0.9,
                                height: min(UIScreen.main.bounds.height * 0.65, 500)
                            )
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                    }
                    .ignoresSafeArea()
                }
                
                // Bottom chat button
                VStack(spacing: 0){
                    Spacer()
                    HStack(spacing: 0){
                        Spacer()
                        HStack(spacing: 0) {
                            ChatToggleButton(showChat: $showChat, viewModel: viewModel)
                        }
                        .padding()
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: .gray.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                        .overlay(
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 2)
                                .clipShape(Capsule())
                                .padding(.vertical, 8)
                            , alignment: .trailing
                        )
                        .fixedSize()
                    }
                    .padding(.bottom, 50)
                    .padding(.trailing, 12)
                }
            }
            .ignoresSafeArea()
        }
        
    }
        
}

struct ChatToggleButton: View {
    @Binding var showChat: Bool
    @ObservedObject var viewModel: AgentsClientSdk
    var body: some View {
        Button(action: {
            withAnimation {
                showChat.toggle()
            }
        }) {
            Image(systemName: viewModel.iskeyboardActive ? "message.fill" : "message")
                .foregroundColor(viewModel.iskeyboardActive ? .red : .blue)
                .font(.title)
                .frame(width: 40, height: 40)
                .padding(.trailing, 0)
                .background(Color.white)
                .clipShape(Circle())
        }
        //.padding(.trailing, 16)
        //  .padding(.bottom, 40)
    }
}
  

struct MessagesListView: View {
    @ObservedObject var viewModel: AgentsClientSdk
    @State private var adaptiveCardHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        HStack {
                            if message.sender == "User" { Spacer() }
                            VStack(alignment: message.sender == "User" ? .trailing : .leading) {
                                Text(message.sender)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.bottom, 2)
                                if let customView = message.customView {
                                    
                                    AdaptiveCardViewRepresentable(
                                        customView: customView
                                    )
                                    .frame(width: UIScreen.main.bounds.width*0.650, height: 500)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                                    .background(Color.green)
                                    .padding(.bottom, 2)
                                } else if let imageUrl = message.imageUrl {
                                    AsyncImage(url: URL(string: imageUrl)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFit()
                                                .cornerRadius(8)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.gray)
                                                .opacity(0.5)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else if let text = message.text {
                                    Text(text)
                                        .padding(12)
                                        .background(message.sender == "User" ? Color.blue : Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                }else{
                                    
                                }
                                if let actions = message.suggestedActions, message.id == viewModel.messages.last?.id {
                                    let columns = [
                                        GridItem(.adaptive(minimum: 100), spacing: 8)
                                    ]
                                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                        ForEach(actions, id: \.self) { actionTitle in
                                            Button(action: {
                                                Task {
                                                    await viewModel.sendMessage(text: actionTitle)
                                                }
                                            }) {
                                                Text(actionTitle)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(20)
                                            }
                                        }
                                    }
                                    .padding(.top, 4)
                                }
                            }
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: message.sender == "User" ? .trailing : .leading)
                            .padding(.leading, message.sender == "User" ? 60 : 12)   // Fixed left padding for user
                            .padding(.trailing, message.sender == "Bot" ? 60 : 12)   // Fixed right padding for bot
                            if message.sender == "Bot" { Spacer() }
                        }
                        .padding(.vertical, 4)
                        .id(message.id)
                    }
                }
                
                .padding(.bottom)
                .onChange(of: viewModel.messages.count) { _ in
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

struct TypingBubbleView: View {
    @State private var animateIndex: Int = 0
    let dotCount = 3
    let dotSize: CGFloat = 10
    let animationDuration = 0.4
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<dotCount, id: \.self) { i in
                Circle()
                    .fill(Color.green.opacity(0.85))
                    .frame(width: dotSize, height: dotSize)
                    .opacity(0.85)
                    .offset(y: animateIndex == i ? -6 : 6)
                    .animation(
                        .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true)
                        .delay(Double(i) * animationDuration / 2),
                        value: animateIndex
                    )
            }
        }
        .padding(12)
        // .background(Color.white.opacity(0.85))
        .cornerRadius(16)
        .shadow(radius: 5)
        .onAppear {
            animateDots()
        }
    }
    
    func animateDots() {
        // Animate the dots in sequence
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: true) { _ in
            animateIndex = (animateIndex + 1) % dotCount
        }
    }
}


struct ChatView: View {
    @ObservedObject var viewModel: AgentsClientSdk
    @Binding var showChat: Bool
    @State private var recognizedText: String = ""
    
    var body: some View {
         GeometryReader { geometry in
        VStack(spacing: 0) {
            // Close button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation {
                        showChat = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title)
                        .padding()
                }
            }
            
            // Messages area
            MessagesListView(viewModel: viewModel)
            
            // Input area - always at bottom
            if !viewModel.userToken.isEmpty {
                VStack(spacing: 0) {
                    Divider()
                    HStack {
                        TextField("Type a message", text: $viewModel.userMessage)
                            .padding(12)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .textFieldStyle(PlainTextFieldStyle())
                        
                        Button(action: {
                            Task {
                                await viewModel.sendMessage(text: viewModel.userMessage)
                                viewModel.isBotResponding = true
                                viewModel.stopSpeaking()
                            }
                        }) {
                            Text("Send")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.userMessage.isEmpty)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
        }
         }
        .background(Color.white)
        .cornerRadius(12)
       //   .keyboardAdaptive()
        // Removed .keyboardAdaptive() since KeyboardAwareChatView handles positioning
    }
}

struct AdaptiveCardViewRepresentable: UIViewControllerRepresentable {
    let customView: UIView
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.autoresizingMask = [.flexibleHeight];
        controller.view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        
        
        NSLayoutConstraint.activate([
            customView.topAnchor.constraint(equalTo: controller.view.topAnchor),
            customView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            customView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            customView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        ])
        
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        // Coordinator(contentHeight: $contentHeight)
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No-op
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: ()) {
        // No-op
    }
    
}

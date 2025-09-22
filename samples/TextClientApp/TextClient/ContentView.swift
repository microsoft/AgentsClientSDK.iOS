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

// MARK: - Keyboard Manager
class KeyboardManager: ObservableObject {
    @Published var keyboardOffset: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .sink { [weak self] notification in
                guard let self = self else { return }
                if let userInfo = notification.userInfo,
                   let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    DispatchQueue.main.async {
                        if notification.name == UIResponder.keyboardWillShowNotification {
                            self.keyboardOffset = 100//keyboardFrame.height
                        } else {
                            self.keyboardOffset = 0
                        }
                    }
                }
            }
    }

    deinit {
        cancellable?.cancel()
    }
}

// MARK: - Adaptive Card View Representable
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
        Coordinator()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // No-op
    }
    
    static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
        // No-op
    }
    
    class Coordinator {
        // Coordinator implementation
    }
}

// MARK: - Chat Toggle Button
struct ChatToggleButton: View {
    @Binding var showChat: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                showChat.toggle()
            }
        }) {
            Image(systemName: showChat ? "message.fill" : "message")
                .foregroundColor(.blue)
                .font(.title)
                .frame(width: 40, height: 40)
                .padding(.trailing, 0)
                .background(Color.white)
                .clipShape(Circle())
        }
    }
}

// MARK: - Microphone Button
struct MicrophoneButton: View {
    @ObservedObject var client: ClientSDK
    @State private var recognizedText: String = ""
    @State private var isMicrophoneActive: Bool = false
    
    var body: some View {
        Button(action: {
            if isMicrophoneActive {
                try? client.stopContinuousListening()
                isMicrophoneActive = false
            } else {
                isMicrophoneActive = true
                try? client.registerForContinuousListening(
                    onRecognizing : { recognizedText in
                        self.recognizedText = recognizedText
                    },
                    onRecognized: { recognizedText in
                        print("onRecognized: \(recognizedText)")
                        self.recognizedText = recognizedText
                        
                        if !recognizedText.isEmpty {
                            let text = recognizedText
                            self.recognizedText = ""
                            Task {
                                await client.sendMessage(text: text)
                            }
                        }
                    })
            }
        }) {
            Image(systemName: isMicrophoneActive ? "mic.fill" : "mic")
                .foregroundColor(isMicrophoneActive ? .red : .blue)
                .font(.title)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
        }
        .padding(.trailing, 8)
    }
}

// MARK: - Mic Toggle Button
struct MicToggleButton: View {
    @Binding var speechEnabled: Bool
    
    var body: some View {
        HStack {
            Toggle("", isOn: $speechEnabled)
                .labelsHidden()
                .padding(.trailing, 5)
            Text(speechEnabled ? "Disable Speech Service" : "Enable Speech Service")
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Typing Bubble View
struct TypingBubbleView: View {
    @State private var animationOffset: [CGFloat] = [0, 0, 0]
    let dotCount = 3
    let dotSize: CGFloat = 8
    let animationDuration: Double = 0.4

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.8))
                    .frame(width: dotSize, height: dotSize)
                    .offset(y: animationOffset[index])
                    .animation(
                        .easeInOut(duration: animationDuration)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animationOffset[index]
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.green.opacity(0.85))
        .cornerRadius(16)
        .shadow(radius: 5)
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        for index in 0..<dotCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                animationOffset[index] = -6
            }
        }
    }
}

// MARK: - Messages List View
struct MessagesListView: View {
    @ObservedObject var client: ClientSDK
    @State private var adaptiveCardHeight: CGFloat = 0
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                VStack(spacing: 12) {
                    ForEach(client.messages) { message in
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
                                }
                                if let actions = message.suggestedActions, message.id == client.messages.last?.id {
                                    let columns = [
                                        GridItem(.adaptive(minimum: 100), spacing: 8)
                                    ]
                                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                                        ForEach(actions, id: \.self) { actionTitle in
                                            Button(action: {
                                                Task {
                                                    await client.sendMessage(text: actionTitle)
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
                            .padding(.leading, message.sender == "User" ? 60 : 12)
                            .padding(.trailing, message.sender == "Bot" ? 60 : 12)
                            if message.sender == "Bot" { Spacer() }
                        }
                        .padding(.vertical, 4)
                        .id(message.id)
                    }

                    // Typing indicator aligned like bot responses
                    if client.isAgentResponding {
                        HStack {
                            TypingBubbleView()
                        }
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                        .padding(.leading, 40)
                        .padding(.trailing, 60)
                        .padding(.vertical, 4)
                        .id("typing-indicator")
                    }
                }
                .padding(.bottom)
                .onChange(of: client.messages.count) { _ in
                    if let lastMessage = client.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: client.isAgentResponding) { isTyping in
                    if isTyping {
                        withAnimation {
                            proxy.scrollTo("typing-indicator", anchor: .bottom)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Chat View
struct ChatView: View {
    @ObservedObject var client: ClientSDK
    @Binding var showChat: Bool
    @State private var recognizedText: String = ""
    @State private var userMessage: String = ""
    @State private var isBotResponding: Bool = false
    @Binding var isSpeechEnabled: Bool
    
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
                MessagesListView(client: client)
                
                // Input area - always at bottom
                if client.isInitialized {
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            TextField("Type a message", text: $userMessage)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .textFieldStyle(PlainTextFieldStyle())
                            
                            Button(action: {
                                Task {
                                    await client.sendMessage(text: userMessage)
                                    userMessage = ""
                                    isBotResponding = true
                                    try? client.stopSpeaking()
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
                            .disabled(userMessage.isEmpty)
                            
                            if(isSpeechEnabled){
                                MicrophoneButton(client: client)
                            }
                        }
                        .padding()
                        .background(Color.white)
                    }
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Sign In View
struct SignInView: View {
    @State private var isSigningIn = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack {
                if isSigningIn {
                    Spacer()
                    ProgressView("Signing in...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                } else {
                    Spacer()
                    Text("Sign in to Microsoft to continue")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer().frame(height: 24)
                    Button(action: {
                        AgentsClientSdk.shared.authHandler.signIn()
                        isSigningIn = true
                    }) {
                        Text("Sign in")
                            .font(.headline)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - Main App View
struct MainAppView: View {
    @ObservedObject var client: ClientSDK
    @Binding var showChat: Bool
    @Binding var isSpeechEnabled : Bool
    @StateObject private var keyboardManager = KeyboardManager()
    
    var body: some View {
        ZStack (alignment: .top){
            // Background image
            Image("appbackground")
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
                        ChatView(client: client, showChat: $showChat, isSpeechEnabled: $isSpeechEnabled)
                            .frame(
                                width: UIScreen.main.bounds.width * 0.9,
                                height: min(UIScreen.main.bounds.height * 0.65, 500)
                            )
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(radius: 10)
                            .transition(.move(edge: .bottom))
                    }
                    .offset(y: -keyboardManager.keyboardOffset)
                    .animation(.easeOut(duration: 0.3), value: keyboardManager.keyboardOffset)
                    .ignoresSafeArea()
                }
                
                // Bottom chat button
                VStack(spacing: 0){
                    Spacer()
                    HStack(spacing: 0){
                        Spacer()
                        HStack(spacing: 0) {
                            ChatToggleButton(showChat: $showChat)
                            if (isSpeechEnabled){
                                MicrophoneButton(client: client)
                            }
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
        .onAppear {
            isSpeechEnabled = AgentsClientSdk.shared.isSpeechEnabled
            print("isSpeechEnabled: \(isSpeechEnabled)")
        }
    }
}

// MARK: - Content View (Main Entry Point)
struct ContentView: View, IAuthenticationUI {
    
    @State private var client: ClientSDK?
    @State private var showChat = false
    @State private var appSettings: AppSettings?
    @State private var showSignInSheet = false
    @State private var isSignInLoading = false
    @State private var isSpeechEnabled = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isInitialized = false
    
    func hideSignInContent() {
        DispatchQueue.main.async {
            self.showSignInSheet = false
        }
    }
    
    func showSignInContent(){
        DispatchQueue.main.async {
            self.showSignInSheet = true
        }
    }
    
    func showSignInLoading() {
        DispatchQueue.main.async {
            self.isSignInLoading = true
        }
    }
    
    func hideSignInLoading() {
        DispatchQueue.main.async {
            self.isSignInLoading = false
        }
    }
    
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
            if let client = client, client.isInitialized {
                MainAppView(client: client, showChat: $showChat, isSpeechEnabled: $isSpeechEnabled)
            } else if isSignInLoading {
                // Show sign-in loading state
                ProgressView("Signing in...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            } else {
                // Show general loading screen
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }
        }
        .onAppear {
            self.appSettings = loadAppSettings()
            initializeSDK()
        }
        .onChange(of: client?.isInitialized) { oldValue, newValue in
            print("client isInitialized changed to: \(String(describing: newValue))")
            
            switch newValue {
            case .some(true):
                print("Client is now initialized! Applying changes...")
                isSpeechEnabled = AgentsClientSdk.shared.isSpeechEnabled
                hideSignInContent()
            case .some(false):
                print("Client exists but not yet initialized - starting wait loop...")
                Task {
                    await waitforInitialization()
                }
            case .none:
                print("Client is nil")
            }
        }

        .onChange(of: isInitialized) { oldValue, newValue in
            if newValue == true {
                isSpeechEnabled = AgentsClientSdk.shared.isSpeechEnabled
                hideSignInContent()
            }
        }
        
        .sheet(isPresented: $showSignInSheet) {
            // sign-in sheet if the primary sign-in fails
            SignInView()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("Dismiss") {
                // Exit the app equivalent to finishAffinity()
                exit(0)
            }
        } message: {
            Text(errorMessage)
        }
    }

    private func waitforInitialization() async {
        while self.client?.isInitialized != true {
                try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
                
                // Safety check to prevent infinite loop
                if client == nil {
                    print("Client became nil, stopping wait loop")
                    break
                }
            }
            
            // Update the local state when initialization is complete
            if client?.isInitialized == true {
                await MainActor.run {
                    self.isInitialized = true
                }
            }
    }
    
    private func initializeSDK() {
        guard let appSettings = self.appSettings else { return }
        // Check if SDK is already initialized
        if !AgentsClientSdk.shared.isInitialized {
            Task {
                do {
                    self.client = try await AgentsClientSdk.shared.initSDK(authenticationDelegate:self, appSettings: appSettings)
                    // If client is still nil after initialization, try to get it from shared SDK
                   if self.client == nil {
                       self.client = AgentsClientSdk.shared.client
                   }
                } catch let error as SDKError {
                    let errorMsg = "\(error.errorCode): \(error.localizedDescription)"
                    print("ContentView Error: \(errorMsg)")
                    await MainActor.run {
                        showToast(errorMsg)
                    }
                } catch {
                    print("ContentView Error: \(error)")
                    await MainActor.run {
                        showToast("Initialization failed: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func getPresentingViewController() async -> UIViewController? {
        // Ensure we're on the main thread when accessing UIWindow
        return await MainActor.run {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                return nil
            }
            return windowScene.windows.first?.rootViewController
        }
    }

    func showToast(_ message: String){
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showErrorAlert = true
        }
    }
}

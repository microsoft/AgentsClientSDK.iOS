//
//  PluggableChatComponent.swift
//  sampleApp
//
//  Created by Prachi Pachankar on 14/12/25.
//

import SwiftUI
import AgentsClientSDK

/// A self-contained, pluggable chat component that can be easily integrated into any SwiftUI app
///
/// Usage Example:
/// ```swift
/// PluggableChatComponent(
///     client: yourClientSDK,
///     isPresented: $showChat,
///     position: .bottomRight,
///     appearance: .modern
/// )
/// ```
public struct PluggableChatComponent: View {
    // MARK: - Public Properties
    @ObservedObject public var client: ClientSDK
    @Binding public var isPresented: Bool
    
    public var position: ChatPosition = .bottomRight
    public var appearance: ChatAppearance = .modern
    public var customization: ChatCustomization = .default
    
    // MARK: - Private State
    @State private var userMessage: String = ""
    @State private var isSpeechEnabled: Bool = false
    @StateObject private var keyboardManager = KeyboardManager()
    
    // MARK: - Initializer
    public init(
        client: ClientSDK,
        isPresented: Binding<Bool>,
        position: ChatPosition = .bottomRight,
        appearance: ChatAppearance = .modern,
        customization: ChatCustomization = .default
    ) {
        self.client = client
        self._isPresented = isPresented
        self.position = position
        self.appearance = appearance
        self.customization = customization
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            if isPresented {
                // Overlay background - tap to close (optional, can be disabled via customization)
                if customization.overlayOpacity > 0 {
                    Color.black.opacity(customization.overlayOpacity)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.3)) {
                                isPresented = false
                            }
                        }
                }
                
                // Chat window
                chatWindow
                    .transition(transitionStyle)
            }
            
            // Floating Action Button
            if !isPresented && customization.showFloatingButton {
                floatingActionButton
            }
        }
    }
    
    // MARK: - Chat Window
    private var chatWindow: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader
            
            // Messages
            MessagesView(client: client)
            
            // Input area
            if client.isInitialized {
                chatInputArea
            }
        }
        .frame(
            width: customization.width,
            height: dynamicHeight
        )
        .background(appearance.backgroundColor)
        .cornerRadius(customization.cornerRadius)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.trailing, 25)
        .padding(.top, 10)
        .position(windowPosition)
        .animation(.easeOut(duration: 0.3), value: keyboardManager.keyboardHeight)
    }
    
    // MARK: - Chat Header
    private var chatHeader: some View {
        ZStack {
            appearance.headerGradient
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(customization.botName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("Online")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.3)) {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .frame(height: 80)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Chat Input Area
    private var chatInputArea: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "message.fill")
                        .foregroundColor(.gray.opacity(0.6))
                        .font(.system(size: 16))
                    
                    TextField(customization.inputPlaceholder, text: $userMessage)
                        .textFieldStyle(PlainTextFieldStyle())
                        .font(.body)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(userMessage.isEmpty ? Color.clear : appearance.accentColor.opacity(0.3), lineWidth: 1.5)
                )
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: userMessage.isEmpty ?
                                        [Color.gray.opacity(0.5), Color.gray.opacity(0.4)] :
                                        appearance.sendButtonGradient),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(userMessage.isEmpty)
                .shadow(color: userMessage.isEmpty ? .clear : appearance.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                .animation(.easeInOut(duration: 0.2), value: userMessage.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Floating Action Button
    private var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                if position == .bottomLeft || position == .topLeft {
                    fabButton
                    Spacer()
                } else {
                    Spacer()
                    fabButton
                }
            }
            .padding(position.buttonPadding)
        }
    }
    
    private var fabButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPresented.toggle()
            }
        }) {
            ZStack {
                Circle()
                    .fill(appearance.fabGradient)
                    .frame(width: customization.fabSize, height: customization.fabSize)
                    .shadow(color: appearance.accentColor.opacity(0.4), radius: 12, x: 0, y: 6)
                
                Image(systemName: customization.fabIcon)
                    .font(.system(size: customization.fabSize * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Helper Methods
    private func sendMessage() {
        let messageToSend = userMessage
        userMessage = ""
        Task {
            await client.sendMessage(text: messageToSend)
        }
    }
    
    private var dynamicHeight: CGFloat {
        if keyboardManager.keyboardHeight > 0 {
            return UIScreen.main.bounds.height - keyboardManager.keyboardHeight - 65
        }
        return customization.height
    }
    
    private var windowPosition: CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let yOffset: CGFloat = keyboardManager.keyboardHeight > 0 ?
            120 + (dynamicHeight / 2) :
            position.yPosition(screenHeight: screenHeight, chatHeight: dynamicHeight)
        
        return CGPoint(
            x: screenWidth / 2,
            y: yOffset
        )
    }
    
    private var transitionStyle: AnyTransition {
        switch position {
        case .bottomRight, .bottomLeft:
            return .asymmetric(
                insertion: .move(edge: .bottom).combined(with: .opacity),
                removal: .move(edge: .bottom).combined(with: .opacity)
            )
        case .topRight, .topLeft, .center:
            return .asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            )
        }
    }
}

// MARK: - Messages View
private struct MessagesView: View {
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(client.messages) { message in
                        MessageBubbleView(message: message, client: client)
                            .id(message.id)
                    }
                    
                    if client.isAgentResponding {
                        TypingIndicatorView()
                            .id("typing-indicator")
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 12)
                .onChange(of: client.messages.count) { _ in
                    if let lastMessage = client.messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: client.isAgentResponding) { isTyping in
                    if isTyping {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo("typing-indicator", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - Message Bubble View
private struct MessageBubbleView: View {
    let message: AgentsClientSDK.ChatMessage
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        HStack {
            if message.sender == "User" { Spacer() }
            
            VStack(alignment: message.sender == "User" ? .trailing : .leading) {
                Text(message.sender)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                
                // Adaptive Card rendering
                if let customView = message.customView {
                    AdaptiveCardViewRepresentable(customView: customView)
                        .frame(maxWidth: 280, idealHeight: 300)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                        .padding(.bottom, 2)
                }
                // Image rendering
                else if let imageUrl = message.imageUrl {
                    AsyncImage(url: URL(string: imageUrl)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 150, height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 250, maxHeight: 250)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        case .failure:
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("Image not available")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 150, height: 150)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                // Text message rendering
                else if let text = message.text {
                    Text(text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(messageBubbleBackground)
                        .foregroundColor(message.sender == "User" ? .white : .primary)
                        .cornerRadius(18)
                        .shadow(color: message.sender == "User" ? Color.blue.opacity(0.3) : Color.black.opacity(0.1),
                               radius: 8, x: 0, y: 4)
                }
                
                // Suggested Actions rendering
                if let actions = message.suggestedActions, !actions.isEmpty, message.id == client.messages.last?.id {
                    let columns = [GridItem(.adaptive(minimum: 100), spacing: 8)]
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                        ForEach(actions, id: \.self) { actionTitle in
                            Button(action: {
                                Task {
                                    await client.sendMessage(text: actionTitle)
                                }
                            }) {
                                Text(actionTitle)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.1)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                                    .shadow(color: .blue.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .frame(maxWidth: 280, alignment: message.sender == "User" ? .trailing : .leading)
            
            if message.sender == "Bot" { Spacer() }
        }
        .padding(.vertical, 2)
    }
    
    @ViewBuilder
    private var messageBubbleBackground: some View {
        if message.sender == "User" {
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Typing Indicator View
private struct TypingIndicatorView: View {
    @State private var circleCount = 1
    @State private var timer: Timer?
    @State private var isIncreasing = true
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        HStack {
            HStack(spacing: 6) {
                ForEach(0..<circleCount, id: \.self) { index in
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 7, height: 7)
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeInOut(duration: 0.2)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.1),
                            value: pulseScale
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray5), Color(.systemGray6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(18)
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            Spacer()
        }
        .padding(.leading, 12)
        .onAppear {
            pulseScale = 1.3
            timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isIncreasing {
                        circleCount += 1
                        if circleCount >= 4 { isIncreasing = false }
                    } else {
                        circleCount -= 1
                        if circleCount <= 1 { isIncreasing = true }
                    }
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

// MARK: - Configuration Types

/// Position of the chat window on screen
public enum ChatPosition {
    case bottomRight
    case bottomLeft
    case topRight
    case topLeft
    case center
    
    var buttonPadding: EdgeInsets {
        switch self {
        case .bottomRight:
            return EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 20)
        case .bottomLeft:
            return EdgeInsets(top: 0, leading: 20, bottom: 50, trailing: 0)
        case .topRight:
            return EdgeInsets(top: 100, leading: 0, bottom: 0, trailing: 20)
        case .topLeft:
            return EdgeInsets(top: 100, leading: 20, bottom: 0, trailing: 0)
        case .center:
            return EdgeInsets(top: 0, leading: 0, bottom: 50, trailing: 20)
        }
    }
    
    func yPosition(screenHeight: CGFloat, chatHeight: CGFloat) -> CGFloat {
        switch self {
        case .bottomRight, .bottomLeft:
            return screenHeight - chatHeight/2 - 100
        case .topRight, .topLeft:
            return 120 + chatHeight/2
        case .center:
            return screenHeight / 2
        }
    }
}

/// Appearance theme for the chat
public enum ChatAppearance {
    case modern
    case minimal
    case vibrant
    case custom(primary: Color, secondary: Color, background: Color)
    
    var headerGradient: LinearGradient {
        switch self {
        case .modern:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .minimal:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.8), Color.gray.opacity(0.6)]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .vibrant:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.orange]),
                startPoint: .leading,
                endPoint: .trailing
            )
        case .custom(let primary, let secondary, _):
            return LinearGradient(
                gradient: Gradient(colors: [primary, secondary]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
    
    var fabGradient: LinearGradient {
        switch self {
        case .modern:
            return LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .minimal:
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .vibrant:
            return LinearGradient(
                gradient: Gradient(colors: [Color.pink, Color.orange]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .custom(let primary, let secondary, _):
            return LinearGradient(
                gradient: Gradient(colors: [primary, secondary]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    var sendButtonGradient: [Color] {
        switch self {
        case .modern:
            return [Color.blue, Color.purple.opacity(0.8)]
        case .minimal:
            return [Color.gray, Color.gray.opacity(0.8)]
        case .vibrant:
            return [Color.pink, Color.orange]
        case .custom(let primary, let secondary, _):
            return [primary, secondary]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .modern:
            return .blue
        case .minimal:
            return .gray
        case .vibrant:
            return .pink
        case .custom(let primary, _, _):
            return primary
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .modern, .minimal, .vibrant:
            return .white
        case .custom(_, _, let background):
            return background
        }
    }
}

/// Customization options for the chat component
public struct ChatCustomization {
    public var width: CGFloat
    public var height: CGFloat
    public var cornerRadius: CGFloat
    public var overlayOpacity: Double
    public var fabSize: CGFloat
    public var fabIcon: String
    public var showFloatingButton: Bool
    public var botName: String
    public var inputPlaceholder: String
    
    public static let `default` = ChatCustomization(
        width: UIScreen.main.bounds.width * 0.9,
        height: UIScreen.main.bounds.height * 0.65,
        cornerRadius: 16,
        overlayOpacity: 0.0,
        fabSize: 64,
        fabIcon: "message.fill",
        showFloatingButton: true,
        botName: "Contoso Bot",
        inputPlaceholder: "Type your message..."
    )
    
    public init(
        width: CGFloat = UIScreen.main.bounds.width * 0.9,
        height: CGFloat = UIScreen.main.bounds.height * 0.65,
        cornerRadius: CGFloat = 16,
        overlayOpacity: Double = 0.3,
        fabSize: CGFloat = 64,
        fabIcon: String = "message.fill",
        showFloatingButton: Bool = true,
        botName: String = "Contoso Bot",
        inputPlaceholder: String = "Type your message..."
    ) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
        self.overlayOpacity = overlayOpacity
        self.fabSize = fabSize
        self.fabIcon = fabIcon
        self.showFloatingButton = showFloatingButton
        self.botName = botName
        self.inputPlaceholder = inputPlaceholder
    }
}

// MARK: - Keyboard Manager
private class KeyboardManager: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
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
                            self.keyboardHeight = keyboardFrame.height
                        } else {
                            self.keyboardHeight = 0
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
private struct AdaptiveCardViewRepresentable: UIViewControllerRepresentable {
    let customView: UIView
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.autoresizingMask = [.flexibleHeight]
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
        // Coordinator for handling adaptive card interactions if needed
    }
}

// Import Combine for keyboard manager
import Combine

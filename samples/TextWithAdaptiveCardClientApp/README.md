# AgentsClientSDK Integration Guide

This document outlines the steps taken to integrate the AgentsClientSDK into the TextWithAdaptiveCardClientApp iOS application.

## Overview

This SwiftUI-based iOS application demonstrates the integration of Microsoft's AgentsClientSDK, enabling AI-powered chat functionality with support for authentication, speech services, and adaptive card rendering.

## Prerequisites

- Xcode 26.0.1 or later
- iOS deployment target
- Swift 5.x
- AgentsClientSDK.xcframework
- MSAL.xcframework (for authentication)
- MicrosoftCognitiveServicesSpeech.xcframework (for speech capabilities)

## Integration Steps

### 1. Project Setup

Created a new SwiftUI iOS project named "TextWithAdaptiveCardClientApp" with the following structure:
- `TextWithAdaptiveCardClientAppApp.swift` - Main app entry point
- `ContentView.swift` - Main view controller with SDK initialization
- `PluggableChatComponent.swift` - Reusable chat UI component
- `appsettings.json` - Configuration file for SDK settings

### 2. Framework Integration

#### Added Required Frameworks

Added the following frameworks to the Xcode project:

1. **AgentsClientSDK.xcframework**
   - Source: [https://github.com/microsoft/AgentsClientSDK.iOS/releases](https://github.com/microsoft/AgentsClientSDK.iOS/releases)
   - Download the latest release from GitHub
   - Extract and locate the `AgentsClientSDK.xcframework`
   - Embedded & signed in the app bundle

2. **MSAL.xcframework** (Microsoft Authentication Library)
   - Source: [https://github.com/AzureAD/microsoft-authentication-library-for-objc/releases/download/2.4.0/MSAL.zip](https://github.com/AzureAD/microsoft-authentication-library-for-objc/releases/download/2.4.0/MSAL.zip)
   - Download and extract the signed zip file
   - Version: 2.4.0
   - Required for authentication functionality
   - Embedded & signed in the app bundle

3. **MicrosoftCognitiveServicesSpeech.xcframework**
   - Source: [https://aka.ms/csspeech/iosbinary](https://aka.ms/csspeech/iosbinary)
   - Download and extract the framework
   - Version: 1.47.0
   - Provides speech-to-text and text-to-speech capabilities
   - Added to Frameworks build phase

#### Project Configuration

Updated `project.pbxproj` to include:
- Framework search paths
- Embed Frameworks build phase
- Framework references with proper code signing attributes
- Resource files (LICENSE.md, ThirdPartyNotices.md, REDIST.txt)

### 3. Configuration File Setup

Created `appsettings.json` with the following structure:

```json
{
    "user": {
        "environmentId": "your-environment-id",
        "schemaName": "your-schema-name",
        "environment": "prod",
        "isAuthEnabled": false,
        "auth": {
            "clientId": "",
            "tenantId": "",
            "redirectUri": ""
        }
    },
    "speech": {
        "enabled": false,
        "speechSubscriptionKey": "",
        "speechServiceRegion": ""
    },
    "voiceLive": {
        "enabled": false,
        "useSpeechToSpeech": false,
        "endpoint": "",
        "apiKey": ""
    }
}
```

**Note**: The `appsettings.json` file is excluded from the compile sources build phase and is added as a resource bundle.

### 4. SDK Initialization (ContentView.swift)

#### Implemented IAuthenticationUI Protocol

```swift
struct ContentView: View, IAuthenticationUI {
    // Required protocol methods
    func hideSignInContent()
    func showSignInContent()
    func showSignInLoading()
    func hideSignInLoading()
    func getPresentingViewController() async -> UIViewController?
    func showToast(_ message: String)
}
```

#### SDK Initialization Flow

1. **Load Configuration**:
   ```swift
   private func loadAppSettings() -> AppSettings? {
       guard let url = Bundle.main.url(
           forResource: "appsettings",
           withExtension: "json"
       ) else { return nil }
       
       let data = try Data(contentsOf: url)
       return try JSONDecoder().decode(AppSettings.self, from: data)
   }
   ```

2. **Initialize SDK**:
   ```swift
   private func initializeSDK() {
       Task {
           do {
               self.client = try await AgentsClientSdk.shared.initSDK(
                   authenticationDelegate: self,
                   appSettings: appSettings
               )
           } catch let error as SDKError {
               // Handle SDK-specific errors
           }
       }
   }
   ```

3. **Wait for Initialization**:
   ```swift
   private func waitforInitialization() async {
       while self.client?.isInitialized != true {
           try? await Task.sleep(nanoseconds: 100_000_000)
       }
   }
   ```

4. **Monitor Initialization State**:
   ```swift
   .onChange(of: client?.isInitialized) { oldValue, newValue in
       switch newValue {
       case .some(true):
           isSpeechEnabled = AgentsClientSdk.shared.isSpeechEnabled
           hideSignInContent()
       case .some(false):
           Task { await waitforInitialization() }
       case .none:
           print("Client is nil")
       }
   }
   ```

### 5. Chat Component Implementation (PluggableChatComponent.swift)

Created a fully-featured, pluggable chat component with:

#### Key Features

1. **Flexible Positioning**: Bottom-right, bottom-left, top-right, top-left, or center
2. **Multiple Appearance Themes**: Modern, minimal, vibrant, or custom
3. **Customization Options**: Width, height, colors, bot name, etc.
4. **Floating Action Button**: Toggle chat visibility
5. **Message Types Support**:
   - Text messages
   - Images (with AsyncImage)
   - Adaptive Cards (via UIViewControllerRepresentable)
   - Suggested actions/quick replies

#### Component Structure

```swift
public struct PluggableChatComponent: View {
    @ObservedObject public var client: ClientSDK
    @Binding public var isPresented: Bool
    
    public var position: ChatPosition
    public var appearance: ChatAppearance
    public var customization: ChatCustomization
}
```

#### Sub-Components

1. **MessagesView**: Displays chat history with scroll-to-bottom functionality
2. **MessageBubbleView**: Renders individual messages with proper styling
3. **TypingIndicatorView**: Animated typing indicator for bot responses
4. **KeyboardManager**: Handles keyboard appearance and adjusts chat height
5. **AdaptiveCardViewRepresentable**: Wraps UIKit adaptive card views

#### Usage Example

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    position: .bottomRight,
    appearance: .modern,
    customization: .default
)
```

### 6. State Management

#### ContentView State Variables

```swift
@State private var client: ClientSDK?
@State private var showChat = false
@State private var appSettings: AppSettings?
@State private var showSignInSheet = false
@State private var isSignInLoading = false
@State private var isSpeechEnabled = false
@State private var showErrorAlert = false
@State private var errorMessage = ""
@State private var isInitialized = false
```

#### Chat Component State Variables

```swift
@State private var userMessage: String = ""
@State private var isSpeechEnabled: Bool = false
@StateObject private var keyboardManager = KeyboardManager()
```

### 7. Message Handling

#### Sending Messages

```swift
private func sendMessage() {
    let messageToSend = userMessage
    userMessage = ""
    Task {
        await client.sendMessage(text: messageToSend)
    }
}
```

#### Suggested Actions

```swift
ForEach(actions, id: \.self) { actionTitle in
    Button(action: {
        Task {
            await client.sendMessage(text: actionTitle)
        }
    }) {
        Text(actionTitle)
            .padding()
            .background(Color.blue.opacity(0.15))
            .cornerRadius(20)
    }
}
```

### 8. UI/UX Features

#### Keyboard Management

- Auto-adjusts chat window height when keyboard appears
- Smooth animations for keyboard transitions
- Maintains scroll position and visibility

#### Animations

- Slide-in/slide-out transitions for chat window
- Fade animations for overlay
- Smooth scroll animations for new messages
- Typing indicator with pulsing animation

#### Adaptive Layouts

- Responsive to screen sizes
- Dynamic positioning based on configuration
- Support for safe areas and notches

### 9. Error Handling

Implemented comprehensive error handling:

```swift
do {
    self.client = try await AgentsClientSdk.shared.initSDK(
        authenticationDelegate: self,
        appSettings: appSettings
    )
} catch let error as SDKError {
    showToast("\(error.errorCode): \(error.localizedDescription)")
} catch {
    showToast("Initialization failed: \(error.localizedDescription)")
}
```

Alert handling for critical errors:

```swift
.alert("Error", isPresented: $showErrorAlert) {
    Button("Dismiss") {
        exit(0)
    }
} message: {
    Text(errorMessage)
}
```

## Configuration Options

### ChatPosition

- `.bottomRight` - Bottom right corner (default)
- `.bottomLeft` - Bottom left corner
- `.topRight` - Top right corner
- `.topLeft` - Top left corner
- `.center` - Center of screen

### ChatAppearance

- `.modern` - Blue and purple gradient theme
- `.minimal` - Grayscale theme
- `.vibrant` - Pink and orange gradient theme
- `.custom(primary: Color, secondary: Color, background: Color)` - Custom colors

### ChatCustomization

```swift
ChatCustomization(
    width: CGFloat,              // Chat window width
    height: CGFloat,             // Chat window height
    cornerRadius: CGFloat,       // Corner radius for chat window
    overlayOpacity: Double,      // Background overlay opacity
    fabSize: CGFloat,            // Floating action button size
    fabIcon: String,             // SF Symbol name for FAB
    showFloatingButton: Bool,    // Show/hide FAB
    botName: String,             // Display name for bot
    inputPlaceholder: String     // Placeholder text for input field
)
```

## Testing

The project includes test targets:
- `TextWithAdaptiveCardClientAppTests` - Unit tests
- `TextWithAdaptiveCardClientAppUITests` - UI tests

## Dependencies Summary

| Framework | Purpose | Version |
|-----------|---------|---------|
| AgentsClientSDK | Core AI agent functionality | Latest |
| MSAL | Microsoft Authentication | Latest |
| MicrosoftCognitiveServicesSpeech | Speech services | 1.47.0 |

## Build Configuration

- **Framework Search Paths**: Configured to locate XCFrameworks
- **Embed & Sign**: All frameworks embedded and signed
- **Build Phases**: Proper ordering of compile sources, frameworks, and resources
- **Code Signing**: Frameworks properly code-signed with developer certificate

## Authentication

The SDK supports both authenticated and unauthenticated modes:

- Set `isAuthEnabled: false` for anonymous access
- Set `isAuthEnabled: true` and provide `clientId`, `tenantId`, and `redirectUri` for authenticated access
- Implement `IAuthenticationUI` protocol methods to handle authentication UI flows

## Speech Integration

Optional speech capabilities:

- Set `speech.enabled: true` to enable speech recognition
- Provide `speechSubscriptionKey` and `speechServiceRegion`
- Speech status is monitored via `AgentsClientSdk.shared.isSpeechEnabled`

## Best Practices Implemented

1. ✅ **Async/Await Pattern**: Used throughout for SDK operations
2. ✅ **Main Actor Usage**: UI updates properly dispatched to main thread
3. ✅ **Observable Pattern**: Using `@ObservedObject` and `@StateObject` for reactive UI
4. ✅ **Resource Management**: Proper cleanup of keyboard observers
5. ✅ **Error Handling**: Comprehensive try-catch blocks with user-friendly messages
6. ✅ **Type Safety**: Strong typing with Swift protocols and generics
7. ✅ **Code Organization**: Clear separation of concerns with MARK comments
8. ✅ **Reusability**: Chat component designed as a pluggable module
9. ✅ **Accessibility**: Using semantic SF Symbols and standard UI patterns
10. ✅ **Performance**: Lazy loading of views and efficient state management

## Known Limitations

- `appsettings.json` must be in the main bundle
- Speech services require additional Azure subscription keys
- Authentication requires proper Azure AD app registration
- Adaptive Cards require UIKit bridge for rendering in SwiftUI

## Next Steps

1. Configure your own `environmentId` and `schemaName` in `appsettings.json`
2. Enable authentication if required and provide Azure AD credentials
3. Enable speech services if needed and provide Azure Speech Service keys
4. Customize chat appearance and behavior using provided configuration options
5. Build and run the app on a physical device or simulator

## Support

For SDK-specific issues, refer to the AgentsClientSDK documentation.
For app-specific questions, contact the development team.

## License

See `LICENSE.md` and `ThirdPartyNotices.md` for framework licenses.

---

**Created**: December 14, 2025  
**Last Updated**: December 15, 2025  
**Author**: Prachi Pachankar

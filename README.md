# Welcome to AgentsClientSDK.iOS

We make it easy for you to have multi modal interactions with the agents created through Microsoft
Copilot Studio (MCS) and Agents SDK.

You can now text and talk to your agent.
There are exciting new updates coming up. 

Currently, our SDK is only available for private preview and will have to be included as a local
build dependency. We will very soon be available on major package managers/ repositories - ex. SPM

Follow along to add the iOS SDK to your app for multimodal agent interactions.

## Getting started with iOS

This tutorial will help you connect with an agent created and published in Copilot Studio without authentication.
The SDK connects to agents using Directline protocol, which enables anonymous text based agent
interactions through websockets.

To ensure a smooth and successful integration of the SDK with your application, please make sure your development environment meets the following prerequisites.

#### Target device supported 

- iOS 14.0+

#### Dev Env Prerequisites

- Xcode 12.0+ or later
- iOS deployment target
- Swift 5.x
- AgentsClientSDK.xcframework
- MSAL.xcframework (for authentication)
- MicrosoftCognitiveServicesSpeech.xcframework (for speech capabilities)

#### Swift Language & XCFramework

This SDK is built entirely in **Swift** and distributed as an **XCFramework**

#### XCFramework Structure

XCFramework is Apple's binary distribution format that packages multiple architectures (iOS, macOS, simulator, etc.) into a single bundle for easier library distribution and consumption across different platforms. AgentsClientSDK supports only iOS devices and iOS simulators 


```
AgentsClientSDK.xcframework/
├── ios-arm64/              # Physical iOS devices
├── ios-arm64_x86_64-simulator/  # iOS Simulator
└── Info.plist             # Framework metadata
```

## Integration Steps

### 1. Project Setup

Create a new SwiftUI iOS project with the following structure:
- `YourAppApp.swift` - Main app entry point
- `ContentView.swift` - Main view controller with SDK initialization
- `PluggableChatComponent.swift` - Reusable chat UI component (optional)
- `appsettings.json` - Configuration file for SDK settings

### 2. Framework Integration

#### Add Required Frameworks

Add the following frameworks to your Xcode project:

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

In Xcode, configure your project to:
- Set framework search paths to locate the XCFrameworks
- Add an "Embed Frameworks" build phase
- Ensure frameworks are properly code signed
- Include resource files (LICENSE.md, ThirdPartyNotices.md, REDIST.txt) if using Speech SDK

### 3. Configuration File Setup

Create an `appsettings.json` file in your project with the following structure:

```json
{
    "user": {                       // Contains user and authentication configuration.
        "environmentId": "",          // Unique identifier for the environment in which agent is created. Available in agent Metadata
        "schemaName": "",             // Name of the schema name of agent. Also available in agent Metadata
        "environment": "",            // Specifies the environment (e.g., preprod, prod). Mapping given below
        "isAuthEnabled": false,     // Enables or disables authentication.
        "auth": {                     // Authentication details.
        "clientId": "",             // Application's client ID for authentication.
        "tenantId": "",             // Directory (tenant) ID for authentication.
        "redirectUri": ""           // URI to redirect after authentication.
        }
    },
    "speech": {                     // Contains "ACogs" speech service configuration.
        "enabled": false,           // Enables or disables speech features.
        "speechSubscriptionKey": "",  // API key for the speech service.
        "speechServiceRegion": ""     // Region for the speech service.
    },
        "voiceLive": {          // Contains "VoiceLive" speech service configuration.
            "enabled": false,     // Enables or disables speech features enabled with VoiceLive.
            "useSpeechToSpeech": false,  // Enables premium voice if true. Default is Basic
            "endpoint": "",
            "apiKey": ""
        }
}
```

**Important**: Ensure the `appsettings.json` file is added to your app bundle as a resource (not in compile sources).

### 4. Initialize SDK on App Launch

In your `ContentView.swift`, initialize the SDK when the view appears:

```swift
var body: some View {
    ZStack {
        // Your main content
    }
    .onAppear {
        self.appSettings = loadAppSettings()
        initializeSDK()
    }
}
```

### 5. Implement IAuthenticationUI Protocol

Your ContentView must implement the `IAuthenticationUI` protocol

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
        guard
            let url = Bundle.main.url(
                forResource: "appsettings",
                withExtension: "json"
            )
        else {
            print("Could not find appsettings.json file in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let appSettings = try JSONDecoder().decode(
                AppSettings.self,
                from: data
            )
            return appSettings
        } catch {
            print("Error loading or parsing appsettings.json: \(error)")
            return nil
        }
    }
   ```

2. **Initialize SDK**:
   ```swift
   private func initializeSDK() {
       guard let appSettings = self.appSettings else { return }
        // Check if SDK is already initialized
        if !AgentsClientSdk.shared.isInitialized {
            Task {
                do {
                    self.client = try await AgentsClientSdk.shared.initSDK(
                        authenticationDelegate: self,
                        appSettings: appSettings
                    )
                    // If client is still nil after initialization, try to get it from shared SDK
                    if self.client == nil {
                        self.client = AgentsClientSdk.shared.client
                    }
                } catch let error as SDKError {
                    let errorMsg =
                        "\(error.errorCode): \(error.localizedDescription)"
                    print("ContentView Error: \(errorMsg)")
                    await MainActor.run {
                        print(errorMsg)
                    }
                } catch {
                    print("ContentView Error: \(error)")
                    await MainActor.run {
                        print(
                            "Initialization failed: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }
   }
   ```

3. **Wait for Initialization**:
   ```swift
   private func waitforInitialization() async {
       while self.client?.isInitialized != true {
            try? await Task.sleep(nanoseconds: 100_000_000)  // 100ms

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
   ```
4. **Invoke initialize SDK**:
   ```swift
   .onAppear {
            self.appSettings = loadAppSettings()
            initializeSDK()
        }
   ```

5. **Monitor Initialization State**:
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

### 6. Integrate Chat UI Component (Optional)

You can use the provided `PluggableChatComponent` - a reusable chat UI component that integrates into your application with minimal setup.

**Reference Implementation**: See the complete sample at  
`samples/TextWithAdaptiveCardClientApp/TextWithAdaptiveCardClientApp/PluggableChatComponent.swift`

#### Usage

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    position: .bottomRight,
    appearance: .modern,
    customization: .default
)
```
For more details check samples/TextWithAdaptiveCardClientApp/PLUGGABLE_CHAT_README.md 

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

### 8. Handle SDK Errors

Implement proper error handling to catch SDK initialization and runtime errors:

**Handle SDK-specific errors:**
```swift
do {
    self.client = try await AgentsClientSdk.shared.initSDK(
        authenticationDelegate: self,
        appSettings: appSettings
    )
} catch let error as SDKError {
    // Handle SDK-specific errors with error code and description
    showToast("\(error.errorCode): \(error.localizedDescription)")
} catch {
    // Handle general initialization errors
    showToast("Initialization failed: \(error.localizedDescription)")
}
```

**Display critical errors to users:**
```swift
.alert("Error", isPresented: $showErrorAlert) {
    Button("Dismiss") {
        exit(0)
    }
} message: {
    Text(errorMessage)
}
```

**Best Practice:** Always provide user-friendly error messages and handle both `SDKError` and general exceptions appropriately.

## Configuration Options

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

## Troubleshooting

### Common Issues

1. **Bot communication issues**: Verify network connectivity and app settings.

Thats the essence of it.
The TextClientApp in samples folder of this repository provides a complete implementation. Do
check it out.

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the
instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted
the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see
the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or
comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of
Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion
or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

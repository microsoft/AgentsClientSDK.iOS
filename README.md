# Welcome to AgentsClientSDK.iOS

We make it easy for you to have multi modal interactions with the agents created through Microsoft
Copilot Studio (MCS) and Agents SDK.

You can now text and talk to your agent.
There are exciting new updates coming up. 

Currently, our SDK is only available for private preview and will have to be included as a local
build dependency. We will very soon be available on major package managers/ repositories - ex. SPM

Follow along to add the iOS SDK to your app for multimodal agent interactions.

## Getting started with iOS

This tutorial will help you connect with an agent created in Copilot Studio and published to custom
website or mobile app, without authentication.
The SDK connects to agents using Directline protocol, which enables anonymous text based agent
interactions through websockets.
You will need the following:

1. Bot schema name
2. Environment Id
3. tenant Id
4. environment

## Requirements

- iOS 14.0+
- Xcode 12.0+
- Swift 5.0+

#### Swift Language & XCFramework

This SDK is built entirely in **Swift** and distributed as an **XCFramework**

#### XCFramework Structure
```
AgentsClientSDK.xcframework/
├── ios-arm64/              # Physical iOS devices
├── ios-arm64_x86_64-simulator/  # iOS Simulator
└── Info.plist             # Framework metadata
```

### XCFramework Integration 

1. Download the `AgentsClientSDK.xcframework` from https://github.com/microsoft/AgentsClientSDK.iOS/releases/
2. Drag it into your Xcode project
3. Add to "Frameworks, Libraries, and Embedded Content"
4. Set to "Embed & Sign"

### API Reference

#### Core Methods

##### `initSDK(viewController:appSettings:authToken:)`
Initialize the SDK with required parameters.

##### `sendMessage(text:) async`
Send a text message to the bot asynchronously.

### Available Properties

##### Published Properties (Observable)

- `userMessage: String` - Current user input message
- `userToken: String` - Current authentication token
- `messages: [ChatMessage]` - Array of chat messages
- `isBotResponding: Bool` - Whether bot is currently responding

### Step 1: Include in build

Include the AgentsClientSDK.xcframework file as a dependency, along with the following
dependencies

```
MSAL.xcframework : https://github.com/AzureAD/microsoft-authentication-library-for-objc/releases/download/2.1.0/MSAL.zip
```

### Step 2: Import multimodal classes in your main activity

``` 
import AgentsClientSDK
```

### Step 3: Connection to SDK is initialized like so

``` 
    @StateObject var viewModel = MultimodalClientSdk.shared

    let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    if let rootViewController = windowScene?.windows.first?.rootViewController {
        viewModel.initSDK(
            viewController: rootViewController,
            appSettings: self.appSettings!
        )
    }

```

### Step 4: Add this function to load appsettings.json to AppSettings

``` 
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

```

### Step 4: Chat window for Rendering message
#### Published Messages Array within Sdk
```swift
@Published public var messages: [ChatMessage] = []
```

This is the primary storage for chat messages that automatically updates SwiftUI views when modified. It's declared as a `@Published` property, making it observable by SwiftUI components.

### ChatMessage

```swift
public struct ChatMessage: Identifiable {
    public let id: UUID
    public let text: String?
    public let sender: String
    public let imageUrl: String?
    public let customView: UIView?
    public let suggestedActions: [String]?
}
```
#### SwiftUI Integration
```swift
struct ChatView: View {
    @StateObject private var viewModel = MultimodalClientSdk.shared
    
    var body: some View {
        // Automatically updates when messages change
        ForEach(viewModel.messages) { message in
            MessageRow(message: message)
        }
    }
}
```

### Step 5. Send Messages

```swift
// Send a text message to the bot
await viewModel.sendMessage(text: "Hello, how can you help me?")
```

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

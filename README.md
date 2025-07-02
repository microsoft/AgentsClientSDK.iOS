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

### Step 1: Include in build

Include the AgentsClientSDK.xcframework file as a dependency, along with the following
dependencies

```

MSAL.xcframework : https://github.com/AzureAD/microsoft-authentication-library-for-objc/releases/download/2.1.0/MSAL.zip
AgentsClientSDK.xcframework: https://github.com/microsoft/AgentsClientSDK.iOS/releases/
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

### Step 4: Add this function to load config.json to AppSettings

``` 
        // Function to load AppSettings from config.json
    private func loadAppSettings() -> AppSettings? {
        guard let url = Bundle.main.url(forResource: "config", withExtension: "json") else {
            print("Could not find config.json file in bundle")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let appSettings = try JSONDecoder().decode(AppSettings.self, from: data)
            return appSettings
        } catch {
            print("Error loading or parsing config.json: \(error)")
            return nil
        }
    }

```

### Step 4: Chat window for viewing text

Your users can see the text version of the exchange.
To list messages. They are stored in messages.
Can be accessed as in viewModel.messages


### Step 5: Send Message
Below is example on how you can send message to bot

await viewModel.sendMessage(text: viewModel.userMessage)


Thats the essence of it.
The Sample Application in samples folder of this repository provides a complete implementation. Do
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

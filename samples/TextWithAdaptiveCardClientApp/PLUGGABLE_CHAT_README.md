# PluggableChatComponent - Complete Guide

A beautiful, self-contained, and highly customizable chat UI component for SwiftUI apps using AgentsClientSDK.

## 🎯 Overview

`PluggableChatComponent` is a production-ready chat interface that can be dropped into any iOS app with just 3 lines of code. It handles everything from UI rendering to message management, keyboard adjustments, and user interactions.

## ✨ Features

- 🎨 **Beautiful Modern UI** - Gradient themes, smooth animations, polished design
- 🔌 **Plug & Play** - Zero configuration required, works out of the box
- 🎭 **Multiple Themes** - Modern, Minimal, Vibrant, or fully custom
- 📍 **Flexible Positioning** - Place anywhere on screen (5 positions available)
- 💬 **Rich Messages** - Text, adaptive cards, images, suggested actions
- ⌨️ **Smart Keyboard** - Auto-adjusts for keyboard visibility
- 🎪 **Floating Action Button** - Elegant toggle with animations
- 🎨 **Fully Customizable** - Control every aspect of appearance
- 📱 **Responsive** - Adapts to different screen sizes
- ♿ **Accessible** - VoiceOver and accessibility support

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [Installation](#installation)
- [Basic Integration](#basic-integration)
- [Customization](#customization)
  - [Themes](#themes)
  - [Positioning](#positioning)
  - [Styling Options](#styling-options)
  - [Overlay Control](#overlay-control)
- [Advanced Usage](#advanced-usage)
- [Message Types](#message-types)
- [API Reference](#api-reference)
- [Examples](#examples)
- [Troubleshooting](#troubleshooting)

## 🚀 Quick Start

### Simplest Integration (3 lines)

```swift
if let client = client, client.isInitialized {
    PluggableChatComponent(client: client, isPresented: $showChat)
}
```

That's it! You get:
- ✅ Floating action button
- ✅ Beautiful chat window
- ✅ Message bubbles
- ✅ Input field with send button
- ✅ Typing indicators
- ✅ Auto-scroll
- ✅ Keyboard handling

## 📦 Installation

### Step 1: Add the Component File

Copy `PluggableChatComponent.swift` to your Xcode project.

### Step 2: Ensure Dependencies

Make sure you have:
- AgentsClientSDK
- SwiftUI (iOS 15.0+)
- Combine framework

### Step 3: Import Required Frameworks

```swift
import SwiftUI
import AgentsClientSDK
import Combine
```

## 🔧 Basic Integration

### 1. Initialize ClientSDK

```swift
@main
struct YourApp: App {
    @State private var client: ClientSDK?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        client = try? await AgentsClientSdk.shared.initSDK(
                            authenticationDelegate: yourDelegate,
                            appSettings: yourSettings
                        )
                    }
                }
        }
    }
}
```

### 2. Add to Your View

```swift
struct ContentView: View {
    @State private var showChat = false
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        ZStack {
            // Your app content
            YourAppContent()
            
            // Add chat component
            if let client = client, client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showChat
                )
            }
        }
    }
}
```

### 3. Run Your App

Build and run - the floating action button appears automatically!

## 🎨 Customization

### Themes

#### Modern Theme (Default)
Blue and purple gradients with a contemporary look.

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    appearance: .modern
)
```

#### Minimal Theme
Clean grayscale design for professional apps.

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    appearance: .minimal
)
```

#### Vibrant Theme
Bold pink and orange gradients for energetic apps.

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    appearance: .vibrant
)
```

#### Custom Theme
Define your own brand colors.

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    appearance: .custom(
        primary: Color.red,
        secondary: Color.orange,
        background: Color.white
    )
)
```

### Positioning

Place the chat window anywhere on screen:

```swift
// Bottom right (default)
position: .bottomRight

// Bottom left
position: .bottomLeft

// Top right
position: .topRight

// Top left
position: .topLeft

// Center
position: .center
```

**Example:**
```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    position: .bottomLeft
)
```

### Styling Options

Use `ChatCustomization` to control every aspect:

```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    customization: ChatCustomization(
        width: 400,                          // Chat window width
        height: 600,                         // Chat window height
        cornerRadius: 20,                    // Corner radius
        overlayOpacity: 0.5,                 // Background dim (0-1)
        fabSize: 70,                         // Button size
        fabIcon: "bubble.left.fill",         // SF Symbol name
        showFloatingButton: true,            // Show/hide button
        botName: "Support Bot",              // Bot display name
        inputPlaceholder: "Type a message..." // Input hint
    )
)
```

### Overlay Control

Control the grey background overlay:

#### Remove Completely
```swift
customization: ChatCustomization(
    overlayOpacity: 0  // No dimming
)
```

#### Light Dimming
```swift
customization: ChatCustomization(
    overlayOpacity: 0.1  // Very subtle
)
```

#### Strong Dimming
```swift
customization: ChatCustomization(
    overlayOpacity: 0.6  // Strong focus on chat
)
```

## 🎯 Advanced Usage

### Example 1: Customer Support

```swift
struct SupportView: View {
    @State private var showSupport = false
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        ZStack {
            // Your support page
            SupportContent()
            
            // Support chat
            if let client = client, client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showSupport,
                    position: .bottomRight,
                    appearance: .custom(
                        primary: Color.green,
                        secondary: Color.teal,
                        background: Color.white
                    ),
                    customization: ChatCustomization(
                        botName: "Support Assistant",
                        inputPlaceholder: "How can we help?",
                        fabIcon: "questionmark.circle.fill"
                    )
                )
            }
        }
    }
}
```

### Example 2: E-commerce Assistant

```swift
struct ProductView: View {
    @State private var showAssistant = false
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        ZStack {
            // Product details
            ProductDetails()
            
            // Shopping assistant
            if let client = client, client.isInitialized {
                PluggableChatComponent(
                    client: client,
                    isPresented: $showAssistant,
                    position: .bottomLeft,
                    appearance: .vibrant,
                    customization: ChatCustomization(
                        botName: "Shopping Assistant",
                        inputPlaceholder: "Ask about this product...",
                        fabIcon: "cart.fill",
                        overlayOpacity: 0.2
                    )
                )
            }
        }
    }
}
```

### Example 3: Multiple Chat Windows

```swift
struct MultiChatView: View {
    @State private var showSales = false
    @State private var showSupport = false
    @ObservedObject var salesClient: ClientSDK
    @ObservedObject var supportClient: ClientSDK
    
    var body: some View {
        ZStack {
            MainContent()
            
            // Sales chat (bottom-right)
            if let sales = salesClient, sales.isInitialized {
                PluggableChatComponent(
                    client: sales,
                    isPresented: $showSales,
                    position: .bottomRight,
                    appearance: .vibrant,
                    customization: ChatCustomization(
                        botName: "Sales Bot",
                        fabIcon: "dollarsign.circle.fill"
                    )
                )
            }
            
            // Support chat (bottom-left)
            if let support = supportClient, support.isInitialized {
                PluggableChatComponent(
                    client: support,
                    isPresented: $showSupport,
                    position: .bottomLeft,
                    appearance: .modern,
                    customization: ChatCustomization(
                        botName: "Support Bot",
                        fabIcon: "questionmark.circle.fill"
                    )
                )
            }
        }
    }
}
```

### Example 4: Minimal Chat (No FAB)

```swift
struct EmbeddedChatView: View {
    @State private var showChat = true  // Always visible
    @ObservedObject var client: ClientSDK
    
    var body: some View {
        if let client = client, client.isInitialized {
            PluggableChatComponent(
                client: client,
                isPresented: $showChat,
                position: .center,
                appearance: .minimal,
                customization: ChatCustomization(
                    showFloatingButton: false,  // No FAB
                    overlayOpacity: 0           // No overlay
                )
            )
        }
    }
}
```

## 💬 Message Types

The component supports all AgentsClientSDK message types:

### 1. Text Messages
Basic text with styled bubbles (user/bot colors).

```swift
// Automatically rendered when message has text property
```

### 2. Adaptive Cards
Rich interactive cards with buttons, images, and forms.

```swift
// Automatically rendered when message has customView property
// Supports all adaptive card elements
```

### 3. Images
Async image loading with loading/error states.

```swift
// Automatically rendered when message has imageUrl property
// Features:
// - Loading spinner
// - Proper scaling
// - Error placeholder
```

### 4. Suggested Actions
Quick reply buttons below messages.

```swift
// Automatically rendered when message has suggestedActions
// Only shows for the last message in conversation
```

### 5. Typing Indicators
Animated "thinking" state for bot responses.

```swift
// Automatically shown when client.isAgentResponding is true
```

## 📚 API Reference

### PluggableChatComponent

Main component for displaying chat interface.

```swift
public struct PluggableChatComponent: View {
    public init(
        client: ClientSDK,
        isPresented: Binding<Bool>,
        position: ChatPosition = .bottomRight,
        appearance: ChatAppearance = .modern,
        customization: ChatCustomization = .default
    )
}
```

#### Parameters:
- `client` - Initialized ClientSDK instance (required)
- `isPresented` - Binding to control visibility (required)
- `position` - Chat window position (optional, default: `.bottomRight`)
- `appearance` - Visual theme (optional, default: `.modern`)
- `customization` - Detailed styling options (optional, default: `.default`)

### ChatPosition

Position of the chat window on screen.

```swift
public enum ChatPosition {
    case bottomRight  // Bottom right corner
    case bottomLeft   // Bottom left corner
    case topRight     // Top right corner
    case topLeft      // Top left corner
    case center       // Screen center
}
```

### ChatAppearance

Visual theme for the chat interface.

```swift
public enum ChatAppearance {
    case modern                                        // Blue/purple gradient
    case minimal                                       // Grayscale
    case vibrant                                       // Pink/orange gradient
    case custom(primary: Color, secondary: Color, background: Color)
}
```

### ChatCustomization

Detailed customization options.

```swift
public struct ChatCustomization {
    public var width: CGFloat              // Default: 90% of screen width
    public var height: CGFloat             // Default: 65% of screen height
    public var cornerRadius: CGFloat       // Default: 16
    public var overlayOpacity: Double      // Default: 0.3 (0-1)
    public var fabSize: CGFloat            // Default: 64
    public var fabIcon: String             // Default: "message.fill"
    public var showFloatingButton: Bool    // Default: true
    public var botName: String             // Default: "Contoso Bot"
    public var inputPlaceholder: String    // Default: "Type your message..."
}
```

## 🎬 Examples

### Basic Chat
```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat
)
```

### Custom Position & Theme
```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    position: .topRight,
    appearance: .minimal
)
```

### Full Customization
```swift
PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    position: .bottomLeft,
    appearance: .custom(
        primary: Color(red: 0.2, green: 0.4, blue: 0.8),
        secondary: Color(red: 0.4, green: 0.2, blue: 0.8),
        background: Color.white
    ),
    customization: ChatCustomization(
        width: 380,
        height: 550,
        cornerRadius: 24,
        overlayOpacity: 0.4,
        fabSize: 72,
        fabIcon: "message.badge.fill",
        showFloatingButton: true,
        botName: "AI Assistant",
        inputPlaceholder: "Ask me anything..."
    )
)
```

### Brand-Specific Chat
```swift
// Your company colors
let brandPrimary = Color(red: 0.95, green: 0.26, blue: 0.21)
let brandSecondary = Color(red: 1.0, green: 0.59, blue: 0.0)

PluggableChatComponent(
    client: client,
    isPresented: $showChat,
    appearance: .custom(
        primary: brandPrimary,
        secondary: brandSecondary,
        background: .white
    ),
    customization: ChatCustomization(
        botName: "YourCompany Bot",
        inputPlaceholder: "How can YourCompany help?",
        fabIcon: "building.2.fill"
    )
)
```

## 🐛 Troubleshooting

### Issue: "Implicitly unwrapped nil value" error

**Cause:** Passing nil or uninitialized client.

**Solution:** Always check for nil and initialization:
```swift
// ✅ CORRECT
if let client = client, client.isInitialized {
    PluggableChatComponent(client: client, isPresented: $showChat)
}

// ❌ WRONG
PluggableChatComponent(client: client!, isPresented: $showChat)
```

### Issue: Grey overlay won't go away

**Cause:** Default overlay opacity is 0.3.

**Solution:** Set overlay opacity to 0:
```swift
customization: ChatCustomization(
    overlayOpacity: 0
)
```

### Issue: Chat appears behind other views

**Cause:** ZStack ordering or zIndex issues.

**Solution:** Ensure chat is last in ZStack:
```swift
ZStack {
    YourContent()      // First (bottom)
    OtherViews()       // Middle
    PluggableChatComponent(...)  // Last (top)
}
```

Or use explicit zIndex:
```swift
PluggableChatComponent(...)
    .zIndex(999)
```

### Issue: Floating button not appearing

**Cause:** `showFloatingButton` is false or chat is always presented.

**Solution:**
```swift
// Ensure button is enabled
customization: ChatCustomization(
    showFloatingButton: true
)

// And chat is not always shown
@State private var showChat = false  // Must be false initially
```

### Issue: Keyboard covers input

**Cause:** Keyboard handling is automatic, but view might need adjustment.

**Solution:** The component handles this automatically. If issues persist:
```swift
// Wrap in ScrollView if needed
ScrollView {
    YourContent()
}
```

### Issue: Messages not appearing

**Cause:** Client not properly initialized or messages not in client.

**Solution:**
1. Verify client is initialized: `client.isInitialized == true`
2. Check client has messages: `client.messages.count > 0`
3. Ensure message structure matches expected format

### Issue: Adaptive cards not rendering

**Cause:** Missing `customView` property in message.

**Solution:** Ensure your ClientSDK provides `customView`:
```swift
// Message should have:
message.customView != nil  // UIView from adaptive card
```

### Issue: Images not loading

**Cause:** Invalid URL or network issues.

**Solution:**
1. Verify image URL is valid: `URL(string: imageUrl) != nil`
2. Check network permissions in Info.plist
3. Test URL in browser first

## 💡 Best Practices

### 1. Always Check for Nil
```swift
if let client = client, client.isInitialized {
    // Safe to use client
}
```

### 2. Use Meaningful Bot Names
```swift
customization: ChatCustomization(
    botName: "Customer Support"  // Not "Bot" or "Assistant"
)
```

### 3. Match Your Brand
```swift
appearance: .custom(
    primary: YourBrand.primaryColor,
    secondary: YourBrand.secondaryColor,
    background: .white
)
```

### 4. Choose Appropriate Positions
- Customer service: `.bottomRight`
- Shopping help: `.bottomLeft`
- Tutorials: `.center` or `.topRight`

### 5. Adjust Overlay for Context
- Focus mode: `overlayOpacity: 0.5`
- Background integration: `overlayOpacity: 0.1`
- No distraction: `overlayOpacity: 0`

### 6. Use Descriptive Icons
```swift
// Match purpose with icon
fabIcon: "cart.fill"           // Shopping
fabIcon: "questionmark.circle" // Support
fabIcon: "info.circle"         // Information
fabIcon: "message.badge"       // Notifications
```

### 7. Provide Clear Placeholders
```swift
inputPlaceholder: "Ask about shipping..."  // Specific
// Not: "Type here..."  // Generic
```

### 8. Test on Different Devices
- iPhone SE (small screen)
- iPhone Pro Max (large screen)
- iPad (if supporting)

### 9. Handle Loading States
```swift
ZStack {
    if client == nil {
        ProgressView("Loading chat...")
    } else if let client = client, client.isInitialized {
        PluggableChatComponent(...)
    }
}
```

### 10. Monitor Performance
- Keep message history reasonable
- Implement message pagination if needed
- Monitor memory usage with large images

## 🔗 Related Documentation

- **INTEGRATION_GUIDE.md** - Full integration examples
- **NIL_CLIENT_FIX.md** - Troubleshooting nil client issues
- **README.md** - Main project documentation
- **AgentsClientSDK Docs** - Official SDK documentation

## 📝 Changelog

### Version 1.0 (December 2025)
- Initial release
- Modern, minimal, and vibrant themes
- 5 positioning options
- Full customization support
- Adaptive card rendering
- Image support
- Suggested actions
- Typing indicators
- Keyboard handling
- Floating action button

## 📄 License

This component is part of the sampleApp and is provided as-is for demonstration purposes.

## 🤝 Contributing

To improve this component:
1. Test thoroughly on different devices
2. Document any issues or enhancements
3. Follow SwiftUI best practices
4. Maintain backward compatibility

## 📞 Support

For questions or issues:
1. Check this documentation
2. Review troubleshooting section
3. See NIL_CLIENT_FIX.md for common errors
4. Check AgentsClientSDK documentation
5. Review example implementations in `Examples/` folder

---

Made with ❤️ for the AgentsClientSDK community

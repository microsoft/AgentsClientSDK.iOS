//
//  ContentView.swift
//  TextWithAdaptiveCardClientApp
//
//  Created by Prachi Pachankar on 14/12/25.
//

import SwiftUI
import AgentsClientSDK

struct ContentView: View , IAuthenticationUI {
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

    func showSignInContent() {
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

    func getPresentingViewController() async -> UIViewController? {
        // Ensure we're on the main thread when accessing UIWindow
        return await MainActor.run {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene
            else {
                return nil
            }
            return windowScene.windows.first?.rootViewController
        }
    }

    func showToast(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showErrorAlert = true
        }
    }

    // Function to load AppSettings from appsettings.json
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
                        showToast(errorMsg)
                    }
                } catch {
                    print("ContentView Error: \(error)")
                    await MainActor.run {
                        showToast(
                            "Initialization failed: \(error.localizedDescription)"
                        )
                    }
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            if let client = client, client.isInitialized {
                MainContent(client: client, showChat: $showChat)
            } else {
                // Show general loading screen
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
                    .padding()
            }
        }
        .padding()
        .onAppear {
            self.appSettings = loadAppSettings()
            initializeSDK()
        }
        .onChange(of: client?.isInitialized) { oldValue, newValue in
            print(
                "client isInitialized changed to: \(String(describing: newValue))"
            )

            switch newValue {
            case .some(true):
                print("Client is now initialized! Applying changes...")
                isSpeechEnabled = AgentsClientSdk.shared.isSpeechEnabled
                hideSignInContent()
            case .some(false):
                print(
                    "Client exists but not yet initialized - starting wait loop..."
                )
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

        .alert("Error", isPresented: $showErrorAlert) {
            Button("Dismiss") {
                // Exit the app equivalent to finishAffinity()
                exit(0)
            }
        } message: {
            Text(errorMessage)
        }
    }
}

#Preview {
    ContentView()
}

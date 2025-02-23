import SwiftUI

struct ContentView: View {
    @State private var showOnboarding: Bool = true
    
    var body: some View {
        if showOnboarding {
            OnboardingView(showOnboarding: $showOnboarding)
        } else {
            SetupScreen()
        }
    }
}

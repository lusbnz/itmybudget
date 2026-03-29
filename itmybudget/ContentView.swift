import SwiftUI

struct ContentView: View {
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        Group {
            switch appStateManager.currentState {
            case .splash:
                SplashView()
            case .auth:
                AuthView()
            case .onboarding:
                OnboardingView()
            case .main:
                MainTabView()
            }
        }
        .transition(.opacity)
    }
}

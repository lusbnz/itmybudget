import SwiftUI

enum AppFlowState {
    case splash
    case auth
    case onboarding
    case main
}

@Observable
class AppStateManager {
    var currentState: AppFlowState = .auth
    
    func moveToAuth() {
        withAnimation {
            currentState = .auth
        }
    }
    
    func moveToOnboarding() {
        withAnimation {
            currentState = .onboarding
        }
    }
    
    func moveToMain() {
        withAnimation {
            currentState = .main
        }
    }
}

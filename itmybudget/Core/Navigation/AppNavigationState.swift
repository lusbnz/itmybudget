import SwiftUI
import Combine

class AppNavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
}

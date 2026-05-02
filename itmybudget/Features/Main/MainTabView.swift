import SwiftUI

struct MainTabView: View {
    @StateObject private var navState = AppNavigationState()
    @State private var isShowingAddSheet: Bool = false
    @State private var isExpanded: Bool = false
    @State private var initialFormMode: TransactionEntryMode = .manual
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $navState.selectedTab) {
                HomeView()
                    .tabItem {
                        Label("tabs.home".localized, systemImage: "house.fill")
                    }
                    .tag(0)
                
                PlanningView()
                    .tabItem {
                        Label("tabs.planning".localized, systemImage: "calendar.badge.plus")
                    }
                    .tag(1)
                
                HistoryView()
                    .tabItem {
                        Label("tabs.history".localized, systemImage: "clock.arrow.circlepath")
                    }
                    .tag(2)
                
                AnalyticsView()
                    .tabItem {
                        Label("tabs.analytics".localized, systemImage: "chart.bar.xaxis")
                    }
                    .tag(3)
            }
            .tint(.blue)
            
            if isExpanded {
                Color.black.opacity(0.15)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isExpanded = false
                        }
                    }
            }
            
            ExpandableFAB(
                isExpanded: $isExpanded,
                onManual: {
                    isExpanded = false
                    initialFormMode = .manual
                    isShowingAddSheet = true
                },
                onChat: {
                    isExpanded = false
                    initialFormMode = .chat
                    isShowingAddSheet = true
                },
                onCamera: {
                    isExpanded = false
                    initialFormMode = .camera
                    isShowingAddSheet = true
                }
            )
            .padding(.trailing, 20)
            .padding(.bottom, 70)
        }
        .background(Color(red: 1.0, green: 0.97, blue: 0.92).ignoresSafeArea())
        .fullScreenCover(isPresented: $isShowingAddSheet) {
            TransactionFormView(initialMode: initialFormMode)
        }
        .environmentObject(navState)
    }
}

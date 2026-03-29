import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var isShowingAddSheet: Bool = false
    @State private var isExpanded: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    .tag(0)
                
                PlanningView()
                    .tabItem {
                        Label("Planning", systemImage: "calendar.badge.plus")
                    }
                    .tag(1)
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                    .tag(2)
                
                AnalyticsView()
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.xaxis")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person.crop.circle")
                    }
                    .tag(4)
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
                    isShowingAddSheet = true
                },
                onChat: {
                    isExpanded = false
                },
                onCamera: {
                    isExpanded = false
                }
            )
            .padding(.trailing, 20)
            .padding(.bottom, 70)
        }
        .background(Color(red: 1.0, green: 0.97, blue: 0.92).ignoresSafeArea())
        .sheet(isPresented: $isShowingAddSheet) {
            NavigationStack {
                Text("Add New Transaction Page")
                    .navigationTitle("Add Transaction")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                isShowingAddSheet = false
                            }) {
                                Text("Done")
                            }
                        }
                    }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

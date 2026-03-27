import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
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
    }
}

// Placeholder Views for Each Tab
struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Chào mừng Quoc Viet!")
                        .font(.headline)
                    Text("Số dư: 15,000,000₫")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            .navigationTitle("itmybudget")
        }
    }
}

struct PlanningView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Text("Lập kế hoạch ngân sách")
                    .font(.title3)
                    .foregroundStyle(.gray)
                
                Image(systemName: "calendar.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue.opacity(0.3))
                    .padding()
            }
            .navigationTitle("Planning")
        }
    }
}

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<10) { _ in
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Mua sắm")
                                .font(.headline)
                            Text("Hôm nay")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                        Text("-500,000₫")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}

struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.blue.opacity(0.1))
                        .frame(height: 200)
                        .overlay {
                            Text("Biểu đồ phân tích chi tiêu")
                                .foregroundStyle(.blue)
                        }
                        .padding()
                }
            }
            .navigationTitle("Analytics")
        }
    }
}

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.gray)
                        VStack(alignment: .leading) {
                            Text("Quoc Viet")
                                .font(.headline)
                            Text("Premium Member")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Cài đặt") {
                    Label("Tài khoản", systemImage: "person")
                    Label("Thông báo", systemImage: "bell")
                    Label("Bảo mật", systemImage: "lock")
                }
                
                Section {
                    Button(role: .destructive) {
                        // Logout handled by appStateManager
                    } label: {
                        Text("Đăng xuất")
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

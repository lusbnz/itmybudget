import SwiftUI

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let dateEarned: String?
    let color: Color
}

extension Badge {
    static var sampleData: [Badge] {
        [
            Badge(name: "Savings Master", icon: "bolt.shield.fill", description: "Saved 20% of income for 3 months.", dateEarned: "Mar 12, 2026", color: .orange),
            Badge(name: "Budget King", icon: "crown.fill", description: "Stayed within budget for 30 consecutive days.", dateEarned: "Feb 28, 2026", color: .yellow),
            Badge(name: "Smart Spender", icon: "brain.head.profile.fill", description: "Zero emotional purchases detected in a week.", dateEarned: "Jan 15, 2026", color: .blue),
            Badge(name: "Early Bird", icon: "bird.fill", description: "Logged transactions first thing in the morning.", dateEarned: "Jan 10, 2026", color: .green),
            Badge(name: "Goal Crusher", icon: "target", description: "Completely funded your first personal goal.", dateEarned: "Mar 25, 2026", color: .red),
            Badge(name: "Cloud Saver", icon: "icloud.and.arrow.up.fill", description: "Synced backup for the first time.", dateEarned: "Dec 30, 2025", color: .teal),
            
            Badge(name: "Iron Will", icon: "lock.shield.fill", description: "Maintain a budget for 6 consecutive months.", dateEarned: nil, color: .gray),
            Badge(name: "Investor Mind", icon: "chart.line.uptrend.xyaxis", description: "Start an automated investment plan.", dateEarned: nil, color: .gray),
            Badge(name: "Diamond Hand", icon: "suit.diamond.fill", description: "Hold your savings without withdrawals for a year.", dateEarned: nil, color: .gray),
            Badge(name: "Wealth Architect", icon: "building.2.fill", description: "Reach a net worth milestone of $10,000.", dateEarned: nil, color: .gray),
            Badge(name: "Eco Consumer", icon: "leaf.fill", description: "Keep expenses in eco-friendly categories for a month.", dateEarned: nil, color: .gray),
            Badge(name: "Generous Heart", icon: "heart.fill", description: "Donate at least 5% of your income to charity.", dateEarned: nil, color: .gray)
        ]
    }
}

struct BadgeListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    @State private var badges = Badge.sampleData
    
    private var earnedCount: Int {
        badges.filter { $0.dateEarned != nil }.count
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    progressCard
                    
                    badgeSection(title: "Earned", badges: badges.filter { $0.dateEarned != nil })
                    
                    badgeSection(title: "In Progress", badges: badges.filter { $0.dateEarned == nil })
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    showContent = true
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Badges")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
    
    private var progressCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.05), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(earnedCount) / CGFloat(badges.count))
                    .stroke(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(earnedCount)")
                        .font(.system(size: 20, weight: .bold))
                    Text("/\(badges.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 70, height: 70)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Achiever Level")
                    .font(.system(size: 16, weight: .bold))
                Text("Keep saving to unlock more rare badges!")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .offset(y: showContent ? 0 : 15)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private func badgeSection(title: String, badges: [Badge]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(badges) { badge in
                    BadgeCard(badge: badge)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.top, 8)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    private var isUnlocked: Bool { badge.dateEarned != nil }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.12) : Color.gray.opacity(0.05))
                    .frame(width: 64, height: 64)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isUnlocked ? badge.color : .gray.opacity(0.3))
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: 20)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                }
            }
            .padding(.top, 4)
            
            VStack(spacing: 4) {
                Text(badge.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isUnlocked ? .black : .gray)
                    .multilineTextAlignment(.center)
                
                if let date = badge.dateEarned {
                    Text(date)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.green)
                } else {
                    Text(badge.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 24)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

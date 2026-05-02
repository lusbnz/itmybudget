import SwiftUI

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let description: String
    let dateEarned: String?
    let color: Color
}

extension Badge {
    static var sampleData: [Badge] {
        [
            // Foundation
            Badge(name: "badges.first_step".localized, category: "badge_categories.foundation".localized, icon: "sparkles", description: "badges.first_step_desc".localized, dateEarned: "Mar 12, 2026", color: .blue),
            Badge(name: "badges.seven_day_streak".localized, category: "badge_categories.foundation".localized, icon: "calendar.badge.check", description: "badges.seven_day_streak_desc".localized, dateEarned: "Feb 28, 2026", color: .orange),
            Badge(name: "badges.expense_detective".localized, category: "badge_categories.foundation".localized, icon: "magnifyingglass", description: "badges.expense_detective_desc".localized, dateEarned: "Jan 15, 2026", color: .purple),
            
            // Control Master
            Badge(name: "badges.temptation_resistor".localized, category: "badge_categories.control".localized, icon: "hand.raised.fill", description: "badges.temptation_resistor_desc".localized, dateEarned: "Jan 10, 2026", color: .green),
            Badge(name: "badges.budget_engineer".localized, category: "badge_categories.control".localized, icon: "ruler.fill", description: "badges.budget_engineer_desc".localized, dateEarned: "Mar 25, 2026", color: .gray),
            Badge(name: "badges.safe_landing".localized, category: "badge_categories.control".localized, icon: "checkmark.seal.fill", description: "badges.safe_landing_desc".localized, dateEarned: "Dec 30, 2025", color: .cyan),
            Badge(name: "badges.revival".localized, category: "badge_categories.control".localized, icon: "heart.text.square.fill", description: "badges.revival_desc".localized, dateEarned: nil, color: .red),
            Badge(name: "badges.zero_spend_day".localized, category: "badge_categories.control".localized, icon: "nosign", description: "badges.zero_spend_day_desc".localized, dateEarned: nil, color: .green),
            Badge(name: "badges.shopaholic_no_more".localized, category: "badge_categories.control".localized, icon: "cart.badge.minus", description: "badges.shopaholic_no_more_desc".localized, dateEarned: nil, color: .cyan),
            Badge(name: "badges.minimalist".localized, category: "badge_categories.control".localized, icon: "leaf.fill", description: "badges.minimalist_desc".localized, dateEarned: nil, color: .green),
            Badge(name: "badges.self_disciplined".localized, category: "badge_categories.control".localized, icon: "lock.fill", description: "badges.self_disciplined_desc".localized, dateEarned: nil, color: .gray),
            Badge(name: "badges.steady_stream".localized, category: "badge_categories.control".localized, icon: "drop.fill", description: "badges.steady_stream_desc".localized, dateEarned: nil, color: .blue),
            Badge(name: "badges.great_wall".localized, category: "badge_categories.control".localized, icon: "shield.fill", description: "badges.great_wall_desc".localized, dateEarned: nil, color: .indigo),
            
            // Prosperity & Growth
            Badge(name: "badges.self_made".localized, category: "badge_categories.prosperity".localized, icon: "bitcoinsign.circle.fill", description: "badges.self_made_desc".localized, dateEarned: nil, color: .yellow),
            Badge(name: "badges.savings_engine".localized, category: "badge_categories.prosperity".localized, icon: "engine.combustion.fill", description: "badges.savings_engine_desc".localized, dateEarned: nil, color: .gray),
            Badge(name: "badges.young_investor".localized, category: "badge_categories.prosperity".localized, icon: "chart.pie.fill", description: "badges.young_investor_desc".localized, dateEarned: nil, color: .indigo),
            Badge(name: "badges.great_tree".localized, category: "badge_categories.prosperity".localized, icon: "tree.fill", description: "badges.great_tree_desc".localized, dateEarned: nil, color: .green),
            Badge(name: "badges.sleep_earn".localized, category: "badge_categories.prosperity".localized, icon: "bed.double.fill", description: "badges.sleep_earn_desc".localized, dateEarned: nil, color: .purple),
            Badge(name: "badges.financial_freedom".localized, category: "badge_categories.prosperity".localized, icon: "figure.stand.line.dotted.figure.rodeo", description: "badges.financial_freedom_desc".localized, dateEarned: nil, color: .yellow),
            Badge(name: "badges.emergency_fund".localized, category: "badge_categories.prosperity".localized, icon: "lifepreserver.fill", description: "badges.emergency_fund_desc".localized, dateEarned: nil, color: .orange),
            Badge(name: "badges.upward_trend".localized, category: "badge_categories.prosperity".localized, icon: "chart.line.uptrend.xyaxis", description: "badges.upward_trend_desc".localized, dateEarned: nil, color: .green),
            Badge(name: "badges.philanthropist".localized, category: "badge_categories.prosperity".localized, icon: "hands.sparkles.fill", description: "badges.philanthropist_desc".localized, dateEarned: nil, color: .pink),
            
            // Retention
            Badge(name: "badges.golden_week".localized, category: "badge_categories.retention".localized, icon: "calendar.badge.check", description: "badges.golden_week_desc".localized, dateEarned: nil, color: .orange),
            Badge(name: "badges.financial_detective".localized, category: "badge_categories.retention".localized, icon: "magnifyingglass", description: "badges.financial_detective_desc".localized, dateEarned: nil, color: .purple),
            Badge(name: "badges.shopping_immunity".localized, category: "badge_categories.retention".localized, icon: "cart.badge.minus", description: "badges.shopping_immunity_desc".localized, dateEarned: nil, color: .green),
            Badge(name: "badges.phoenix".localized, category: "badge_categories.retention".localized, icon: "flame.fill", description: "badges.phoenix_desc".localized, dateEarned: nil, color: .red),
            Badge(name: "badges.first_milestone".localized, category: "badge_categories.retention".localized, icon: "flag.checkered", description: "badges.first_milestone_desc".localized, dateEarned: nil, color: .blue),
            Badge(name: "badges.veteran".localized, category: "badge_categories.retention".localized, icon: "crown.fill", description: "badges.veteran_desc".localized, dateEarned: nil, color: .indigo),
            
            // Advanced Habits
            Badge(name: "badges.hundred_day_mastery".localized, category: "badge_categories.habits".localized, icon: "flame.fill", description: "badges.hundred_day_mastery_desc".localized, dateEarned: nil, color: .red),
            Badge(name: "badges.appraiser".localized, category: "badge_categories.habits".localized, icon: "camera.fill", description: "badges.appraiser_desc".localized, dateEarned: nil, color: .teal),
            Badge(name: "badges.novelist".localized, category: "badge_categories.habits".localized, icon: "text.quote", description: "badges.novelist_desc".localized, dateEarned: nil, color: .brown),
            Badge(name: "badges.time_traveler".localized, category: "badge_categories.habits".localized, icon: "clock.arrow.circlepath", description: "badges.time_traveler_desc".localized, dateEarned: nil, color: .gray),
            Badge(name: "badges.entry_machine".localized, category: "badge_categories.habits".localized, icon: "train.side.front.car", description: "badges.entry_machine_desc".localized, dateEarned: nil, color: .orange),
            
            // Secret
            Badge(name: "badges.lord_of_night".localized, category: "badge_categories.secret".localized, icon: "moon.zzz.fill", description: "badges.lord_of_night_desc".localized, dateEarned: nil, color: .purple),
            Badge(name: "badges.financial_eve".localized, category: "badge_categories.secret".localized, icon: "fireworks", description: "badges.financial_eve_desc".localized, dateEarned: nil, color: .red),
            Badge(name: "badges.lucky_numbers".localized, category: "badge_categories.secret".localized, icon: "number.square.fill", description: "badges.lucky_numbers_desc".localized, dateEarned: nil, color: .yellow),
            Badge(name: "badges.penny_pincher".localized, category: "badge_categories.secret".localized, icon: "1.circle.fill", description: "badges.penny_pincher_desc".localized, dateEarned: nil, color: .teal),
            Badge(name: "badges.confused_mind".localized, category: "badge_categories.secret".localized, icon: "trash.fill", description: "badges.confused_mind_desc".localized, dateEarned: nil, color: .gray),
            Badge(name: "badges.boba_infinity".localized, category: "badge_categories.secret".localized, icon: "cup.and.saucer.fill", description: "badges.boba_infinity_desc".localized, dateEarned: nil, color: .brown),
            Badge(name: "badges.love_fund".localized, category: "badge_categories.secret".localized, icon: "heart.fill", description: "badges.love_fund_desc".localized, dateEarned: nil, color: .pink),
            Badge(name: "badges.paw_parent".localized, category: "badge_categories.secret".localized, icon: "pawprint.fill", description: "badges.paw_parent_desc".localized, dateEarned: nil, color: .orange),
            Badge(name: "badges.happy_birthday".localized, category: "badge_categories.secret".localized, icon: "gift.fill", description: "badges.happy_birthday_desc".localized, dateEarned: nil, color: .pink),
            Badge(name: "badges.rock_bottom".localized, category: "badge_categories.secret".localized, icon: "battery.25", description: "badges.rock_bottom_desc".localized, dateEarned: nil, color: .red),
            Badge(name: "badges.make_it_rain".localized, category: "badge_categories.secret".localized, icon: "cloud.heavyrain.fill", description: "badges.make_it_rain_desc".localized, dateEarned: nil, color: .cyan),
            Badge(name: "badges.long_time_no_see".localized, category: "badge_categories.secret".localized, icon: "questionmark.folder.fill", description: "badges.long_time_no_see_desc".localized, dateEarned: nil, color: .gray),
            Badge(name: "badges.fresh_start".localized, category: "badge_categories.secret".localized, icon: "sun.max.fill", description: "badges.fresh_start_desc".localized, dateEarned: nil, color: .yellow),
            Badge(name: "badges.deal_hunter".localized, category: "badge_categories.secret".localized, icon: "tag.fill", description: "badges.deal_hunter_desc".localized, dateEarned: nil, color: .orange)
        ]
    }
}

struct BadgeListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LocalizationManager.self) private var loc
    @State private var showContent = false
    
    private var badges: [Badge] {
        Badge.sampleData
    }
    
    private var earnedCount: Int {
        badges.filter { $0.dateEarned != nil }.count
    }
    
    private var badgeCategories: [String] {
        [
            "badge_categories.foundation".localized,
            "badge_categories.control".localized,
            "badge_categories.prosperity".localized,
            "badge_categories.retention".localized,
            "badge_categories.habits".localized,
            "badge_categories.secret".localized
        ]
    }
    
    private func badges(for category: String) -> [Badge] {
        badges.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    progressCard
                    
                    ForEach(badgeCategories, id: \.self) { category in
                        if !badges(for: category).isEmpty {
                            badgeSection(title: category, badges: badges(for: category))
                        }
                    }
                    
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
            LText("badge_list.title")
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
                LText("badge_list.achiever_level")
                    .font(.system(size: 16, weight: .bold))
                LText("badge_list.unlock_more")
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
        .padding(.top, 16)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
}

struct NoiseView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                let seed = timeline.date.timeIntervalSince1970
                var rng = SeededRandomNumberGenerator(seed: Int(seed * 1000))
                
                for _ in 0..<200 {
                    let x = Double.random(in: 0...size.width, using: &rng)
                    let y = Double.random(in: 0...size.height, using: &rng)
                    let opacity = Double.random(in: 0.1...0.3, using: &rng)
                    let dotWidth = Double.random(in: 1...4, using: &rng)
                    
                    context.fill(
                        Path(CGRect(x: x, y: y, width: dotWidth, height: 1)),
                        with: .color(Color.black.opacity(opacity))
                    )
                }
            }
        }
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

struct BadgeCard: View {
    @Environment(LocalizationManager.self) private var loc
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
                    .blur(radius: isUnlocked ? 0 : 4)
                    .offset(x: isUnlocked ? 0 : CGFloat.random(in: -0.5...0.5))
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: 20)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .phaseAnimator([0, 1]) { content, phase in
                            content
                                .scaleEffect(1 + CGFloat(phase) * 0.1)
                        } animation: { phase in
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        }
                }
            }
            .padding(.top, 4)
            
            VStack(spacing: 4) {
                Text(isUnlocked ? badge.name : "badge_list.hidden".localized)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isUnlocked ? .black : .gray)
                    .multilineTextAlignment(.center)
                    .blur(radius: isUnlocked ? 0 : 2)
                    .offset(x: isUnlocked ? 0 : CGFloat.random(in: -1...1))
                
                if let date = badge.dateEarned {
                    Text(date)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.green)
                } else {
                    Text(badge.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.gray.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 24)
                        .blur(radius: 2)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(
            Group {
                if !isUnlocked {
                    NoiseView()
                        .blendMode(.multiply)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

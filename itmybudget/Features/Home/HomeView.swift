import SwiftUI
import Charts

struct PulseData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isPrediction: Bool
}

struct HomeView: View {
    @EnvironmentObject private var navState: AppNavigationState
    @State private var showHeader: Bool = false
    @State private var showSections: Bool = false
    @State private var selectedFilter: TransactionType = .all
    @State private var showAllTransactions: Bool = false
    @State private var showNotifications: Bool = false
    @State private var selectedBudgetForDetail: Budget? = nil
    @State private var isShowingProfile: Bool = false
    @Namespace private var filterNamespace
    @State private var selectedTransaction: Transaction? = nil
    @State private var showingJourneySheet = false
    @State private var showingAnalyticSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    Color.clear
                            .frame(height: 1)
                            .id("top")
                    
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        
                        overviewSection
                        
                        pulseSection
                        
                        transactionsSection
                        
                        budgetSection
    
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 60)
                }
                .onChange(of: navState.selectedTab) { oldValue, newValue in
                    if newValue == 0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showNotifications) {
                NotificationsView()
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(edges: .top)
            .fullScreenCover(item: $selectedTransaction) { transaction in
                TransactionDetailView(transaction: transaction)
            }
            .sheet(isPresented: $showAllTransactions) {
                SimpleTransactionListSheet(
                    title: "Latest",
                    transactions: filteredTransactions
                )
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(item: $selectedBudgetForDetail) { budget in
                BudgetDetailView(budget: budget)
            }
            .fullScreenCover(isPresented: $isShowingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingJourneySheet) {
                JourneyDetailSheet(title: "Journey Details")
                    .presentationDetents([.fraction(0.85)])
            }
            .sheet(isPresented: $showingAnalyticSheet) {
                AnalyticDetailSheet(title: "Detailed Analysis")
                    .presentationDetents([.fraction(0.85)])
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showHeader = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showSections = true
            }
        }
    }
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {
                    isShowingProfile = true
                }) {
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.black)
                            .frame(width: 4, height: 24)
                        
                        Text("Quoc Viet")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.black)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            Text("12")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(.orange.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(.orange.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showHeader ? 0 : 10)
                .opacity(showHeader ? 1 : 0)
                
                Spacer()
                
                Button(action: {
                    showNotifications = true
                }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showHeader ? 0 : 10)
                .opacity(showHeader ? 1 : 0)
            }
                                        
            HStack(spacing: 8) {
                Text("29 March 2026")
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.gray)
            .padding(.bottom, 12)
            .offset(y: showHeader ? 0 : 5)
            .opacity(showHeader ? 1 : 0)
        
            HStack(spacing: 8) {
                badgeTag(text: "Savings Master", color: .orange)
                badgeTag(text: "Saving Streak", color: .green)
            }
            .padding(.bottom, 24)
            .offset(y: showHeader ? 0 : 5)
            .opacity(showHeader ? 1 : 0)
        }
    }

    @ViewBuilder
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Weekly Overview",
            )
            
            AIInsightCarousel(
                content: "Every time you go out for drinks on Friday night, you usually spend another **$20** on *online shopping* on Saturday.",
                cta: "View Journey Detail",
                onCTATap: {
                    showingJourneySheet = true
                }
            )
        }
        .padding(.bottom, 24)
        .offset(y: showSections ? 0 : 20)
        .opacity(showSections ? 1 : 0)
    }

    @ViewBuilder
    private var pulseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(
                title: "Financial Pulse",
            )
            
            HStack(spacing: 12) {
                FinancialPulseCard(
                    title: "Balance",
                    value: "$12.450",
                    trend: "+2.4%",
                    color: .teal,
                    data: balanceSampleData
                )
                
                FinancialPulseCard(
                    title: "Burn Rate",
                    value: "$85",
                    subtitle: "/day",
                    trend: "-15%",
                    color: .orange,
                    data: burnRateSampleData
                )
            }
        }
        .padding(.bottom, 24)
        .offset(y: showSections ? 0 : 20)
        .opacity(showSections ? 1 : 0)
    }

    @ViewBuilder
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Latest Transactions",
                extraActionTitle: "See All",
                onExtraAction: {
                    showAllTransactions = true
                }
            )
            
            HStack(spacing: 8) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    FilterTabView(
                        title: type.rawValue,
                        isSelected: selectedFilter == type,
                        namespace: filterNamespace,
                        action: { 
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedFilter = type 
                            }
                        }
                    )
                }
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 8) {
                ForEach(filteredTransactions.prefix(3)) { transaction in
                    TransactionItemView(transaction: transaction) {
                        selectedTransaction = transaction
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: filteredTransactions)
        }
        .padding(.bottom, 24)
        .offset(y: showSections ? 0 : 20)
        .opacity(showSections ? 1 : 0)
    }

    @ViewBuilder
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "Budget Tracking",
                extraActionTitle: "See All",
                onExtraAction: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        navState.selectedTab = 1
                    }
                }
            )
            
            VStack(spacing: 8) {
                ForEach(recentBudgets) { budget in
                    BudgetItemView(budget: budget, showDetails: true, onTap: {
                        selectedBudgetForDetail = budget
                    })
                }
            }
        }
        .padding(.bottom, 24)
        .offset(y: showSections ? 0 : 20)
        .opacity(showSections ? 1 : 0)
    }

    @ViewBuilder
    private func sectionHeader(title: String, extraActionTitle: String? = nil, onExtraAction: (() -> Void)? = nil) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if let extra = extraActionTitle {
                Button(action: {
                    onExtraAction?()
                }) {
                    Text(extra)
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
    }

    @ViewBuilder
    private func badgeTag(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
    }
}

struct FinancialPulseCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let trend: String
    let color: Color
    let data: [PulseData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray)
                Spacer()
                Text(trend)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
                        .padding(.bottom, 2)
                }
            }
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                }
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 50)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
    }
}

extension HomeView {
    private var recentBudgets: [Budget] {
        Array(Budget.sampleData
            .sorted { $0.lastTransactionDate > $1.lastTransactionDate }
            .prefix(5))
    }

    private var filteredTransactions: [Transaction] {
        if selectedFilter == .all {
            return Transaction.sampleData
        }
        return Transaction.sampleData.filter { $0.type == selectedFilter }
    }
    
    private var balanceSampleData: [PulseData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<12).map { i in
            PulseData(
                date: calendar.date(byAdding: .day, value: i - 11, to: now)!,
                value: Double.random(in: 10000...12500),
                isPrediction: false
            )
        }
    }
    
    private var burnRateSampleData: [PulseData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<12).map { i in
            PulseData(
                date: calendar.date(byAdding: .day, value: i - 11, to: now)!,
                value: Double.random(in: 60...100),
                isPrediction: false
            )
        }
    }
}

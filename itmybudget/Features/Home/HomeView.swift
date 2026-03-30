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
    @Namespace private var filterNamespace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        HStack(spacing: 12) {
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
                
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(
                            title: "Weekly Overview",
                        )
                        
                        AIInsightCarousel()
                    }
                    .padding(.bottom, 24)
                    .offset(y: showSections ? 0 : 20)
                    .opacity(showSections ? 1 : 0)

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

                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(
                            title: "Latest Transactions",
                            extraActionTitle: "All",
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
                            ForEach(filteredTransactions) { transaction in
                                TransactionItemView(transaction: transaction)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .move(edge: .top).combined(with: .opacity)
                                    ))
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0), value: filteredTransactions)
                    }
                    .padding(.bottom, 24)
                    .offset(y: showSections ? 0 : 20)
                    .opacity(showSections ? 1 : 0)

                    VStack(alignment: .leading, spacing: 16) {
                        sectionHeader(
                            title: "Budget Tracking",
                            extraActionTitle: "All",
                            onExtraAction: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    navState.selectedTab = 1
                                }
                            }
                        )
                        
                        VStack(spacing: 8) {
                            ForEach(Budget.sampleData) { budget in
                                BudgetItemView(budget: budget)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                    .offset(y: showSections ? 0 : 20)
                    .opacity(showSections ? 1 : 0)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 60)
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
            .sheet(isPresented: $showAllTransactions) {
                HistoryView()
                    .presentationDetents([.fraction(0.85)])
                    .presentationDragIndicator(.visible)
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

struct FilterTabView: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.black)
                                .matchedGeometryEffect(id: "filterTab", in: namespace)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                )
                        }
                    }
                )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

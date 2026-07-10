import SwiftUI
import SwiftData
import Charts

struct PulseData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isPrediction: Bool
}

struct HomeView: View {
    @EnvironmentObject private var navState: AppNavigationState
    @Environment(\.modelContext) private var modelContext
    var authManager = AuthManager.shared
    
    @Query(sort: \DBBudget.updatedAt, order: .reverse) private var dbBudgets: [DBBudget]
    @State private var budgets: [Budget] = []
    
    @Query(sort: \DBTransaction.createdAt, order: .reverse) private var dbTransactions: [DBTransaction]
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
    @State private var showingBadgeList = false
    
    @State private var balanceChartData: [PulseData] = []
    @State private var burnRateChartData: [PulseData] = []
    @State private var currentBalance: String = "0đ"
    @State private var currentBurnRate: String = "0đ"
    
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
                    title: "Giao dịch mới nhất",
                    transactions: filteredTransactions
                )
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(item: $selectedBudgetForDetail) { budget in
                BudgetDetailView(budget: budget)
            }
            .fullScreenCover(isPresented: $isShowingProfile) {
                ProfileView()
            }
            .sheet(isPresented: $showingJourneySheet) {
                JourneyDetailSheet(title: "Chi tiết hành trình")
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingAnalyticSheet) {
                AnalyticDetailSheet(title: "Phân tích chi tiết")
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingBadgeList) {
                BadgeListView()
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
        .task {
            updateBudgetsFromDB()
            await fetchBudgets()
            await fetchTransactions()
            await fetchPulseData()
            if authManager.currentUser == nil {
                await authManager.fetchMe(context: modelContext)
            }
        }
        .onChange(of: dbBudgets) {
            updateBudgetsFromDB()
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
                        
                        Text(authManager.currentUser?.full_name ?? "User")
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
                Text(Date().formatted(date: .long, time: .omitted))
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.gray)
            .padding(.bottom, 12)
            .offset(y: showHeader ? 0 : 5)
            .opacity(showHeader ? 1 : 0)
        
            HStack(spacing: 8) {
                Button(action: { showingBadgeList = true }) {
                    badgeTag(text: "profile.savings_master", color: .orange)
                }
                .buttonStyle(BouncyButtonStyle())
                
                Button(action: { showingBadgeList = true }) {
                    badgeTag(text: "home.saving_streak", color: .green)
                }
                .buttonStyle(BouncyButtonStyle())
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
                title: "Tổng quan hàng tuần",
            )
            
            AIInsightCarousel(
                content: "Mỗi khi bạn đi uống nước vào tối thứ Sáu, bạn thường chi thêm **20$** cho *mua sắm trực tuyến* vào thứ Bảy.",
                cta: "Xem chi tiết hành trình",
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
                title: "Nhịp đập tài chính",
            )
            
            HStack(spacing: 12) {
                FinancialPulseCard(
                    title: "Số dư",
                    value: currentBalance,
                    trend: "",
                    color: .teal,
                    data: balanceChartData.isEmpty ? balanceSampleData : balanceChartData
                )
                
                FinancialPulseCard(
                    title: "Tốc độ chi tiêu",
                    value: currentBurnRate,
                    subtitle: "/ngày",
                    trend: "",
                    color: .orange,
                    data: burnRateChartData.isEmpty ? burnRateSampleData : burnRateChartData
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
                title: "Giao dịch mới nhất",
                extraActionTitle: "Xem tất cả",
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
                if filteredTransactions.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 32))
                            .foregroundStyle(.gray.opacity(0.3))
                        Text("Chưa có giao dịch nào")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
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
                title: "Theo dõi ngân sách",
                extraActionTitle: "Xem tất cả",
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
                if !trend.isEmpty {
                    Text(trend)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                }
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
        Array(budgets
            .sorted { $0.lastTransactionDate > $1.lastTransactionDate }
            .prefix(5))
    }
    
    private func updateBudgetsFromDB() {
        let newBudgets = dbBudgets.map { db in
            Budget(
                id: db.id,
                name: db.name,
                spent: Double(db.spentAmountStr) ?? 0,
                total: Double(db.limitStr) ?? 0,
                dailyLimit: (Double(db.limitStr) ?? 0) / 30,
                nextTopUp: db.periodType,
                lastTransactionDate: Date()
            )
        }
        withAnimation {
            self.budgets = newBudgets
        }
    }
    
    private func fetchBudgets() async {
        do {
            let budgetList: [APIBudgetResponse] = try await NetworkManager.shared.request(BudgetEndpoint.list)
            
            await MainActor.run {
                for serverBudget in budgetList {
                    let serverId = serverBudget.id
                    let fetchDescriptor = FetchDescriptor<DBBudget>(predicate: #Predicate { $0.id == serverId })
                    if let existing = try? modelContext.fetch(fetchDescriptor).first {
                        existing.name = serverBudget.name
                        existing.limitStr = serverBudget.limit
                        existing.amountStr = serverBudget.amount
                        existing.periodType = serverBudget.period_type
                        existing.startDate = serverBudget.start_date
                        existing.endDate = serverBudget.end_date
                        existing.icon = serverBudget.icon
                        existing.color = serverBudget.color
                        existing.budgetType = serverBudget.budget_type
                        existing.isActive = serverBudget.is_active
                        existing.spentAmountStr = serverBudget.spent_amount
                        existing.updatedAt = serverBudget.updated_at
                    } else {
                        let dbBudget = DBBudget(
                            id: serverBudget.id,
                            userId: serverBudget.user_id,
                            name: serverBudget.name,
                            limitStr: serverBudget.limit,
                            amountStr: serverBudget.amount,
                            periodType: serverBudget.period_type,
                            startDate: serverBudget.start_date,
                            endDate: serverBudget.end_date,
                            icon: serverBudget.icon,
                            color: serverBudget.color,
                            budgetType: serverBudget.budget_type,
                            isActive: serverBudget.is_active,
                            spentAmountStr: serverBudget.spent_amount,
                            createdAt: serverBudget.created_at,
                            updatedAt: serverBudget.updated_at
                        )
                        modelContext.insert(dbBudget)
                    }
                }
                
                let serverIds = budgetList.map { $0.id }
                let fetchDescriptor = FetchDescriptor<DBBudget>()
                if let allDbBudgets = try? modelContext.fetch(fetchDescriptor) {
                    for dbb in allDbBudgets {
                        if !serverIds.contains(dbb.id) {
                            modelContext.delete(dbb)
                        }
                    }
                }
                
                try? modelContext.save()
            }
        } catch {
            print("Failed to fetch budgets list: \(error)")
        }
    }
    
    private func fetchTransactions() async {
        do {
            let response: [APIRecentTransactionResponse] = try await NetworkManager.shared.request(TransactionEndpoint.recent(limit: 10, type: nil))
            
            await MainActor.run {
                for item in response {
                    let fetchDescriptor = FetchDescriptor<DBTransaction>(predicate: #Predicate { $0.id == item.id })
                    
                    if let existing = try? modelContext.fetch(fetchDescriptor).first {
                        existing.budgetId = item.budget_id
                        existing.amount = abs(item.amount)
                        existing.type = item.type
                        existing.note = item.note
                        existing.categoryName = item.category_name
                        existing.createdAt = item.created_at
                    } else {
                        let newDbTx = DBTransaction(
                            id: item.id,
                            budgetId: item.budget_id,
                            categoryId: nil,
                            amount: abs(item.amount),
                            type: item.type,
                            note: item.note,
                            categoryName: item.category_name,
                            images: nil,
                            createdAt: item.created_at,
                            updatedAt: nil
                        )
                        modelContext.insert(newDbTx)
                    }
                }
                
                try? modelContext.save()
            }
        } catch {
            print("Failed to fetch transactions: \(error)")
        }
    }
    
    private var transactions: [Transaction] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return dbTransactions.map { dbTx -> Transaction in
            let txType: TransactionType = dbTx.type == "income" ? .income : .outcome
            let date = formatter.date(from: dbTx.createdAt ?? "") ?? Date()
            
            return Transaction(
                name: dbTx.note ?? "Giao dịch",
                description: "",
                date: date,
                images: dbTx.images ?? [],
                location: "",
                amount: abs(dbTx.amount),
                budgetName: dbTx.categoryName ?? "Ngân sách",
                type: txType,
                icon: "dollarsign.circle.fill",
                isImageIcon: false
            )
        }
    }

    private var filteredTransactions: [Transaction] {
        if selectedFilter == .all {
            return transactions
        }
        return transactions.filter { $0.type == selectedFilter }
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

    private func fetchPulseData() async {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        do {
            async let balanceResponse: BalanceChartResponse? = try? NetworkManager.shared.request(BudgetEndpoint.balanceChart(month: month, year: year))
            async let spendingResponse: AverageSpendingResponse? = try? NetworkManager.shared.request(BudgetEndpoint.averageSpendingChart(month: month, year: year))
            
            let bRes = await balanceResponse
            let sRes = await spendingResponse
            
            await MainActor.run {
                if let b = bRes {
                    self.processBalanceData(b)
                }
                if let s = sRes {
                    self.processSpendingData(s)
                }
            }
        }
    }

    private func processBalanceData(_ response: BalanceChartResponse) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var newData: [PulseData] = []
        for item in response.data {
            if let date = formatter.date(from: item.date) {
                let value = parseHugeNumber(item.total_amount)
                newData.append(PulseData(date: date, value: value, isPrediction: false))
            }
        }
        self.balanceChartData = newData.sorted(by: { $0.date < $1.date })
        
        if let last = response.data.last {
            self.currentBalance = formatHugeNumber(last.total_amount)
        }
    }

    private func processSpendingData(_ response: AverageSpendingResponse) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var newData: [PulseData] = []
        for item in response.data {
            if let date = formatter.date(from: item.date) {
                let value = parseHugeNumber(item.average_amount)
                newData.append(PulseData(date: date, value: value, isPrediction: false))
            }
        }
        self.burnRateChartData = newData.sorted(by: { $0.date < $1.date })
        
        if let last = response.data.last {
            self.currentBurnRate = formatHugeNumber(last.average_amount)
        }
    }

    private func parseHugeNumber(_ string: String) -> Double {
        var str = string.replacingOccurrences(of: "+", with: "")
        while str.hasPrefix("0") && str.count > 1 && !str.hasPrefix("0.") {
            str.removeFirst()
        }
        return Double(str) ?? 0.0
    }
    
    private func formatHugeNumber(_ string: String) -> String {
        var str = string.replacingOccurrences(of: "+", with: "")
        while str.hasPrefix("0") && str.count > 1 && !str.hasPrefix("0.") {
            str.removeFirst()
        }
        
        if let val = Double(str) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "vi_VN")
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: val)) ?? "\(val)đ"
        }
        return str + "đ"
    }
}

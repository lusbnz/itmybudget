import SwiftUI
import _SwiftData_SwiftUI

enum HistoryMode: String, CaseIterable {
    case timeline = "Dòng thời gian"
    case calendar = "Lịch"
    
    var localizedName: String {
        self.rawValue
    }
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedMode: HistoryMode = .timeline
    @Namespace private var budgetNamespace
    @State private var showingSearchSheet = false
    @State private var searchText: String = ""
    @State private var selectedType: TransactionType = .all
    @State private var selectedBudgetId: Int? = nil
    @State private var selectedCategory: Category? = nil
    @State private var showMonthPicker = false
    @State private var selectedDate = Date()
    @State private var showContent = false
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var showFilter = false
    @FocusState private var isSearchFocused: Bool
    @State private var selectedDayTransactions: [Transaction]? = nil
    @State private var selectedDayDate: Date? = nil
    @State private var showDayDetail = false
    @State private var selectedTransaction: Transaction? = nil
    
    @Query(sort: \DBTransaction.createdAt, order: .reverse) private var dbTransactions: [DBTransaction]
    @Query(sort: \DBBudget.updatedAt, order: .reverse) private var dbBudgets: [DBBudget]
    @State private var densityMap: [String: Int] = [:]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HistoryModeTabs(selectedMode: $selectedMode, showContent: showContent)
                        .padding(.bottom, 8)
                    
                    if selectedMode == .timeline {
                        timelineView
                    } else {
                        calendarView
                    }
                    
                    Spacer()
                }
            }
        }
        .background(Color(red: 1.0, green: 0.97, blue: 0.92))
        .task {
            await fetchTransactions()
            await fetchDensity()
        }
        .onChange(of: selectedDate) { _, _ in
            Task {
                await fetchDensity()
            }
        }
        .onChange(of: selectedBudgetId) { _, _ in
            Task {
                await fetchDensity()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
        .sheet(isPresented: $showFilter) {
            FilterSheetView(selectedType: $selectedType, selectedBudgetId: $selectedBudgetId, selectedCategory: $selectedCategory)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSearchSheet) {
            SearchSheetView(searchText: $searchText)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMonthPicker) {
            MonthPickerSheet(selectedDate: $selectedDate, isPresented: $showMonthPicker)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showDayDetail) {
            DayDetailSheet(date: selectedDayDate, transactions: selectedDayTransactions, isPresented: $showDayDetail)
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionDetailView(transaction: transaction)
        }
    }
    
    @ViewBuilder
    private var timelineView: some View {
        VStack(spacing: 24) {
            spendingIntensitySection

            budgetCategoryTabs
            
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                if groupedTransactions.isEmpty {
                    emptyStateView
                } else {
                    transactionList
                }
            }
            .padding(.bottom, 40)
        }
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.system(size: 40))
                .foregroundStyle(.gray.opacity(0.4))
            
            Text("Chưa có giao dịch nào")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var transactionList: some View {
        ForEach(groupedTransactions.keys.sorted(by: { $0 > $1 }), id: \.self) { date in
            Section {
                VStack(spacing: 0) {
                    ForEach(groupedTransactions[date] ?? []) { transaction in
                        TransactionTimelineItem(transaction: transaction, isLast: transaction == (groupedTransactions[date]?.last)) {
                            selectedTransaction = transaction
                        }
                    }
                }
            } header: {
                HStack {
                    Text(dateHeader(for: date))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Text(totalAmount(for: groupedTransactions[date] ?? []))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color(red: 1.0, green: 0.97, blue: 0.92))
            }
        }
    }

    private var transactions: [Transaction] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        return dbTransactions.map { dbTx -> Transaction in
            let txType: TransactionType = dbTx.type == "income" ? .income : .outcome
            let date = formatter.date(from: dbTx.createdAt ?? "") ?? Date()
            
            let budgetName = dbBudgets.first(where: { $0.id == dbTx.budgetId })?.name ?? "Ngân sách"
            return Transaction(
                name: dbTx.note ?? "Giao dịch",
                description: "",
                date: date,
                images: dbTx.images ?? [],
                location: "",
                amount: abs(dbTx.amount),
                budgetName: budgetName,
                type: txType,
                icon: "dollarsign.circle.fill",
                isImageIcon: false
            )
        }
    }

    private func fetchTransactions() async {
        do {
            let response: APITransactionListResponse = try await NetworkManager.shared.request(TransactionEndpoint.list(budgetId: nil, page: 0, size: 100))
            
            await MainActor.run {
                let serverIds = response.items.map { $0.id }
                
                for item in response.items {
                    let amt = Double(item.amount) ?? 0.0
                    let fetchDescriptor = FetchDescriptor<DBTransaction>(predicate: #Predicate { $0.id == item.id })
                    
                    if let existing = try? modelContext.fetch(fetchDescriptor).first {
                        existing.budgetId = item.budget_id
                        existing.categoryId = item.category_id
                        existing.amount = amt
                        existing.type = item.type
                        existing.note = item.note
                        existing.images = item.images
                        existing.createdAt = item.created_at
                        existing.updatedAt = item.updated_at
                    } else {
                        let newDbTx = DBTransaction(
                            id: item.id,
                            budgetId: item.budget_id,
                            categoryId: item.category_id,
                            amount: amt,
                            type: item.type,
                            note: item.note,
                            categoryName: nil,
                            images: item.images,
                            createdAt: item.created_at,
                            updatedAt: item.updated_at
                        )
                        modelContext.insert(newDbTx)
                    }
                }
                
                let fetchAllDescriptor = FetchDescriptor<DBTransaction>()
                if let allDbTxs = try? modelContext.fetch(fetchAllDescriptor) {
                    for dbTx in allDbTxs {
                        if !serverIds.contains(dbTx.id) {
                            modelContext.delete(dbTx)
                        }
                    }
                }
                
                try? modelContext.save()
            }
        } catch {
            print("Failed to fetch history transactions: \(error)")
        }
    }

    private var filteredTransactions: [Transaction] {
        var filtered = transactions
        
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.description.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        if selectedType != .all {
            filtered = filtered.filter { $0.type == selectedType }
        }
        
        if let selectedId = selectedBudgetId {
            let budgetName = dbBudgets.first(where: { $0.id == selectedId })?.name ?? ""
            filtered = filtered.filter { $0.budgetName == budgetName }
        }
        
        if let selectedCat = selectedCategory {
            filtered = filtered.filter { $0.icon == selectedCat.icon }
        }
        
        return filtered
    }

    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }

    private func dateHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Hôm nay"
        } else if calendar.isDateInYesterday(date) {
            return "Hôm qua"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM"
            return formatter.string(from: date)
        }
    }

    private func totalAmount(for transactions: [Transaction]) -> String {
        let total = transactions.reduce(0.0) { sum, transaction in
            let value = transaction.type == .income ? transaction.amount : -transaction.amount
            return sum + value
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "đ"
        return formatter.string(from: NSNumber(value: total)) ?? "0đ"
    }

    private var spendingIntensitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cường độ chi tiêu")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 16) {
                intensityGrid
                
                HStack(spacing: 30) {
                    legendItem(label: "Không chi tiêu", level: 0)
                    legendItem(label: "Cường độ cao", level: 4)
                    Spacer()
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }

    private var intensityGrid: some View {
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        let year = calendar.component(.year, from: selectedDate)
        let month = calendar.component(.month, from: selectedDate)
        
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 12), spacing: 6) {
            ForEach(1...daysInMonth, id: \.self) { day in
                let dateString = String(format: "%04d-%02d-%02d", year, month, day)
                let count = densityMap[dateString] ?? 0
                
                RoundedRectangle(cornerRadius: 6)
                    .fill(intensityColor(forCount: count))
                    .aspectRatio(1, contentMode: .fill)
            }
        }
    }

    private func intensityColor(forCount count: Int) -> Color {
        let level: Int
        if count == 0 { level = 0 }
        else if count <= 2 { level = 1 }
        else if count <= 5 { level = 2 }
        else if count <= 10 { level = 3 }
        else { level = 4 }
        return intensityColor(forLevel: level)
    }

    private func legendItem(label: String, level: Int) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(intensityColor(forLevel: level))
                .frame(width: 14, height: 14)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.black.opacity(0.5))
        }
    }

    private func intensityColor(forLevel level: Int) -> Color {
        switch level {
        case 0: return Color.black.opacity(0.06)
        case 1: return Color.orange.opacity(0.1)
        case 2: return Color.orange.opacity(0.25)
        case 3: return Color.orange.opacity(0.45)
        case 4: return Color.orange.opacity(0.7)
        default: return Color.black.opacity(0.06)
        }
    }

    @ViewBuilder
    private var calendarView: some View {
        VStack(spacing: 16) {
            MonthNavigator(selectedDate: $selectedDate, onShowPicker: { showMonthPicker = true })
            
            budgetCategoryTabs
            
            CalendarGridView(
                selectedDate: selectedDate,
                transactions: filteredTransactions,
                onDaySelect: { transactions, date in
                    selectedDayTransactions = transactions
                selectedDayDate = date
                showDayDetail = true
            })
            
            monthlyOverview
            
            Spacer(minLength: 100)
        }
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }

    private var monthlyOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tổng quan hàng tháng")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                overviewItem(
                    icon: "chart.bar.fill",
                    color: .orange,
                    title: "Tổng chi tiêu",
                    value: "1,234đ",
                    trend: "-8%",
                    isPositive: true
                )
                
                overviewItem(
                    icon: "calendar.badge.clock",
                    color: .blue,
                    title: "Số ngày không chi tiêu",
                    value: "14 ngày",
                    trend: "Tiết kiệm tốt",
                    isPositive: true
                )
                
                overviewItem(
                    icon: "star.fill",
                    color: .purple,
                    title: "Danh mục hàng đầu",
                    value: "Mua sắm",
                    trend: "860đ",
                    isPositive: false
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 8)
    }
    
    private func overviewItem(icon: String, color: Color, title: String, value: String, trend: String, isPositive: Bool) -> some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.gray)
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
            }
            
            Spacer()
            
            Text(trend)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(isPositive ? .green : .gray)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isPositive ? Color.green.opacity(0.08) : Color.black.opacity(0.04))
                .clipShape(Capsule())
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.04), lineWidth: 1))
    }
    
    private var header: some View {
        HStack {
            Text("Lịch sử")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: {
                    showingSearchSheet = true
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
                
                Button(action: {
                    showFilter = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }

    private var budgetCategoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterTabView(
                    title: "Tất cả",
                    isSelected: selectedBudgetId == nil,
                    namespace: budgetNamespace,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedBudgetId = nil
                        }
                    }
                )
                
                ForEach(dbBudgets) { budget in
                    FilterTabView(
                        title: budget.name,
                        isSelected: selectedBudgetId == budget.id,
                        namespace: budgetNamespace,
                        action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                selectedBudgetId = budget.id
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private func fetchDensity() async {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: selectedDate)
        let year = calendar.component(.year, from: selectedDate)
        
        do {
            let response: APIDensityResponse = try await NetworkManager.shared.request(TransactionEndpoint.density(month: month, year: year, budgetId: selectedBudgetId))
            
            var newDensityMap: [String: Int] = [:]
            for day in response.days {
                newDensityMap[day.date] = day.count
            }
            
            await MainActor.run {
                withAnimation {
                    self.densityMap = newDensityMap
                }
            }
        } catch {
            print("Failed to fetch density: \(error)")
        }
    }
}

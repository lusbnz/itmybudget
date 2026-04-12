import SwiftUI

enum HistoryMode: String, CaseIterable {
    case timeline = "Timeline"
    case calendar = "Calendar"
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: HistoryMode = .timeline
    @Namespace private var budgetNamespace
    @State private var showingSearchSheet = false
    @State private var searchText: String = ""
    @State private var selectedType: TransactionType = .all
    @State private var selectedBudgetId: UUID? = nil
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
            
            Text("No transactions yet")
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

    private var filteredTransactions: [Transaction] {
        var transactions = Transaction.sampleData
        
        if !searchText.isEmpty {
            transactions = transactions.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) || 
                $0.description.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        if selectedType != .all {
            transactions = transactions.filter { $0.type == selectedType }
        }
        
        if let selectedId = selectedBudgetId {
            let budgetName = Budget.sampleData.first(where: { $0.id == selectedId })?.name ?? ""
            transactions = transactions.filter { $0.budgetName == budgetName }
        }
        
        if let selectedCat = selectedCategory {
            transactions = transactions.filter { $0.icon == selectedCat.icon }
        }
        
        return transactions
    }

    private var groupedTransactions: [Date: [Transaction]] {
        Dictionary(grouping: filteredTransactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
    }

    private func dateHeader(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
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
        formatter.currencySymbol = "$"
        return formatter.string(from: NSNumber(value: total)) ?? "$0.00"
    }

    private var spendingIntensitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending Intensity")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 16) {
                intensityGrid
                
                HStack(spacing: 30) {
                    legendItem(label: "No Spend", level: 0)
                    legendItem(label: "High Intensity", level: 4)
                    Spacer()
                }
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
    }

    private var intensityGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 12), spacing: 6) {
            ForEach(0..<36) { i in
                RoundedRectangle(cornerRadius: 6)
                    .fill(intensityColor(for: i))
                    .aspectRatio(1, contentMode: .fill)
            }
        }
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

    private func intensityColor(for index: Int) -> Color {
        let weights = [0, 0, 0, 0, 1, 1, 2, 2, 3, 4]
        let level = weights.randomElement() ?? 0
        return intensityColor(forLevel: level)
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
            
            CalendarGridView(selectedDate: selectedDate, onDaySelect: { transactions, date in
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
            Text("Monthly Overview")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 16)
            
            VStack(spacing: 12) {
                overviewItem(
                    icon: "chart.bar.fill",
                    color: .orange,
                    title: "Total Spending",
                    value: "$1,234",
                    trend: "-8%",
                    isPositive: true
                )
                
                overviewItem(
                    icon: "calendar.badge.clock",
                    color: .blue,
                    title: "No-spending Days",
                    value: "14 days",
                    trend: "Good Saving",
                    isPositive: true
                )
                
                overviewItem(
                    icon: "star.fill",
                    color: .purple,
                    title: "Top Category",
                    value: "Shopping",
                    trend: "$860",
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
            Text("History")
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
                    title: "All",
                    isSelected: selectedBudgetId == nil,
                    namespace: budgetNamespace,
                    action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                            selectedBudgetId = nil
                        }
                    }
                )
                
                ForEach(Budget.sampleData) { budget in
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
}

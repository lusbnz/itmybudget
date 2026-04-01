import SwiftUI
import Charts

struct BudgetDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let budget: Budget
    
    @State private var showingTopUpSheet = false
    @State private var showingBudgetSheet = false
    @State private var currentBudget: Budget
    @State private var spendingTab: SpendingTab = .week
    @State private var showingHistorySheet = false
    @EnvironmentObject private var navState: AppNavigationState
    @Namespace private var tabNamespace
    
    init(budget: Budget) {
        self.budget = budget
        self._currentBudget = State(initialValue: budget)
    }
    
    enum SpendingTab: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
    }
    
    private let incomeAmount: Double = 85.0
    private let outcomeAmount: Double = 65.0
    private let incomeTrend: String = "+2.4%"
    private let transactionsCount: Int = 12
    
    private var progress: Double {
        currentBudget.total > 0 ? currentBudget.spent / currentBudget.total : 0
    }
    
    @State private var showingTransferSheet = false
    @State private var showingAnalyticsSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    headerSection
                        .padding(.horizontal, 20)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(currentBudget.name)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.black)
                        
                        HStack(spacing: 4) {
                            Text("You spent")
                            Text(formatCurrency(currentBudget.spent))
                                .fontWeight(.bold)
                            Text("of")
                            Text(formatCurrency(currentBudget.total))
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 14))
                        
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 14))
                            Text("**\(transactionsCount) transactions** this month")
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.horizontal, 20)
                    
                    limitBox
                        .padding(.horizontal, 20)
                    
                    incomeOutcomeSection
                        .padding(.horizontal, 20)
                    
                    AIInsightCarousel(
                        content: "Dự kiến bạn sẽ vượt ngân sách vào ngày 26 của tháng này.",
                        cta: "Xem chi tiết phân tích",
                        onCTATap: {
                            showingAnalyticsSheet = true
                        }
                    )
                    .padding(.horizontal, 20)
                    
                    dailySpendingSection
                        .padding(.horizontal, 20)
                    
                    recentTransactionsSection
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            
            bottomActionButtons
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingTopUpSheet) {
            TransferFormSheet(
                budgets: Budget.sampleData,
                currentBudget: currentBudget,
                onConfirm: { amount, sourceId in
                    // Mock top up logic
                    print("Topping up \(amount) to \(currentBudget.name)")
                }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingBudgetSheet) {
            BudgetFormSheet(
                budgetToEdit: currentBudget,
                onSave: { newName, newTotal in
                    currentBudget = Budget(
                        id: currentBudget.id,
                        name: newName,
                        spent: currentBudget.spent,
                        total: newTotal,
                        dailyLimit: newTotal / 30,
                        nextTopUp: currentBudget.nextTopUp,
                        lastTransactionDate: Date()
                    )
                },
                onDelete: {
                    dismiss()
                }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingHistorySheet) {
            HistoryView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAnalyticsSheet) {
            AnalyticsView()
                .presentationDetents([.fraction(0.85)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingTransferSheet) {
            TransferFormSheet(
                budgets: Budget.sampleData,
                currentBudget: currentBudget,
                onConfirm: { amount, sourceId in
                    // Logic to handle transfer can be added here
                    print("Transfering \(amount) from \(sourceId) to \(currentBudget.id)")
                }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())
            
            Text("Budget Detail")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Menu {
                Button(action: { showingBudgetSheet = true }) {
                    Label("Edit Details", systemImage: "pencil")
                }
                
                Button(action: { /* set default logic */ }) {
                    Label("Set as Default", systemImage: "star")
                }
                
                Button(role: .destructive, action: { dismiss() }) {
                    Label("Delete Budget", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }
    
    private var limitBox: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("This month's limit")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
                Spacer()
                Text("Remaining")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text("**\(Int(progress * 100))%**")
                    .font(.system(size: 16))
                Spacer()
                Text(formatCurrency(currentBudget.total - currentBudget.spent))
                    .font(.system(size: 16, weight: .semibold))
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.black.opacity(0.05))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(Color.black)
                        .frame(width: geo.size.width * progress, height: 10)
                }
            }
            .frame(height: 10)
            
            HStack {
                Text(formatCurrency(0))
                Spacer()
                Text(formatCurrency(currentBudget.total))
            }
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: "repeat")
                    .font(.system(size: 10))
                HStack(spacing: 4) {
                    Text("Top-up")
                    Text(formatCurrency(currentBudget.total))
                        .fontWeight(.bold)
                    Text("/")
                    Text("1 month")
                        .fontWeight(.bold)
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(.black)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var incomeOutcomeSection: some View {
        HStack(spacing: 8) {
            statusCard(
                title: "Income",
                amount: incomeAmount,
                trend: incomeTrend,
                icon: "arrow.down.circle.fill",
                color: .green
            )
            
            statusCard(
                title: "Outcome",
                amount: outcomeAmount,
                trend: "-1.2%",
                icon: "arrow.up.circle.fill",
                color: .orange
            )
        }
    }
    
    private func statusCard(title: String, amount: Double, trend: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.8))
                
                Spacer()
                
                Text(trend)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(color.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Text(formatCurrency(amount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
    
    private var dailySpendingSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("Daily Spending")
                    .font(.system(size: 16, weight: .bold))
                
                Spacer()
                
                HStack(spacing: 4) {
                    ForEach(SpendingTab.allCases, id: \.self) { tab in
                        Button(action: { 
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                spendingTab = tab 
                            }
                        }) {
                            Text(tab.rawValue)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(spendingTab == tab ? .white : .gray)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    ZStack {
                                        if spendingTab == tab {
                                            Capsule()
                                                .fill(Color.black)
                                                .matchedGeometryEffect(id: "tabPill", in: tabNamespace)
                                        }
                                    }
                                )
                        }
                    }
                }
                .padding(4)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
            }
            
            Chart {
                ForEach(mockSpendingData) { data in
                    BarMark(
                        x: .value("Day", data.day),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(by: .value("Type", data.type))
                    .cornerRadius(4)
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: spendingTab)
            .chartForegroundStyleScale([
                "In": Color.green,
                "Out": Color.orange
            ])
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                        .font(.system(size: 10, weight: .medium))
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 180)
            .chartLegend(.hidden)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 32))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Transactions")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Button(action: {
                    showingHistorySheet = true
                }) {
                    Text("See All")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.gray)
                }
            }
            
            VStack(spacing: 8) {
                let budgetTransactions = Transaction.sampleData.filter { 
                    let bName = $0.budgetName.lowercased()
                    let cName = currentBudget.name.lowercased()
                    return bName.contains(cName) || cName.contains(bName) || bName.prefix(3) == cName.prefix(3)
                }
                
                let displayTransactions = budgetTransactions.isEmpty ? Array(Transaction.sampleData.prefix(4)) : Array(budgetTransactions.prefix(4))
                
                ForEach(displayTransactions) { transaction in
                    TransactionItemView(transaction: transaction)
                }
            }
        }
    }
    
    private var bottomActionButtons: some View {
        HStack(spacing: 8) {
            Button(action: { showingTopUpSheet = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Top-up")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black)
                .clipShape(Capsule())
            }
            .buttonStyle(BouncyButtonStyle())
            
            Button(action: { showingTransferSheet = true }) {
                HStack {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("Transfer")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1))
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 40)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(0.95), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "$\(Int(value))"
    }
    
    private struct SpendingPoint: Identifiable {
        let id = UUID()
        let day: String
        let amount: Double
        let type: String
    }
    
    private var mockSpendingData: [SpendingPoint] {
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        var data: [SpendingPoint] = []
        for day in days {
            data.append(SpendingPoint(day: day, amount: Double.random(in: 40...100), type: "Out"))
            data.append(SpendingPoint(day: day, amount: Double.random(in: 20...60), type: "In"))
        }
        return data
    }
}



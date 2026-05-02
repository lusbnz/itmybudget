import SwiftUI

enum BudgetSortOption: String, CaseIterable {
    case recent = "planning.sort_recent"
    case leastRemaining = "planning.sort_least_remaining"
    
    var localizedName: String {
        self.rawValue.localized
    }
}

struct PlanningView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navState: AppNavigationState
    @Environment(LocalizationManager.self) private var loc
    @State private var budgets: [Budget] = Budget.sampleData
    @State private var goals: [PersonalGoal] = PersonalGoal.sampleData
    @State private var sortOption: BudgetSortOption = .recent
    @State private var isExpanded: Bool = false
    @State private var showDetails: Bool = false
    @State private var showContent: Bool = false
    @State private var showingBudgetSheet: Bool = false
    @State private var selectedBudgetToEdit: Budget? = nil
    @State private var showingGoalSheet: Bool = false
    @State private var selectedGoalToEdit: PersonalGoal? = nil
    @State private var selectedBudgetForDetail: Budget? = nil
    @State private var selectedRecurringTransaction: RecurringExpense? = nil
    
    var sortedBudgets: [Budget] {
        switch sortOption {
        case .recent:
            return budgets.sorted { $0.lastTransactionDate > $1.lastTransactionDate }
        case .leastRemaining:
            return budgets.sorted { ($0.total - $0.spent) < ($1.total - $1.spent) }
        }
    }
    
    var displayedBudgets: [Budget] {
        if isExpanded {
            return sortedBudgets
        } else {
            return Array(sortedBudgets.prefix(5))
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Color.clear
                            .frame(height: 1)
                            .id("top")
                        
                        planningHeader
                        
                        budgetTrackerSection
                        
                        recurringExpensesSection
                        
                        personalGoalsSection
                        
                        Spacer(minLength: 100)
                    }
                }
                .onChange(of: navState.selectedTab) { oldValue, newValue in
                    if newValue == 1 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                proxy.scrollTo("top", anchor: .top)
                            }
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $showingBudgetSheet) {
                BudgetFormSheet(
                    budgetToEdit: selectedBudgetToEdit,
                    onSave: { name, amount in
                        if let edited = selectedBudgetToEdit {
                            if let index = budgets.firstIndex(where: { $0.id == edited.id }) {
                                let updated = Budget(
                                    id: edited.id,
                                    name: name,
                                    spent: edited.spent,
                                    total: amount,
                                    dailyLimit: amount / 30,
                                    nextTopUp: edited.nextTopUp,
                                    lastTransactionDate: Date()
                                )
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    budgets[index] = updated
                                }
                            }
                        } else {
                            let newBudget = Budget(
                                name: name,
                                spent: 0,
                                total: amount,
                                dailyLimit: amount / 30,
                                nextTopUp: "Next month",
                                lastTransactionDate: Date()
                            )
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                budgets.insert(newBudget, at: 0)
                            }
                        }
                    },
                    onDelete: {
                        if let edited = selectedBudgetToEdit {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                budgets.removeAll(where: { $0.id == edited.id })
                            }
                        }
                    }
                )
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showingGoalSheet) {
                GoalFormSheet(
                    goalToEdit: selectedGoalToEdit,
                    budgets: budgets,
                    onSave: { newGoal in
                        if let index = goals.firstIndex(where: { $0.id == newGoal.id }) {
                            goals[index] = newGoal
                        } else {
                            goals.insert(newGoal, at: 0)
                        }
                    },
                    onDelete: {
                        if let edited = selectedGoalToEdit {
                            goals.removeAll(where: { $0.id == edited.id })
                        }
                    }
                )
                .presentationDragIndicator(.visible)
            }
            .fullScreenCover(item: $selectedBudgetForDetail) { budget in
                BudgetDetailView(budget: budget)
            }
            .fullScreenCover(item: $selectedRecurringTransaction) { expense in
                TransactionFormView(
                    transactionToEdit: expense.name == "New Recurring" ? nil : Transaction.from(recurring: expense),
                    startWithRecurring: true
                )
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    @ViewBuilder
    private var planningHeader: some View {
        HStack(spacing: 16) {
            LText("planning.title")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Button(action: {
                selectedBudgetToEdit = nil
                showingBudgetSheet = true
            }) {
                HStack(spacing: 4) {
                    LText("planning.create_new")
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Color.black)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(BouncyButtonStyle())
        }
        .padding(.top, 60)
        .padding(.horizontal, 16)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }

    @ViewBuilder
    private var budgetTrackerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                LText("planning.budget_tracker")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showDetails.toggle()
                        }
                    }) {
                        Image(systemName: showDetails ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 13))
                            .foregroundStyle(showDetails ? .black : .gray)
                            .frame(width: 32, height: 32)
                            .background(Color.white)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    Menu {
                        ForEach(BudgetSortOption.allCases, id: \.self) { option in
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    sortOption = option
                                }
                            }) {
                                HStack {
                                    Text(option.localizedName)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.black)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                ForEach(displayedBudgets) { budget in
                    BudgetItemView(budget: budget, showDetails: showDetails, onTap: {
                        selectedBudgetForDetail = budget
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
                
                if sortedBudgets.count > 5 {
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 4) {
                            LText(isExpanded ? "planning.show_less" : "planning.view_more")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(.gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.4))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .padding(.top, 4)
                }
            }
            .padding(.horizontal, 16)
        }
        .offset(y: showContent ? 0 : 30)
        .opacity(showContent ? 1 : 0)
    }

    @ViewBuilder
    private var recurringExpensesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "planning.recurring_expenses".localized,
                extraActionTitle: "planning.create".localized,
                onExtraAction: {
                    selectedRecurringTransaction = RecurringExpense(
                        name: "New Recurring",
                        amount: 0,
                        frequency: "Monthly",
                        nextDate: "Today",
                        isActive: true,
                        categoryIcon: "repeat"
                    )
                }
            )
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(RecurringExpense.sampleData) { expense in
                        Button(action: {
                            selectedRecurringTransaction = expense
                        }) {
                            RecurringExpenseCard(expense: expense)
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        .offset(y: showContent ? 0 : 40)
        .opacity(showContent ? 1 : 0)
    }

    @ViewBuilder
    private var personalGoalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(
                title: "planning.personal_goals".localized,
                extraActionTitle: "planning.create".localized,
                onExtraAction: {
                    selectedGoalToEdit = nil
                    showingGoalSheet = true
                }
            )
            .padding(.horizontal, 16)
            
            VStack(spacing: 8) {
                ForEach(goals) { goal in
                    PersonalGoalItem(goal: goal, onTap: {
                        selectedGoalToEdit = goal
                        showingGoalSheet = true
                    })
                }
            }
            .padding(.horizontal, 16)
        }
        .offset(y: showContent ? 0 : 50)
        .opacity(showContent ? 1 : 0)
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
}

struct RecurringExpenseCard: View {
    @Environment(LocalizationManager.self) private var loc
    let expense: RecurringExpense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "repeat.circle.fill")
                        .font(.system(size: 16))
                    Text(expense.nextDate)
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                if expense.isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                }
            }
            
            Text(expense.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
                .lineLimit(1)
            
            Text("\(loc.currentLanguage == "vi" ? "" : "$")\(Int(expense.amount))\(loc.currentLanguage == "vi" ? "đ" : "")")
                .font(.system(size: 12))
                .foregroundStyle(.gray)
        }
        .padding(16)
        .frame(width: 180)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

struct PersonalGoalItem: View {
    @Environment(LocalizationManager.self) private var loc
    let goal: PersonalGoal
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "dot.scope")
                .font(.system(size: 16))
                .foregroundStyle(.black)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                
                HStack(alignment: .bottom) {
                    HStack(spacing: 0) {
                        LText("planning.completed_by")
                        Text(goal.targetDate).fontWeight(.bold)
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        Text("\(loc.currentLanguage == "vi" ? "" : "$")\(Int(goal.monthlyAmount))\(loc.currentLanguage == "vi" ? "đ" : "")").fontWeight(.bold)
                        LText("planning.every_month")
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

import SwiftUI

struct GoalFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let goalToEdit: PersonalGoal?
    let budgets: [Budget]
    var onSave: (PersonalGoal) -> Void
    var onDelete: (() -> Void)? = nil
    
    @State private var name: String = ""
    @State private var targetAmount: String = ""
    @State private var selectedBudgetId: UUID?
    @State private var targetMonths: Int = 1
    @State private var isActive: Bool = true
    @State private var isShowingBudgetSelector = false
    
    @Namespace private var tagNamespace
    
    init(goalToEdit: PersonalGoal?, budgets: [Budget], onSave: @escaping (PersonalGoal) -> Void, onDelete: (() -> Void)? = nil) {
        self.goalToEdit = goalToEdit
        self.budgets = budgets
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: goalToEdit?.name ?? "")
        _targetAmount = State(initialValue: goalToEdit != nil ? String(format: "%.0f", goalToEdit!.targetAmount) : "")
        _targetMonths = State(initialValue: goalToEdit?.targetMonths ?? 1)
        _isActive = State(initialValue: goalToEdit?.isActive ?? true)
        _selectedBudgetId = State(initialValue: goalToEdit?.sourceBudgetId)
    }
    
    private var isEditMode: Bool {
        goalToEdit != nil
    }
    
    private var dynamicQuickAmounts: [Double] {
        let base = Double(targetAmount) ?? 1
        let multiplier = (base > 0 && base < 1_000_000) ? base : 1
        return [multiplier * 1000, multiplier * 10000, multiplier * 100000]
    }
    
    private var estimatedMonthlySaving: Double {
        if let amount = Double(targetAmount), amount > 0 {
            return amount / Double(targetMonths)
        }
        return 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Give your goal a name and set your sights on the finish line.")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Goal Name")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        TextField("e.g., Dream House", text: $name)
                            .font(.system(size: 16, weight: .medium))
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Source")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        Button(action: { isShowingBudgetSelector = true }) {
                            HStack {
                                Text(budgets.first(where: { $0.id == selectedBudgetId })?.name ?? "Select Budget")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(selectedBudgetId == nil ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.gray)
                            }
                            .padding(16)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Amount")
                            .font(.system(size: 14, weight: .bold))
                        
                        HStack {
                            TextField("0", text: $targetAmount)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("USD")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.gray)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(dynamicQuickAmounts, id: \.self) { val in
                                    Button(action: {
                                        targetAmount = String(format: "%.0f", val)
                                    }) {
                                        Text("$\(formatCurrency(val))")
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                            )
                                    }
                                    .buttonStyle(BouncyButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Target Date")
                            .font(.system(size: 14, weight: .bold))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach([1, 3, 6, 12], id: \.self) { months in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            targetMonths = months
                                        }
                                    }) {
                                        Text("\(months) months")
                                            .font(.system(size: 12, weight: targetMonths == months ? .bold : .medium))
                                            .foregroundStyle(targetMonths == months ? .white : .black)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(
                                                ZStack {
                                                    if targetMonths == months {
                                                        Capsule()
                                                            .fill(Color.black)
                                                            .matchedGeometryEffect(id: "tagTab", in: tagNamespace)
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
                        }
                    }
                    
                    HStack {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 20, height: 20)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                            
                            Text("Active")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.black)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isActive)
                            .labelsHidden()
                            .tint(.black)
                            .scaleEffect(0.8)
                            .frame(width: 44, height: 28)
                    }
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Estimated Monthly Saving")
                                .font(.system(size: 14, weight: .bold))
                            Spacer()
                            Image(systemName: "sparkles")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)
                        }
                        
                        Text("$\(formatCurrency(estimatedMonthlySaving))")
                            .font(.system(size: 24, weight: .bold))
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.05))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(Color.black)
                                .frame(width: 40, height: 8)
                        }
                        
                        Text("Based on a lifetime starting today.")
                            .font(.system(size: 12).italic())
                            .foregroundStyle(.gray)
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
                    
                    Text("“The secret to getting ahead is getting started.”")
                        .font(.system(size: 12).italic())
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                }
                .padding(20)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: {
                    if let amount = Double(targetAmount), !name.isEmpty {
                        let newGoal = PersonalGoal(
                            id: goalToEdit?.id ?? UUID(),
                            name: name,
                            targetDate: "\(targetMonths) months",
                            targetAmount: amount,
                            targetMonths: targetMonths,
                            monthlyAmount: estimatedMonthlySaving,
                            isActive: isActive,
                            sourceBudgetId: selectedBudgetId
                        )
                        onSave(newGoal)
                        dismiss()
                    }
                }) {
                    Text("Set Target")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                }
                .buttonStyle(BouncyButtonStyle())
                
                Button(action: { dismiss() }) {
                    Text("Maybe later")
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }
                .buttonStyle(BouncyButtonStyle())
            }
            .padding(20)
            .padding(.bottom, 10)
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .onAppear {
            loadGoalData()
        }
        .onChange(of: goalToEdit) { oldValue, newValue in
            loadGoalData()
        }
        .sheet(isPresented: $isShowingBudgetSelector) {
            BudgetSelectorSheet { budget in
                selectedBudgetId = budget.id
            }
            .presentationDetents([.fraction(0.85)])
        }
    }
    
    private func loadGoalData() {
        if let goal = goalToEdit {
            name = goal.name
            targetAmount = String(format: "%.0f", goal.targetAmount)
            targetMonths = goal.targetMonths
            isActive = goal.isActive
            selectedBudgetId = goal.sourceBudgetId
        } else {
            name = ""
            targetAmount = ""
            targetMonths = 1
            isActive = true
            selectedBudgetId = nil
        }
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            Text(isEditMode ? "Update Goal" : "Create Goal")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if isEditMode {
                Menu {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Label("Delete Goal", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 5)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}

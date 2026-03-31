import SwiftUI

struct BudgetFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let budgetToEdit: Budget?
    var onSave: (String, Double) -> Void
    var onDelete: (() -> Void)? = nil
    
    @State private var name: String = ""
    @State private var amount: String = ""
    
    init(budgetToEdit: Budget?, onSave: @escaping (String, Double) -> Void, onDelete: (() -> Void)? = nil) {
        self.budgetToEdit = budgetToEdit
        self.onSave = onSave
        self.onDelete = onDelete
        
        _name = State(initialValue: budgetToEdit?.name ?? "")
        _amount = State(initialValue: budgetToEdit != nil ? String(format: "%.0f", budgetToEdit!.total) : "")
    }
    
    private var isEditMode: Bool {
        budgetToEdit != nil
    }
    
    private var dynamicQuickAmounts: [Double] {
        let base = Double(amount) ?? 1
        let multiplier = (base > 0 && base < 1_000_000) ? base : 1
        return [multiplier * 1000, multiplier * 10000, multiplier * 100000]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Budget Name")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        TextField("e.g., Daily Spending", text: $name)
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
                        Text("Budget Amount")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .bold))
                            
                            Text("VNĐ")
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
                                        amount = String(format: "%.0f", val)
                                    }) {
                                        Text("\(formatCurrency(val)) VNĐ")
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
                }
                .padding(20)
            }
            
            Spacer()
            
            Button(action: {
                if let amt = Double(amount), !name.isEmpty {
                    onSave(name, amt)
                    dismiss()
                }
            }) {
                Text(isEditMode ? "Save changes" : "Create now")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(BouncyButtonStyle())
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
            loadBudgetData()
        }
        .onChange(of: budgetToEdit) { oldValue, newValue in
            loadBudgetData()
        }
    }
    
    private func loadBudgetData() {
        if let budget = budgetToEdit {
            name = budget.name
            amount = String(format: "%.0f", budget.total)
        } else {
            name = ""
            amount = ""
        }
    }
    
    private var header: some View {
        HStack(alignment: .center) {
            Text(isEditMode ? "Edit Budget" : "Create Budget")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            if isEditMode {
                Menu {
                    Button(role: .destructive) {
                        onDelete?()
                        dismiss()
                    } label: {
                        Label("Delete Budget", systemImage: "trash")
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
        .padding(.bottom, 15)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}

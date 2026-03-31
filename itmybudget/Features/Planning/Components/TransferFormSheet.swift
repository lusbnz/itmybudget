import SwiftUI

struct TransferFormSheet: View {
    @Environment(\.dismiss) private var dismiss
    let budgets: [Budget]
    let currentBudget: Budget
    var onConfirm: (Double, UUID) -> Void
    
    @State private var amountString: String = ""
    @State private var selectedSourceBudgetId: UUID?
    
    private let quickAmounts: [Double] = [100000, 200000, 500000, 1000000]
    
    init(budgets: [Budget], currentBudget: Budget, onConfirm: @escaping (Double, UUID) -> Void) {
        self.budgets = budgets
        self.currentBudget = currentBudget
        self.onConfirm = onConfirm
        _selectedSourceBudgetId = State(initialValue: budgets.first(where: { $0.id != currentBudget.id })?.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Text("Move your funds efficiently between your designated budgets.")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, -8)
                    
                    // Amount Field
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Amount")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        HStack {
                            TextField("0", text: $amountString)
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
                        
                        // Quick Amount Selectors
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(quickAmounts, id: \.self) { val in
                                    Button(action: {
                                        amountString = String(format: "%.0f", val)
                                    }) {
                                        Text("\(formatCurrency(val))")
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
                    
                    // Source Budget
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Source Budget")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black.opacity(0.8))
                        
                        Menu {
                            ForEach(budgets.filter { $0.id != currentBudget.id }) { budget in
                                Button(budget.name) {
                                    selectedSourceBudgetId = budget.id
                                }
                            }
                        } label: {
                            HStack {
                                Text(budgets.first(where: { $0.id == selectedSourceBudgetId })?.name ?? "Select Source")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(selectedSourceBudgetId == nil ? .gray : .black)
                                Spacer()
                                Image(systemName: "chevron.down")
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
                    }
                    
                    Text("Moving money between budgets helps you stay on track.")
                        .font(.system(size: 12).italic())
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)
                }
                .padding(20)
            }
            
            Spacer()
            
            // Buttons
            VStack(spacing: 12) {
                Button(action: {
                    if let amount = Double(amountString), let sourceId = selectedSourceBudgetId {
                        onConfirm(amount, sourceId)
                        dismiss()
                    }
                }) {
                    Text("Xác nhận")
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
                        .font(.system(size: 14, weight: .bold))
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
    }
    
    private var header: some View {
        HStack {
            Text("Transfer Funds")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 10)
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}

import SwiftUI

struct BudgetItemView: View {
    let budget: Budget
    var showDetails: Bool = false
    
    var body: some View {
        Button(action: {
            // Budget detail action
        }) {
            VStack(alignment: .leading, spacing: showDetails ? 12 : 8) {
                HStack {
                    Text(budget.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Text("$\(Int(budget.spent)) / $\(Int(budget.total))")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }
                
                if showDetails {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.05))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(budgetColor)
                                .frame(width: geo.size.width * budget.progress, height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Remain: $\(Int(budget.total - budget.spent))")
                            .font(.system(size: 12))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Text("Recommended: $\(Int(budget.dailyLimit)) / day")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Text("Next refill: \(budget.nextTopUp)")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(.gray.opacity(0.8))
                    .padding(.top, -4)
                } else {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.black.opacity(0.05))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(budgetColor)
                                .frame(width: geo.size.width * budget.progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(showDetails ? 16 : 14)
            .background(
                RoundedRectangle(cornerRadius: showDetails ? 24 : 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: showDetails ? 24 : 16)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }
    
    private var budgetColor: Color {
        if budget.progress > 0.9 {
            return .red
        } else if budget.progress > 0.7 {
            return .orange
        } else {
            return .green
        }
    }
}

#Preview {
    BudgetItemView(budget: Budget.sampleData[0])
        .padding()
}

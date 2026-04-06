import SwiftUI

struct TransactionTimelineItem: View {
    let transaction: Transaction
    let isLast: Bool
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(transaction.type == .income ? Color.green.opacity(0.12) : Color.blue.opacity(0.08))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: transaction.isImageIcon ? (transaction.type == .income ? "arrow.up.circle.fill" : "arrow.down.circle.fill") : transaction.icon)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(transaction.type == .income ? Color.green : Color.blue)
                }
                .padding(.top, 4)
                
                if !isLast {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.black.opacity(0.12), Color.black.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 2.0)
                        .frame(maxHeight: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(transaction.name)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                        
                        HStack(spacing: 6) {
                            Text(transaction.dateString)
                            
                            Text("•")
                            Text(transaction.location)
                                .lineLimit(1)
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.gray)
                    }
                    
                    Spacer()
                    
                    Text(transaction.amountString)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(transaction.type == .income ? .green : .black)
                }
                
                HStack(spacing: 8) {
                    Text(transaction.budgetName)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color.black.opacity(0.6))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.04))
                        )
                }
                

            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal, 12)
        .contentShape(Rectangle())
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

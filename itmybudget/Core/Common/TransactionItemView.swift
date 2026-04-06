import SwiftUI

struct TransactionItemView: View {
    let transaction: Transaction
    var onTap: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            HStack(spacing: 12) {
                TransactionIconView(transaction: transaction)
                
                TransactionInfoView(transaction: transaction)
                
                Spacer()
                
                TransactionAmountView(transaction: transaction)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.black.opacity(0.04), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

private struct TransactionIconView: View {
    let transaction: Transaction
    
    var body: some View {
        if transaction.isImageIcon {
            AsyncImage(url: URL(string: transaction.icon)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            )
        } else {
            ZStack {
                Circle()
                    .fill(transaction.type == .income ? Color.green.opacity(0.15) : Color.blue.opacity(0.1))
                
                Image(systemName: transaction.icon)
                    .font(.system(size: 16))
                    .foregroundStyle(transaction.type == .income ? Color.green : Color.blue)
            }
            .frame(width: 36, height: 36)
        }
    }
}

private struct TransactionInfoView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(transaction.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.black)
            
            HStack(spacing: 6) {
                Text(transaction.dateString)
                
                if !transaction.images.isEmpty {
                    Text("•")
                    HStack(spacing: 2) {
                        Text("\(transaction.images.count) Pics")
                    }
                }
                
                Text("•")
                Text(transaction.location)
                    .lineLimit(1)
            }
            .font(.system(size: 10))
            .foregroundStyle(.gray)
        }
    }
}

private struct TransactionAmountView: View {
    let transaction: Transaction
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(transaction.amountString)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(transaction.type == .income ? .green : .black)
            
            Text(transaction.budgetName)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.black.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.05))
                )
        }
    }
}

extension Transaction {
    static var sampleData: [Transaction] {
        let now = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
        let fewDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: now)!
        
        return [
            Transaction(
                name: "Starbucks Coffee",
                description: "Morning coffee",
                date: now,
                images: ["starbucks1"],
                location: "New York, NY",
                amount: 5.50,
                budgetName: "Daily",
                type: .outcome,
                icon: "cup.and.saucer.fill",
                isImageIcon: false
            ),
            Transaction(
                name: "Monthly Salary",
                description: "Salary deposit",
                date: now,
                images: [],
                location: "Remote",
                amount: 5000.00,
                budgetName: "Main",
                type: .income,
                icon: "banknote.fill",
                isImageIcon: false
            ),
            Transaction(
                name: "Apple Store",
                description: "iPhone Case",
                date: yesterday,
                images: ["case1", "case2"],
                location: "Apple Fifth Avenue",
                amount: 49.00,
                budgetName: "Gadgets",
                type: .outcome,
                icon: "https://picsum.photos/200",
                isImageIcon: true
            ),
            Transaction(
                name: "Whole Foods",
                description: "Weekly groceries",
                date: yesterday,
                images: [],
                location: "San Francisco",
                amount: 125.20,
                budgetName: "Groceries",
                type: .outcome,
                icon: "cart.fill",
                isImageIcon: false
            ),
            Transaction(
                name: "Uber",
                description: "Ride to airport",
                date: fewDaysAgo,
                images: [],
                location: "JFK Airport",
                amount: 45.00,
                budgetName: "Travel",
                type: .outcome,
                icon: "car.fill",
                isImageIcon: false
            ),
            Transaction(
                name: "Netflix",
                description: "Monthly subscription",
                date: fewDaysAgo,
                images: [],
                location: "Online",
                amount: 15.99,
                budgetName: "Entertainment",
                type: .outcome,
                icon: "play.tv.fill",
                isImageIcon: false
            )
        ]
    }
}

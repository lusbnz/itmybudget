import Foundation
import SwiftUI

enum TransactionType: String, CaseIterable {
    case all = "Tất cả"
    case income = "Thu nhập"
    case outcome = "Chi tiêu"
    
    var localizedName: String {
        self.rawValue
    }
}

struct Transaction: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let description: String
    let date: Date
    let images: [String]
    let location: String
    let amount: Double
    let budgetName: String
    let type: TransactionType
    let icon: String
    let isImageIcon: Bool
    
    var amountString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "đ"
        formatter.positivePrefix = ""
        formatter.positiveSuffix = "đ"
        formatter.negativePrefix = "-"
        formatter.negativeSuffix = "đ"
        
        let value = type == .income ? amount : -amount
        return formatter.string(from: NSNumber(value: value)) ?? "0đ"
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

extension Transaction {
    static func from(recurring: RecurringExpense) -> Transaction {
        Transaction(
            name: recurring.name,
            description: "",
            date: Date(),
            images: [],
            location: "Chọn vị trí",
            amount: recurring.amount,
            budgetName: "Ngân sách chính",
            type: .outcome,
            icon: recurring.categoryIcon,
            isImageIcon: false
        )
    }
}




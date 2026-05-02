import Foundation
import SwiftUI

enum TransactionType: String, CaseIterable {
    case all = "history.all"
    case income = "budget_detail.income"
    case outcome = "budget_detail.outcome"
    
    var localizedName: String {
        self.rawValue.localized
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
        let isVietnamese = LocalizationManager.shared.currentLanguage == "vi"
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = isVietnamese ? "đ" : "$"
        formatter.positivePrefix = isVietnamese ? "" : "+"
        formatter.positiveSuffix = isVietnamese ? "đ" : ""
        formatter.negativePrefix = isVietnamese ? "-" : "-$"
        formatter.negativeSuffix = isVietnamese ? "đ" : ""
        
        let value = type == .income ? amount : -amount
        return formatter.string(from: NSNumber(value: value)) ?? (isVietnamese ? "0đ" : "$0.00")
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
            location: "Select Location",
            amount: recurring.amount,
            budgetName: "Main Budget",
            type: .outcome,
            icon: recurring.categoryIcon,
            isImageIcon: false
        )
    }
}


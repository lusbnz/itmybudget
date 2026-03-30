import Foundation
import SwiftUI

enum TransactionType: String, CaseIterable {
    case all = "All"
    case income = "Income"
    case outcome = "Outcome"
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
        formatter.currencySymbol = "$"
        let value = type == .outcome ? -amount : amount
        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

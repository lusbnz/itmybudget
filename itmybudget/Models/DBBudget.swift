import Foundation
import SwiftData

@Model
final class DBBudget {
    @Attribute(.unique) var id: Int
    var userId: Int
    var name: String
    var limitStr: String
    var amountStr: String
    var periodType: String
    var startDate: String
    var endDate: String
    var icon: String
    var color: String
    var budgetType: String
    var isActive: Bool
    var spentAmountStr: String
    var createdAt: String
    var updatedAt: String
    
    init(
        id: Int,
        userId: Int,
        name: String,
        limitStr: String,
        amountStr: String,
        periodType: String,
        startDate: String,
        endDate: String,
        icon: String,
        color: String,
        budgetType: String,
        isActive: Bool,
        spentAmountStr: String,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.limitStr = limitStr
        self.amountStr = amountStr
        self.periodType = periodType
        self.startDate = startDate
        self.endDate = endDate
        self.icon = icon
        self.color = color
        self.budgetType = budgetType
        self.isActive = isActive
        self.spentAmountStr = spentAmountStr
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

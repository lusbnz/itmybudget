import SwiftUI

struct PersonalGoal: Identifiable, Equatable {
    let id: UUID
    let name: String
    let targetDate: String
    let targetAmount: Double
    let targetMonths: Int
    let monthlyAmount: Double
    let isActive: Bool
    let sourceBudgetId: UUID?
    
    init(id: UUID = UUID(), name: String, targetDate: String, targetAmount: Double, targetMonths: Int, monthlyAmount: Double, isActive: Bool = true, sourceBudgetId: UUID? = nil) {
        self.id = id
        self.name = name
        self.targetDate = targetDate
        self.targetAmount = targetAmount
        self.targetMonths = targetMonths
        self.monthlyAmount = monthlyAmount
        self.isActive = isActive
        self.sourceBudgetId = sourceBudgetId
    }
}

extension PersonalGoal {
    static var sampleData: [PersonalGoal] {
        return [
            PersonalGoal(name: "MacBook Pro 16\"", targetDate: "Dec 2026", targetAmount: 2500, targetMonths: 10, monthlyAmount: 250, isActive: true),
            PersonalGoal(name: "Summer Japan Trip", targetDate: "Aug 2026", targetAmount: 4800, targetMonths: 12, monthlyAmount: 400, isActive: true),
            PersonalGoal(name: "Emergency Savings", targetDate: "Continuous", targetAmount: 1800, targetMonths: 12, monthlyAmount: 150, isActive: true)
        ]
    }
}

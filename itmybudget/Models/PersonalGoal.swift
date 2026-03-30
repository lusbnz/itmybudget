import SwiftUI

struct PersonalGoal: Identifiable {
    let id = UUID()
    let name: String
    let targetDate: String
    let monthlyAmount: Int
}

extension PersonalGoal {
    static let sampleData = [
        PersonalGoal(name: "MacBook Pro 16\"", targetDate: "Dec 2026", monthlyAmount: 250),
        PersonalGoal(name: "Summer Japan Trip", targetDate: "Aug 2026", monthlyAmount: 400),
        PersonalGoal(name: "Emergency Savings", targetDate: "Continuous", monthlyAmount: 150)
    ]
}

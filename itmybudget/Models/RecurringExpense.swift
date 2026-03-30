import SwiftUI

struct RecurringExpense: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let frequency: String
    let nextDate: String
    let isActive: Bool
    let categoryIcon: String
}

extension RecurringExpense {
    static let sampleData = [
        RecurringExpense(name: "House Rent", amount: 1500, frequency: "Monthly", nextDate: "Apr 01", isActive: true, categoryIcon: "house.fill"),
        RecurringExpense(name: "Spotify Premium", amount: 9.99, frequency: "Monthly", nextDate: "Apr 15", isActive: true, categoryIcon: "music.note"),
        RecurringExpense(name: "Fitness Center", amount: 50.00, frequency: "Monthly", nextDate: "Apr 20", isActive: false, categoryIcon: "figure.walk"),
        RecurringExpense(name: "Electricity Bill", amount: 85.50, frequency: "Monthly", nextDate: "Apr 22", isActive: true, categoryIcon: "bolt.fill"),
        RecurringExpense(name: "Car Insurance", amount: 120.00, frequency: "Monthly", nextDate: "May 05", isActive: true, categoryIcon: "car.fill")
    ]
}

import Foundation

struct Budget: Identifiable, Equatable {
    let id: UUID
    let name: String
    let spent: Double
    let total: Double
    let dailyLimit: Double
    let nextTopUp: String
    let lastTransactionDate: Date
    
    init(id: UUID = UUID(), name: String, spent: Double, total: Double, dailyLimit: Double, nextTopUp: String, lastTransactionDate: Date) {
        self.id = id
        self.name = name
        self.spent = spent
        self.total = total
        self.dailyLimit = dailyLimit
        self.nextTopUp = nextTopUp
        self.lastTransactionDate = lastTransactionDate
    }
    
    var progress: Double {
        total > 0 ? spent / total : 0
    }
    
    var remaining: Double {
        total - spent
    }
}

extension Budget {
    static var sampleData: [Budget] {
        let now = Date()
        return [
            Budget(name: "Daily Spending", spent: 450, total: 1000, dailyLimit: 85, nextTopUp: "Tomorrow", lastTransactionDate: now.addingTimeInterval(-3600)),
            Budget(name: "Shopping", spent: 120, total: 500, dailyLimit: 50, nextTopUp: "in 3 days", lastTransactionDate: now.addingTimeInterval(-72000)),
            Budget(name: "Gadgets", spent: 890, total: 2000, dailyLimit: 150, nextTopUp: "in 1 week", lastTransactionDate: now.addingTimeInterval(-120000)),
            Budget(name: "Dining Out", spent: 300, total: 600, dailyLimit: 40, nextTopUp: "in 2 days", lastTransactionDate: now.addingTimeInterval(-15000)),
            Budget(name: "Groceries", spent: 500, total: 800, dailyLimit: 100, nextTopUp: "next month", lastTransactionDate: now.addingTimeInterval(-4800)),
            Budget(name: "Rent", spent: 2000, total: 2000, dailyLimit: 0, nextTopUp: "in 2 weeks", lastTransactionDate: now.addingTimeInterval(-600000)),
            Budget(name: "Utilities", spent: 150, total: 200, dailyLimit: 10, nextTopUp: "in 5 days", lastTransactionDate: now.addingTimeInterval(-90000)),
            Budget(name: "Entertainment", spent: 50, total: 300, dailyLimit: 30, nextTopUp: "tomorrow evening", lastTransactionDate: now.addingTimeInterval(-18000)),
            Budget(name: "Health", spent: 20, total: 100, dailyLimit: 15, nextTopUp: "next month", lastTransactionDate: now.addingTimeInterval(-86400 * 3)),
            Budget(name: "Travel", spent: 400, total: 1500, dailyLimit: 100, nextTopUp: "in 2 months", lastTransactionDate: now.addingTimeInterval(-86400 * 5))
        ]
    }
}

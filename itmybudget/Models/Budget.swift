import Foundation

struct Budget: Identifiable, Equatable {
    let id: Int
    let name: String
    let spent: Double
    let total: Double
    let dailyLimit: Double
    let nextTopUp: String
    let lastTransactionDate: Date
    
    init(id: Int = 0, name: String, spent: Double, total: Double, dailyLimit: Double, nextTopUp: String, lastTransactionDate: Date) {
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
    static let sampleData: [Budget] = [
        Budget(id: 1, name: "Daily", spent: 450, total: 1000, dailyLimit: 85, nextTopUp: "Tomorrow", lastTransactionDate: Date().addingTimeInterval(-3600)),
        Budget(id: 2, name: "Shopping", spent: 120, total: 500, dailyLimit: 50, nextTopUp: "in 3 days", lastTransactionDate: Date().addingTimeInterval(-72000)),
        Budget(id: 3, name: "Gadgets", spent: 890, total: 2000, dailyLimit: 150, nextTopUp: "in 1 week", lastTransactionDate: Date().addingTimeInterval(-120000)),
        Budget(id: 4, name: "Dining Out", spent: 300, total: 600, dailyLimit: 40, nextTopUp: "in 2 days", lastTransactionDate: Date().addingTimeInterval(-15000)),
        Budget(id: 5, name: "Groceries", spent: 500, total: 800, dailyLimit: 100, nextTopUp: "next month", lastTransactionDate: Date().addingTimeInterval(-4800)),
        Budget(id: 6, name: "Rent", spent: 2000, total: 2000, dailyLimit: 0, nextTopUp: "in 2 weeks", lastTransactionDate: Date().addingTimeInterval(-600000)),
        Budget(id: 7, name: "Utilities", spent: 150, total: 200, dailyLimit: 10, nextTopUp: "in 5 days", lastTransactionDate: Date().addingTimeInterval(-90000)),
        Budget(id: 8, name: "Entertainment", spent: 50, total: 300, dailyLimit: 30, nextTopUp: "tomorrow evening", lastTransactionDate: Date().addingTimeInterval(-18000)),
        Budget(id: 9, name: "Health", spent: 20, total: 100, dailyLimit: 15, nextTopUp: "next month", lastTransactionDate: Date().addingTimeInterval(-86400 * 3)),
        Budget(id: 10, name: "Travel", spent: 400, total: 1500, dailyLimit: 100, nextTopUp: "in 2 months", lastTransactionDate: Date().addingTimeInterval(-86400 * 5))
    ]
}

import Foundation

struct Budget: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let spent: Double
    let total: Double
    let dailyLimit: Double
    let nextTopUp: String
    
    var progress: Double {
        total > 0 ? spent / total : 0
    }
}

extension Budget {
    static var sampleData: [Budget] {
        [
            Budget(name: "Daily", spent: 450, total: 1000, dailyLimit: 85, nextTopUp: "Tomorrow"),
            Budget(name: "Shopping", spent: 120, total: 500, dailyLimit: 50, nextTopUp: "in 3 days"),
            Budget(name: "Gadgets", spent: 890, total: 2000, dailyLimit: 150, nextTopUp: "in 1 week")
        ]
    }
}

import Foundation

struct AppNotification: Identifiable, Hashable {
    let id: Int
    let title: String
    let description: String
    let icon: String
    let date: Date
    var isRead: Bool
    
    init(id: Int = 0, title: String, description: String, icon: String, date: Date, isRead: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.date = date
        self.isRead = isRead
    }
    
    init(from api: APINotification) {
        self.id = api.id
        self.title = api.title
        self.description = api.body
        self.isRead = api.is_read
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.date = formatter.date(from: api.created_at) ?? Date()
        
        // Map icon based on type
        switch api.type {
        case "TRANSACTION_INCOME", "TRANSACTION_EXPENSE":
            self.icon = "dollarsign.circle.fill"
        default:
            self.icon = "bell.fill"
        }
    }
}

extension AppNotification {
    static var sampleData: [AppNotification] {
        let now = Date()
        let calendar = Calendar.current
        
        return [
            AppNotification(
                id: 1,
                title: "Budget reached 80%",
                description: "You've spent $800 of your $1,000 monthly food budget.",
                icon: "chart.pie.fill",
                date: now,
                isRead: false
            ),
            AppNotification(
                id: 2,
                title: "New Achievement!",
                description: "Congratulations! You've saved for 7 days in a row.",
                icon: "trophy.fill",
                date: now.addingTimeInterval(-3600),
                isRead: true
            ),
            AppNotification(
                id: 3,
                title: "Subscription Reminder",
                description: "Your Netflix subscription ($15.99) will be charged tomorrow.",
                icon: "calendar",
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                isRead: false
            ),
            AppNotification(
                id: 4,
                title: "Large Expense Detected",
                description: "A transaction of $500 was recorded in 'Electronics'.",
                icon: "exclamationmark.triangle.fill",
                date: calendar.date(byAdding: .day, value: -1, to: now)!,
                isRead: true
            ),
            AppNotification(
                id: 5,
                title: "Monthly Summary Ready",
                description: "Your financial report for March is now available to view.",
                icon: "doc.text.fill",
                date: calendar.date(byAdding: .day, value: -2, to: now)!,
                isRead: true
            )
        ]
    }
}

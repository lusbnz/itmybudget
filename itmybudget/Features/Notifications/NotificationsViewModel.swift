import SwiftUI
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = AppNotification.sampleData
    @Published var selectedTab: NotificationTab = .all
    
    enum NotificationTab: String, CaseIterable {
        case all = "All"
        case unread = "Unread"
    }
    
    var filteredNotifications: [AppNotification] {
        switch selectedTab {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        }
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    // Grouped by date (relative date string: Today, Yesterday, Date)
    var groupedNotifications: [(String, [AppNotification])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredNotifications) { notification in
            calendar.startOfDay(for: notification.date)
        }
        
        let sortedDates = grouped.keys.sorted(by: >)
        return sortedDates.map { date in
            let dateString: String
            if calendar.isDateInToday(date) {
                dateString = "Today"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                dateString = formatter.string(from: date)
            }
            return (dateString, grouped[date] ?? [])
        }
    }
    
    func markAllAsRead() {
        notifications = notifications.map {
            var n = $0
            n.isRead = true
            return n
        }
    }
    
    func deleteAll() {
        notifications = []
    }
    
    func toggleReadState(for notification: AppNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead.toggle()
        }
    }
}

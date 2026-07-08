import SwiftUI
import Combine

class NotificationsViewModel: ObservableObject {
    @Published var notifications: [AppNotification] = []
    @Published var selectedTab: NotificationTab = .all
    @Published var unreadCount: Int = 0
    
    // Pagination state
    @Published var isLoading = false
    private(set) var currentPage = 0
    private(set) var totalPages = 1
    private let pageSize = 20
    
    var hasReachedEnd: Bool {
        return currentPage >= totalPages
    }
    
    enum NotificationTab: String, CaseIterable {
        case all = "Tất cả"
        case unread = "Chưa đọc"
    }
    
    var filteredNotifications: [AppNotification] {
        switch selectedTab {
        case .all:
            return notifications
        case .unread:
            return notifications.filter { !$0.isRead }
        }
    }
    
    var groupedNotifications: [(String, [AppNotification])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredNotifications) { notification in
            calendar.startOfDay(for: notification.date)
        }
        
        let sortedDates = grouped.keys.sorted(by: >)
        return sortedDates.map { date in
            let dateString: String
            if calendar.isDateInToday(date) {
                dateString = "Hôm nay"
            } else if calendar.isDateInYesterday(date) {
                dateString = "Hôm qua"
            } else {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                dateString = formatter.string(from: date)
            }
            return (dateString, grouped[date] ?? [])
        }
    }
    
    // MARK: - API Calls
    
    @MainActor
    func fetchUnreadCount() {
        Task {
            do {
                let response: APIUnreadCountResponse = try await NetworkManager.shared.request(NotificationEndpoint.getUnreadCount)
                self.unreadCount = response.count
            } catch {
                print("Error fetching unread count: \(error)")
            }
        }
    }
    
    @MainActor
    func fetchNotifications(reset: Bool = false) {
        if reset {
            currentPage = 0
            totalPages = 1
            notifications.removeAll()
        }
        
        guard currentPage < totalPages, !isLoading else { return }
        isLoading = true
        
        Task {
            do {
                let response: APINotificationListResponse = try await NetworkManager.shared.request(
                    NotificationEndpoint.getList(page: currentPage, size: pageSize)
                )
                
                let newNotifications = response.items.map { AppNotification(from: $0) }
                
                if reset {
                    self.notifications = newNotifications
                } else {
                    self.notifications.append(contentsOf: newNotifications)
                }
                
                self.totalPages = response.total_pages
                self.currentPage += 1
                
                self.isLoading = false
            } catch {
                print("Error fetching notifications: \(error)")
                self.isLoading = false
            }
        }
    }
    
    @MainActor
    func markAllAsRead() {
        Task {
            do {
                let _: EmptyResponse = try await NetworkManager.shared.request(NotificationEndpoint.readAll)
                
                // Optimistic update
                self.notifications = self.notifications.map {
                    var n = $0
                    n.isRead = true
                    return n
                }
                self.unreadCount = 0
            } catch {
                print("Error marking all as read: \(error)")
            }
        }
    }
    
    @MainActor
    func toggleReadState(for notification: AppNotification) {
        // Find if it's currently unread, we only have API to mark as read, not unread, 
        // but if it's already read, we might not need to call the API.
        if notification.isRead { return }
        
        Task {
            do {
                // The API returns the updated notification object, we can decode it
                // but for simplicity, we can just use EmptyResponse if we don't need the updated data, 
                // or decode to APINotification. Since we just need to update local state, let's just do optimistic update.
                let _: APINotification = try await NetworkManager.shared.request(NotificationEndpoint.readSingle(id: notification.id))
                
                if let index = self.notifications.firstIndex(where: { $0.id == notification.id }) {
                    self.notifications[index].isRead = true
                    if self.unreadCount > 0 {
                        self.unreadCount -= 1
                    }
                }
            } catch {
                print("Error marking single notification as read: \(error)")
            }
        }
    }
    
    @MainActor
    func delete(notification: AppNotification) {
        Task {
            do {
                let _: EmptyResponse = try await NetworkManager.shared.request(NotificationEndpoint.delete(id: notification.id))
                
                // Optimistic update
                self.notifications.removeAll { $0.id == notification.id }
                if !notification.isRead && self.unreadCount > 0 {
                    self.unreadCount -= 1
                }
            } catch {
                print("Error deleting notification: \(error)")
            }
        }
    }
}

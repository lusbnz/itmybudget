import Foundation

// MARK: - Models

struct APIUnreadCountResponse: Codable {
    let count: Int
}

struct APINotificationListResponse: Codable {
    let items: [APINotification]
    let total: Int
    let page: Int
    let size: Int
    let total_pages: Int
}

struct APINotification: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let title: String
    let body: String
    let type: String
    let is_read: Bool
    let read_at: String?
    let created_at: String
}

// MARK: - Endpoint Definition

enum NotificationEndpoint: APIEndpoint {
    case getUnreadCount
    case getList(page: Int, size: Int)
    case readAll
    case readSingle(id: Int)
    case delete(id: Int)
    
    var path: String {
        switch self {
        case .getUnreadCount:
            return "/notifications/unread-count"
        case .getList:
            return "/notifications/"
        case .readAll:
            return "/notifications/read-all"
        case .readSingle(let id):
            return "/notifications/\(id)/read"
        case .delete(let id):
            return "/notifications/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUnreadCount, .getList:
            return .get
        case .readAll, .readSingle:
            return .patch
        case .delete:
            return .delete
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        return nil
    }
    
    var queryParameters: [String: Any]? {
        switch self {
        case .getList(let page, let size):
            return [
                "page": page,
                "size": size
            ]
        default:
            return nil
        }
    }
}

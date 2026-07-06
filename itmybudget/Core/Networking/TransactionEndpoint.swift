import Foundation

struct APITransactionResponse: Codable {
    let id: Int
    let budget_id: Int?
    let category_id: Int?
    let amount: String
    let type: String
    let note: String?
    let images: [String]?
    let is_deleted: Bool?
    let created_at: String?
    let updated_at: String?
}

struct APIRecentTransactionResponse: Codable {
    let id: Int
    let budget_id: Int?
    let amount: Double
    let type: String
    let category_name: String?
    let note: String?
    let created_at: String?
}

struct APIDensityDayResponse: Codable {
    let date: String
    let count: Int
}

struct APIDensityResponse: Codable {
    let month: Int
    let year: Int
    let days: [APIDensityDayResponse]
}

struct APITransactionListResponse: Codable {
    let items: [APITransactionResponse]
    let total: Int
    let page: Int
    let size: Int
    let total_pages: Int
}

enum TransactionEndpoint: APIEndpoint {
    case list(budgetId: Int? = nil, page: Int = 0, size: Int = 100)
    case recent(limit: Int = 10, type: String? = nil)
    case density(month: Int, year: Int, budgetId: Int? = nil)
    
    var path: String {
        switch self {
        case .list:
            return "/transactions/"
        case .recent:
            return "/transactions/recent"
        case .density:
            return "/transactions/density"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .list, .recent, .density: return .get
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var queryParameters: [String : Any]? {
        switch self {
        case .list(let budgetId, let page, let size):
            var params: [String: Any] = [
                "page": page,
                "size": size
            ]
            if let budgetId = budgetId {
                params["budget_id"] = budgetId
            }
            return params
        case .recent(let limit, let type):
            var params: [String: Any] = ["limit": limit]
            if let type = type {
                params["type"] = type
            }
            return params
        case .density(let month, let year, let budgetId):
            var params: [String: Any] = [
                "month": month,
                "year": year
            ]
            if let budgetId = budgetId {
                params["budget_id"] = budgetId
            }
            return params
        }
    }
    
    var body: Data? {
        return nil
    }
}

import Foundation

struct BudgetCategoryInput: Codable {
    let category_id: Int
    let amount: Double
}

struct BudgetCreateInput: Codable {
    let name: String
    let amount: Double
    let period_type: String
    let start_date: String
    let end_date: String
    let icon: String
    let color: String
    let budget_type: String
    let categories: [BudgetCategoryInput]
}

struct BudgetUpdateInput: Codable {
    let name: String
    let amount: Double
    let period_type: String
    let start_date: String
    let end_date: String
    let icon: String
    let color: String
    let budget_type: String
    let is_active: Bool
    let categories: [BudgetCategoryInput]
}

struct APIBudgetResponse: Codable {
    let id: Int
    let user_id: Int
    let name: String
    let limit: String
    let amount: String
    let period_type: String
    let start_date: String
    let end_date: String
    let icon: String
    let color: String
    let budget_type: String
    let is_active: Bool
    let categories: [BudgetCategoryInput]
    let spent_amount: String
    let created_at: String
    let updated_at: String
}

struct APIBudgetStatusResponse: Codable {
    let budget_id: Int
    let budget_name: String
    let limit: Double
    let spent: Double
    let remaining: Double
    let period_type: String
    let is_over: Bool
}

enum BudgetEndpoint: APIEndpoint {
    case create(name: String, amount: Double, icon: String, color: String)
    case get(id: Int)
    case update(id: Int, name: String, amount: Double, icon: String, color: String, isActive: Bool)
    case delete(id: Int)
    case list
    case status
    
    var path: String {
        switch self {
        case .create, .list:
            return "/budgets/"
        case .get(let id), .update(let id, _, _, _, _, _), .delete(let id):
            return "/budgets/\(id)"
        case .status:
            return "/budgets/status"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create: return .post
        case .get, .list, .status: return .get
        case .update: return .put
        case .delete: return .delete
        }
    }
    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
    
    var queryParameters: [String : Any]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .create(let name, let amount, let icon, let color):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStr = formatter.string(from: Date())
            
            let input = BudgetCreateInput(
                name: name,
                amount: amount,
                period_type: "daily",
                start_date: dateStr,
                end_date: dateStr,
                icon: icon,
                color: color,
                budget_type: "all_spending",
                categories: []
            )
            return try? JSONEncoder().encode(input)
        case .update(_, let name, let amount, let icon, let color, let isActive):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateStr = formatter.string(from: Date())
            
            let input = BudgetUpdateInput(
                name: name,
                amount: amount,
                period_type: "daily",
                start_date: dateStr,
                end_date: dateStr,
                icon: icon,
                color: color,
                budget_type: "all_spending",
                is_active: isActive,
                categories: []
            )
            return try? JSONEncoder().encode(input)
        case .get, .list, .status, .delete:
            return nil
        }
    }
}

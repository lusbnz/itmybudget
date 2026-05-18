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
    let spent_amount: String
    let created_at: String
    let updated_at: String
}

enum BudgetEndpoint: APIEndpoint {
    case create(name: String, amount: Double, icon: String, color: String)
    case list
    
    var path: String {
        switch self {
        case .create, .list:
            return "/budgets/"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create: return .post
        case .list: return .get
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
        case .list:
            return nil
        }
    }
}

import Foundation

struct CategoryCreateInput: Codable {
    let name: String
    let icon: String
    let color: String
}

struct CategoryBulkInput: Codable {
    let categories: [CategoryCreateInput]
}

struct CategoryUpdateInput: Codable {
    let name: String
    let is_hidden: Bool
    let icon: String
    let color: String
}

struct APICategoryResponse: Codable {
    let name: String
    let icon: String
    let color: String
    let id: Int
    let user_id: Int
    let is_default: Bool
    let is_hidden: Bool
    let created_at: String
    let updated_at: String
}

enum CategoryEndpoint: APIEndpoint {
    case create(name: String, icon: String, color: String)
    case bulkCreate(categories: [CategoryCreateInput])
    case update(id: Int, name: String, isHidden: Bool, icon: String, color: String)
    case list
    
    var path: String {
        switch self {
        case .create, .list:
            return "/categories/"
        case .bulkCreate:
            return "/categories/bulk"
        case .update(let id, _, _, _, _):
            return "/categories/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .create, .bulkCreate: return .post
        case .update: return .put
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
        case .create(let name, let icon, let color):
            return try? JSONEncoder().encode(CategoryCreateInput(name: name, icon: icon, color: color))
        case .bulkCreate(let categories):
            return try? JSONEncoder().encode(CategoryBulkInput(categories: categories))
        case .update(_, let name, let isHidden, let icon, let color):
            return try? JSONEncoder().encode(CategoryUpdateInput(name: name, is_hidden: isHidden, icon: icon, color: color))
        case .list:
            return nil
        }
    }
}

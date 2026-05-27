import Foundation

struct APIUserResponse: Codable {
    let email: String
    let full_name: String?
    let is_active: Bool?
    let id: Int
    let is_superuser: Bool?
    let is_new_user: Bool?
    let avatar_url: String?
    let provider: String?
    let created_at: String?
    let updated_at: String?
}

struct UpdateMeInput: Codable {
    let full_name: String?
    let password: String?
    let is_active: Bool?
}

struct UpdateOnboardingInput: Codable {
    let is_new_user: Bool
    let extra: [String: String]?
}

enum UserEndpoint: APIEndpoint {
    case me
    case updateMe(UpdateMeInput)
    case updateAvatar(Data, fileName: String, mimeType: String)
    case updateOnboarding(UpdateOnboardingInput)
    
    var path: String {
        switch self {
        case .me, .updateMe:
            return "/users/me"
        case .updateAvatar:
            return "/users/me/avatar"
        case .updateOnboarding:
            return "/users/me/onboarding"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .me: return .get
        case .updateMe, .updateAvatar, .updateOnboarding: return .patch
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .updateAvatar(_, _, _):
            return ["Content-Type": "multipart/form-data; boundary=Boundary-itmybudget-upload"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var queryParameters: [String : Any]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .me:
            return nil
        case .updateMe(let input):
            return try? JSONEncoder().encode(input)
        case .updateOnboarding(let input):
            return try? JSONEncoder().encode(input)
        case .updateAvatar(let data, let fileName, let mimeType):
            let boundary = "Boundary-itmybudget-upload"
            var bodyData = Data()
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
            bodyData.append(data)
            bodyData.append("\r\n".data(using: .utf8)!)
            bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)
            return bodyData
        }
    }
}


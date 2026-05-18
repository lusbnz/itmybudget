import Foundation

enum AuthEndpoint: APIEndpoint {
    case login(String, String)
    case register(UserRegister)
    case refreshToken(String)
    case social(String)
    
    var path: String {
        switch self {
        case .login: return "/auth/login"
        case .register: return "/auth/register"
        case .refreshToken: return "/auth/refresh"
        case .social: return "/auth/social"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .register, .refreshToken, .social: return .post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .login:
            return ["Content-Type": "application/x-www-form-urlencoded"]
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var queryParameters: [String : Any]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .login(let username, let password):
            let bodyString = "username=\(username)&password=\(password)"
            return bodyString.data(using: .utf8)
        case .register(let user):
            return try? JSONEncoder().encode(user)
        case .refreshToken(let token):
            return try? JSONEncoder().encode(["refresh_token": token])
        case .social(let idToken):
            return try? JSONEncoder().encode(["id_token": idToken])
        }
    }
}

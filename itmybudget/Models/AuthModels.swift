import Foundation

struct UserRegister: Codable {
    let email: String
    let full_name: String?
    let password: String
    let confirm_password: String
}

struct AuthToken: Codable {
    let access_token: String
    let refresh_token: String
    let token_type: String
}

struct UserResponse: Codable {
    let email: String
    let full_name: String?
    let is_active: Bool
    let id: Int
    let is_superuser: Bool
    let avatar_url: String?
    let provider: String
    let created_at: String
    let updated_at: String
}

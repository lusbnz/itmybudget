import Foundation
import SwiftData

@Model
final class DBUser {
    @Attribute(.unique) var id: Int
    var email: String
    var fullName: String?
    var isActive: Bool?
    var isSuperuser: Bool?
    var isNewUser: Bool?
    var avatarUrl: String?
    var provider: String?
    var createdAt: String?
    var updatedAt: String?
    
    init(id: Int, email: String, fullName: String?, isActive: Bool?, isSuperuser: Bool?, isNewUser: Bool?, avatarUrl: String?, provider: String?, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.isActive = isActive
        self.isSuperuser = isSuperuser
        self.isNewUser = isNewUser
        self.avatarUrl = avatarUrl
        self.provider = provider
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

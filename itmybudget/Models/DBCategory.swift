import Foundation
import SwiftData

@Model
final class DBCategory {
    @Attribute(.unique) var id: Int
    var name: String
    var icon: String
    var colorHex: String
    var userId: Int
    var isDefault: Bool
    var isHidden: Bool
    var createdAt: String
    var updatedAt: String
    
    init(
        id: Int,
        name: String,
        icon: String,
        colorHex: String,
        userId: Int,
        isDefault: Bool,
        isHidden: Bool,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.userId = userId
        self.isDefault = isDefault
        self.isHidden = isHidden
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

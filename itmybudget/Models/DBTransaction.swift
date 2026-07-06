import Foundation
import SwiftData

@Model
final class DBTransaction {
    @Attribute(.unique) var id: Int
    var budgetId: Int?
    var categoryId: Int?
    var amount: Double
    var type: String
    var note: String?
    var categoryName: String?
    var images: [String]?
    var createdAt: String?
    var updatedAt: String?
    
    init(
        id: Int,
        budgetId: Int? = nil,
        categoryId: Int? = nil,
        amount: Double,
        type: String,
        note: String? = nil,
        categoryName: String? = nil,
        images: [String]? = nil,
        createdAt: String? = nil,
        updatedAt: String? = nil
    ) {
        self.id = id
        self.budgetId = budgetId
        self.categoryId = categoryId
        self.amount = amount
        self.type = type
        self.note = note
        self.categoryName = categoryName
        self.images = images
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

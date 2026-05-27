import SwiftUI

struct Category: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    var isActive: Bool
}

extension Category {
    static var sampleData: [Category] {
        [
            Category(name: "categories.food_drink".localized, icon: "cup.and.saucer.fill", color: .orange, isActive: true),
            Category(name: "categories.shopping".localized, icon: "cart.fill", color: .blue, isActive: true),
            Category(name: "categories.transport".localized, icon: "car.fill", color: .green, isActive: true),
            Category(name: "categories.entertainment".localized, icon: "popcorn.fill", color: .purple, isActive: true),
            Category(name: "categories.health".localized, icon: "heart.fill", color: .red, isActive: false),
            Category(name: "categories.education".localized, icon: "book.fill", color: .teal, isActive: true),
            Category(name: "categories.home".localized, icon: "house.fill", color: .brown, isActive: true),
            Category(name: "categories.gifts".localized, icon: "gift.fill", color: .pink, isActive: false)
        ]
    }
}

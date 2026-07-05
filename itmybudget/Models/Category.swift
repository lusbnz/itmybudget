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
            Category(name: "Ăn uống", icon: "cup.and.saucer.fill", color: .orange, isActive: true),
            Category(name: "Mua sắm", icon: "cart.fill", color: .blue, isActive: true),
            Category(name: "Di chuyển", icon: "car.fill", color: .green, isActive: true),
            Category(name: "Giải trí", icon: "popcorn.fill", color: .purple, isActive: true),
            Category(name: "Sức khỏe", icon: "heart.fill", color: .red, isActive: false),
            Category(name: "Giáo dục", icon: "book.fill", color: .teal, isActive: true),
            Category(name: "Nhà cửa", icon: "house.fill", color: .brown, isActive: true),
            Category(name: "Quà tặng", icon: "gift.fill", color: .pink, isActive: false)
        ]
    }
}

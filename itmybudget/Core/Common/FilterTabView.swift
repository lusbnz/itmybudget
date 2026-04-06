import SwiftUI

struct FilterTabView: View {
    let title: String
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? .white : .gray)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(Color.black)
                                .matchedGeometryEffect(id: "filterTab", in: namespace)
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.8))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                                )
                        }
                    }
                )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

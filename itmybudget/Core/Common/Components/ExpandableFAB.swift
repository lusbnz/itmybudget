import SwiftUI

struct ExpandableFAB: View {
    @Binding var isExpanded: Bool
    var onManual: () -> Void
    var onChat: () -> Void
    var onCamera: () -> Void
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if isExpanded {
                fabSubButton(icon: "square.and.pencil", label: "Manual", action: onManual)
                    .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                
                fabSubButton(icon: "camera.fill", label: "Camera", action: onCamera)
                    .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))

                fabSubButton(icon: "bubble.left.and.bubble.right.fill", label: "Chat", action: onChat)
                    .transition(.move(edge: .bottom).combined(with: .opacity).combined(with: .scale))
                
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            colors: isExpanded ? [Color.gray.opacity(0.8), Color.gray.opacity(0.5)] : [Color(red: 0.15, green: 0.15, blue: 0.15), Color(red: 0.3, green: 0.3, blue: 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .shadow(color: (isExpanded ? Color.gray : Color.black).opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
    }
    
    @ViewBuilder
    private func fabSubButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 12) {
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            
            Button(action: action) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.15, green: 0.15, blue: 0.15), Color(red: 0.3, green: 0.3, blue: 0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: (isExpanded ? Color.gray : Color.black).opacity(0.2), radius: 10, x: 0, y: 5)
            }
        }
    }
}

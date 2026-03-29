import SwiftUI

struct AIInsightCarousel: View {
    var body: some View {
        AIInsightCard(
            content: "Every time you go out for drinks on Friday night, you usually spend another **$20** on *online shopping* on Saturday. Watch out for this 'combo'!",
            cta: "View Journey Details"
        )
    }
}

struct AIInsightCard: View {
    let content: String
    let cta: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(LocalizedStringKey(content))
                .font(.system(size: 12, weight: .medium))
                .lineSpacing(4)
                .foregroundStyle(.white.opacity(0.95))
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: {}) {
                HStack(spacing: 4) {
                    Text(cta)
                        .font(.system(size: 12, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 12, weight: .bold))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(.white.opacity(0.3), lineWidth: 0.5)
                )
                .foregroundStyle(.white)
            }
            .buttonStyle(CardButtonStyle())
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.7, blue: 0.6),
                        Color(red: 0.95, green: 0.6, blue: 0.5),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                    .offset(x: 100, y: -50)
                
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .blur(radius: 40)
                    .offset(x: -80, y: 60)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(color: Color.orange.opacity(0.2), radius: 15, x: 0, y: 8)
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

import SwiftUI

extension Color {
    var hexString: String {
        switch self {
        case .orange: return "#FF9500"
        case .blue: return "#007AFF"
        case .green: return "#34C759"
        case .purple: return "#AF52DE"
        case .red: return "#FF3B30"
        case .teal: return "#30B0C7"
        case .brown: return "#A2845E"
        case .pink: return "#FF2D55"
        case .cyan: return "#32ADE6"
        case .indigo: return "#5856D6"
        case .mint: return "#00C7BE"
        case .yellow: return "#FFCC00"
        case .gray: return "#8E8E93"
        case .black: return "#000000"
        default: return "#8E8E93"
        }
    }
    
    static func from(hex: String) -> Color {
        switch hex.uppercased() {
        case "#FF9500": return .orange
        case "#007AFF": return .blue
        case "#34C759": return .green
        case "#AF52DE": return .purple
        case "#FF3B30": return .red
        case "#30B0C7": return .teal
        case "#A2845E": return .brown
        case "#FF2D55": return .pink
        case "#32ADE6": return .cyan
        case "#5856D6": return .indigo
        case "#00C7BE": return .mint
        case "#FFCC00": return .yellow
        case "#8E8E93": return .gray
        case "#000000": return .black
        default: return .gray
        }
    }
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

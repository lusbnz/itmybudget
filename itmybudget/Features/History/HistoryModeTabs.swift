import SwiftUI

struct HistoryModeTabs: View {
    @Binding var selectedMode: HistoryMode
    var showContent: Bool
    @Namespace private var ns
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(HistoryMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedMode == mode ? .white : .black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            ZStack {
                                if selectedMode == mode {
                                    Capsule()
                                        .fill(Color.black)
                                        .matchedGeometryEffect(id: "modePill", in: ns)
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(Color.white)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .offset(y: showContent ? 0 : 15)
        .opacity(showContent ? 1 : 0)
    }
}

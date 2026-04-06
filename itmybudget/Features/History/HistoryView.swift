import SwiftUI

enum HistoryMode: String, CaseIterable {
    case timeline = "Timeline"
    case calendar = "Calendar"
}

struct HistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMode: HistoryMode = .timeline
    @Namespace private var modeNamespace
    @State private var showContent = false
    @State private var showSearch = false
    @State private var showFilter = false
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            modeTabs
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if selectedMode == .timeline {
                        timelineView
                    } else {
                        calendarView
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var modeTabs: some View {
        HStack(spacing: 0) {
            ForEach(HistoryMode.allCases, id: \.self) { mode in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedMode = mode
                    }
                }) {
                    Text(mode.rawValue)
                        .font(.system(size: 13, weight: selectedMode == mode ? .semibold : .medium))
                        .foregroundStyle(selectedMode == mode ? .white : .gray)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            ZStack {
                                if selectedMode == mode {
                                    Capsule()
                                        .fill(Color.black)
                                        .matchedGeometryEffect(id: "historyMode", in: modeNamespace)
                                }
                            }
                        )
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.5))
                .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .offset(y: showContent ? 0 : 15)
        .opacity(showContent ? 1 : 0)
    }

    @ViewBuilder
    private var timelineView: some View {
        VStack(spacing: 24) {
            spendingIntensitySection
            
            VStack(spacing: 12) {
                Image(systemName: "tray.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.gray.opacity(0.4))
                
                Text("No transactions yet")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            .padding(.top, 20)
        }
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }

    private var spendingIntensitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spending Intensity")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 24) {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 8), spacing: 10) {
                    ForEach(0..<30) { i in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(intensityColor(for: i))
                            .aspectRatio(1, contentMode: .fill)
                    }
                }
                
                HStack(spacing: 40) {
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(intensityColor(forLevel: 0))
                            .frame(width: 20, height: 20)
                        Text("No Spend")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(intensityColor(forLevel: 4))
                            .frame(width: 20, height: 20)
                        Text("High Intensity")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.black)
                    }
                    Spacer()
                }
            }
        }
        .padding(.top, 20)
    }

    private func intensityColor(for index: Int) -> Color {
        // Balanced distribution for demo
        let weights = [0, 0, 0, 0, 1, 1, 2, 2, 3, 4]
        let level = weights.randomElement() ?? 0
        return intensityColor(forLevel: level)
    }

    private func intensityColor(forLevel level: Int) -> Color {
        // Using a warm theme color (Orange) for spending intensity
        switch level {
        case 0: return Color.black.opacity(0.06)
        case 1: return Color.orange.opacity(0.1)
        case 2: return Color.orange.opacity(0.25)
        case 3: return Color.orange.opacity(0.45)
        case 4: return Color.orange.opacity(0.7)
        default: return Color.black.opacity(0.06)
        }
    }

    @ViewBuilder
    private var calendarView: some View {
        VStack(spacing: 12) {
            Image(systemName: "calendar")
                .font(.system(size: 40))
                .foregroundStyle(.gray.opacity(0.4))
            
            Text("Calendar view coming soon")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
        }
        .padding(.top, 100)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
    
    private var header: some View {
        HStack {
            Text("History")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()

            HStack(spacing: 12) {
                Button(action: {
                    showSearch.toggle()
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
                
                Button(action: {
                    showFilter = true
                }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                }
                .buttonStyle(BouncyButtonStyle())
                .offset(y: showContent ? 0 : 10)
                .opacity(showContent ? 1 : 0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
}

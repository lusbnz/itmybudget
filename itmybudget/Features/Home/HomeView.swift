import SwiftUI
import Charts

struct PulseData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let isPrediction: Bool
}

struct HomeView: View {
    @State private var showHeader: Bool = false
    @State private var showSections: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        HStack(spacing: 12) {
                            Text("Quoc Viet")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.black)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 14))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.orange, .red],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                Text("12")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.black)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(.orange.opacity(0.12))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(.orange.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .offset(y: showHeader ? 0 : 10)
                        .opacity(showHeader ? 1 : 0)
                        
                        Spacer()
                        
                        Button(action: {
                        }) {
                            Image(systemName: "bell.fill")
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
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .offset(y: showHeader ? 0 : 10)
                        .opacity(showHeader ? 1 : 0)
                    }
                                                
                    HStack(spacing: 8) {
                        Text("29 March 2026")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 12)
                    .offset(y: showHeader ? 0 : 5)
                    .opacity(showHeader ? 1 : 0)
                
                    HStack(spacing: 8) {
                        badgeTag(text: "Savings Master", color: .orange)
                        badgeTag(text: "Saving Streak", color: .green)
                    }
                    .padding(.bottom, 24)
                    .offset(y: showHeader ? 0 : 5)
                    .opacity(showHeader ? 1 : 0)
                
                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(
                            title: "Weekly Overview",
                        )
                        
                        AIInsightCarousel()
                    }
                    .padding(.bottom, 24)
                    .offset(y: showSections ? 0 : 20)
                    .opacity(showSections ? 1 : 0)

                    VStack(alignment: .leading, spacing: 12) {
                        sectionHeader(
                            title: "Financial Pulse",
                        )
                        
                        HStack(spacing: 12) {
                            FinancialPulseCard(
                                title: "Balance",
                                value: "$12.450",
                                trend: "+2.4%",
                                color: .teal,
                                data: balanceSampleData
                            )
                            
                            FinancialPulseCard(
                                title: "Burn Rate",
                                value: "$85",
                                subtitle: "/day",
                                trend: "-15%",
                                color: .orange,
                                data: burnRateSampleData
                            )
                        }
                    }
                    .padding(.bottom, 24)
                    .offset(y: showSections ? 0 : 20)
                    .opacity(showSections ? 1 : 0)

                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 60)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .ignoresSafeArea(edges: .top)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarBackground(.hidden, for: .tabBar)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                showHeader = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                showSections = true
            }
        }
    }
    
    @ViewBuilder
    private func sectionHeader(title: String) -> some View {
        HStack(alignment: .center, spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
            }
        }
    }

    @ViewBuilder
    private func badgeTag(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.25), lineWidth: 1)
            )
    }
}

struct FinancialPulseCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let trend: String
    let color: Color
    let data: [PulseData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.gray)
                Spacer()
                Text(trend)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .bottom, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.gray)
                        .padding(.bottom, 2)
                }
            }
            
            Chart {
                ForEach(data) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Value", point.value)
                    )
                }
                .foregroundStyle(color)
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 50)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.white.opacity(0.9))
                
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.black.opacity(0.05), lineWidth: 1)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.06), radius: 15, x: 0, y: 8)
    }
}

extension HomeView {
    private var balanceSampleData: [PulseData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<12).map { i in
            PulseData(
                date: calendar.date(byAdding: .day, value: i - 11, to: now)!,
                value: Double.random(in: 10000...12500),
                isPrediction: false
            )
        }
    }
    
    private var burnRateSampleData: [PulseData] {
        let calendar = Calendar.current
        let now = Date()
        return (0..<12).map { i in
            PulseData(
                date: calendar.date(byAdding: .day, value: i - 11, to: now)!,
                value: Double.random(in: 60...100),
                isPrediction: false
            )
        }
    }
}

extension Color {
    static let emerald = Color(red: 0.06, green: 0.69, blue: 0.44)
}

struct BouncyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

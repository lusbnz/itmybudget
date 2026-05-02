import SwiftUI
import Charts

struct JourneyDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            LText("analytics_detail.spending_journey")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Image(systemName: "figure.walk")
                                .font(.system(size: 18))
                                .foregroundStyle(.orange)
                        }
                        
                        LText("analytics_detail.journey_insight")
                            .font(.system(size: 13))
                            .lineSpacing(4)
                            .foregroundStyle(.black.opacity(0.7))
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        LText("analytics_detail.journey_breakdown")
                            .font(.system(size: 14, weight: .bold))
                        
                        ForEach(1...3, id: \.self) { i in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle().fill(Color.orange.opacity(0.1)).frame(width: 40, height: 40)
                                    Text("\(i)").font(.system(size: 14, weight: .bold)).foregroundStyle(.orange)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(i == 1 ? "analytics_detail.friday_afternoon".localized : (i == 2 ? "analytics_detail.friday_evening".localized : "analytics_detail.saturday_morning".localized))
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(i == 1 ? "analytics_detail.coffee_snacks".localized : (i == 2 ? "analytics_detail.drinks_friends".localized : "analytics_detail.shopping_spree".localized))
                                        .font(.system(size: 12))
                                        .foregroundStyle(.gray)
                                }
                                
                                Spacer()
                                
                                Text("$\(i * 15)")
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.bottom, 24)
                .padding(.horizontal, 24)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                LText(title)
                    .font(.system(size: 22, weight: .bold))
                LText("analytics_detail.habit_journey")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(24)
    }
}

struct AnalyticDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        LText("analytics_detail.spending_breakdown")
                            .font(.system(size: 16, weight: .bold))
                        
                        Chart {
                            BarMark(x: .value("Day", "Mon"), y: .value("Amount", 120))
                            BarMark(x: .value("Day", "Tue"), y: .value("Amount", 90))
                            BarMark(x: .value("Day", "Wed"), y: .value("Amount", 150))
                            BarMark(x: .value("Day", "Thu"), y: .value("Amount", 80))
                            BarMark(x: .value("Day", "Fri"), y: .value("Amount", 240))
                                .foregroundStyle(.orange)
                            BarMark(x: .value("Day", "Sat"), y: .value("Amount", 400))
                                .foregroundStyle(.orange)
                            BarMark(x: .value("Day", "Sun"), y: .value("Amount", 180))
                        }
                        .foregroundStyle(.blue.opacity(0.8))
                        .frame(height: 200)
                        
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                            LText("analytics_detail.weekend_insight")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 5)
                    .overlay(RoundedRectangle(cornerRadius: 32).stroke(Color.black.opacity(0.05), lineWidth: 1))
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        comparisonstatBox(title: "analytics_detail.this_month".localized, value: "$1,240", diff: "+12%", isUp: true)
                        comparisonstatBox(title: "analytics_detail.avg_monthly".localized, value: "$980", diff: "-5%", isUp: false)
                        comparisonstatBox(title: "analytics_detail.highest_spending".localized, value: "analytics_detail.saturdays".localized, diff: nil, isUp: true)
                        comparisonstatBox(title: "analytics_detail.budget_status".localized, value: "analytics_detail.over_budget".localized, diff: nil, isUp: true)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(24)
            }
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                LText(title)
                    .font(.system(size: 22, weight: .bold))
                LText("analytics_detail.financial_habits")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(24)
    }
    
    private func comparisonstatBox(title: String, value: String, diff: String?, isUp: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            LText(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.gray)
            
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                
                if let diff = diff {
                    Text(diff)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(isUp ? .red : .green)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }
}

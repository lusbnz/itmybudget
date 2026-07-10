import SwiftUI
import Charts

enum AnalyticsTab: String, CaseIterable {
    case currentMonth = "April 2026"
    case lastWeek = "Tuần trước"
    case lastMonth = "Tháng trước"
    case lastQuarter = "Quý trước"
    case lastYear = "Năm trước"
    
    var localizedName: String {
        self.rawValue
    }
}

struct SpendingCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let amount: Double
    let percentage: Int
    let color: Color
    let status: String?
}

struct TrendData: Identifiable {
    let id = UUID()
    let period: String
    let amount: Double
}

struct AnalyticsView: View {

    @State private var selectedTab: AnalyticsTab = .currentMonth
    @Namespace private var tabNamespace
    @State private var showDatePicker = false
    @State private var showContent = false
    @State private var showingAnalyticDetail = false
    
    @State private var currentTotalSpending: String = "0đ"
    @State private var transactionTrendData: [TrendData] = []
    
    private var spendingCategories: [SpendingCategory] {
        [
            SpendingCategory(name: "Ăn uống", icon: "cup.and.saucer.fill", amount: 450, percentage: 45, color: .orange, status: "Cảnh báo"),
            SpendingCategory(name: "Mua sắm", icon: "cart.fill", amount: 250, percentage: 25, color: .blue, status: "Đúng kế hoạch"),
            SpendingCategory(name: "Di chuyển", icon: "car.fill", amount: 150, percentage: 15, color: .green, status: "Tốt"),
            SpendingCategory(name: "Giải trí", icon: "popcorn.fill", amount: 100, percentage: 10, color: .purple, status: "Đúng kế hoạch"),
            SpendingCategory(name: "Khác", icon: "ellipsis.circle.fill", amount: 50, percentage: 5, color: .gray, status: "Tốt")
        ]
    }
    
    private var mockTrendData: [TrendData] {
        [
            TrendData(period: "Week 1", amount: 1200),
            TrendData(period: "Week 2", amount: 800),
            TrendData(period: "Week 3", amount: 1500),
            TrendData(period: "Week 4", amount: 1650)
        ]
    }
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Color.clear
                            .frame(height: 1)
                            .id("top")
                        
                        header
                        
                        categoryTabs
                        
                        spendingOverview
                        
                        statsRow
                        
                        aiInsightCarousel
                        
                        transactionTrends
                        
                        topSpendingCategories
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6)) {
                        showContent = true
                    }
                }
                .task {
                    await fetchAnalyticsData()
                }
                .sheet(isPresented: $showDatePicker) {
                    dateRangePickerSheet
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $showingAnalyticDetail) {
                    AnalyticDetailSheet(title: "Detailed Analysis")
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Phân tích tài chính")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
            Spacer()
        }
        .padding(.top, 60)
        .padding(.horizontal, 16)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
    
    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                    Button(action: {
                        if tab == .currentMonth {
                            showDatePicker = true
                        }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 4) {
                            Text(tab.rawValue)
                                .font(.system(size: 12, weight: selectedTab == tab ? .semibold : .medium))
                            
                            if tab == .currentMonth {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 8, weight: .bold))
                            }
                        }
                        .foregroundStyle(selectedTab == tab ? .white : .gray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            ZStack {
                                if selectedTab == tab {
                                    Capsule()
                                        .fill(Color.black)
                                        .matchedGeometryEffect(id: "analyticsTab", in: tabNamespace)
                                } else {
                                    Capsule()
                                        .fill(Color.white.opacity(0.8))
                                        .overlay(Capsule().stroke(Color.black.opacity(0.05), lineWidth: 1))
                                }
                            }
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .offset(y: showContent ? 0 : 30)
        .opacity(showContent ? 1 : 0)
    }
    
    private var spendingOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tổng quan chi tiêu")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text("+ 2.4% so với kỳ trước")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.red)
            }
            .padding(.horizontal, 16)
            
            VStack(spacing: 24) {
                ZStack {
                    Chart {
                        ForEach(spendingCategories) { category in
                            SectorMark(
                                angle: .value("Amount", category.amount),
                                innerRadius: .ratio(0.65),
                                angularInset: 2
                            )
                            .cornerRadius(8)
                            .foregroundStyle(category.color)
                        }
                    }
                    .frame(height: 200)
                    .chartLegend(.hidden)
                    
                    VStack(spacing: 0) {
                        Text(currentTotalSpending)
                            .font(.system(size: 24, weight: .black))
                        Text("Tổng chi tiêu")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(spendingCategories) { category in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 8, height: 8)
                            
                            Text(category.name)
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                            
                            Spacer()
                            
                            Text("\(category.percentage)%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(.black)
                        }
                    }
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
        .padding(.horizontal, 16)
    }
    
    private var statsRow: some View {
        HStack(spacing: 16) {
            statBox(icon: "arrow.left.arrow.right", title: "Giao dịch", value: "12", diff: "+2.4%", isDiffPositive: true)
            statBox(icon: "chart.line.uptrend.xyaxis", title: "Trung bình/ngày", value: "\("")45\("đ")", diff: "-5%", isDiffPositive: false)
        }
        .padding(.horizontal, 16)
    }
    
    private func statBox(icon: String, title: String, value: String, diff: String, isDiffPositive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.gray)
            }
            
            HStack(alignment: .lastTextBaseline) {
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Text(diff)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(isDiffPositive ? .red : .green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((isDiffPositive ? Color.red : Color.green).opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
    }
    
    private var aiInsightCarousel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Phân tích AI")
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 20)
            
            AIInsightCarousel(cta: nil)
                .padding(.horizontal, 16)
        }
    }
    
    private var transactionTrends: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Xu hướng giao dịch")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Tổng quan giai đoạn")
                    .font(.system(size: 12))
                    .foregroundStyle(.gray)
                
                Chart {
                    let dataToShow = transactionTrendData.isEmpty ? mockTrendData : transactionTrendData
                    ForEach(dataToShow) { data in
                        BarMark(
                            x: .value("Period", data.period),
                            y: .value("Amount", data.amount)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.2, green: 0.8, blue: 0.8), Color(red: 0.1, green: 0.5, blue: 0.7)],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(6)
                    }
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel()
                            .font(.system(size: 10))
                    }
                }
                .chartYAxis(.hidden)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }
    
    private var topSpendingCategories: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danh mục chi tiêu hàng đầu")
                .font(.system(size: 16, weight: .bold))
                .padding(.horizontal, 16)
            
            VStack(spacing: 0) {
                ForEach(spendingCategories.prefix(5)) { category in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(category.color.opacity(0.1)).frame(width: 40, height: 40)
                            Image(systemName: category.icon).font(.system(size: 14)).foregroundStyle(category.color)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.name).font(.system(size: 14, weight: .semibold))
                            HStack(spacing: 4) {
                                Text("\(category.percentage)%")
                                Text("tổng số")
                            }
                                .font(.system(size: 11))
                                .foregroundStyle(.gray)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("\("")\(Int(category.amount))\("đ")")
                                .font(.system(size: 14, weight: .semibold))
                            
                            if let status = category.status {
                                Text(status)
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundStyle(status == "Warning" ? .red : .green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background((status == "Warning" ? Color.red : Color.green).opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.vertical, 14)
                    
                    if category.id != spendingCategories.prefix(5).last?.id {
                        Divider().opacity(0.3)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
            .padding(.horizontal, 16)
        }
    }
    
    @ViewBuilder
    private var dateRangePickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                Text("Chọn khoảng thời gian")
                        .font(.system(size: 20, weight: .bold))
                Text("Lọc phân tích của bạn theo một khoảng thời gian cụ thể")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
            .padding(24)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    DatePicker("", selection: .constant(Date()), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .accentColor(.black)
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 24)
            }
            
            VStack(spacing: 12) {
                Button(action: { showDatePicker = false }) {
                    Text("Áp dụng")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.black)
                        .clipShape(Capsule())
                }
                
                Button(action: { showDatePicker = false }) {
                    Text("Hủy")
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }
            }
            .padding(24)
            .background(Color(red: 1.0, green: 0.98, blue: 0.96))
        }
        .background(Color(red: 1.0, green: 0.98, blue: 0.96).ignoresSafeArea())
    }
}

extension AnalyticsView {
    private func fetchAnalyticsData() async {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let year = calendar.component(.year, from: now)
        
        do {
            async let spendingRes: AverageSpendingResponse? = try? NetworkManager.shared.request(BudgetEndpoint.averageSpendingChart(month: month, year: year))
            async let trendRes: AvgTransactionChartResponse? = try? NetworkManager.shared.request(BudgetEndpoint.avgTransactionChart(viewType: "month", year: year, month: month, date: nil, budgetId: nil))
            
            let sRes = await spendingRes
            let tRes = await trendRes
            
            await MainActor.run {
                if let s = sRes, let last = s.data.last {
                    self.currentTotalSpending = formatHugeNumber(last.average_amount)
                }
                
                if let t = tRes {
                    var newTrends: [TrendData] = []
                    for item in t.data {
                        newTrends.append(TrendData(period: item.label, amount: parseHugeNumber(item.average)))
                    }
                    self.transactionTrendData = newTrends
                }
            }
        }
    }
    
    private func parseHugeNumber(_ string: String) -> Double {
        var str = string.replacingOccurrences(of: "+", with: "")
        while str.hasPrefix("0") && str.count > 1 && !str.hasPrefix("0.") {
            str.removeFirst()
        }
        return Double(str) ?? 0.0
    }
    
    private func formatHugeNumber(_ string: String) -> String {
        var str = string.replacingOccurrences(of: "+", with: "")
        while str.hasPrefix("0") && str.count > 1 && !str.hasPrefix("0.") {
            str.removeFirst()
        }
        
        if let val = Double(str) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.locale = Locale(identifier: "vi_VN")
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: val)) ?? "\(val)đ"
        }
        return str + "đ"
    }
}

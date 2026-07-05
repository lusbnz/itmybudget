import SwiftUI

struct Badge: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let description: String
    let dateEarned: String?
    let color: Color
}

extension Badge {
    static var sampleData: [Badge] {
        [
            // Foundation
            Badge(name: "Khai mở tài chính", category: "Xây dựng nền móng", icon: "sparkles", description: "Tạo giao dịch đầu tiên.", dateEarned: "Mar 12, 2026", color: .blue),
            Badge(name: "Tuần lễ kỷ luật", category: "Xây dựng nền móng", icon: "calendar.badge.check", description: "Ghi chép liên tục trong 7 ngày.", dateEarned: "Feb 28, 2026", color: .orange),
            Badge(name: "Thám tử chi tiêu", category: "Xây dựng nền móng", icon: "magnifyingglass", description: "Phân loại cho tối thiểu 10 chi tiêu trong tháng.", dateEarned: "Jan 15, 2026", color: .purple),
            
            // Control Master
            Badge(name: "Vượt qua cám dỗ", category: "Bậc thầy kiểm soát", icon: "hand.raised.fill", description: "Không phát sinh chi tiêu ăn chơi trong 3 ngày.", dateEarned: "Jan 10, 2026", color: .green),
            Badge(name: "Kỹ sư ngân sách", category: "Bậc thầy kiểm soát", icon: "ruler.fill", description: "Thiết lập ít nhất 5 ngân sách.", dateEarned: "Mar 25, 2026", color: .gray),
            Badge(name: "Cán đích an toàn", category: "Bậc thầy kiểm soát", icon: "checkmark.seal.fill", description: "Kết thúc tháng mà không vượt ngân sách tổng.", dateEarned: "Dec 30, 2025", color: .cyan),
            Badge(name: "Hồi sinh", category: "Bậc thầy kiểm soát", icon: "heart.text.square.fill", description: "Quay lại ghi chép sau một tháng tạm ngưng.", dateEarned: nil, color: .red),
            Badge(name: "Ngày Không Chi Tiêu", category: "Bậc thầy kiểm soát", icon: "nosign", description: "Hoàn thành một ngày không tiêu một đồng nào.", dateEarned: nil, color: .green),
            Badge(name: "Cai Nghiện Mua Sắm", category: "Bậc thầy kiểm soát", icon: "cart.badge.minus", description: "Không phát sinh giao dịch mua sắm online trong 30 ngày.", dateEarned: nil, color: .cyan),
            Badge(name: "Lối Sống Tối Giản", category: "Bậc thầy kiểm soát", icon: "leaf.fill", description: "Tổng số lượng giao dịch chi tiêu trong tháng dưới 20.", dateEarned: nil, color: .green),
            Badge(name: "Tự Kỷ Luật", category: "Bậc thầy kiểm soát", icon: "lock.fill", description: "Không chỉnh sửa hay xóa bất kỳ giao dịch nào trong tuần.", dateEarned: nil, color: .gray),
            Badge(name: "Nước Chảy Đá Mòn", category: "Bậc thầy kiểm soát", icon: "drop.fill", description: "Tiết kiệm được 5% ngân sách mỗi tháng liên tục 3 tháng.", dateEarned: nil, color: .blue),
            Badge(name: "Bức Tường Thành", category: "Bậc thầy kiểm soát", icon: "shield.fill", description: "Không vượt ngân sách bất kỳ danh mục nào trong tháng.", dateEarned: nil, color: .indigo),
            
            // Prosperity & Growth
            Badge(name: "Triệu phú tự thân", category: "Thịnh vượng & Tăng trưởng", icon: "bitcoinsign.circle.fill", description: "Đạt cột mốc tiết kiệm 5 triệu đầu tiên.", dateEarned: nil, color: .yellow),
            Badge(name: "Cỗ máy tích lũy", category: "Thịnh vượng & Tăng trưởng", icon: "engine.combustion.fill", description: "Tăng tỷ lệ tiết kiệm hàng tháng trong 3 tháng.", dateEarned: nil, color: .gray),
            Badge(name: "Nhà đầu tư trẻ", category: "Thịnh vượng & Tăng trưởng", icon: "chart.pie.fill", description: "Bắt đầu phân bổ tiền vào các quỹ đầu tư.", dateEarned: nil, color: .indigo),
            Badge(name: "Cây đại thụ", category: "Thịnh vượng & Tăng trưởng", icon: "tree.fill", description: "Đồng hành cùng app tròn 1 năm.", dateEarned: nil, color: .green),
            Badge(name: "Ngủ Cũng Ra Tiền", category: "Thịnh vượng & Tăng trưởng", icon: "bed.double.fill", description: "Ghi nhận khoản thu nhập thụ động đầu tiên.", dateEarned: nil, color: .purple),
            Badge(name: "Tự Do Tài Chính", category: "Thịnh vượng & Tăng trưởng", icon: "figure.stand.line.dotted.figure.rodeo", description: "Đạt Net Worth gấp 12 lần chi tiêu hàng tháng.", dateEarned: nil, color: .yellow),
            Badge(name: "Phao Cứu Sinh", category: "Thịnh vượng & Tăng trưởng", icon: "lifepreserver.fill", description: "Xây dựng xong Quỹ khẩn cấp (bằng 3 tháng chi tiêu).", dateEarned: nil, color: .orange),
            Badge(name: "Đồ Thị Xanh", category: "Thịnh vượng & Tăng trưởng", icon: "chart.line.uptrend.xyaxis", description: "Net worth tăng trưởng dương liên tục trong 6 tháng.", dateEarned: nil, color: .green),
            Badge(name: "Sứ Giả Cho Đi", category: "Thịnh vượng & Tăng trưởng", icon: "hands.sparkles.fill", description: "Phát sinh giao dịch Từ thiện/Quyên góp.", dateEarned: nil, color: .pink),
            
            // Retention
            Badge(name: "Tuần Lễ Vàng", category: "Tăng cường Retention", icon: "calendar.badge.check", description: "Ghi chép liên tục trong 7 ngày.", dateEarned: nil, color: .orange),
            Badge(name: "Thám Tử Tài Chính", category: "Tăng cường Retention", icon: "magnifyingglass", description: "Phân loại 100% chi tiêu trong tháng.", dateEarned: nil, color: .purple),
            Badge(name: "Kháng Thể Shopping", category: "Tăng cường Retention", icon: "cart.badge.minus", description: "Không chi tiêu vượt định mức Mua sắm.", dateEarned: nil, color: .green),
            Badge(name: "Phượng Hoàng", category: "Tăng cường Retention", icon: "flame.fill", description: "Quay lại ghi chép sau 1 tuần vắng bóng.", dateEarned: nil, color: .red),
            Badge(name: "Cột Mốc Đầu Tiên", category: "Tăng cường Retention", icon: "flag.checkered", description: "Đạt 10% mục tiêu tiết kiệm lớn nhất.", dateEarned: nil, color: .blue),
            Badge(name: "Lão Làng", category: "Tăng cường Retention", icon: "crown.fill", description: "Sử dụng app liên tục trong 365 ngày.", dateEarned: nil, color: .indigo),
            
            // Advanced Habits
            Badge(name: "Bách Nhật Tu Luyện", category: "Thói quen Nâng cao", icon: "flame.fill", description: "Ghi chép liên tục trong 100 ngày.", dateEarned: nil, color: .red),
            Badge(name: "Nhà Thẩm Định", category: "Thói quen Nâng cao", icon: "camera.fill", description: "Đính kèm hình ảnh vào 10 giao dịch.", dateEarned: nil, color: .teal),
            Badge(name: "Tiểu Thuyết Gia", category: "Thói quen Nâng cao", icon: "text.quote", description: "Ghi chú dài hơn 50 ký tự cho một giao dịch.", dateEarned: nil, color: .brown),
            Badge(name: "Nhà Cổ Sinh Vật", category: "Thói quen Nâng cao", icon: "clock.arrow.circlepath", description: "Sửa lại một giao dịch đã tạo từ hơn 30 ngày trước.", dateEarned: nil, color: .gray),
            Badge(name: "Đầu Tàu Ghi Chép", category: "Thói quen Nâng cao", icon: "train.side.front.car", description: "Thêm 10 giao dịch trong cùng một ngày.", dateEarned: nil, color: .orange),
            
            // Secret
            Badge(name: "Chúa Tể Cú Đêm", category: "Huy hiệu Bí ẩn", icon: "moon.zzz.fill", description: "Ghi chép giao dịch vào lúc 2:00 - 4:00 sáng.", dateEarned: nil, color: .purple),
            Badge(name: "Giao Thừa Tài Chính", category: "Huy hiệu Bí ẩn", icon: "fireworks", description: "Mở app và ghi chép lúc 00:00 - 00:01 phút.", dateEarned: nil, color: .red),
            Badge(name: "Số Đẹp Lộc Phát", category: "Huy hiệu Bí ẩn", icon: "number.square.fill", description: "Tạo giao dịch có đuôi 68, 86, 6868...", dateEarned: nil, color: .yellow),
            Badge(name: "Chi Li Từng Đồng", category: "Huy hiệu Bí ẩn", icon: "1.circle.fill", description: "Nhập giao dịch với số tiền cực nhỏ.", dateEarned: nil, color: .teal),
            Badge(name: "Tâm Trí Bất Ổn", category: "Huy hiệu Bí ẩn", icon: "trash.fill", description: "Xóa 3 giao dịch liên tiếp trong vòng 5 phút.", dateEarned: nil, color: .gray),
            Badge(name: "Trà Sữa Vô Cực", category: "Huy hiệu Bí ẩn", icon: "cup.and.saucer.fill", description: "Phát sinh hơn 10 giao dịch cafe/trà sữa trong 1 tháng.", dateEarned: nil, color: .brown),
            Badge(name: "Quỹ Tình Yêu", category: "Huy hiệu Bí ẩn", icon: "heart.fill", description: "Ghi chú có chứa từ khóa 'Người yêu', 'Hẹn hò', 'Crush'.", dateEarned: nil, color: .pink),
            Badge(name: "Sen Chính Hiệu", category: "Huy hiệu Bí ẩn", icon: "pawprint.fill", description: "Chi tiêu cho Thú cưng vượt 10% tổng chi tiêu tháng.", dateEarned: nil, color: .orange),
            Badge(name: "Sinh Nhật Vui Vẻ", category: "Huy hiệu Bí ẩn", icon: "gift.fill", description: "Mở app và ghi chép vào đúng ngày sinh nhật.", dateEarned: nil, color: .pink),
            Badge(name: "Chạm Đáy Nỗi Đau", category: "Huy hiệu Bí ẩn", icon: "battery.25", description: "Số dư tổng tài khoản chỉ còn dưới 5% trước ngày nhận lương.", dateEarned: nil, color: .red),
            Badge(name: "Cơn Mưa Tiền Thưởng", category: "Huy hiệu Bí ẩn", icon: "cloud.heavyrain.fill", description: "Có 3 giao dịch Thu nhập trong cùng 1 tuần.", dateEarned: nil, color: .cyan),
            Badge(name: "Quên Lãng", category: "Huy hiệu Bí ẩn", icon: "questionmark.folder.fill", description: "Không mở app trong 14 ngày rồi quay lại.", dateEarned: nil, color: .gray),
            Badge(name: "Sự Khởi Đầu Mới", category: "Huy hiệu Bí ẩn", icon: "sun.max.fill", description: "Xóa toàn bộ dữ liệu và bắt đầu lại từ đầu.", dateEarned: nil, color: .yellow),
            Badge(name: "Chuyên Gia Săn Sale", category: "Huy hiệu Bí ẩn", icon: "tag.fill", description: "5 giao dịch ghi chú từ khóa 'Sale', 'Khuyến mãi', 'Giảm giá'.", dateEarned: nil, color: .orange)
        ]
    }
}

struct BadgeListView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showContent = false
    
    private var badges: [Badge] {
        Badge.sampleData
    }
    
    private var earnedCount: Int {
        badges.filter { $0.dateEarned != nil }.count
    }
    
    private var badgeCategories: [String] {
        [
            "Xây dựng nền móng",
            "Bậc thầy kiểm soát",
            "Thịnh vượng & Tăng trưởng",
            "Tăng cường Retention",
            "Thói quen Nâng cao",
            "Huy hiệu Bí ẩn"
        ]
    }
    
    private func badges(for category: String) -> [Badge] {
        badges.filter { $0.category == category }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    
                    progressCard
                    
                    ForEach(badgeCategories, id: \.self) { category in
                        if !badges(for: category).isEmpty {
                            badgeSection(title: category, badges: badges(for: category))
                        }
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
            }
            .background(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    showContent = true
                }
            }
        }
    }
    
    private var header: some View {
        HStack {
            Text("Huy hiệu Thành tích")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 25)
        .padding(.bottom, 15)
    }
    
    private var progressCard: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.black.opacity(0.05), lineWidth: 8)
                Circle()
                    .trim(from: 0, to: CGFloat(earnedCount) / CGFloat(badges.count))
                    .stroke(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 0) {
                    Text("\(earnedCount)")
                        .font(.system(size: 20, weight: .bold))
                    Text("/\(badges.count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.gray)
                }
            }
            .frame(width: 70, height: 70)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Cấp độ Đạt được")
                    .font(.system(size: 16, weight: .bold))
                Text("Tiết kiệm nhiều hơn để mở khóa thêm nhiều huy hiệu hiếm!")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.black.opacity(0.05), lineWidth: 1))
        .offset(y: showContent ? 0 : 15)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private func badgeSection(title: String, badges: [Badge]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.gray)
                .padding(.leading, 4)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(badges) { badge in
                    BadgeCard(badge: badge)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .padding(.top, 16)
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
}

struct NoiseView: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                let seed = timeline.date.timeIntervalSince1970
                var rng = SeededRandomNumberGenerator(seed: Int(seed * 1000))
                
                for _ in 0..<200 {
                    let x = Double.random(in: 0...size.width, using: &rng)
                    let y = Double.random(in: 0...size.height, using: &rng)
                    let opacity = Double.random(in: 0.1...0.3, using: &rng)
                    let dotWidth = Double.random(in: 1...4, using: &rng)
                    
                    context.fill(
                        Path(CGRect(x: x, y: y, width: dotWidth, height: 1)),
                        with: .color(Color.black.opacity(opacity))
                    )
                }
            }
        }
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    init(seed: Int) {
        srand48(seed)
    }
    
    func next() -> UInt64 {
        return UInt64(drand48() * Double(UInt64.max))
    }
}

struct BadgeCard: View {
    let badge: Badge
    
    private var isUnlocked: Bool { badge.dateEarned != nil }
    
    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color.opacity(0.12) : Color.gray.opacity(0.05))
                    .frame(width: 64, height: 64)
                
                Image(systemName: badge.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isUnlocked ? badge.color : .gray.opacity(0.3))
                    .blur(radius: isUnlocked ? 0 : 4)
                    .offset(x: isUnlocked ? 0 : CGFloat.random(in: -0.5...0.5))
                
                if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10))
                        .padding(4)
                        .background(Color.white)
                        .clipShape(Circle())
                        .offset(x: 20, y: 20)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        .phaseAnimator([0, 1]) { content, phase in
                            content
                                .scaleEffect(1 + CGFloat(phase) * 0.1)
                        } animation: { phase in
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                        }
                }
            }
            .padding(.top, 4)
            
            VStack(spacing: 4) {
                Text(isUnlocked ? badge.name : "Phần thưởng Bí mật")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isUnlocked ? .black : .gray)
                    .multilineTextAlignment(.center)
                    .blur(radius: isUnlocked ? 0 : 2)
                    .offset(x: isUnlocked ? 0 : CGFloat.random(in: -1...1))
                
                if let date = badge.dateEarned {
                    Text(date)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.green)
                } else {
                    Text(badge.description)
                        .font(.system(size: 10))
                        .foregroundStyle(.gray.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(height: 24)
                        .blur(radius: 2)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .overlay(
            Group {
                if !isUnlocked {
                    NoiseView()
                        .blendMode(.multiply)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
    }
}

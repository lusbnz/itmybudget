import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navState: AppNavigationState
    @Environment(\.modelContext) private var modelContext
    var authManager = AuthManager.shared
    
    @State private var showContent: Bool = false
    @State private var autoDetectLocation: Bool = true
    
    @State private var isShowingEditProfile = false
    @State private var isShowingUpgrade = false
    @State private var isShowingCurrency = false
    @State private var isShowingLogoutAlert = false
    @State private var isShowingCategories = false
    @State private var isShowingBadges = false
    @State private var isShowingGallery = false
    @State private var isShowingDeleteAlert = false
    @State private var isShowingNotifications = false
    @State private var isShowingSuggest = false
    
    var body: some View {
      NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Color.clear
                        .frame(height: 1)
                        .id("top")

                    profileHeader
                    
                    personalInfoCard
                    
                    upgradeBanner
                    
                    transactionImagesSection
                    
                    badgesSection
                    
                    premiumToolsSection
                    
                    permissionsSection
                    
                    dataSection
                    
                    applicationSection
                    
                    accountSection
                    
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
            )
            .ignoresSafeArea(edges: .top)
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    showContent = true
                }
            }
            .task {
                if authManager.currentUser == nil {
                    await authManager.fetchMe(context: modelContext)
                }
            }
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileSheet()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingUpgrade) {
                SubscriptionSheet()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingCurrency) {
                currencySelectionSheet
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingBadges) {
                BadgeListView()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingGallery) {
                TransactionGalleryView()
                    .presentationDragIndicator(.visible)
            }
            .fullScreenCover(isPresented: $isShowingCategories) {
                CategoryListView()
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationSettingsSheet()
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $isShowingSuggest) {
                FeatureSuggestSheet()
                    .presentationDragIndicator(.visible)
            }
            .alert("Đăng xuất", isPresented: $isShowingLogoutAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Đăng xuất", role: .destructive) {
                }
            } message: {
                Text("Bạn có chắc chắn muốn đăng xuất?")
            }
            .alert("Xóa tài khoản", isPresented: $isShowingDeleteAlert) {
                Button("Hủy", role: .cancel) { }
                Button("Xóa", role: .destructive) {
                }
            } message: {
                Text("Bạn có chắc chắn muốn xóa tài khoản? Hành động này là vĩnh viễn và toàn bộ dữ liệu sẽ bị mất.")
            }
        }
    }
    
    @ViewBuilder
    private var profileHeader: some View {
        HStack(spacing: 16) {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }
            .buttonStyle(BouncyButtonStyle())

            Text("Hồ sơ")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
        }
        .padding(.top, 60)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var personalInfoCard: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: authManager.currentUser?.avatar_url ?? "https://i.pravatar.cc/300")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                }
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.black.opacity(0.05), lineWidth: 1))
                
                Button(action: { isShowingEditProfile = true }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.black)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }
                .offset(x: 2, y: 2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(authManager.currentUser?.full_name ?? "User")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                
                Text(authManager.currentUser?.email ?? "")
                    .font(.system(size: 13))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Button(action: { isShowingEditProfile = true }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.3))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        )
        .offset(y: showContent ? 0 : 30)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var upgradeBanner: some View {
        Button(action: { isShowingUpgrade = true }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.orange)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Nâng cấp Premium")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Mở khóa tất cả tính năng nâng cao")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text("Nâng cấp")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black)
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(Color.orange.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.orange.opacity(0.15), lineWidth: 1)
            )
        }
        .buttonStyle(BouncyButtonStyle())
        .offset(y: showContent ? 0 : 40)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var transactionImagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Ảnh giao dịch", actionTitle: "Xem tất cả") {
                isShowingGallery = true
            }
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 4)
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<8) { i in
                    ZStack {
                        AsyncImage(url: URL(string: "https://picsum.photos/200?random=\(i+10)")) { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.05)
                        }
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        if i == 7 {
                            Color.black.opacity(0.6)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            Text("+12")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .offset(y: showContent ? 0 : 50)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var badgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeader(title: "Huy hiệu đã đạt", actionTitle: "Xem tất cả") {
                isShowingBadges = true
            }
            
            FlowLayout(spacing: 8) {
                badgeTag(text: "profile.savings_master", color: .orange)
                badgeTag(text: "profile.budget_king", color: .purple)
                badgeTag(text: "profile.smart_spender", color: .blue)
                badgeTag(text: "profile.early_bird", color: .green)
                badgeTag(text: "profile.streak_week", color: .red)
            }
        }
        .offset(y: showContent ? 0 : 60)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var premiumToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Công cụ Premium")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 8) {
                premiumToolItem(icon: "app.badge", title: "Biểu tượng ứng dụng tùy chỉnh", desc: "Cá nhân hóa giao diện ứng dụng", color: .orange)
                premiumToolItem(icon: "arrow.triangle.2.circlepath", title: "Đồng bộ ngân hàng", desc: "Tự động đồng bộ giao dịch", color: .blue)
                premiumToolItem(icon: "person.2.fill", title: "Ngân sách chia sẻ", desc: "Lập kế hoạch với đối tác", color: .green)
                premiumToolItem(icon: "chart.line.uptrend.xyaxis", title: "Dự báo 12 tháng", desc: "Dự đoán tiết kiệm tương lai", color: .purple)
            }
        }
        .offset(y: showContent ? 0 : 70)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quyền hạn")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                rowItem(title: "Thông báo", value: "Push, Email, Vị trí") {
                    isShowingNotifications = true
                }
                HStack {
                    Text("Tự động nhận diện vị trí")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    Spacer()
                    Toggle("", isOn: $autoDetectLocation)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .black))
                        .scaleEffect(0.8)
                }
                .padding(.vertical, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
    
    @ViewBuilder
    private var dataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dữ liệu & Quyền riêng tư")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Tiền tệ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("USD ($)") {}
                        Button("VND (đ)") {}
                        Button("EUR (€)") {}
                        Button("JPY (¥)") {}
                    } label: {
                        HStack(spacing: 4) {
                            Text("USD ($)")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.gray)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.05))
                        .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 12)
                
                Divider().opacity(0.3).padding(.vertical, 4)
                
                HStack(spacing: 12) {
                    Text("Ngôn ngữ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("Tiếng Việt") { }
                    } label: {
                        HStack(spacing: 4) {
                            Text("Tiếng Việt")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.gray)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 10))
                                .foregroundStyle(.gray.opacity(0.5))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.gray.opacity(0.05))
                        .clipShape(Capsule())
                    }
                }
                .padding(.vertical, 12)
                
                Divider().opacity(0.3).padding(.vertical, 4)
                
                rowItem(title: "Danh mục", icon: "list.bullet.indent") {
                    isShowingCategories = true
                }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Xuất dữ liệu", value: "Nâng cấp", icon: "lock.fill", isLocked: true) {
                    isShowingUpgrade = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
    
    @ViewBuilder
    private var applicationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Ứng dụng")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                rowItem(title: "Gợi ý tính năng") {
                    isShowingSuggest = true
                }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Đánh giá ứng dụng")
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Chính sách bảo mật") { }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Điều khoản dịch vụ") { }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
    
    @ViewBuilder
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Tài khoản")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                Button(action: { isShowingLogoutAlert = true }) {
                    HStack {
                        Text("Đăng xuất")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.black)
                        Spacer()
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical, 12)
                }
                
                Divider().opacity(0.3).padding(.vertical, 0)
                
                Button(action: { isShowingDeleteAlert = true }) {
                    HStack {
                        Text("Xóa tài khoản")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.red)
                        Spacer()
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                    }
                    .padding(.vertical, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
    }
    
    private func sectionHeader(title: String, actionTitle: String? = nil, onAction: (() -> Void)? = nil) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            Spacer()
            if let action = actionTitle {
                Button(action: { onAction?() }) {
                    Text(action)
                        .font(.system(size: 12, weight: .medium))
                }
                .buttonStyle(BouncyButtonStyle())
            }
        }
    }
    
    private func premiumToolItem(icon: String, title: String, desc: String, color: Color) -> some View {
        Button(action: { isShowingUpgrade = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(color.opacity(0.1))
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundStyle(color)
                }
                .frame(width: 44, height: 44)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                    Text(desc)
                        .font(.system(size: 11))
                        .foregroundStyle(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
        .buttonStyle(BouncyButtonStyle())
    }
    
    private func rowItem(title: String, value: String? = nil, icon: String? = nil, isLocked: Bool = false, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black)
                
                Spacer()
                
                if let v = value {
                    Text(v)
                        .font(.system(size: 12, weight: isLocked ? .bold : .medium))
                        .foregroundStyle(isLocked ? .orange : .gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(isLocked ? Color.orange.opacity(0.1) : Color.clear)
                        .clipShape(Capsule())
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.gray.opacity(0.3))
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
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
    
    @ViewBuilder
    private func placeholderSheet(title: String) -> some View {
        NavigationStack {
            VStack {
                Text(title)
                    .font(.headline)
                Text("Tính năng này sắp ra mắt...")
                    .foregroundStyle(.gray)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") {
                        isShowingEditProfile = false
                        isShowingUpgrade = false
                        isShowingCategories = false
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var currencySelectionSheet: some View {
        NavigationStack {
            List {
                currencyRow(flag: "🇺🇸", code: "USD", name: "Đô la Mỹ")
                currencyRow(flag: "🇻🇳", code: "VND", name: "Việt Nam Đồng")
                currencyRow(flag: "🇪🇺", code: "EUR", name: "Euro")
                currencyRow(flag: "🇯🇵", code: "JPY", name: "Yên Nhật")
            }
            .navigationTitle("Tiền tệ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Xong") { isShowingCurrency = false }
                }
            }
        }
    }
    
    private func currencyRow(flag: String, code: String, name: String) -> some View {
        Button(action: {
            isShowingCurrency = false
        }) {
            HStack {
                VStack(alignment: .leading) {
                    Text("\(flag) \(code)").font(.system(size: 14, weight: .bold))
                    Text(name).font(.system(size: 12)).foregroundStyle(.gray)
                }
                Spacer()
                if code == "USD" {
                    Image(systemName: "checkmark").foregroundStyle(.black)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var navState: AppNavigationState
    
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
            .sheet(isPresented: $isShowingEditProfile) {
                EditProfileSheet()
            }
            .sheet(isPresented: $isShowingUpgrade) {
                SubscriptionSheet()
            }
            .sheet(isPresented: $isShowingCurrency) {
                currencySelectionSheet
            }
            .sheet(isPresented: $isShowingBadges) {
                BadgeListView()
            }
            .sheet(isPresented: $isShowingGallery) {
                TransactionGalleryView()
            }
            .fullScreenCover(isPresented: $isShowingCategories) {
                CategoryListView()
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationSettingsSheet()
            }
            .sheet(isPresented: $isShowingSuggest) {
                FeatureSuggestSheet()
            }
            .alert("Logout", isPresented: $isShowingLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Delete Account", isPresented: $isShowingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                }
            } message: {
                Text("Are you sure you want to delete your account? This action is permanent and all your data will be lost.")
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

            Text("Profile")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.black)
        }
        .padding(.top, 60)
        .padding(.bottom, 8)
        .offset(y: showContent ? 0 : 10)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var personalInfoCard: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: "https://i.pravatar.cc/300")) { image in
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
                Text("Quoc Viet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)
                
                Text("quocviet@itmybudget.app")
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
                    Text("Upgrade to Premium")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                    Text("Unlock all advanced features")
                        .font(.system(size: 12))
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Text("Upgrade")
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
            sectionHeader(title: "Transaction Images", actionTitle: "See All") {
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
            sectionHeader(title: "Earned Badges", actionTitle: "See All") {
                isShowingBadges = true
            }
            
            FlowLayout(spacing: 8) {
                badgeTag(text: "Savings Master", color: .orange)
                badgeTag(text: "Budget King", color: .purple)
                badgeTag(text: "Smart Spender", color: .blue)
                badgeTag(text: "Early Bird", color: .green)
                badgeTag(text: "Streak Week", color: .red)
            }
        }
        .offset(y: showContent ? 0 : 60)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var premiumToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Tools")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 8) {
                premiumToolItem(icon: "app.badge", title: "Custom App Icon", desc: "Personalize your app look", color: .orange)
                premiumToolItem(icon: "arrow.triangle.2.circlepath", title: "Bank Sync", desc: "Auto-sync transactions", color: .blue)
                premiumToolItem(icon: "person.2.fill", title: "Shared Budgets", desc: "Plan with your partner", color: .green)
                premiumToolItem(icon: "chart.line.uptrend.xyaxis", title: "12-Month Forecast", desc: "Predict your future savings", color: .purple)
            }
        }
        .offset(y: showContent ? 0 : 70)
        .opacity(showContent ? 1 : 0)
    }
    
    @ViewBuilder
    private var permissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Permissions")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                rowItem(title: "Notifications", value: "Push, Email, Location") {
                    isShowingNotifications = true
                }
                HStack {
                    Text("Auto Detect Location")
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
            Text("Data & Privacy")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Currency")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("USD ($)") { /* Set USD */ }
                        Button("VND (đ)") { /* Set VND */ }
                        Button("EUR (€)") { /* Set EUR */ }
                        Button("JPY (¥)") { /* Set JPY */ }
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
                
                rowItem(title: "Categories", icon: "list.bullet.indent") {
                    isShowingCategories = true
                }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Export Data", value: "Premium", icon: "lock.fill", isLocked: true) {
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
            Text("Application")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                rowItem(title: "Suggest a Feature") {
                    isShowingSuggest = true
                }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Rate the App")
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Privacy Policy") { }
                Divider().opacity(0.3).padding(.vertical, 4)
                rowItem(title: "Terms of Service") { }
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
            Text("Account")
                .font(.system(size: 16, weight: .bold))
            
            VStack(spacing: 0) {
                Button(action: { isShowingLogoutAlert = true }) {
                    HStack {
                        Text("Logout")
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
                        Text("Delete Account")
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
                Text("This feature is coming soon...")
                    .foregroundStyle(.gray)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
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
                currencyRow(flag: "🇺🇸", code: "USD", name: "US Dollar")
                currencyRow(flag: "🇻🇳", code: "VND", name: "Vietnamese Dong")
                currencyRow(flag: "🇪🇺", code: "EUR", name: "Euro")
                currencyRow(flag: "🇯🇵", code: "JPY", name: "Japanese Yen")
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { isShowingCurrency = false }
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

struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var maxWidth: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            maxWidth = max(maxWidth, currentX)
        }
        
        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

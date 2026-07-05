import SwiftUI
import SwiftData

struct OnboardingStep {
    let title: String
    let description: String
    let percentage: String
    let progress: Double
    let color: Color
    let footerNote: String
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]
    @Query private var budgets: [DBBudget]
    
    @Environment(AppStateManager.self) private var appStateManager
    @State private var selection: Int = 0
    @State private var isLoading = false
    
    @State private var autoDetectLocation: Bool = true
    @State private var isShowingNotifications = false
    @State private var selectedCurrency = "USD"
    @State private var selectedCurrencyLabel = "USD ($)"
    
    @State private var onboardingCategories = Category.sampleData
    
    @State private var budgetName: String = ""
    @State private var budgetAmount: String = ""
    @State private var shimmerOffset: CGFloat = -0.5
    
    var steps: [OnboardingStep] {
        [
            OnboardingStep(
                title: "Thiết lập Cơ bản",
                description: "Cá nhân hóa trải nghiệm của bạn bằng cách chọn loại tiền tệ ưa thích.",
                percentage: "33%",
                progress: 0.33,
                color: .teal,
                footerNote: "Bạn luôn có thể cập nhật các tùy chọn này trong phần Thông tin cá nhân!"
            ),
            OnboardingStep(
                title: "Danh mục Chi tiêu",
                description: "Chọn các danh mục bạn chi tiêu thường xuyên nhất để giúp chúng tôi tối ưu hóa biểu đồ tài chính của bạn.",
                percentage: "66%",
                progress: 0.66,
                color: .orange,
                footerNote: "Bạn có thể sửa đổi hoặc thêm/xóa các danh mục chi tiêu bất cứ lúc nào sau khi thiết lập!"
            ),
            OnboardingStep(
                title: "Ngân sách Đầu tiên",
                description: "Thiết lập ngân sách của bạn để itmybudget tự động tối ưu hóa tài chính cá nhân.",
                percentage: "99%",
                progress: 0.99,
                color: .green,
                footerNote: "Dựa trên mức chi tiêu trung bình của những người dùng có thu nhập tương tự trong khu vực của bạn!"
            )
        ]
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                Text("itmybudget")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                ZStack(alignment: .leading) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        if selection == index {
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .lastTextBaseline) {
                                    Text(steps[index].title)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    
                                    Text(steps[index].percentage)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                                .padding(.top, 20)
                                
                                Color.clear.frame(height: 18) 
                                
                                Text(steps[index].description)
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.top, 24)
                                    .lineSpacing(6)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                if index == 0 {
                                    ScrollView(showsIndicators: false) {
                                        VStack(alignment: .leading, spacing: 24) {
                                            permissionSection
                                            dataSection
                                        }
                                        .padding(.top, 24)
                                        .padding(.bottom, 24)
                                    }
                                }
                                
                                if index == 1 {
                                    ScrollView(showsIndicators: false) {
                                        categorySelectionSection
                                            .padding(.top, 24)
                                            .padding(.bottom, 24)
                                    }
                                }
                                
                                if index == 2 {
                                    ScrollView(showsIndicators: false) {
                                        budgetSetupSection
                                            .padding(.top, 24)
                                            .padding(.bottom, 24)
                                    }
                                }
                                
                                Spacer()
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .offset(y: 10)),
                                removal: .opacity
                            ))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .overlay(
                    VStack {
                        Spacer().frame(height: 20 + 28 + 20)
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(height: 6)
                                
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(steps[selection].color.gradient)
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                stops: [
                                                    .init(color: .clear, location: 0),
                                                    .init(color: .white.opacity(0.4), location: 0.5),
                                                    .init(color: .clear, location: 1)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: 80)
                                        .offset(x: geo.size.width * steps[selection].progress * shimmerOffset * 2)
                                        .onAppear {
                                            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                                                shimmerOffset = 1.5
                                            }
                                        }
                                }
                                .frame(width: geo.size.width * steps[selection].progress, height: 6)
                                .clipShape(Capsule())
                                .shadow(color: steps[selection].color.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        .frame(height: 6)
                        .padding(.horizontal, 24)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: selection)
                        
                        Spacer()
                    },
                    alignment: .top
                )
                
                HStack(spacing: 12) {
                    if selection > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection -= 1
                            }
                        }) {
                            Text("Quay lại")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.gray)
                                .frame(width: 110)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1.5))
                        }
                        .buttonStyle(BouncyButtonStyle())
                    }
                    
                    Button(action: {
                        isLoading = true
                        Task {
                            if selection == 0 {
                                saveStep1Settings()
                            } else if selection == 1 {
                                await saveStep2Categories()
                            } else if selection == 2 {
                                await saveStep3Budget()
                                await AuthManager.shared.completeOnboarding(context: modelContext)
                            }
                            
                            await MainActor.run {
                                isLoading = false
                                if selection < 2 {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selection += 1
                                    }
                                } else {
                                    appStateManager.moveToMain()
                                }
                            }
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(Color.black)
                                .clipShape(Capsule())
                        } else {
                            Text(selection == 2 ? "Xác nhận và tạo" : "Tiếp tục")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .disabled(isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
            .sheet(isPresented: $isShowingNotifications) {
                NotificationSettingsSheet()
                    .presentationDragIndicator(.visible)
            }
            .onAppear {
                if let s = settings.first {
                    autoDetectLocation = s.autoDetectLocation
                    selectedCurrency = s.currency
                    if s.currency == "USD" {
                        selectedCurrencyLabel = "USD ($)"
                    } else if s.currency == "VND" {
                        selectedCurrencyLabel = "VND (đ)"
                    } else if s.currency == "EUR" {
                        selectedCurrencyLabel = "EUR (€)"
                    }

                } else {
                    let defaultSettings = UserSettings(
                        pushNotificationsEnabled: true,
                        reminderTime: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
                        autoDetectLocation: autoDetectLocation,
                        currency: selectedCurrency,
                        language: "vi"
                    )
                    modelContext.insert(defaultSettings)
                    try? modelContext.save()
                }
            }
        }
    }
    
    @ViewBuilder
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quyền truy cập")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                rowItem(title: "onboarding.notifications", value: "onboarding.allow") {
                    isShowingNotifications = true
                }
                
                Divider().opacity(0.3)
                
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Dữ liệu")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Tiền tệ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("USD ($)") { selectedCurrency = "USD"; selectedCurrencyLabel = "USD ($)" }
                        Button("VND (đ)") { selectedCurrency = "VND"; selectedCurrencyLabel = "VND (đ)" }
                        Button("EUR (€)") { selectedCurrency = "EUR"; selectedCurrencyLabel = "EUR (€)" }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedCurrencyLabel)
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

            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
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
    
    @ViewBuilder
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Chọn danh mục")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(onboardingCategories.indices, id: \.self) { index in
                    Button(action: {
                        onboardingCategories[index].isActive.toggle()
                    }) {
                        BudgetCategoryCard(
                            title: onboardingCategories[index].name,
                            icon: onboardingCategories[index].icon,
                            color: onboardingCategories[index].color,
                            isSelected: onboardingCategories[index].isActive
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                    .background(Color.clear)
                }
            }
            .background(Color.clear)
        }
        .padding(.horizontal, 2)
    }
    
    private var dynamicQuickAmounts: [Double] {
        let base = Double(budgetAmount) ?? 0
        if base == 0 {
            return [100, 500, 1000, 2000, 5000]
        }
        
        return [base * 100, base * 1000, base * 10000]
    }
    
    @ViewBuilder
    private var budgetSetupSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Tên ngân sách")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                TextField("Ví dụ: Hàng ngày, Du lịch...", text: $budgetName)
                    .font(.system(size: 16, weight: .medium))
                    .padding(16)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Số tiền ngân sách")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                HStack {
                    TextField("0", text: $budgetAmount)
                        .keyboardType(.numberPad)
                        .font(.system(size: 16, weight: .bold))
                    
                    Text(selectedCurrencyLabel)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.gray)
                }
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.black.opacity(0.06), lineWidth: 1)
                )
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(dynamicQuickAmounts, id: \.self) { val in
                            Button(action: {
                                budgetAmount = String(format: "%.0f", val)
                            }) {
                                Text("\(selectedCurrency == "USD" ? "$" : "")\(formatValue(val))\(selectedCurrency == "VND" ? "đ" : "")")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private func saveStep2Categories() async {
        let selected = onboardingCategories.filter { $0.isActive }
        guard !selected.isEmpty else { return }
        
        print("📁 Selected onboarding categories: \(selected.map { $0.name })")
        
        do {
            let categoryInputs = selected.map { CategoryCreateInput(name: $0.name, icon: $0.icon, color: $0.color.hexString) }
            print("🚀 Creating \(categoryInputs.count) categories in bulk...")
            let endpoint = CategoryEndpoint.bulkCreate(categories: categoryInputs)
            let serverCategories: [APICategoryResponse] = try await NetworkManager.shared.request(endpoint)
            print("✅ Bulk categories created successfully!")
            
            // Save to SwiftData
            print("💾 Saving \(serverCategories.count) categories to SwiftData...")
            for serverCat in serverCategories {
                let categoryId = serverCat.id
                let fetchDescriptor = FetchDescriptor<DBCategory>(
                    predicate: #Predicate { $0.id == categoryId }
                )
                
                if let existing = try? modelContext.fetch(fetchDescriptor).first {
                    existing.name = serverCat.name
                    existing.icon = serverCat.icon
                    existing.colorHex = serverCat.color
                    existing.userId = serverCat.user_id
                    existing.isDefault = serverCat.is_default
                    existing.isHidden = serverCat.is_hidden
                    existing.createdAt = serverCat.created_at
                    existing.updatedAt = serverCat.updated_at
                } else {
                    let dbCat = DBCategory(
                        id: serverCat.id,
                        name: serverCat.name,
                        icon: serverCat.icon,
                        colorHex: serverCat.color,
                        userId: serverCat.user_id,
                        isDefault: serverCat.is_default,
                        isHidden: serverCat.is_hidden,
                        createdAt: serverCat.created_at,
                        updatedAt: serverCat.updated_at
                    )
                    modelContext.insert(dbCat)
                }
            }
            
            try? modelContext.save()
            print("✅ All categories saved to SwiftData successfully!")
            
        } catch {
            print("❌ Error saving onboarding categories: \(error.localizedDescription)")
        }
    }
    
    private func saveStep3Budget() async {
        let name = budgetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Ngân sách Đầu tiên" : budgetName
        let amount = Double(budgetAmount) ?? 100.0
        
        print("📁 Selected onboarding budget: \(name) with amount: \(amount)")
        
        do {
            // 1. Post budget to server
            let endpoint = BudgetEndpoint.create(
                name: name,
                amount: amount,
                icon: "wallet.pass.fill",
                color: "#34C759"
            )
            let createResponse: APIBudgetResponse = try await NetworkManager.shared.request(endpoint)
            print("✅ Budget created successfully on backend! ID: \(createResponse.id)")
            
            // 2. Fetch updated budgets list from server
            print("📡 Fetching budgets list from backend...")
            let listResponse: [APIBudgetResponse] = try await NetworkManager.shared.request(BudgetEndpoint.list)
            
            // 3. Save/Upsert into SwiftData
            print("💾 Saving \(listResponse.count) budgets to SwiftData...")
            for serverBudget in listResponse {
                let budgetId = serverBudget.id
                let fetchDescriptor = FetchDescriptor<DBBudget>(
                    predicate: #Predicate { $0.id == budgetId }
                )
                
                if let existing = try? modelContext.fetch(fetchDescriptor).first {
                    existing.name = serverBudget.name
                    existing.limitStr = serverBudget.limit
                    existing.amountStr = serverBudget.amount
                    existing.periodType = serverBudget.period_type
                    existing.startDate = serverBudget.start_date
                    existing.endDate = serverBudget.end_date
                    existing.icon = serverBudget.icon
                    existing.color = serverBudget.color
                    existing.budgetType = serverBudget.budget_type
                    existing.isActive = serverBudget.is_active
                    existing.spentAmountStr = serverBudget.spent_amount
                    existing.createdAt = serverBudget.created_at
                    existing.updatedAt = serverBudget.updated_at
                } else {
                    let dbBudget = DBBudget(
                        id: serverBudget.id,
                        userId: serverBudget.user_id,
                        name: serverBudget.name,
                        limitStr: serverBudget.limit,
                        amountStr: serverBudget.amount,
                        periodType: serverBudget.period_type,
                        startDate: serverBudget.start_date,
                        endDate: serverBudget.end_date,
                        icon: serverBudget.icon,
                        color: serverBudget.color,
                        budgetType: serverBudget.budget_type,
                        isActive: serverBudget.is_active,
                        spentAmountStr: serverBudget.spent_amount,
                        createdAt: serverBudget.created_at,
                        updatedAt: serverBudget.updated_at
                    )
                    modelContext.insert(dbBudget)
                }
            }
            
            try? modelContext.save()
            print("✅ All budgets saved to SwiftData successfully!")
            
        } catch {
            print("❌ Error saving onboarding budget: \(error.localizedDescription)")
        }
    }
    
    private func saveStep1Settings() {
        if let s = settings.first {
            s.autoDetectLocation = autoDetectLocation
            s.currency = selectedCurrency

        } else {
            let s = UserSettings(
                autoDetectLocation: autoDetectLocation,
                currency: selectedCurrency,
                language: "vi"
            )
            modelContext.insert(s)
        }
        try? modelContext.save()
    }
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}

import SwiftUI

struct OnboardingStep {
    let title: String
    let description: String
    let percentage: String
    let progress: Double
    let color: Color
    let footerNote: String
}

struct OnboardingView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var selection: Int = 0
    
    // Step 1 States
    @State private var autoDetectLocation: Bool = true
    @State private var isShowingNotifications = false
    @State private var isShowingCurrency = false
    @State private var selectedCurrency = "USD ($)"
    
    // Step 2 States
    @State private var onboardingCategories = Category.sampleData
    
    // Step 3 States
    @State private var budgetName: String = ""
    @State private var budgetAmount: String = ""
    
    let steps = [
        OnboardingStep(
            title: "Basic Setup",
            description: "Personalize your experience by choosing your preferred currency.",
            percentage: "33%",
            progress: 0.33,
            color: .teal,
            footerNote: "You can always update these preferences in the Personal Information section!"
        ),
        OnboardingStep(
            title: "Expense Categories",
            description: "Select the categories you spend on most frequently to help us optimize your financial charts.",
            percentage: "66%",
            progress: 0.66,
            color: .orange,
            footerNote: "You can modify or add/remove spending categories at any time after setup!"
        ),
        OnboardingStep(
            title: "First Budget",
            description: "Set up your budget to let itmybudget automatically optimize your personal finances.",
            percentage: "99%",
            progress: 0.99,
            color: .green,
            footerNote: "$500 based on the average spending of users with similar income in your area!"
        )
    ]
    
    var body: some View {
        ZStack {
            // Home-like orange background
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.97, blue: 0.92), Color(red: 1.0, green: 0.94, blue: 0.88)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Fixed Header
                Text("itmybudget")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.top, 20)
                    .padding(.horizontal, 24)
                
                // Content with Fade Transition
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
                                
                                // Placeholder for progress bar to keep layout consistent
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
                                
                                // Footer Note Box (AI Insight Style)
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(LocalizedStringKey(steps[index].footerNote))
                                        .font(.system(size: 13, weight: .semibold))
                                        .lineSpacing(4)
                                        .foregroundStyle(.white)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    ZStack {
                                        // Single color matching AIInsightCarousel
                                        Color(red: 1.0, green: 0.7, blue: 0.6)
                                        
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 120, height: 120)
                                            .blur(radius: 30)
                                            .offset(x: 80, y: -30)
                                        
                                        Circle()
                                            .fill(Color.black.opacity(0.1))
                                            .frame(width: 80, height: 80)
                                            .blur(radius: 20)
                                            .offset(x: -40, y: 40)
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: Color(red: 1.0, green: 0.7, blue: 0.6).opacity(0.3), radius: 15, x: 0, y: 8)
                                .padding(.bottom, 20)
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
                    // Animated Progress Bar overlaying the placeholder
                    VStack {
                        Spacer().frame(height: 20 + 28 + 20) // App name + Title + Title padding
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(height: 6)
                                
                                Capsule()
                                    .fill(steps[selection].color.gradient)
                                    .frame(width: geo.size.width * steps[selection].progress, height: 6)
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
                
                // Bottom Buttons (Retry/Create and Confirm layout)
                HStack(spacing: 12) {
                    if selection > 0 {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection -= 1
                            }
                        }) {
                            Text("Back")
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
                        if selection < 2 {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                selection += 1
                            }
                        } else {
                            appStateManager.moveToMain()
                        }
                    }) {
                        Text(selection == 2 ? "Confirm and create" : "Continue")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.black)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 34)
            }
        }
    }
    
    // MARK: - Step 1 Components
    
    @ViewBuilder
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Permission")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                rowItem(title: "Thông báo", value: "Cho phép") {
                    isShowingNotifications = true
                }
                
                Divider().opacity(0.3)
                
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
        VStack(alignment: .leading, spacing: 12) {
            Text("Data")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Text("Tiền tệ")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("USD ($)") { selectedCurrency = "USD ($)" }
                        Button("VND (đ)") { selectedCurrency = "VND (đ)" }
                        Button("EUR (€)") { selectedCurrency = "EUR (€)" }
                    } label: {
                        HStack(spacing: 4) {
                            Text(selectedCurrency)
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
    
    // MARK: - Step 2 Components
    
    @ViewBuilder
    private var categorySelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Categories")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(onboardingCategories.indices, id: \.self) { index in
                    Button(action: {
                        onboardingCategories[index].isActive.toggle()
                    }) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(onboardingCategories[index].color.opacity(0.12))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: onboardingCategories[index].icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(onboardingCategories[index].color)
                                }
                                
                                Spacer()
                                
                                if onboardingCategories[index].isActive {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.black)
                                } else {
                                    Image(systemName: "circle")
                                        .font(.system(size: 16))
                                        .foregroundStyle(.gray.opacity(0.3))
                                }
                            }
                            
                            Text(onboardingCategories[index].name)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.black)
                                .lineLimit(1)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.05), lineWidth: 1)
                        )
                    }
                    .buttonStyle(BouncyButtonStyle())
                }
            }
        }
    }
    
    // MARK: - Step 3 Components
    
    private var dynamicQuickAmounts: [Double] {
        let base = Double(budgetAmount) ?? 0
        if base == 0 {
            return [100, 500, 1000, 2000, 5000]
        }
        
        // If user types '2', suggest 200, 2000, 20000
        // We can also suggest based on the number of digits if it's large, 
        // but the request is simple: base * 100, base * 1000, base * 10000
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
                    
                    Text(selectedCurrency.split(separator: " ").last.map(String.init) ?? "USD")
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
                                Text("\(selectedCurrency.contains("USD") ? "$" : "")\(formatValue(val))")
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
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}

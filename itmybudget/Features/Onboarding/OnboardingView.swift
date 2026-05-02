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
    @Environment(LocalizationManager.self) private var loc
    @State private var selection: Int = 0
    
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
                title: "onboarding.step1_title".localized,
                description: "onboarding.step1_desc".localized,
                percentage: "33%",
                progress: 0.33,
                color: .teal,
                footerNote: "onboarding.footer1".localized
            ),
            OnboardingStep(
                title: "onboarding.step2_title".localized,
                description: "onboarding.step2_desc".localized,
                percentage: "66%",
                progress: 0.66,
                color: .orange,
                footerNote: "onboarding.footer2".localized
            ),
            OnboardingStep(
                title: "onboarding.step3_title".localized,
                description: "onboarding.step3_desc".localized,
                percentage: "99%",
                progress: 0.99,
                color: .green,
                footerNote: "onboarding.footer3".localized
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
                LText("app_name")
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
                            LText("onboarding.back")
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
                        LText(selection == 2 ? "onboarding.confirm" : "onboarding.continue")
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
            .sheet(isPresented: $isShowingNotifications) {
                NotificationSettingsSheet()
                    .presentationDragIndicator(.visible)
            }
        }
    }
    
    @ViewBuilder
    private var permissionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            LText("onboarding.permission")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                rowItem(title: "onboarding.notifications", value: "onboarding.allow") {
                    isShowingNotifications = true
                }
                
                Divider().opacity(0.3)
                
                HStack {
                    LText("onboarding.auto_location")
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
            LText("onboarding.data")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    LText("onboarding.currency")
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
                
                Divider().opacity(0.3).padding(.vertical, 4)
                
                HStack(spacing: 12) {
                    LText("profile.language")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Menu {
                        Button("English") {
                            loc.currentLanguage = "en"
                        }
                        Button("Tiếng Việt") {
                            loc.currentLanguage = "vi"
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Text(loc.currentLanguage == "en" ? "English" : "Tiếng Việt")
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
                LText(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.black)
                
                Spacer()
                
                if let v = value {
                    LText(v)
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
            LText("onboarding.select_categories")
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
                LText("onboarding.budget_name")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.8))
                
                TextField("onboarding.budget_name_placeholder".localized, text: $budgetName)
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
                LText("onboarding.budget_amount")
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
    
    private func formatValue(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))")
    }
}
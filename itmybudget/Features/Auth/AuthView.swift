import SwiftUI
import AuthenticationServices
import Combine
import SwiftData

struct AuthView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppStateManager.self) private var appStateManager
    @State private var isAnimating = false
    @State private var moveAnimating = false
    @State private var chartValues: [CGFloat] = (0..<14).map { _ in CGFloat.random(in: 15...40) }
    @State private var highlightedIndex: Int = 3
    @State private var progressValue: CGFloat = 0.0
    @State private var netWorth: Double = 84250.00
    @State private var shimmerOffset: CGFloat = -0.5
    @State private var isLoading = false
    
    let timer = Timer.publish(every: 2.0, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(red: 1.0, green: 0.98, blue: 0.96)
                .ignoresSafeArea()
            
            ZStack {
                VStack(spacing: 40) {
                    ForEach(0..<20) { i in
                        Text("ITMYBUDGET FINANCE PLANNING WEALTH SAVINGS BUDGETING ITMYBUDGET FINANCE PLANNING WEALTH SAVINGS BUDGETING ")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(Color.black.opacity(0.04))
                            .lineLimit(1)
                            .offset(x: moveAnimating ? (i % 2 == 0 ? -200 : 200) : (i % 2 == 0 ? 200 : -200))
                    }
                }
                .rotationEffect(.degrees(-15))
                .onAppear {
                    withAnimation(.linear(duration: 40).repeatForever(autoreverses: true)) {
                        moveAnimating = true
                    }
                }
                
                GeometryReader { geo in
                    Circle()
                        .fill(Color.orange.opacity(0.06))
                        .frame(width: 500, height: 500)
                        .blur(radius: 100)
                        .offset(x: -150, y: 0)
                    
                    Circle()
                        .fill(Color.teal.opacity(0.03))
                        .frame(width: 400, height: 400)
                        .blur(radius: 80)
                        .offset(x: geo.size.width - 200, y: 0)
                }
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        LText("app_name")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .padding(.horizontal, 48)
                            .offset(y: 30)
                            .scaleEffect(0.9)
                        
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .padding(.horizontal, 36)
                            .offset(y: 15)
                            .scaleEffect(0.95)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    LText("auth.net_worth")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(.orange)
                                        .tracking(1.2)
                                    
                                    Text(String(format: "$%.2f", netWorth))
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundStyle(.black)
                                        .contentTransition(.numericText())

                                }
                                Spacer()
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .bold))
                                    Text("12.5%")
                                        .font(.system(size: 12, weight: .bold))
                                }
                                .foregroundStyle(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                            }
                            
                            HStack(alignment: .bottom, spacing: 12) {
                                ForEach(0..<14, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(i == highlightedIndex ? Color.orange : Color.orange.opacity(0.12))
                                        .frame(width: 8, height: i == highlightedIndex ? 50 : chartValues[i])
                                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: chartValues[i])
                                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: highlightedIndex)
                                }
                            }
                            .frame(height: 50)
                            .frame(maxWidth: .infinity, alignment: .center)


                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 20, x: 0, y: 10)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.black.opacity(0.03), lineWidth: 1)
                        )
                        .padding(.horizontal, 24)
                    }
                    .scaleEffect(isAnimating ? 1 : 0.98)
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                LText("auth.summer_goal")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(.black)
                                Spacer()
                                Text("75%")
                                    .font(.system(size: 12, weight: .black))
                                    .foregroundStyle(.teal)
                            }
                            
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.black.opacity(0.05))
                                        .frame(height: 8)
                                    
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(LinearGradient(colors: [.teal, .teal.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                        
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
                                            .frame(width: 100)
                                            .offset(x: geo.size.width * progressValue * shimmerOffset * 2.5)
                                            .onAppear {
                                                withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                                                    shimmerOffset = 1.5
                                                }
                                            }
                                    }
                                    .frame(width: geo.size.width * progressValue, height: 8)
                                    .clipShape(Capsule())
                                    .animation(.spring(response: 1.5, dampingFraction: 0.8), value: progressValue)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.03), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 8)



                    
                    VStack(spacing: 24) {
                        LText("auth.start_journey")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        VStack(spacing: 14) {
                            // Button(action: {
                            //     withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            //         appStateManager.moveToOnboarding()
                            //     }
                            // }) {
                            //     HStack(spacing: 10) {
                            //         Image(systemName: "applelogo")
                            //             .font(.system(size: 18))
                            //         LText("auth.continue_apple")
                            //             .font(.system(size: 16, weight: .bold))
                            //     }
                            //     .frame(maxWidth: .infinity)
                            //     .frame(height: 58)
                            //     .background(
                            //         ZStack {
                            //             Color.black
                            //             LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom)
                            //         }
                            //     )
                            //     .foregroundStyle(.white)
                            //     .clipShape(Capsule())
                            //     .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                            // }
                            // .buttonStyle(BouncyButtonStyle())
                            
                            Button(action: {
                                isLoading = true
                                Task {
                                    do {
                                        try await AuthManager.shared.signInWithGoogle()
                                        
                                        // Fetch budgets to check count
                                        print("📡 Fetching budgets list from backend to check count...")
                                        let listResponse: [APIBudgetResponse] = (try? await NetworkManager.shared.request(BudgetEndpoint.list)) ?? []
                                        
                                        if listResponse.isEmpty {
                                            print("ℹ️ No budgets found. Moving to Onboarding.")
                                            await MainActor.run {
                                                isLoading = false
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    appStateManager.moveToOnboarding()
                                                }
                                            }
                                        } else {
                                            print("ℹ️ Found \(listResponse.count) budgets. Saving to SwiftData and moving to Main.")
                                            
                                            // Sync budgets
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
                                            
                                            // Sync categories as well
                                            let catList: [APICategoryResponse] = (try? await NetworkManager.shared.request(CategoryEndpoint.list)) ?? []
                                            for serverCat in catList {
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
                                            
                                            await MainActor.run {
                                                isLoading = false
                                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                                    appStateManager.moveToMain()
                                                }
                                            }
                                        }
                                    } catch {
                                        print("Google Sign In Error: \(error.localizedDescription)")
                                        await MainActor.run {
                                            isLoading = false
                                        }
                                    }
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .tint(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 58)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(
                                            Capsule()
                                                .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                        )
                                        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                                } else {
                                    HStack(spacing: 10) {
                                        Image(systemName: "g.circle.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(
                                                LinearGradient(colors: [.red, .orange, .green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            )
                                        
                                        LText("auth.continue_google")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 58)
                                    .background(Color.white)
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.black.opacity(0.08), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                                }
                            }
                            .buttonStyle(BouncyButtonStyle())
                            .disabled(isLoading)
                        }
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: isAnimating)
                    }
                    .padding(.top, 180)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
                .padding(.top, 210)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                isAnimating = true
                progressValue = 0.75
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.spring(response: 1.2, dampingFraction: 0.8)) {
                chartValues = (0..<14).map { _ in CGFloat.random(in: 15...45) }
                highlightedIndex = Int.random(in: 0..<14)
                netWorth += Double.random(in: -20...50)
            }
        }
    }
}

import SwiftUI

struct SubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isYearly = true
    @State private var showContent = false
    
    private let benefits = [
        ("Bank Sync", "Auto-track all transactions"),
        ("Shared Budget", "Plan with family/friends"),
        ("Custom Icons", "Personalize your app look"),
        ("12-month Forecast", "Predict future savings"),
        ("Export Data", "Download your history"),
        ("No Ads", "Clean, seamless experience")
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    promoSection
                    
                    billingToggle
                    
                    pricingCardsGrid
                    
                    comparisonTable
                    
                    Spacer(minLength: 60)
                }
                .padding(20)
            }
            
            Spacer()
            
            actionButton
        }
        .background(
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.98, blue: 0.96), Color(red: 1.0, green: 0.95, blue: 0.90)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
        }
    }
    
    private var header: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black.opacity(0.3))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 25)
    }
    
    private var promoSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(Color.orange.opacity(0.1)).frame(width: 60, height: 60)
                Image(systemName: "crown.fill").font(.system(size: 24)).foregroundStyle(.orange)
            }
            
            VStack(spacing: 4) {
                Text("Unlock Everything")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                Text("Join 10,000+ users mastering their budgets")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .offset(y: showContent ? 0 : 20)
        .opacity(showContent ? 1 : 0)
    }
    
    private var billingToggle: some View {
        HStack(spacing: 0) {
            Button(action: { withAnimation { isYearly = false } }) {
                Text("Monthly")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(isYearly ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(isYearly ? Color.clear : Color.black)
                    .clipShape(Capsule())
            }
            
            Button(action: { withAnimation { isYearly = true } }) {
                HStack(spacing: 6) {
                    Text("Yearly")
                        .font(.system(size: 14, weight: .bold))
                    Text("-50%")
                        .font(.system(size: 10, weight: .black))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isYearly ? Color.orange : Color.orange.opacity(0.2))
                        .clipShape(Capsule())
                }
                .foregroundStyle(isYearly ? .white : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isYearly ? Color.black : Color.clear)
                .clipShape(Capsule())
            }
        }
        .background(Color.white)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .offset(y: showContent ? 0 : 30)
        .opacity(showContent ? 1 : 0)
    }
    
    private var pricingCardsGrid: some View {
        HStack(spacing: 16) {
            // Standard
            pricingCard(
                title: isYearly ? "Annual" : "1 Month",
                price: isYearly ? "$29.99" : "$4.99",
                billing: isYearly ? "Billed annually" : "Billed monthly",
                isPopular: isYearly
            )
            
            // Lifetime
            pricingCard(
                title: "Lifetime",
                price: "$79.99",
                billing: "Pay once, forever",
                isPopular: !isYearly
            )
        }
        .offset(y: showContent ? 0 : 40)
        .opacity(showContent ? 1 : 0)
    }
    
    private func pricingCard(title: String, price: String, billing: String, isPopular: Bool) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                Spacer()
                if isPopular {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.orange)
                }
            }
            .foregroundStyle(isPopular ? .black : .gray)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(price)
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.black)
                Text(billing)
                    .font(.system(size: 11))
                    .foregroundStyle(.gray)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isPopular ? Color.orange : Color.black.opacity(0.06), lineWidth: 2)
        )
        .shadow(color: isPopular ? Color.orange.opacity(0.1) : Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
    
    private var comparisonTable: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Features")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            VStack(spacing: 0) {
                ForEach(benefits, id: \.0) { title, desc in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(title).font(.system(size: 14, weight: .bold))
                            Text(desc).font(.system(size: 11)).foregroundStyle(.gray)
                        }
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.orange)
                            .font(.system(size: 18))
                    }
                    .padding(.vertical, 16)
                    
                    if title != benefits.last?.0 {
                        Divider().opacity(0.3)
                    }
                }
            }
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.black.opacity(0.05), lineWidth: 1))
        }
        .offset(y: showContent ? 0 : 50)
        .opacity(showContent ? 1 : 0)
    }
    
    private var actionButton: some View {
        VStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Text("Start Full Access")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.black)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(BouncyButtonStyle())
            
            Text("No commitment, cancel anytime")
                .font(.system(size: 11))
                .foregroundStyle(.gray)
        }
        .padding(24)
        .padding(.bottom, 10)
    }
}

#Preview {
    SubscriptionSheet()
}

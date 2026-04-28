import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var isAnimating = false
    @State private var moveAnimating = false
    
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
                VStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("itmybudget")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                        
                        Text("Intelligent Wealth Management")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 80)
                    .padding(.horizontal, 24)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .padding(.horizontal, 48)
                            .offset(y: 30)
                            .scaleEffect(0.9)
                        
                        RoundedRectangle(cornerRadius: 32)
                            .fill(Color.white.opacity(0.6))
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .padding(.horizontal, 36)
                            .offset(y: 15)
                            .scaleEffect(0.95)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("NET WORTH")
                                        .font(.system(size: 10, weight: .black))
                                        .foregroundStyle(.orange)
                                        .tracking(1.2)
                                    
                                    Text("$84,250.00")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundStyle(.black)
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
                            
                            HStack(alignment: .bottom, spacing: 5) {
                                ForEach(0..<18, id: \.self) { i in
                                    RoundedRectangle(cornerRadius: 3)
                                        .fill(i == 12 ? Color.orange : Color.orange.opacity(0.15))
                                        .frame(width: 7, height: i == 12 ? 50 : CGFloat.random(in: 15...40))
                                }
                            }
                            .frame(height: 50)
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            HStack(spacing: 0) {
                                parameterView(title: "SPENT", value: "$1,240", color: .red)
                                Spacer()
                                parameterView(title: "LEFT", value: "$3,760", color: .teal)
                                Spacer()
                                parameterView(title: "SAVED", value: "24%", color: .orange)
                            }
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
                                Text("Summer Vacation Goal")
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
                                    
                                    Capsule()
                                        .fill(LinearGradient(colors: [.teal, .teal.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: geo.size.width * 0.75, height: 8)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.03), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    VStack(spacing: 24) {
                        Text("Start your journey to financial freedom")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.gray)
                        
                        VStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    appStateManager.moveToOnboarding()
                                }
                            }) {
                                Text("Continue with Apple")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.black)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(BouncyButtonStyle())
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    appStateManager.moveToOnboarding()
                                }
                            }) {
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(Color.white)
                                    .foregroundStyle(.black)
                                    .clipShape(Capsule())
                                    .overlay(Capsule().stroke(Color.black.opacity(0.08), lineWidth: 1))
                            }
                            .buttonStyle(BouncyButtonStyle())
                        }
                    }
                    .padding(.top, 120)
                    .padding(.horizontal, 32)
                }
                .padding(.top, 170)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
    
    private func parameterView(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(.gray)
                .tracking(0.5)
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.black)
            
            RoundedRectangle(cornerRadius: 1)
                .fill(color)
                .frame(width: 20, height: 2)
        }
    }
}

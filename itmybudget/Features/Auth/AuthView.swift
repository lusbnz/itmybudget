import SwiftUI
import AuthenticationServices
import Combine

struct AuthView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var isAnimating = false
    @State private var moveAnimating = false
    @State private var chartValues: [CGFloat] = (0..<14).map { _ in CGFloat.random(in: 15...40) }
    @State private var highlightedIndex: Int = 3
    @State private var progressValue: CGFloat = 0.0
    @State private var netWorth: Double = 84250.00
    @State private var shimmerOffset: CGFloat = -0.5
    
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
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    appStateManager.moveToOnboarding()
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "applelogo")
                                        .font(.system(size: 18))
                                    LText("auth.continue_apple")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .background(
                                    ZStack {
                                        Color.black
                                        LinearGradient(colors: [.white.opacity(0.12), .clear], startPoint: .top, endPoint: .bottom)
                                    }
                                )
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                            }
                            .buttonStyle(BouncyButtonStyle())
                            
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    appStateManager.moveToOnboarding()
                                }
                            }) {
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
                            .buttonStyle(BouncyButtonStyle())
                        }
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.4), value: isAnimating)
                    }
                    .padding(.top, 140)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 50)
                }
                .padding(.top, 170)
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

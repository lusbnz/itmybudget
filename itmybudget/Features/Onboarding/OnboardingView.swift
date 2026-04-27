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
    
    let steps = [
        OnboardingStep(
            title: "Basic Setup",
            description: "Personalize your experience by choosing your preferred language and currency.",
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
                    .font(.system(size: 14, weight: .bold))
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
                                
                                Spacer()
                                
                                // Footer Note Box (AI Insight Style)
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "sparkles")
                                            .font(.system(size: 14, weight: .bold))
                                        Text("AI Insight")
                                            .font(.system(size: 12, weight: .bold))
                                            .textCase(.uppercase)
                                    }
                                    .foregroundStyle(.white.opacity(0.8))
                                    
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
                                .padding(.bottom, 40)
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
}

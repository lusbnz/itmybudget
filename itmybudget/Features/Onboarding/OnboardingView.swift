import SwiftUI

struct OnboardingView: View {
    @Environment(AppStateManager.self) private var appStateManager
    @State private var selection: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack {
                TabView(selection: $selection) {
                    OnboardingSlide(
                        title: "Basic Setup",
                        description: "Welcome! Let's start your journey to effective financial management.",
                        image: "gearshape.fill",
                        tag: 0
                    )
                    
                    OnboardingSlide(
                        title: "Expense Categorization",
                        description: "Organize all your income and expenses into clear and scientific categories.",
                        image: "list.bullet.rectangle.portrait.fill",
                        tag: 1
                    )
                    
                    OnboardingSlide(
                        title: "First Budget",
                        description: "Set your spending plan for this month to reach your financial goals faster.",
                        image: "briefcase.fill",
                        tag: 2
                    )
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                
                VStack(spacing: 16) {
                    Button(action: {
                        if selection < 2 {
                            withAnimation {
                                selection += 1
                            }
                        } else {
                            appStateManager.moveToMain()
                        }
                    }) {
                        Text(selection == 2 ? "Get Started" : "Next")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                    
                    if selection < 2 {
                        Button(action: {
                            appStateManager.moveToMain()
                        }) {
                            Text("Skip")
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

struct OnboardingSlide: View {
    let title: String
    let description: String
    let image: String
    let tag: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundStyle(.blue.gradient)
                .padding(.bottom, 16)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 40)
        }
        .tag(tag)
    }
}

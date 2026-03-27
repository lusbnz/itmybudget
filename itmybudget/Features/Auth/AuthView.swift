import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("itmybudget")
                        .font(.custom("Outfit-Bold", size: 40))
                        .fontWeight(.black)
                        .foregroundStyle(.white)
                    
                    Text("Chi tiêu thông minh, tương lai an tâm")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.7))
                }
                
                Spacer()
                
                // Login Buttons
                VStack(spacing: 16) {
                    // Apple Login Button
                    SignInWithAppleButton { request in
                        // Perform request
                    } onCompletion: { result in
                        // Handle result
                        appStateManager.moveToOnboarding()
                    }
                    .frame(height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    }
                    
                    // Google Login Button (UI Only)
                    Button {
                        appStateManager.moveToOnboarding()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill") // Placeholder for Google logo
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                            
                            Text("Tiếp tục với Google")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(.white)
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 64)
            }
        }
    }
}

import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppStateManager.self) private var appStateManager
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                VStack(spacing: 8) {
                    Text("itmybudget")
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(.blue)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        appStateManager.moveToOnboarding()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill") 
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.red)
                            
                            Text("Continue with Google")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(white: 0.96))
                        .foregroundStyle(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 64)
            }
        }
    }
}

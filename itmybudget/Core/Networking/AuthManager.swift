import Foundation
import Observation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

@Observable
class AuthManager {
    static let shared = AuthManager()
    
    var accessToken: String? {
        get { UserDefaults.standard.string(forKey: "access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "access_token") }
    }
    
    var refreshToken: String? {
        get { UserDefaults.standard.string(forKey: "refresh_token") }
        set { UserDefaults.standard.set(newValue, forKey: "refresh_token") }
    }
    
    var isAuthenticated: Bool {
        accessToken != nil
    }
    
    private init() {}
    
    @MainActor
    func signInWithGoogle() async throws {
        // 1. Get client ID from Firebase
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase Client ID not found"])
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 2. Start Google Sign In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: getRootViewController())
        let user = result.user
        
        print("🔑 Google User Email: \(user.profile?.email ?? "No Email")")
        
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Google ID Token not found"])
        }
        
        print("🆔 Google ID Token: \(idToken)")
        
        // 3. Authenticate with Firebase (Optional, but usually done if using Firebase)
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        let firebaseResult = try await Auth.auth().signIn(with: credential)
        print("🔥 Firebase Login Success: \(firebaseResult.user.uid)")
        
        // 4. Send Firebase ID Token to Backend
        print("📡 Sending Firebase ID Token to Backend...")
        let firebaseIdToken = try await firebaseResult.user.getIDToken()
        print("🆔 Firebase ID Token: \(firebaseIdToken)")
        let endpoint = AuthEndpoint.social(firebaseIdToken)
        let token: AuthToken = try await NetworkManager.shared.request(endpoint)
        
        // 5. Store tokens
        self.accessToken = token.access_token
        self.refreshToken = token.refresh_token
        
        print("✅ Backend Login Success!")
        print("🎟️ Access Token: \(token.access_token)")
        print("🔄 Refresh Token: \(token.refresh_token)")
    }
    
    func logout() {
        accessToken = nil
        refreshToken = nil
        try? Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    private func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
}

import Foundation
import Observation
import GoogleSignIn
import FirebaseCore
import FirebaseAuth
import SwiftData

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
    
    var currentUser: APIUserResponse? = nil
    
    private init() {}
    
    @MainActor
    func fetchMe(context: ModelContext? = nil) async {
        do {
            let user: APIUserResponse = try await NetworkManager.shared.request(UserEndpoint.me)
            self.currentUser = user
            saveToSwiftData(user, context: context)
            print("👤 Fetched User: \(user.full_name ?? user.email)")
        } catch {
            print("Failed to fetch user: \(error)")
        }
    }
    
    @MainActor
    func updateMe(fullName: String, context: ModelContext? = nil) async {
        do {
            let input = UpdateMeInput(full_name: fullName, password: nil, is_active: nil)
            let user: APIUserResponse = try await NetworkManager.shared.request(UserEndpoint.updateMe(input))
            self.currentUser = user
            saveToSwiftData(user, context: context)
            print("👤 Updated User: \(user.full_name ?? "")")
        } catch {
            print("Failed to update user: \(error)")
        }
    }
    
    @MainActor
    func updateAvatar(data: Data, fileName: String, mimeType: String, context: ModelContext? = nil) async {
        do {
            let user: APIUserResponse = try await NetworkManager.shared.request(UserEndpoint.updateAvatar(data, fileName: fileName, mimeType: mimeType))
            self.currentUser = user
            saveToSwiftData(user, context: context)
            print("👤 Updated Avatar")
        } catch {
            print("Failed to update avatar: \(error)")
        }
    }
    
    @MainActor
    func completeOnboarding(context: ModelContext? = nil) async {
        do {
            let input = UpdateOnboardingInput(is_new_user: false, extra: nil)
            let user: APIUserResponse = try await NetworkManager.shared.request(UserEndpoint.updateOnboarding(input))
            self.currentUser = user
            saveToSwiftData(user, context: context)
            print("👤 Completed Onboarding")
        } catch {
            print("Failed to complete onboarding: \(error)")
        }
    }
    
    private func saveToSwiftData(_ user: APIUserResponse, context: ModelContext?) {
        guard let context = context else { return }
        let userId = user.id
        let fetchDescriptor = FetchDescriptor<DBUser>(predicate: #Predicate { $0.id == userId })
        
        if let existing = try? context.fetch(fetchDescriptor).first {
            existing.email = user.email
            existing.fullName = user.full_name
            existing.isActive = user.is_active
            existing.isSuperuser = user.is_superuser
            existing.isNewUser = user.is_new_user
            existing.avatarUrl = user.avatar_url
            existing.provider = user.provider
            existing.createdAt = user.created_at
            existing.updatedAt = user.updated_at
        } else {
            let dbUser = DBUser(
                id: user.id,
                email: user.email,
                fullName: user.full_name,
                isActive: user.is_active,
                isSuperuser: user.is_superuser,
                isNewUser: user.is_new_user,
                avatarUrl: user.avatar_url,
                provider: user.provider,
                createdAt: user.created_at,
                updatedAt: user.updated_at
            )
            context.insert(dbUser)
        }
        try? context.save()
    }
    
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

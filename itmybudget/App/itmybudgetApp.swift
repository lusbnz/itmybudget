import SwiftUI
import SwiftData
import FirebaseCore
import GoogleSignIn

@main
struct itmybudgetApp: App {
    @State private var appStateManager = AppStateManager()
    @State private var localizationManager = LocalizationManager.shared
    
    init() {
        FirebaseApp.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            UserSettings.self,
            DBCategory.self,
            DBBudget.self,
            DBUser.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appStateManager)
                .environment(localizationManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

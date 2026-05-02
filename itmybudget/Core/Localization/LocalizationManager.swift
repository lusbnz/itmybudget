import SwiftUI
import Observation

@Observable
class LocalizationManager {
    static let shared = LocalizationManager()
    
    var currentLanguage: String = "en" {
        didSet {
            loadLanguage(currentLanguage)
        }
    }
    
    private var strings: [String: Any] = [:]
    
    init() {
        let language = UserDefaults.standard.string(forKey: "selected_language") ?? "en"
        self.currentLanguage = language
        loadLanguage(language)
    }
    
    func loadLanguage(_ lang: String) {
        guard let url = Bundle.main.url(forResource: lang, withExtension: "json") else {
            loadFallback(lang)
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            self.strings = json ?? [:]
            UserDefaults.standard.set(lang, forKey: "selected_language")
        } catch {
            print("Error loading localization file: \(error)")
        }
    }
    
    private func loadFallback(_ lang: String) {
        print("Localization: Using fallback loading for \(lang)")
    }
    
    func t(_ key: String) -> String {
        let parts = key.components(separatedBy: ".")
        var current: Any? = strings
        
        for part in parts {
            if let dict = current as? [String: Any] {
                current = dict[part]
            } else {
                return key
            }
        }
        
        return current as? String ?? key
    }
}

extension String {
    var localized: String {
        LocalizationManager.shared.t(self)
    }
}

struct LText: View {
    let key: String
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(LocalizationManager.shared.t(key))
    }
}

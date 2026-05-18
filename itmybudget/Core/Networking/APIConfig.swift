import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://phin-backend-ntt9453-tjakx9lg.leapcell.dev")!
    static let apiVersion = "/api/v1"
    
    static var apiBaseURL: URL {
        baseURL.appendingPathComponent(apiVersion)
    }
}

import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://p01--phin-backend--7xs9c7l2dvfd.code.run")!
    static let apiVersion = "/api/v1"
    
    static var apiBaseURL: URL {
        baseURL.appendingPathComponent(apiVersion)
    }
}

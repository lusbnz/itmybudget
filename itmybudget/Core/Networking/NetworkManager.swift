import Foundation

enum NetworkError: Error {
    case invalidResponse
    case unauthorized
    case serverError(String)
    case decodingError(Error)
    case unknown(Error)
}

class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: configuration)
    }
    
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        var urlRequest = try endpoint.urlRequest()
        
        // Inject Authorization header if token exists
        if let token = AuthManager.shared.accessToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Log request for debugging
        print("🚀 Request: \(urlRequest.httpMethod ?? "") \(urlRequest.url?.absoluteString ?? "")")
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("✅ Response: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoder = JSONDecoder()
                // Backend uses snake_case based on openapi.json
                decoder.keyDecodingStrategy = .useDefaultKeys 
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                throw NetworkError.decodingError(error)
            }
        case 401:
            AuthManager.shared.logout()
            throw NetworkError.unauthorized
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkError.serverError(errorMessage)
        }
    }
}

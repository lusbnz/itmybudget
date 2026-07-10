import Foundation

struct EmptyResponse: Codable {}

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
        print("💻 cURL:\n\(urlRequest.curlString)")
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        print("✅ Response: \(httpResponse.statusCode)")
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                if data.isEmpty, let empty = EmptyResponse() as? T {
                    return empty
                }
                let decoder = JSONDecoder()
                // Backend uses snake_case based on openapi.json
                decoder.keyDecodingStrategy = .useDefaultKeys 
                return try decoder.decode(T.self, from: data)
            } catch {
                if let empty = EmptyResponse() as? T {
                    return empty
                }
                print("❌ Decoding Error: \(error)")
                throw NetworkError.decodingError(error)
            }
        case 401:
            if let refreshToken = AuthManager.shared.refreshToken {
                print("🔄 Token expired, attempting to refresh...")
                do {
                    let refreshEndpoint = AuthEndpoint.refreshToken(refreshToken)
                    let refreshRequest = try refreshEndpoint.urlRequest()
                    
                    let (refreshData, refreshResponse) = try await session.data(for: refreshRequest)
                    
                    if let refreshHttp = refreshResponse as? HTTPURLResponse, refreshHttp.statusCode >= 200, refreshHttp.statusCode <= 299 {
                        let token: AuthToken = try JSONDecoder().decode(AuthToken.self, from: refreshData)
                        AuthManager.shared.accessToken = token.access_token
                        AuthManager.shared.refreshToken = token.refresh_token
                        print("✅ Token refreshed successfully!")
                        
                        // Retry original request with new token
                        urlRequest.setValue("Bearer \(token.access_token)", forHTTPHeaderField: "Authorization")
                        let (retryData, retryResponse) = try await session.data(for: urlRequest)
                        
                        if let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode >= 200, retryHttp.statusCode <= 299 {
                            do {
                                if retryData.isEmpty, let empty = EmptyResponse() as? T {
                                    return empty
                                }
                                let decoder = JSONDecoder()
                                decoder.keyDecodingStrategy = .useDefaultKeys 
                                return try decoder.decode(T.self, from: retryData)
                            } catch {
                                throw NetworkError.decodingError(error)
                            }
                        }
                    } else {
                        print("❌ Refresh token failed or rejected")
                    }
                } catch {
                    print("❌ Failed to refresh token: \(error)")
                }
            }
            
            AuthManager.shared.logout()
            throw NetworkError.unauthorized
        default:
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkError.serverError(errorMessage)
        }
    }
}

extension URLRequest {
    var curlString: String {
        guard let url = url else { return "" }
        var baseCommand = #"curl "\#(url.absoluteString)""#

        if let method = httpMethod {
            baseCommand += #" -X \#(method)"#
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers {
                baseCommand += #" -H "\#(key): \#(value)""#
            }
        }

        if let data = httpBody, let bodyString = String(data: data, encoding: .utf8) {
            let escapedBody = bodyString.replacingOccurrences(of: "'", with: "'\\''")
            baseCommand += #" -d '\#(escapedBody)'"#
        }

        return baseCommand
    }
}

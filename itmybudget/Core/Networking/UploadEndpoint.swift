import Foundation
import UIKit

struct APIUploadResponse: Codable {
    let url: String?
    let urls: [String]?
    let fileUrl: String?
    let path: String?
    let data: [String]?
}

enum UploadEndpoint: APIEndpoint {
    case uploadFiles(images: [Data])
    
    var path: String {
        return "/upload/"
    }
    
    var method: HTTPMethod {
        return .post
    }
    
    var boundary: String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    var headers: [String : String]? {
        switch self {
        case .uploadFiles:
            // Due to property being computed, we'd need a consistent boundary. 
            // So we'll hardcode one for this specific endpoint.
            return ["Content-Type": "multipart/form-data; boundary=itmybudget-upload-boundary"]
        }
    }
    
    var queryParameters: [String : Any]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case .uploadFiles(let images):
            var data = Data()
            let b = "itmybudget-upload-boundary"
            for (index, imageData) in images.enumerated() {
                data.append("--\(b)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"files\"; filename=\"image\(index).jpg\"\r\n".data(using: .utf8)!)
                data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                data.append(imageData)
                data.append("\r\n".data(using: .utf8)!)
            }
            data.append("--\(b)--\r\n".data(using: .utf8)!)
            return data
        }
    }
}

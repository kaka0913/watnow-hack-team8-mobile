import Foundation
import Alamofire

struct GetWalksRequest: RequestProtocol {
    typealias Response = WalksResponse
    
    let path = "/walks"
    let method = HTTPMethod.get
    
    private let bbox: String?
    
    init(bbox: String? = nil) {
        self.bbox = bbox
    }
    
    var query: Parameters? {
        var params: Parameters = [:]
        if let bbox = bbox {
            params["bbox"] = bbox
        }
        return params.isEmpty ? nil : params
    }
    
    var parameters: Parameters? {
        return nil // GETリクエストなのでbodyパラメータはなし
    }
}

// MARK: - Codable Conformance
extension GetWalksRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case bbox
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.bbox = try container.decodeIfPresent(String.self, forKey: .bbox)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(bbox, forKey: .bbox)
    }
}

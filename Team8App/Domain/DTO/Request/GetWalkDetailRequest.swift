import Foundation
import Alamofire

struct GetWalkDetailRequest: RequestProtocol {
    typealias Response = WalkDetailResponse
    
    let method = HTTPMethod.get
    
    private let walkId: String
    
    init(walkId: String) {
        self.walkId = walkId
    }
    
    var path: String {
        return "/walks/\(walkId)"
    }
    
    var query: Parameters? {
        return nil
    }
    
    var parameters: Parameters? {
        return nil // GETリクエストなのでbodyパラメータはなし
    }
}

// MARK: - Codable Conformance
extension GetWalkDetailRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case walkId
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.walkId = try container.decode(String.self, forKey: .walkId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(walkId, forKey: .walkId)
    }
}

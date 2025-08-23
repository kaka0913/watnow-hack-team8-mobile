import Foundation
import Alamofire

struct RecalculateRouteRequest: RequestProtocol {
    typealias Response = RouteRecalculateResponse
    
    let path = "/routes/recalculate"
    let method = HTTPMethod.post
    
    private let routeRecalculateRequest: RouteRecalculateRequest
    
    init(routeRecalculateRequest: RouteRecalculateRequest) {
        self.routeRecalculateRequest = routeRecalculateRequest
    }
    
    var parameters: Parameters? {
        return try? routeRecalculateRequest.asDictionary()
    }
}

// MARK: - Codable Conformance
extension RecalculateRouteRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case routeRecalculateRequest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeRecalculateRequest = try container.decode(RouteRecalculateRequest.self, forKey: .routeRecalculateRequest)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(routeRecalculateRequest, forKey: .routeRecalculateRequest)
    }
}

struct RouteRecalculateRequest: Codable {
    let proposalId: String
    let currentLocation: Location
    let destination: Location?  // APIに合わせて"destination"に変更
    let mode: WalkMode
    let visitedPois: VisitedPois
    
    enum CodingKeys: String, CodingKey {
        case proposalId = "proposal_id"
        case currentLocation = "current_location"
        case destination = "destination"  // APIフィールド名に合わせる
        case mode
        case visitedPois = "visited_pois"
    }
}

struct VisitedPois: Codable {
    let previousPois: [VisitedPoi]
    
    enum CodingKeys: String, CodingKey {
        case previousPois = "previous_pois"
    }
}

struct VisitedPoi: Codable {
    let name: String
    let poiId: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case poiId = "poi_id"
    }
}


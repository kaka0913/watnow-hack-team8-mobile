import Foundation
import Alamofire

struct GenerateRouteProposalsRequest: RequestProtocol {
    typealias Response = RouteProposalResponse
    
    let path = "/routes/proposals"
    let method = HTTPMethod.post
    
    private let routeProposalRequest: RouteProposalRequest
    
    init(routeProposalRequest: RouteProposalRequest) {
        self.routeProposalRequest = routeProposalRequest
    }
    
    var parameters: Parameters? {
        return try? routeProposalRequest.asDictionary()
    }
}

// MARK: - Codable Conformance
extension GenerateRouteProposalsRequest: Codable {
    enum CodingKeys: String, CodingKey {
        case routeProposalRequest
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.routeProposalRequest = try container.decode(RouteProposalRequest.self, forKey: .routeProposalRequest)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(routeProposalRequest, forKey: .routeProposalRequest)
    }
}

struct RouteProposalRequest: Codable {
    let startLocation: Location
    let destination: Location?  // APIに合わせて"destination"に変更
    let mode: WalkMode
    let durationMinutes: Int?   // APIに合わせて"duration_minutes"に変更
    let theme: String
    
    enum CodingKeys: String, CodingKey {
        case startLocation = "start_location"
        case destination = "destination"  // APIフィールド名に合わせる
        case mode, theme
        case durationMinutes = "duration_minutes"  // APIフィールド名に合わせる
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}

enum WalkMode: String, Codable {
    case destination = "destination"
    case timeBased = "time_based"
}

struct RealtimeContext: Codable {
    let weather: String
    let timeOfDay: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case timeOfDay = "time_of_day"
    }
}

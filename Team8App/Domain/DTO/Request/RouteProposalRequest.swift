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
    let destinationLocation: Location?
    let mode: WalkMode
    let timeMinutes: Int?
    let theme: String
    let realtimeContext: RealtimeContext
    
    enum CodingKeys: String, CodingKey {
        case startLocation = "start_location"
        case destinationLocation = "destination_location"
        case mode, theme
        case timeMinutes = "time_minutes"
        case realtimeContext = "realtime_context"
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

import Foundation

struct RouteProposalResponse: ResponseProtocol {
    let proposals: [RouteProposal]
}

struct RouteProposal: Codable {
    let proposalId: String
    let title: String
    let estimatedDurationMinutes: Int
    let estimatedDistanceMeters: Int
    let theme: String
    let displayHighlights: [String]
    let navigationSteps: [NavigationStep]
    let routePolyline: String
    let generatedStory: String
    
    enum CodingKeys: String, CodingKey {
        case proposalId = "proposal_id"
        case title, theme
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case estimatedDistanceMeters = "estimated_distance_meters"
        case displayHighlights = "display_highlights"
        case navigationSteps = "navigation_steps"
        case routePolyline = "route_polyline"
        case generatedStory = "generated_story"
    }
}

struct NavigationStep: Codable {
    let type: NavigationStepType
    let description: String
    let distanceToNextMeters: Int
    let poiId: String?
    let name: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case type, description, name, latitude, longitude
        case distanceToNextMeters = "distance_to_next_meters"
        case poiId = "poi_id"
    }
}

enum NavigationStepType: String, Codable {
    case navigation = "navigation"
    case poi = "poi"
}


import Foundation

struct RouteRecalculateResponse: ResponseProtocol {
    let updatedRoute: UpdatedRoute
    
    enum CodingKeys: String, CodingKey {
        case updatedRoute = "updated_route"
    }
}

struct UpdatedRoute: Codable {
    let title: String
    let estimatedDurationMinutes: Int
    let estimatedDistanceMeters: Int
    let highlights: [String]
    let routePolyline: String
    let generatedStory: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case estimatedDurationMinutes = "estimated_duration_minutes"
        case estimatedDistanceMeters = "estimated_distance_meters"
        case highlights
        case routePolyline = "route_polyline"
        case generatedStory = "generated_story"
    }
}

import Foundation

struct RouteRecalculateResponse: ResponseProtocol {
    let updatedRoute: UpdatedRoute
    
}

struct UpdatedRoute: Codable {
    let title: String
    let estimatedDurationMinutes: Int
    let estimatedDistanceMeters: Int
    let highlights: [String]
    let routePolyline: String
    let generatedStory: String
    
}

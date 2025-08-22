import Foundation

protocol StoryRouteRepositoryProtocol {
    func fetchStoryRoutes() async throws -> [StoryRoute]
}

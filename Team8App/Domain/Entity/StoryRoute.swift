import Foundation

struct StoryRoute: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let duration: Int // minutes
    let distance: Double // kilometers
    let category: RouteCategory
    let iconColor: RouteIconColor
    let highlights: [RouteHighlight]
    let routePolyline: String? // ポリライン文字列を追加
    
    enum RouteCategory: String, Codable, CaseIterable {
        case gourmet = "グルメ・文化"
        case nature = "自然・癒し"
        case art = "アート・発見"
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    enum RouteIconColor: String, Codable, CaseIterable {
        case pink = "pink"
        case green = "green"
        case purple = "purple"
        case blue = "blue"
        case orange = "orange"
        
        var emoji: String {
 
                return "🐝"
            
        }
    }
}

struct RouteHighlight: Identifiable, Codable {
    let id: String
    let name: String
    let iconColor: String
    
    init(id: String = UUID().uuidString, name: String, iconColor: String = "orange") {
        self.id = id
        self.name = name
        self.iconColor = iconColor
    }
}

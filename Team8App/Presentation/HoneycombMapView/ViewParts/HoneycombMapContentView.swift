import SwiftUI
import MapKit

struct HoneycombMapContentView: View {
    let routes: [StoryRoute]
    let onRouteSelect: (StoryRoute) -> Void
    
    var body: some View {
        ZStack {
            // 統合されたマップビュー（アノテーションとポリライン）
            UnifiedMapView(routes: routes, onRouteSelect: onRouteSelect)
            
            // 地図コントロール
            VStack {
                Spacer()
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Helper Methods
    private func routeColor(for route: StoryRoute) -> Color {
        switch route.iconColor {
        case .blue:
            return Color.blue
        case .green:
            return Color.green
        case .pink:
            return Color.pink
        case .orange:
            return Color.orange
        case .purple:
            return Color.purple
        }
    }
}

#Preview {
    HoneycombMapContentView(
        routes: [
            StoryRoute(
                id: "1",
                title: "雨上がりの虹色散歩道",
                description: "雨上がりの街に現れた小さな虹を追いかけて、思いがけない出会いと発見に満ちた散歩になりました。",
                duration: 38,
                distance: 2.1,
                category: .nature,
                iconColor: .green,
                highlights: [
                    RouteHighlight(name: "青山公園", iconColor: "green"),
                    RouteHighlight(name: "表参道カフェ", iconColor: "orange")
                ], routePolyline: nil
            ),
            StoryRoute(
                id: "2",
                title: "アートな午後",
                description: "表参道のギャラリー巡りで新しい発見がたくさんありました。",
                duration: 45,
                distance: 1.8,
                category: .art,
                iconColor: .purple,
                highlights: [
                    RouteHighlight(name: "現代美術館", iconColor: "purple"),
                    RouteHighlight(name: "デザインショップ", iconColor: "blue")
                ], routePolyline: nil
            )
        ],
        onRouteSelect: { _ in }
    )
}

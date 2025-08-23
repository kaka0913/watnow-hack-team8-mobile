import SwiftUI
import MapKit

struct HoneycombMapContentView: View {
    let routes: [StoryRoute]
    let onRouteSelect: (StoryRoute) -> Void
    
    // 東京（渋谷・表参道エリア）を中心とした地図の初期設定
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454), // 渋谷駅周辺
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // ズームレベル調整
    )
    
    var body: some View {
        ZStack {
            // 実際の地図表示
            Map(coordinateRegion: $region, annotationItems: routeAnnotations) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    Button(action: {
                        onRouteSelect(annotation.route)
                    }) {
                        ZStack {
                            // ベースの円
                            Circle()
                                .fill(routeColor(for: annotation.route))
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                            
                            // アイコン
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(0.9)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: annotation.route.id)
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .ignoresSafeArea()
            
            // 地図コントロール
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        // 現在位置ボタン
                        Button(action: {
                            // 渋谷エリアに戻る
                            withAnimation(.easeInOut(duration: 1.0)) {
                                region = MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454),
                                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                )
                            }
                        }) {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        
                        // 地図スタイル切り替えボタン
                        Button(action: {
                            // 今後のために予約（衛星地図への切り替えなど）
                        }) {
                            Image(systemName: "map.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.green)
                                .frame(width: 44, height: 44)
                                .background(Color.white.opacity(0.9))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.trailing, 16)
                }
                Spacer()
            }
            .padding(.top, 16)
        }
    }
    
    // MARK: - Computed Properties
    private var routeAnnotations: [RouteAnnotation] {
        return routes.enumerated().map { index, route in
            RouteAnnotation(
                id: route.id,
                route: route,
                coordinate: coordinateForRoute(at: index)
            )
        }
    }
    
    // MARK: - Helper Methods
    private func coordinateForRoute(at index: Int) -> CLLocationCoordinate2D {
        // 渋谷・表参道エリア周辺の実際の座標にルートを配置
        let baseCoordinate = CLLocationCoordinate2D(latitude: 35.6586, longitude: 139.7454) // 渋谷駅
        
        switch index % routes.count {
        case 0:
            // 代々木公園エリア
            return CLLocationCoordinate2D(latitude: 35.6663, longitude: 139.7380)
        case 1:
            // 表参道エリア
            return CLLocationCoordinate2D(latitude: 35.6643, longitude: 139.7280)
        case 2:
            // 原宿エリア
            return CLLocationCoordinate2D(latitude: 35.6708, longitude: 139.7028)
        case 3:
            // 青山エリア
            return CLLocationCoordinate2D(latitude: 35.6626, longitude: 139.7096)
        default:
            // その他は渋谷周辺にランダム配置
            let latOffset = Double.random(in: -0.005...0.005)
            let lonOffset = Double.random(in: -0.005...0.005)
            return CLLocationCoordinate2D(
                latitude: baseCoordinate.latitude + latOffset,
                longitude: baseCoordinate.longitude + lonOffset
            )
        }
    }
    
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

// MARK: - RouteAnnotation
struct RouteAnnotation: Identifiable {
    let id: String
    let route: StoryRoute
    let coordinate: CLLocationCoordinate2D
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
                ]
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
                ]
            )
        ],
        onRouteSelect: { _ in }
    )
}

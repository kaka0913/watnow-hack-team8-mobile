import SwiftUI

struct HoneycombMapContentView: View {
    let routes: [StoryRoute]
    let onRouteSelect: (StoryRoute) -> Void
    
    var body: some View {
        ZStack {
            // 背景色（淡い緑）
            Color(red: 0.9, green: 1.0, blue: 0.9)
                .ignoresSafeArea()
            
            // マップ上のポイント
            ForEach(Array(routes.enumerated()), id: \.element.id) { index, route in
                Button(action: {
                    onRouteSelect(route)
                }) {
                    Circle()
                        .fill(routeColor(for: route))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 3)
                        )
                        .overlay(
                            Image(systemName: "location.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .position(positionForRoute(at: index))
            }
            
            // 中央のメッセージ
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("🐝")
                            .font(.system(size: 24))
                    )
                
                Text("ハニカムマップ")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("散歩の投稿がマップ上に表示されます")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.9))
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
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
    
    private func positionForRoute(at index: Int) -> CGPoint {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        // 画面の四隅あたりにポイントを配置
        switch index {
        case 0:
            return CGPoint(x: screenWidth * 0.2, y: screenHeight * 0.3)
        case 1:
            return CGPoint(x: screenWidth * 0.8, y: screenHeight * 0.25)
        case 2:
            return CGPoint(x: screenWidth * 0.15, y: screenHeight * 0.75)
        case 3:
            return CGPoint(x: screenWidth * 0.85, y: screenHeight * 0.8)
        default:
            return CGPoint(x: screenWidth * 0.5, y: screenHeight * 0.5)
        }
    }
}

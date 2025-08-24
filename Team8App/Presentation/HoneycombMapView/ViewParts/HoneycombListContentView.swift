import SwiftUI

struct HoneycombListContentView: View {
    let routes: [StoryRoute]
    let onRouteSelect: (StoryRoute) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ヘッダー
                Text("気になる散歩をタップ")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                
                // ルートリスト
                LazyVStack(spacing: 16) {
                    ForEach(routes) { route in
                        HoneycombStoryRouteCard(
                            route: route,
                            onTap: {
                                onRouteSelect(route)
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .background(Color(red: 0.98, green: 0.98, blue: 0.98))
    }
}

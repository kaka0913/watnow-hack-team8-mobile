import SwiftUI

struct AppHeaderView: View {
    let appTitle: String
    let appSubtitle: String
    
    var body: some View {
        VStack(spacing: 16) {
            // アプリアイコン
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("🐝")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.black)
                )
            
            // タイトル
            Text(appTitle)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.orange)
            
            // サブタイトル
            Text(appSubtitle)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    AppHeaderView(
        appTitle: "BeFree",
        appSubtitle: "蜜を集めるように、街の魅力を巡る散歩へ"
    )
    .padding()
}
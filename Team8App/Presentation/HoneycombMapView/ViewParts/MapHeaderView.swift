import SwiftUI

struct MapHeaderView: View {
    let isMapView: Bool
    let onDisplayModeToggle: () -> Void
    let onBackTap: () -> Void
    
    var body: some View {
        HStack {
            // 戻るボタン
            Button(action: onBackTap) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                    Text("戻る")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.primary)
            }
            
            Spacer()
            
            // タイトル
            HStack(spacing: 8) {
                Text("🐝")
                    .font(.system(size: 20))
                Text("ハニカムマップ")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // 表示切り替えボタン
            Button(action: onDisplayModeToggle) {
                HStack(spacing: 6) {
                    Image(systemName: isMapView ? "list.bullet" : "map")
                        .font(.system(size: 16, weight: .medium))
                    Text(isMapView ? "リスト" : "マップ")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.1))
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

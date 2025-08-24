import SwiftUI

struct HoneycombStoryRouteCard: View {
    let route: StoryRoute
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // ヘッダー部分
                HStack(spacing: 12) {
                    // アイコン
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundColor)
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text("🐝")
                                .font(.system(size: 24))
                        )
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(route.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "location")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            Text(areaText)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            Text(dateText)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                // 説明文
                Text(route.description)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                // 時間・距離・カテゴリ
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                        Text("\(route.duration)分")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                        Text(String(format: "%.1fkm", route.distance))
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                    
                    Text(route.category.displayName)
                        .font(.system(size: 12, weight: .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(categoryBackgroundColor)
                        )
                        .foregroundColor(categoryTextColor)
                    
                    Spacer()
                }
                
                // 立ち寄りスポット
                if !route.highlights.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("立ち寄ったスポット:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                            ForEach(route.highlights.prefix(6)) { highlight in
                                Text(highlight.name)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                        }
                        
                        // タグ表示
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    private var iconBackgroundColor: Color {
        switch route.iconColor {
        case .blue:
            return Color.blue.opacity(0.2)
        case .green:
            return Color.green.opacity(0.2)
        case .pink:
            return Color.pink.opacity(0.2)
        case .orange:
            return Color.orange.opacity(0.2)
        case .purple:
            return Color.purple.opacity(0.2)
        }
    }
    
    private var categoryBackgroundColor: Color {
        switch route.category {
        case .gourmet:
            return Color.orange.opacity(0.2)
        case .nature:
            return Color.green.opacity(0.2)
        case .art:
            return Color.purple.opacity(0.2)
        }
    }
    
    private var categoryTextColor: Color {
        switch route.category {
        case .gourmet:
            return Color.orange
        case .nature:
            return Color.green
        case .art:
            return Color.purple
        }
    }
    
    private var areaText: String {
        // モックデータのエリア情報
        switch route.id {
        case "1":
            return "渋谷・表参道エリア"
        case "2":
            return "下北沢エリア"
        default:
            return "都内エリア"
        }
    }
    
    private var dateText: String {
        // モックデータの日付情報
        switch route.id {
        case "1":
            return "2024年1月15日"
        case "2":
            return "2024年1月12日"
        default:
            return "2024年1月10日"
        }
    }
    
    private var tags: [String] {
        switch route.category {
        case .gourmet:
            return ["#カフェ", "#猫", "#隠れ家"]
        case .nature:
            return ["#自然", "#偶然の出会い"]
        case .art:
            return ["#アート", "#文化"]
        }
    }
}

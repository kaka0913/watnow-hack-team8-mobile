import SwiftUI

struct WalkOptionCard: View {
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    let title: String
    let subtitle: String
    let buttonText: String
    let buttonColor: Color
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // アイコン
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Group {
                            if icon.count <= 3 && icon.unicodeScalars.allSatisfy({ $0.properties.isEmoji }) {
                                // 絵文字の場合
                                Text(icon)
                                    .font(.system(size: 28))
                            } else {
                                // SFシンボルの場合
                                Image(systemName: icon)
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(iconColor)
                            }
                        }
                    )
                
                // タイトルとサブタイトル
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            // ボタン
            Button(action: action) {
                HStack {
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .medium))
                        
                        Text(buttonText)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(buttonColor)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        WalkOptionCard(
            icon: "🧭",
            iconColor: .white,
            backgroundColor: .blue,
            title: "目的地を決めて出発",
            subtitle: "寄り道しながらのんびりと散歩しよう",
            buttonText: "散歩を始める",
            buttonColor: .blue,
            action: { print("Button tapped") }
        )
        
        WalkOptionCard(
            icon: "⏰",
            iconColor: .white,
            backgroundColor: .green,
            title: "目的地なしで出発",
            subtitle: "時間だけ決めて、気ままに散歩を",
            buttonText: "散歩を始める",
            buttonColor: .green,
            action: { print("Clock tapped") }
        )
        
        WalkOptionCard(
            icon: "🔶",
            iconColor: .white,
            backgroundColor: .purple,
            title: "ハニカムマップを見る",
            subtitle: "他の散歩者を追体験しよう",
            buttonText: "地図を探索する",
            buttonColor: .purple,
            action: { print("Honeycomb tapped") }
        )
    }
    .padding()
}

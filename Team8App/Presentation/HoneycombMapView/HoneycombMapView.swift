import SwiftUI

struct HoneycombMapView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("🔶")
                    .font(.system(size: 80))
                
                Text("ハニカムマップ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("他の散歩者の軌跡を見ることができます")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // TODO: マップ機能は後で実装
                Text("マップ機能は開発中です")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                
                Spacer()
                
                Button("戻る") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .navigationTitle("ハニカムマップ")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    HoneycombMapView()
}
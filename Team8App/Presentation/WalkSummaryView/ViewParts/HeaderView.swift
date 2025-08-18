//
//  HeaderView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/11.
//

import SwiftUI

struct HeaderView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onDismiss) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("戻る")
                        .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Text("🥳  散歩完了！")
                .font(.headline)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    HeaderView(onDismiss: {})
}

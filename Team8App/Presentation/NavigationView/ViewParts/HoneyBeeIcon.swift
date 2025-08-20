//
//  HoneyBeeIcon.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct HoneyBeeIcon: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .fill(.yellow)
            .frame(width: 50, height: 50)
            .overlay {
                Text("🐝")
                    .font(.system(size: 28))
                    .offset(y: isAnimating ? -2 : 2)
            }
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    HoneyBeeIcon()
        .padding()
}
//
//  FreeWalkView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct FreeWalkView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景色 - クリーム色
            Color(red: 1.0, green: 1.0, blue: 0.90)
                .ignoresSafeArea()
            
            VStack(spacing: 5) {
                Text("自由散歩")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("準備中...")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                Spacer()
                
                NavigationLink(destination: WalkSummaryView()) {
                    Text("散歩を終了")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("自由散歩")
        .navigationBarTitleDisplayMode(.inline)
    }
}


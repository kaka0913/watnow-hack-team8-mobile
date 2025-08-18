//
//  DestinationHeaderView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/18.
//

import SwiftUI

struct DestinationHeaderView: View {
    let onBack: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
                .foregroundColor(.blue)
            }
            
            Spacer()
            
            HStack {
                Image(systemName: "location.circle.fill")
                    .foregroundColor(.orange)
                Text("目的地設定")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Spacer()
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    DestinationHeaderView(onBack: {})
}

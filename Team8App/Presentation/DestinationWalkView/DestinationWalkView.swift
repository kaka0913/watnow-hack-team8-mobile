//
//  DestinationWalkView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/21.
//

import SwiftUI

struct DestinationWalkView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("A")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("目的地を決めて出発")
    }
}

#Preview {
    NavigationStack {
        DestinationWalkView()
    }
}

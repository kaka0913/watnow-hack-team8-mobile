//
//  HoneycombMapView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/21.
//

import SwiftUI

struct HoneycombMapView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("C")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("ハニカムマップを見る")
    }
}

#Preview {
    NavigationStack {
        HoneycombMapView()
    }
}

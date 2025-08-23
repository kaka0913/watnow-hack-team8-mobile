//
//  FreeWalkView.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/20.
//

import SwiftUI

struct FreeWalkView: View {
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            Text("B")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("目的地なしで出発")
     }
    }


#Preview {
    NavigationStack {
        FreeWalkView()
    }
}

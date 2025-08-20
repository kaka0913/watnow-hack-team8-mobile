//
//  RouteSearchButton.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/18.
//

import SwiftUI

struct RouteSearchButton: View {
    let isFormValid: Bool
    let isLoading: Bool
    let onSearchRoute: () -> Void
    
    var body: some View {
        Button(action: onSearchRoute) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "location.magnifyingglass")
                }
                Text(isLoading ? "検索中..." : "ルートを探す")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isFormValid ? Color.yellow : Color.gray
            )
            .cornerRadius(12)
            .disabled(!isFormValid || isLoading)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    VStack {
        RouteSearchButton(
            isFormValid: true,
            isLoading: false,
            onSearchRoute: {}
        )
        
        RouteSearchButton(
            isFormValid: false,
            isLoading: false,
            onSearchRoute: {}
        )
        
        RouteSearchButton(
            isFormValid: true,
            isLoading: true,
            onSearchRoute: {}
        )
    }
}
//
//  LocationSettingCard.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/18.
//

import SwiftUI

struct LocationSettingCard: View {
    @Binding var startLocation: String
    @Binding var destination: String
    let destinationPlaceholder: String
    let onPlaceSelected: ((PlaceDetails?) -> Void)?
    let onStartPlaceSelected: ((PlaceDetails?) -> Void)?
    
    @State private var selectedPlace: PlaceDetails? = nil
    @State private var selectedStartPlace: PlaceDetails? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 16) {
                Text("場所の設定")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Start Location
                VStack(alignment: .leading, spacing: 8) {
                    Text("出発地")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    AutocompleteTextField(
                        text: $startLocation,
                        selectedPlace: $selectedStartPlace,
                        placeholder: "現在地から出発（変更可能）"
                    )
                    .onChange(of: selectedStartPlace) { oldValue, newValue in
                        onStartPlaceSelected?(newValue)
                    }
                }
                
                // Destination
                VStack(alignment: .leading, spacing: 8) {
                    Text("目的地")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    AutocompleteTextField(
                        text: $destination,
                        selectedPlace: $selectedPlace,
                        placeholder: destinationPlaceholder
                    )
                    .onChange(of: selectedPlace) { oldValue, newValue in
                        onPlaceSelected?(newValue)
                    }
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            .contentShape(Rectangle()) // タップエリアを明確にする
        }
        .padding(.horizontal)
    }
}


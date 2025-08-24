//
//  AutocompleteTextField.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/24.
//

import SwiftUI
import CoreLocation

struct AutocompleteTextField: View {
    @Binding var text: String
    @Binding var selectedPlace: PlaceDetails?
    let placeholder: String
    
    @State private var predictions: [PlaceAutocompletePrediction] = []
    @State private var isLoading = false
    @State private var showPredictions = false
    @State private var searchTask: Task<Void, Never>?
    
    private let googlePlacesService = GooglePlacesService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // テキストフィールド
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: text) { oldValue, newValue in
                    handleTextChange(newValue)
                }
                .overlay(
                    HStack {
                        Spacer()
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .padding(.trailing, 8)
                        }
                    }
                )
            
            // 予測結果のリスト
            if showPredictions && !predictions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(predictions.indices, id: \.self) { index in
                        let prediction = predictions[index]
                        
                        Button(action: {
                            selectPrediction(prediction)
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.gray)
                                        .font(.caption)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(prediction.mainText)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        if !prediction.secondaryText.isEmpty {
                                            Text(prediction.secondaryText)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                                .lineLimit(1)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                
                                if index < predictions.count - 1 {
                                    Divider()
                                        .padding(.leading, 32)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPredictions)
    }
    
    private func handleTextChange(_ newValue: String) {
        // 既存の検索タスクをキャンセル
        searchTask?.cancel()
        
        guard !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            predictions = []
            showPredictions = false
            isLoading = false
            selectedPlace = nil
            return
        }
        
        // デバウンス処理（500ms待機）
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            
            guard !Task.isCancelled else { return }
            
            await performSearch(query: newValue)
        }
    }
    
    @MainActor
    private func performSearch(query: String) async {
        print("🔍 検索開始: '\(query)'")
        isLoading = true
        
        do {
            // 現在地を取得（オプション）
            let currentLocation = await getCurrentLocation()
            print("📍 現在地: \(currentLocation?.latitude ?? 0), \(currentLocation?.longitude ?? 0)")
            
            let results = try await googlePlacesService.fetchAutocompletePredictions(
                input: query,
                location: currentLocation
            )
            
            print("📋 検索結果: \(results.count)件")
            
            predictions = results
            showPredictions = !results.isEmpty
            
            if !results.isEmpty {
                print("✅ 候補表示: \(showPredictions)")
            } else {
                print("⚠️ 検索結果が0件")
            }
            
        } catch {
            print("❌ オートコンプリート検索エラー: \(error)")
            if let googleError = error as? GooglePlacesError {
                print("❌ Google Places エラー詳細: \(googleError.localizedDescription)")
            }
            predictions = []
            showPredictions = false
        }
        
        isLoading = false
        print("🔄 ローディング終了")
    }
    
    private func selectPrediction(_ prediction: PlaceAutocompletePrediction) {
        text = prediction.mainText
        showPredictions = false
        
        // 選択された場所の詳細を取得
        Task {
            do {
                let placeDetails = try await googlePlacesService.fetchPlaceDetails(
                    placeId: prediction.placeId
                )
                
                await MainActor.run {
                    selectedPlace = placeDetails
                    text = placeDetails.name
                }
                
                print("✅ 選択された場所: \(placeDetails.name) (\(placeDetails.coordinate.latitude), \(placeDetails.coordinate.longitude))")
                
            } catch {
                print("❌ 場所詳細取得エラー: \(error.localizedDescription)")
            }
        }
        
        // キーボードを閉じる
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func getCurrentLocation() async -> CLLocationCoordinate2D? {
        // LocationManagerから現在地を取得
        // ここでは京都を中心とした座標を返す（デフォルト）
        return CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681)
    }
}

#Preview {
    @Previewable @State var text = ""
    @Previewable @State var selectedPlace: PlaceDetails? = nil
    
    return VStack {
        AutocompleteTextField(
            text: $text,
            selectedPlace: $selectedPlace,
            placeholder: "目的地を入力してください"
        )
        .padding()
        
        if let place = selectedPlace {
            Text("選択された場所: \(place.name)")
                .padding()
        }
        
        Spacer()
    }
}

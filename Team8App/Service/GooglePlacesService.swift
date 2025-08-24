//
//  GooglePlacesService.swift
//  Team8App
//
//  Created by GitHub Copilot on 2025/08/24.
//

import Foundation
import CoreLocation

struct PlaceAutocompletePrediction: Equatable {
    let placeId: String
    let description: String
    let mainText: String
    let secondaryText: String
}

struct PlaceDetails: Equatable {
    let placeId: String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: PlaceDetails, rhs: PlaceDetails) -> Bool {
        return lhs.placeId == rhs.placeId &&
               lhs.name == rhs.name &&
               lhs.address == rhs.address &&
               lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

class GooglePlacesService {
    static let shared = GooglePlacesService()
    
    private let apiKey = Bundle.main.infoDictionary?["APIKeys"][GOOGLE_MAPS_API_KEY] as? String ?? ""
    private let baseURL = "https://places.googleapis.com/v1/places"
    private init() {}
    
    // MARK: - Autocomplete API
    func fetchAutocompletePredictions(
        input: String,
        location: CLLocationCoordinate2D? = nil,
        radius: Int = 50000 // 50km
    ) async throws -> [PlaceAutocompletePrediction] {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("🔍 入力が空のため、空の配列を返します")
            return []
        }
        
        // デバッグ用：まずローカルテストデータを返してUI動作を確認
        if input.lowercased().contains("京都") || input.lowercased().contains("kyoto") {
            print("🧪 テストデータを返します")
            return [
                PlaceAutocompletePrediction(
                    placeId: "test_kyoto_station",
                    description: "京都駅, 京都府京都市下京区",
                    mainText: "京都駅",
                    secondaryText: "京都府京都市下京区"
                ),
                PlaceAutocompletePrediction(
                    placeId: "test_kiyomizu_temple",
                    description: "清水寺, 京都府京都市東山区",
                    mainText: "清水寺",
                    secondaryText: "京都府京都市東山区"
                ),
                PlaceAutocompletePrediction(
                    placeId: "test_fushimi_inari",
                    description: "伏見稲荷大社, 京都府京都市伏見区",
                    mainText: "伏見稲荷大社",
                    secondaryText: "京都府京都市伏見区"
                )
            ]
        }
        
        guard let url = URL(string: "\(baseURL):autocomplete") else {
            print("❌ 無効なURL")
            throw GooglePlacesError.invalidURL
        }
        
        // 新API用のJSONリクエストボディを作成
        var requestBody: [String: Any] = [
            "input": input,
            "languageCode": "ja",
            "regionCode": "JP"
        ]
        
        // 位置情報がある場合は位置制限を追加
        if let location = location {
            requestBody["locationBias"] = [
                "circle": [
                    "center": [
                        "latitude": location.latitude,
                        "longitude": location.longitude
                    ],
                    "radius": Double(radius)
                ]
            ]
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("*", forHTTPHeaderField: "X-Goog-FieldMask")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("❌ JSONシリアライゼーションエラー: \(error)")
            throw GooglePlacesError.decodingError
        }
        
        print("🔍 Google Places Autocomplete API呼び出し (新API): \(input)")
        print("🌐 URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ 無効なレスポンス")
            throw GooglePlacesError.invalidResponse
        }
        
        print("📱 Google Places API レスポンス: \(httpResponse.statusCode)")
        
        // レスポンスデータをログ出力（デバッグ用）
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 レスポンス内容: \(responseString.prefix(500))...") // 最初の500文字を表示
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ HTTPエラー: \(httpResponse.statusCode)")
            throw GooglePlacesError.httpError(httpResponse.statusCode)
        }
        
        do {
            let autocompleteResponse = try JSONDecoder().decode(GooglePlacesAutocompleteResponseNew.self, from: data)
            
            var predictions: [PlaceAutocompletePrediction] = []
            for suggestion in autocompleteResponse.suggestions {
                if let placePrediction = suggestion.placePrediction {
                    let prediction = PlaceAutocompletePrediction(
                        placeId: placePrediction.placeId,
                        description: placePrediction.text.text,
                        mainText: placePrediction.structuredFormat.mainText.text,
                        secondaryText: placePrediction.structuredFormat.secondaryText?.text ?? ""
                    )
                    predictions.append(prediction)
                }
            }
            
            print("✅ Google Places Autocomplete結果: \(predictions.count)件")
            for (index, prediction) in predictions.prefix(3).enumerated() {
                print("  [\(index + 1)] \(prediction.mainText) - \(prediction.secondaryText)")
            }
            
            return predictions
        } catch {
            print("❌ JSONデコードエラー: \(error)")
            throw GooglePlacesError.decodingError
        }
    }
    
    // MARK: - Place Details API
    func fetchPlaceDetails(placeId: String) async throws -> PlaceDetails {
        guard let url = URL(string: "\(baseURL)/\(placeId)") else {
            throw GooglePlacesError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(apiKey, forHTTPHeaderField: "X-Goog-Api-Key")
        request.setValue("id,displayName,formattedAddress,location", forHTTPHeaderField: "X-Goog-FieldMask")
        
        print("🔍 Google Places Details API呼び出し (新API): \(placeId)")
        print("🌐 URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GooglePlacesError.invalidResponse
        }
        
        print("📱 Google Places Details API レスポンス: \(httpResponse.statusCode)")
        
        // レスポンスデータをログ出力（デバッグ用）
        if let responseString = String(data: data, encoding: .utf8) {
            print("📄 Details レスポンス内容: \(responseString.prefix(500))...")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw GooglePlacesError.httpError(httpResponse.statusCode)
        }
        
        do {
            let detailsResponse = try JSONDecoder().decode(GooglePlacesDetailsResponseNew.self, from: data)
            
            let placeDetails = PlaceDetails(
                placeId: detailsResponse.id,
                name: detailsResponse.displayName?.text ?? "不明な場所",
                address: detailsResponse.formattedAddress ?? "",
                coordinate: CLLocationCoordinate2D(
                    latitude: detailsResponse.location?.latitude ?? 0,
                    longitude: detailsResponse.location?.longitude ?? 0
                )
            )
            
            print("✅ Google Places Details取得完了: \(placeDetails.name)")
            return placeDetails
        } catch {
            print("❌ JSONデコードエラー: \(error)")
            throw GooglePlacesError.decodingError
        }
    }
}

// MARK: - Error Types
enum GooglePlacesError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "無効なURLです"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .httpError(let code):
            return "HTTPエラー: \(code)"
        case .apiError(let status):
            return "Google Places APIエラー: \(status)"
        case .decodingError:
            return "データの解析に失敗しました"
        }
    }
}

// MARK: - Response Models (旧API用)
struct GooglePlacesAutocompleteResponse: Codable {
    let predictions: [Prediction]
    let status: String
    
    struct Prediction: Codable {
        let description: String
        let placeId: String
        let structuredFormatting: StructuredFormatting
        
        enum CodingKeys: String, CodingKey {
            case description
            case placeId = "place_id"
            case structuredFormatting = "structured_formatting"
        }
        
        struct StructuredFormatting: Codable {
            let mainText: String
            let secondaryText: String?
            
            enum CodingKeys: String, CodingKey {
                case mainText = "main_text"
                case secondaryText = "secondary_text"
            }
        }
    }
}

struct GooglePlacesDetailsResponse: Codable {
    let result: PlaceResult
    let status: String
    
    struct PlaceResult: Codable {
        let placeId: String
        let name: String
        let formattedAddress: String
        let geometry: Geometry
        
        enum CodingKeys: String, CodingKey {
            case placeId = "place_id"
            case name
            case formattedAddress = "formatted_address"
            case geometry
        }
        
        struct Geometry: Codable {
            let location: LocationCoordinate
            
            struct LocationCoordinate: Codable {
                let lat: Double
                let lng: Double
            }
        }
    }
}

// MARK: - Response Models (新API用)
struct GooglePlacesAutocompleteResponseNew: Codable {
    let suggestions: [Suggestion]
    
    struct Suggestion: Codable {
        let placePrediction: PlacePrediction?
        
        struct PlacePrediction: Codable {
            let placeId: String
            let text: LocalizedText
            let structuredFormat: StructuredFormat
            
            enum CodingKeys: String, CodingKey {
                case placeId = "placeId"
                case text
                case structuredFormat = "structuredFormat"
            }
            
            struct LocalizedText: Codable {
                let text: String
            }
            
            struct StructuredFormat: Codable {
                let mainText: LocalizedText
                let secondaryText: LocalizedText?
                
                enum CodingKeys: String, CodingKey {
                    case mainText = "mainText"
                    case secondaryText = "secondaryText"
                }
            }
        }
    }
}

struct GooglePlacesDetailsResponseNew: Codable {
    let id: String
    let displayName: LocalizedText?
    let formattedAddress: String?
    let location: LocationNew?
    
    struct LocalizedText: Codable {
        let text: String
    }
    
    struct LocationNew: Codable {
        let latitude: Double
        let longitude: Double
    }
}

# Team8-App

Team8 の散歩アプリのモバイルアプリ側のリポジトリです。

## 📋 概要

ユーザーが選んだテーマに基づき、日常の移動を**ユニークな散歩体験へと変える**ルートを提案するモバイルアプリです。

### **主な機能**

- **位置情報に基づくルート生成**  
  サーバー側でテーマに合う魅力的なスポットを効率的に絞り込み、選出したスポットを巡る最適な順路と歩行ルートを取得。ルート自体は AI ではなく、地理空間情報とロジックによって決定され、「意味のある寄り道」が設計されています。

- **AI による物語性の付与**  
   ロジックによって構築されたルートに対し、**Gemini** を活用してコンテキストに合わせた物語を生成・付与します。ルート、経由地の特徴、天候や時間帯といったリアルタイム情報を組み合わせることで、散歩に感情的な深みと楽しさを加えます。

- **複数のテーマとモード**  
   グルメ、自然、歴史・文化、アートなど、様々な散歩テーマに対応。目的地までの道のりを豊かにする「目的地を決めて出発モード」と、時間を決めて未知の出会いを楽しむ「目的地なしで出発モード」を提供。


| 開始画面 | 設定画面 | ルート提案画面 |
|:--------------:|:----------------:|:----------------:|
| <img src="picture/startview.png" alt="Ranking Screen" width="300"> | <img src="picture/settingview.png" alt="Event Invitation Screen" width="300"> | <img src="picture/destinationsview.png" alt="Profile Screen" width="300"> |


| ルート表示画面 | マップ画面 | 投稿画面 |
|:--------------:|:----------------:|:----------------:|
| <img src="picture/routeview.png" alt="Ranking Screen" width="300"> | <img src="picture/mapview.png" alt="Event Invitation Screen" width="300"> | <img src="picture/completeview.png" alt="Profile Screen" width="300"> |


## 🛠️ 技術スタック

- **iOS**: Swift / SwiftUI
- **アーキテクチャ**: MVVM + Clean Architecture
- **ネットワーキング**: Alamofire
- **地図機能**: MapKit
- **位置情報**: CoreLocation

## 📁 プロジェクト構造

```
Team8App/
├── Domain/          # ビジネスロジック層
├── Infrastructure/  # データアクセス層
├── Presentation/    # UI層（Views, ViewModels）
├── Service/         # 外部サービス連携
└── Preview Content/ # プレビュー用データ
```

## 🚀 セットアップ

### インストール手順

1. リポジトリをクローン
```bash
git clone https://github.com/kaka0913/watnow-hack-team8-mobile.git
cd watnow-hack-team8-mobile
```

2. Xcodeでプロジェクトを開く

3. ビルド & 実行

### 設定ファイル

プロジェクトの設定は `Team8App/Config.xcconfig` で管理されています。

## 📱 動作環境

- **対象iOS**: iOS 17.0以上
- **対応デバイス**: iPhone (iPad対応予定)
- **必要な権限**: 位置情報アクセス許可

## 📚 ドキュメント

詳細な設計ドキュメントは `Docs/` フォルダーに含まれています：

- [アーキテクチャ設計](Docs/architecture.md)
- [API仕様](Docs/api.md)
- [リポジトリレイヤー](Docs/repository-rayler.md)
- [サービスレイヤー](Docs/service-rayler.md)
- [ViewModelパターン](Docs/viewmodel.md)

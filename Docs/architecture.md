# アーキテクチャ設計書

このドキュメントは、Team8App の SwiftUI アプリケーションアーキテクチャの全体設計を説明します。

## 概要

本プロジェクトは **Clean Architecture** を基盤とした **MVVM** パターンを採用し、以下の 4 つの主要レイヤーで構成されています：

```
┌─────────────────────────────────────────┐
│              Presentation               │  ← View /   ViewModel
├─────────────────────────────────────────┤
│              Application                │  ← Service
├─────────────────────────────────────────┤
│               Domain                    │  ← Protocol
├─────────────────────────────────────────┤
│            Infrastructure               │  ← Repository / API
└─────────────────────────────────────────┘
```

---

## レイヤー構成

### 1. Presentation Layer (プレゼンテーション層)

**責務**: UI の表示とユーザーインタラクションの管理

#### View

- SwiftUI による UI 実装
- ユーザー入力の受け取り
- ViewModel の状態変更の監視・反映

#### ViewModel

- `@Observable`マクロによる状態管理
- Service との連携
- UI ロジックの管理

**設計原則**:

- View 間の疎結合（必要な値とクロージャのみを受け渡し）
- ViewModel インスタンスの直接受け渡しは最小限に（EnvironmentObject の多用禁止）
- View は UI とユーザー入力の受け渡しのみ、ViewModel はロジック・状態管理のみ
- 150 行を超える View は積極的に子 View へ分割

### 2. Application Layer (アプリケーション層)

**責務**: ビジネスロジックの orchestration と複数の Repository の連携

#### Service

- 複数の Repository を組み合わせた高レベルな操作
- ビジネスロジックの実装
- 状態を持たない純粋な処理

**設計原則**:

- Singleton パターンによるインスタンス管理
- Repository 層への依存性注入
- ViewModel と Repository 間のファサード
- API 通信の一元管理
- Model/Service/Utility は用途ごとに分割

### 3. Domain Layer (ドメイン層)

**責務**: ビジネスドメインの核となるエンティティとルールの定義

#### Domain Entity
- **能動的データのモデル化**: アプリ側で作成・管理するデータ（ユーザー入力、設定値等）
- **ビジネスロジックの集約**: バリデーション、計算プロパティ、状態管理
- **APIレスポンス以外のデータ**: ローカル状態、フォーム入力、設定情報

**命名規則**:
- **用途を明確に**: `UserData`ではなく`EventCreationForm`のような具体的な用途を示す
- **責務を表現**: `AppSettings`ではなく`NotificationSettings`のような機能領域を明示
- **状態を含む**: `LoadingState`、`ValidationResult`のような状態を表現

```swift
// 良い例 ✅
struct EventCreationForm { ... }     // イベント作成フォーム
struct NotificationSettings { ... }  // 通知設定
struct ChatMessageDraft { ... }      // チャットメッセージ下書き

// 悪い例 ❌  
struct UserData { ... }              // 用途不明
struct AppData { ... }               // 曖昧すぎる
struct FormData { ... }              // どのフォームか不明
```

#### Repository Protocol
- データアクセスの抽象化
- APIパスに基づいたプロトコル設計

**設計原則**:
- **APIレスポンスはそのまま使用**: 単純な置き換えによるEntityは作成しない
- **能動的データのみEntity化**: アプリが主体的に作成・管理するデータに限定
- **ビジネスロジックの必要性**: 計算処理やバリデーションが必要な場合のみEntity作成

### 4. Infrastructure Layer (インフラストラクチャ層)

**責務**: 外部システム（API、データベース等）との連携

#### Repository

- Repository Protocol の具象実装
- API との通信処理
- APIレスポンスをそのまま上位層に返却（無駄な変換は行わない）

#### API Client

- HTTP 通信の抽象化
- Request/Response パターンの実装

**設計原則**:

- デバッグ/本番環境の分離
- モックデータによる開発支援

---

## データフロー

### 標準的なデータフロー

```
User Input → View → ViewModel → Service → Repository → API
                ↑       ↑         ↑         ↑         ↑
               UI    状態管理   ビジネス    データ    外部
             表示               ロジック   アクセス   システム
```

### 具体例: イベント一覧取得

1. **View**: ユーザーが画面を開く
2. **ViewModel**: `loadEvents()`メソッドを実行
3. **Service**: `EventService.fetchEvents()`を呼び出し
4. **Repository**: `EventRepository.fetchAllEvents()`で API 通信
5. **API**: イベントデータを返却
6. **Repository**: APIレスポンスをそのまま返却
7. **Service**: データを ViewModel に返却
8. **ViewModel**: 状態を更新（`events`プロパティ）
9. **View**: 自動的に UI 更新

---

## 依存関係の原則

### 依存性の方向

```
Presentation ──→ Application ──→ Domain ←── Infrastructure
```

- **上位レイヤーは下位レイヤーに依存可能**
- **下位レイヤーは上位レイヤーに依存してはならない**
- **Infrastructure は Domain のプロトコルに依存**

### 依存性注入

各レイヤーは抽象（プロトコル）に依存し、具象実装は注入される：

```swift
// ViewModel → Service
class EventListViewModel {
    private let eventService: EventServiceProtocol // プロトコルに依存
}

// Service → Repository
class EventService {
    private let eventRepository: EventRepositoryProtocol // プロトコルに依存
}
```

---

## ファイル構成

```
Team8App/
├── Presentation
│   └──Views/
│       └── EventListView/
│           └── EventListView.swift
│           └── EventListViewModel.swift
│           └── ViewParts/
│                └── EventDetailViewPart.swift
├── Service/
│   └── EventService.swift
│   └── AuthService.swift
├── Domain/
│   ├── Entities/
│   │   ├── UserInputData.swift      
│   │   └── LocalState.swift      
│   └── RepositoryProtocols/
│       ├── EventRepositoryProtocol.swift
│       └── AuthRepositoryProtocol.swift
└── Infrastructure/
    ├── Repositories/
    │   ├── EventRepository.swift
    │   └── AuthRepository.swift
    └── API/
        └── APIClient.swift
```

---

## コーディング規約

### 命名規則

- **型名・ファイル名**: UpperCamelCase（例: `ProfileView.swift`, `UserProfileService.swift`）
- **変数・関数名**: lowerCamelCase（例: `fetchProfile()`, `userName`）
- **クラス名**: 機能名 + 用途（例: `EventListViewModel`, `AuthService`）
- **Domain Entity名**: 具体的な用途を明示（例: `EventCreationForm`, `NotificationSettings`）

### UI 設計規約

#### SwiftUI

- レイアウトは VStack/HStack/ZStack を適切に使い分ける
- 基本的には ZStack を使わずに作成可能であれば使用しない
- カスタムカラーやテーマは ThemeColor 等で一元管理
- Magic number や直値は極力定数化

#### レスポンシブ対応

- デバイスサイズに応じた適切なレイアウト
- アクセシビリティ対応の考慮

### アクセス制御

- **基本方針**: 外部から利用しない型・プロパティ・関数は`private`を明示
- **モジュール間**: モジュールをまたぐ場合は`public`/`open`を検討
- **レイヤー間**: 適切なアクセスレベルでカプセル化を維持

### コメント・ドキュメント

- **関数・クラス**: 複雑なロジックや API 通信部には簡潔なコメントを付与
- **TODO/FIXME**: 未実装・暫定対応箇所には`// TODO:`や`// FIXME:`を明記
- **MARK**: セクション分離には`// MARK: -`を使用

---

## エラーハンドリング戦略

### エラーの伝播

```
API Error → Repository → Service → ViewModel → View
```

---

## パフォーマンス考慮事項

### 非同期処理

- **async/await**: 全ての非同期処理で使用
- **@MainActor**: UI 更新を伴う処理で明示的に指定
- **Task 管理**: 必要に応じてキャンセル処理を実装

### メモリ管理

- **循環参照の回避**: `[weak self]`を適切に使用
- **リソース管理**: `deinit`でのクリーンアップ

---

## 品質保証

### コード品質

- **アクセス制御**: 適切な`private`/`public`の指定
- **命名規則**: UpperCamelCase（型）、lowerCamelCase（変数・関数）
- **ファイル分割**: 150 行超過時の積極的な分割
- **不要コード削除**: 未使用 import、デッドコードの削除
- **定数管理**: UserDefaults や環境変数のキーは定数で管理

# Repository 生成ルール

## 概要

Repository クラスの作成時に従うべきルールとガイドラインをまとめた文書です。

## 基本構造

### 1. ファイル配置

- **実装**: `Infrastructure/Repositories/` ディレクトリ
- **プロトコル**: `Domain/RepositoryProtocols/` ディレクトリ

### 2. 命名規則

- **プロトコル**: `[機能名]RepositoryProtocol`
- **実装クラス**: `[機能名]Repository`

例：

```swift
// プロトコル
protocol AuthRepositoryProtocol { ... }

// 実装
class AuthRepository: AuthRepositoryProtocol { ... }
```

## プロトコル設計ルール

### 1. プロトコルの作成基準

プロトコルは **API のパスごと** に作成する。共通のパスを持つ機能をグループ化してプロトコルを定義する。

#### 例：認証関連のパス
- `/auth/signup`
- `/auth/signin` 
- `/auth/profile`

上記のような `/auth` パスを持つ API は `AuthRepositoryProtocol` として統合する。

### 2. プロトコルの内容

プロトコルには以下の例のような要素を含める：

```swift
protocol AuthRepositoryProtocol {
    // ユーザー登録（/auth/signup）
    func signup(userName: String, icon: String, authId: String) async throws -> Int
    
    // ユーザーサインイン（/auth/signin）
    func signin(authId: String) async throws -> Int
    
    // プロフィール取得（/auth/profile）
    func getProfile(userId: Int) async throws -> UserProfile
}
```

#### プロトコル設計の指針：
- **同一パス配下の API をグループ化**
- **非同期処理には async throws を使用**
- **戻り値は Response を使用**
- **パラメータは必要最小限に留める**


## クラス設計ルール

### 1. プロトコル準拠

必ず対応する Protocol に準拠する

```swift
class AuthRepository: AuthRepositoryProtocol {
    // 実装
}
```

### 2. APIClient の依存性注入

APIClient を private プロパティとして保持し、依存性注入をサポートする

```swift
class AuthRepository: AuthRepositoryProtocol {
    private let apiClient = APIClient.shared
    static let shared = AuthRepository()
    
    private init() {} // シングルトンの場合はprivate init
}
```

## API との連携ルール

### 1. Request/Response パターン

API との通信には必ず Request/Response パターンを使用する

```swift
func signin(authId: String) async throws -> Int {
    let request = SigninRequest(authId: authId)
    let response = try await apiClient.call(request: request)
    return response.userId
}
```

### 2. Request/Response モデルの定義

Request および Response モデルは、それを使用する Repository ファイル内で定義する

```swift
// AuthRepository.swift内で定義
class AuthRepository: AuthRepositoryProtocol {
    // 実装...
}

struct SigninRequest: APIRequest {
    let authId: String
    let endpoint = "/auth/signin"
    let method = HTTPMethod.POST
}

struct SigninResponse: Codable {
    let userId: Int
    let accessToken: String
}

struct GetProfileRequest: APIRequest {
    let userId: Int
    let endpoint: String
    let method = HTTPMethod.GET
    
    init(userId: Int) {
        self.userId = userId
        self.endpoint = "/auth/profile/\(userId)"
    }
}

struct GetProfileResponse: Codable {
    let id: Int
    let name: String
    let imageURL: String?
}
```

#### Request/Response モデル設計の指針：
- **Repository 内で完結**: 外部ファイルに分離せず、同一ファイル内で定義
- **APIRequest プロトコル準拠**: 統一されたインターフェースを使用
- **Codable 準拠**: JSON との変換を自動化
- **必要最小限**: API 通信に必要な項目のみを含める

### 3. エラーハンドリング

APIClient 経由で投げられるエラーをそのまま上位層に伝播させる

```swift
func getProfile(userId: Int) async throws -> UserProfile {
    // throwsをそのまま伝播
    let request = GetProfileRequest(userId: userId)
    let response = try await apiClient.call(request: request)
    // ...
}
```

## コメントルール

### 1. TODO/FIXME コメント

開発中の項目は適切にコメントする

```swift
//TODO: APIを呼び出すようにして、後で消す
#if DEBUG
// 開発時はモックデータを使用
return try await Self.getMockProfile(userId: userId)
#endif
```

### 2. MARK: コメント

拡張やセクションの分離には MARK: を使用する

```swift
// MARK: - Mock Data
extension AuthRepository {
    // モックデータ関連のメソッド
}
```

## 推奨事項

### 1. 非同期処理

すべての API アクセスは async/await パターンを使用する

### 2. 型安全性

APIResponse からの変換時は型安全性を重視し、適切なエラーハンドリングを行う

### 3. テスタビリティ

依存性注入により、テスト時にモックを注入できるよう設計する

### 4. 責務の分離

Repository は API との通信とデータマッピングのみに責務を限定し、ビジネスロジックは含めない

## 避けるべきパターン

### 1. 直接的な API 操作

Repository クラスで HTTP リクエストを直接構築することは避ける

### 2. ビジネスロジックの混入

データの取得・保存以外のロジックを Repository に記述することは避ける

### 3. 複数の API 依存

一つの Repository で複数の外部 API に依存することは避ける

## チェックリスト

新しい Repository を作成する際のチェックリスト：

- [ ] 対応する Protocol を作成済み
- [ ] プロトコルに準拠している
- [ ] API パスに基づいてプロトコルが適切にグループ化されている
- [ ] APIClient の依存性注入が適切に設定されている
- [ ] シングルトンパターンの使用が適切に判断されている
- [ ] デバッグモードとリリースモードが分離されている
- [ ] モックデータが private extension で実装されている
- [ ] Request/Response モデルが Repository ファイル内で定義されている
- [ ] 適切なコメントが記述されている
- [ ] ファイルが正しいディレクトリに配置されている

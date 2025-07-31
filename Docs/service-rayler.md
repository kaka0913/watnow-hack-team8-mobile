# Service 層 実装ガイドライン

このガイドラインは、SwiftUI アプリケーションにおける Service 層の設計と実装方針を定義します。

## 基本方針

Service 層は、Repository 層の API を一括で呼び出すファサードとして機能します。状態管理は ViewModel で行い、Service は API コールの組み合わせやビジネスロジックを担当します。

### 設計原則

1. **状態なし**: Service 層は状態を持たず、純粋な処理のみ
2. **依存性注入**: Repository 層への依存はプロトコルベース
3. **エラーハンドリング**: 統一的なエラー処理機構
4. **非同期処理**: async/await パターンの採用
5. **ファサードパターン**: 複数の Repository を組み合わせて高レベルな操作を提供

---

## Service の基本構造

### クラス定義パターン

```swift
import Foundation

class XxxService {
    static let shared = XxxService()

    private let repository1: Repository1Protocol
    private let repository2: Repository2Protocol

    private init(
        repository1: Repository1Protocol = Repository1(),
        repository2: Repository2Protocol = Repository2()
    ) {
        self.repository1 = repository1
        self.repository2 = repository2
    }
}
```

### メソッド実装パターン

```swift
// 単純なデータ取得
func fetchData() async throws -> [DataModel] {
    do {
        let data = try await repository.fetchData()
        print("データを取得しました: \(data.count)件")
        return data
    } catch {
        print("データ取得に失敗しました: \(error)")
        throw ServiceError.dataFetchFailed(error.localizedDescription)
    }
}

// 複数Repository連携パターン
func performComplexOperation(params: Params) async throws -> Result {
    do {
        // 1. 前処理
        let step1 = try await repository1.operation1(params)

        // 2. 関連データ取得
        let step2 = try await repository2.operation2(step1.id)

        // 3. 結果統合
        let result = combineResults(step1, step2)

        print("操作が完了しました")
        return result
    } catch {
        print("操作に失敗しました: \(error)")
        throw ServiceError.operationFailed(error.localizedDescription)
    }
}
```


---

## Repository インターフェース

Service 層は Repository プロトコルに依存し、具体的な実装には依存しません。

### プロトコル設計例

```swift
protocol DataRepositoryProtocol {
    func fetchAll() async throws -> [DataModel]
    func create(_ model: DataModel) async throws -> DataModel
    func update(_ model: DataModel) async throws -> DataModel
    func delete(id: String) async throws
}

protocol RealtimeRepositoryProtocol {
    func observe(id: String) -> AsyncStream<[DataModel]>
    func send(_ data: DataModel) async throws
}
```

---

## ベストプラクティス

1. **Singleton パターン**: Service 層は shared インスタンスを提供
2. **依存性注入**: Repository 層はプロトコルベースで注入
3. **エラーハンドリング**: 統一的な ServiceError で管理
4. **ログ出力**: 成功・失敗時の適切なログ
5. **状態管理を ViewModel に委譲**: Service は状態を持たず、データと結果のみを返す
6. **API 呼び出しの組み合わせ**: 複数の Repository を組み合わせて高レベルな操作を提供
7. **戻り値による状態更新**: ViewModel が受け取った結果で状態を更新
8. **純粋な Swift クラス**: SwiftUI に依存せず、Foundation 層のみを使用

---

## ViewModel での使用パターン

```swift
@Observable
class SampleViewModel {
    private let service = SampleService.shared

    var data: [DataModel] = []
    var isLoading = false
    var errorMessage: String?

    @MainActor
    func performAction() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            data = try await service.fetchData()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

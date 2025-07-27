# ViewModel 実装ガイドライン (@Observable 版)

このガイドラインは、SwiftUIの`@Observable`マクロを前提としたViewModelの実装方針を定義します。

## 基本構造

### クラス定義

`@Observable`マクロを適用します。これにより、クラスは自動的に監視可能になります。

```swift
@Observable
class XxxViewModel {
    // プロパティとメソッド
}
```

### 必須要素

  - **`@Observable`** をクラスに適用
  - クラス名は **機能名 + `ViewModel`** の形式

-----

## Viewへのデータ連携

ViewModelのデータをViewに渡す際は、Viewの再利用性と独立性を保つため、原則として必要な値のみを渡します。

### 原則: 必要な値とクロージャのみを渡す

子のViewには、ViewModelの存在を知らせず、必要なデータ（`@Binding`）と振る舞い（クロージャ）だけを渡します。これにより、子のViewは完全に独立し、再利用しやすくなります。

```swift
// 子ViewはViewModelを知らない
struct ChildView: View {
    @Binding var text: String
    let onSave: () -> Void

    var body: some View {
        TextField("入力", text: $text)
        Button("保存", action: onSave)
    }
}

// 親Viewで連携
struct ParentView: View {
    @State private var viewModel = FormViewModel()

    var body: some View {
        ChildView(
            text: $viewModel.inputText,
            onSave: viewModel.save
        )
    }
}
```

### 例外: ViewModelインスタンスを渡す

子のViewがViewModelの多くのプロパティやメソッドを必要とし、個別に渡すと煩雑になる場合に限り、ViewModelインスタンス自体を渡すことを許容します。その際は`@Bindable`を使用します。

```swift
// 子View
struct ComplexChildView: View {
    @Bindable var viewModel: FormViewModel

    var body: some View {
        TextField("テキスト1", text: $viewModel.text1)
        TextField("テキスト2", text: $viewModel.text2)
        Button("保存", action: viewModel.save)
    }
}
```

-----

## プロパティ定義

### 状態プロパティ

UIに反映する状態は、通常のプロパティとして定義します。`@Observable`により、これらのプロパティへの変更は自動的にViewに通知されます。**`@Published`は不要です。**

```swift
var isLoading: Bool = false
var errorMessage: String?
var data: [SomeModel] = []
```

### サービス依存関係

サービスは`let`で定義し、基本的にsharedインスタンスを使用します。

```swift
let exampleService = ExampleService.shared
```

-----

## メソッド実装

### 非同期処理

APIコールなど非同期処理は`async/await`を使用します。

```swift
func fetchData() async {
    isLoading = true
    defer { isLoading = false }

    do {
        let result = try await service.fetchData()
        self.data = result
    } catch {
        print("データ取得に失敗しました: \(error)")
        self.errorMessage = error.localizedDescription
    }
}
```

### フォーム状態の計算プロパティ

フォームの有効性などは計算プロパティで管理します。

```swift
var isFormValid: Bool {
    return !eventName.isEmpty &&
           !eventDescription.isEmpty &&
           !locationName.isEmpty
}
```

-----

## エラーハンドリング

個別または共通のエラープロパティで管理します。

```swift
// パターン1: 個別エラー
var emailError: String?
var passwordError: String?

// パターン2: 共通エラー
var errorMessage: String?
```

-----

## メモリ管理

### weak self の使用

`@Observable`と`async/await`の組み合わせでは`[weak self]`が不要な場合が多いですが、**伝統的なエスケープするクロージャ**（例: `Auth.auth().signIn(...)`）を使用する場合は、循環参照を避けるために`[weak self]`が依然として必要です。

```swift
// 伝統的なクロージャでは依然としてweak selfが必要
service.legacyOperation { [weak self] result in
    guard let self = self else { return }
    // 処理
}
```

### Taskのキャンセル

必要に応じて`Task`をプロパティに保持し、`deinit`でキャンセルします。

```swift
private var messageTask: Task<Void, Never>?

deinit {
    messageTask?.cancel()
}

func observeMessages() {
    messageTask = Task {
        // メッセージ受信処理...
    }
}
```

-----

## 初期化とライフサイクル

### init()での非同期処理

初期化時に非同期処理を呼び出す場合は`Task`でラップします。

```swift
init() {
    Task {
        await fetchInitialData()
    }
}
```

### UI関連の非同期メソッド

UI更新を伴う非同期メソッドには`@MainActor`を明示的に指定します。

```swift
@MainActor
private func fetchInitialData() async {
    // UI更新を含む初期データ取得処理
}
```

-----

## ベストプラクティス

1.  **単一責任の原則**: ViewModelは特定の画面や機能に責任を持つ。
2.  **状態の一元管理**: 関連する状態は1つのViewModelで管理する。
3.  **エラーメッセージの統一**: ユーザー向けメッセージは日本語で分かりやすく。
4.  **ログ出力**: `print`やロギングライブラリを使い、処理の成功・失敗時に適切なログを出力する。
5.  **`defer`の活用**: ローディング状態の解除など、後処理には`defer`を積極的に使用する。
6.  **適切なアクセス制御**: 外部から不要なプロパティやメソッドは`private`にする。
# 4DのORDAイベント：イベント駆動ロジックによるデータ操作の制御

著：Abir HSAINI（4D Inc.テクニカルサービスエンジニア）

テクニカルノート 26-03

## 概要

4D 21では、ORDAイベントを使用してデータベース操作を処理する新しい方法が導入されました。この方法は従来のトリガーに代わるもので、データ操作をよりきめ細かく制御できます。ORDAイベントはデータの作成・変更・保存・削除の際に自動的に実行されるため、開発者は検証、エラー処理、ビジネスロジックをコードに直接追加できます。

テーブル全体をロックする従来のトリガーとは異なり、ORDAイベントは個々のレコード単位で動作し、並列に実行できるため、マルチユーザー環境でのパフォーマンスが向上します。本ドキュメントでは、ORDAイベントを効果的に使用する方法を説明し、従来の4Dトリガーからこの新しい方式へ移行するための手引きを示します。

## はじめに

**4D 21**では、ORDAイベントがデータベース操作をオブジェクト指向で処理するためのモダンなイベント駆動型のソリューションとなり、従来のトリガーに代わるものになりました。これらのイベントはデータクラスの関数として実装され、レコードが作成・更新・保存・削除されたときに自動的に実行されるため、データのライフサイクルにおけるアクションを細かく制御できます。

テーブルレベルで動作し、実行中にテーブル全体をロックすることがある従来のトリガーとは異なり、ORDAイベントはレコードレベルで動作します。この設計により、異なるレコードに対する複数のイベントを並列に実行でき、マルチユーザー環境でのパフォーマンスが向上します。さらに、ORDAイベントはビジネスロジックをデータクラス内に集約するため、検証ルールや処理の保守が容易になり、一貫性も高まります。

ORDAは、ユーザーの操作やコードによる処理に応じてこれらのイベント関数を自動的に呼び出します。イベント関数を手動で呼び出すことはできません。これにより、ユーザーインターフェース、REST API、アプリケーションコードなど、すべてのアクセス経路で一貫したビジネスロジックが保証されます。データのライフサイクル全体をカバーする7種類のイベントにより、ORDAイベントは保存およびドロップ（削除）操作をきめ細かく制御でき、従来のトリガーに代わる堅牢でモダンな選択肢となります。

## 主要な概念

### ORDAイベントとは

ORDAイベントは、エンティティクラス（Entity class）内に定義する特別な関数で、データに対して特定の操作が行われたときに自動的に実行されます。これは、4Dにおけるデータ操作の扱い方の根本的な転換（テーブルレベルのトリガーからエンティティレベルのイベントへの移行）を意味します。

#### 主な特徴

- **エンティティクラスで定義：** イベントは必ずエンティティクラス（例：ProductEntity、CustomerEntity）内で定義します。
- **2つの制御レベル：** イベントは、エンティティのすべての属性に適用されるエンティティレベルと、特定の属性（計算属性を含む）にのみ適用される属性レベルのどちらでも定義できます。両方が存在する場合は、属性レベルのイベントが先に実行され、その後にエンティティレベルのイベントが実行されます。
- **自動実行：** ORDAのイベント関数を手動で呼び出すことはできません。ユーザーの操作、エンティティに対するコードによる処理、およびCRUD操作（作成・読み取り・更新・削除）に応じて、ORDAによって自動的に実行されます。

### ORDAイベントを使用する理由

ORDAイベントは4Dアプリケーションにおけるデータ管理の新しい方法であり、従来の仕組み（トリガー）に比べて明確な利点があります。

#### テーブルをロックしない

- 従来のトリガーは、実行中に対象のテーブル全体をロックします
- ORDAイベントはエンティティ（レコード）レベルでのみ動作します
- 対象のエンティティが異なれば、複数のイベントを並列に実行できます

#### 並列実行

- 異なるレコードに対して複数のイベントを同時に実行できます
- テーブルロックの解除を待つ必要がありません

#### データルールを1か所に集約

- 検証、変換、ビジネスルールはすべてエンティティクラスに置かれます
- コードの検索、テスト、保守が容易になります

#### 7種類のイベント

- エンティティのライフサイクルのどの時点でコードを実行するかを正確に制御できます
- 検証、実行、後処理のそれぞれに異なるイベントを使用できます

## ORDAイベントの種類

ORDAには、エンティティのライフサイクル全体をカバーする7種類のイベントがあります。効果的なビジネスロジックを実装するには、各イベントがいつ実行され、何ができるのかを理解することが重要です。

### イベント実行の概要

| イベント | 発生タイミング | レベル | 実行場所 | 停止可否 | 主な用途 |
|---|---|---|---|---|---|
| touched | メモリ上で値が変更されたとき | エンティティ/属性 | クライアント/サーバー* | 不可 | データの整形、関連属性の更新 |
| validateSave | 保存の開始前 | エンティティ/属性 | サーバー | 可 | データ検証、ビジネスルールのチェック |
| saving | 保存処理中 | エンティティ/属性 | サーバー | 可 | ファイル作成、API呼び出し、外部処理 |
| afterSave | 保存の完了後 | エンティティのみ | サーバー | 不可 | 通知、保存後のクリーンアップ |
| validateDrop | 削除の開始前 | エンティティ/属性 | サーバー | 可 | 権限チェック、削除の検証 |
| dropping | 削除処理中 | エンティティ/属性 | サーバー | 可 | 関連ファイルの削除、リソースのクリーンアップ |
| afterDrop | 削除の完了後 | エンティティのみ | サーバー | 不可 | 監査、通知 |

#### touchedイベント：メモリ上での変更

touchedイベントは、保存処理の前に、属性値が**メモリ上で**変更されたときに発生します。これはORDA独自のイベントで、従来の4Dには相当するものがありません。

**発生するケース：**

- ユーザーが4Dフォームのフィールドに入力したとき
- :=演算子によるコードでの代入（自己代入 $entity.attr := $entity.attr も含む）
- クライアントから送られたエンティティをサーバーが受信したとき
- データを変更するREST APIリクエスト

**シンタックス**

```4d
// Entity-level: triggered for any attribute change
Function event touched($event : Object)
    // code here

// Attribute-level: triggered only for specific attribute
Function event touched <attributeName>($event : Object)
    // code here
```

touchedイベントは、localキーワードの有無によって**クライアントまたはサーバー**で実行されます。

**localキーワードあり（クライアント側で実行）**

```4d
local Function event touched firstName($event : Object)
    // Executes on the client This.firstName := Uppercase(This.firstName)
```

**localキーワードなし（サーバー側で実行）**

```4d
Function event touched firstName($event : Object)
    // Executes on the server
```

**重要**：REST、Qodly、またはリモートデータストアの場合、touchedは**常にサーバー側で実行されます**。

**特徴**

- **アクションの停止**：不可。値を返さず、変更を阻止することはできません
- **用途**：データの整形、リアルタイムの検証、派生属性の更新
- **その他の発生元**：constructor()イベント、およびデータエクスプローラーでの編集

#### validateSaveイベント：保存前の検証

エンティティが実際にディスクに保存される前に発生します。データの整合性を検証し、ビジネスルールを適用する機会となります。

**発生元**

- entity.save()
- dataClass.fromCollection()

**シンタックス**

```4d
// Entity-level: validates entire entity
Function event validateSave($event : Object) : Object
    // Return error object to stop save
// Attribute-level: validates specific attribute (only if touched)
Function event validateSave <attributeName>($event : Object) : Object
    // Return error object to stop save
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：可。エラーオブジェクトを返すことで停止できます
- **属性レベルの動作**：属性がタッチされていない場合は実行**されません**
- **実行順序**：属性レベルのイベントが先、次にエンティティレベルのイベント

#### savingイベント：保存処理中

実際の保存処理中、エンティティがディスクに書き込まれている**最中に**発生します。このイベントはvalidateSaveの後に（エラーが発生しなかった場合に）実行されます。

**発生元**

- entity.save()
- dataClass.fromCollection()

**シンタックス**

```4d
// Entity-level: runs for any save
Function event saving($event : Object) : Object
    // Executes even if no attributes were touched

// Attribute-level: runs only if attribute was touched
Function event saving <attributeName>($event : Object) : Object
    // Return error object to stop save
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：可。エラーオブジェクトを返すことで停止できます
- **用途**：時間のかかる処理、ファイル作成、API呼び出し
- **エラー処理**：ネットワークエラーやディスク容量不足などを捕捉する必要があります

#### afterSaveイベント：保存後のアクション

**発生元**

- entity.save()
- dataClass.fromCollection()

**シンタックス**

```4d
// Entity-level only (no attribute-level version)
Function event afterSave($event : Object)
    // Cannot return error object
    // Cannot stop the action
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：不可。保存はすでに完了しています
- **レベル**：エンティティレベルのみ
- **実行されない場合**：タッチされた属性がない場合
- **制限**：Thisに対してsave()を呼び出すとエラーになります（無限ループの防止）

**使用する場面**

- 保存が成功した後に確認メールを送信する
- 変更を外部システムに反映する

#### validateDropイベント：削除前の検証

エンティティが実際にディスクから削除される前に発生します。権限のない削除や不適切な削除を防ぐ機会となります。

**発生元：**

- entity.drop()
- entitySelection.drop()
- データベースの削除制御ルール

**シンタックス**

```4d
// Entity-level: validates entire deletion
Function event validateDrop($event : Object) : Object
    // Return error object to prevent deletion

// Attribute-level: validates specific attribute
Function event validateDrop <attributeName>($event : Object) : Object
    // Return error object to prevent deletion
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：可。エラーオブジェクトを返すことで停止できます
- **用途**：権限チェック、ステータスの検証、ビジネスルールの適用

#### droppingイベント：削除処理中

実際の削除処理中、エンティティがディスクから削除されている**最中に**発生します。validateDropの後に（エラーが発生しなかった場合に）実行されます。

**発生元：**

- entity.drop()
- entitySelection.drop()
- データベースの削除制御ルール

**シンタックス**

```4d
// Entity-level
Function event dropping($event : Object) : Object
    // Return error object to stop deletion

// Attribute-level
Function event dropping <attributeName>($event : Object) : Object
    // Return error object to stop deletion
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：可。エラーオブジェクトを返すことで停止できます
- **用途**：関連ファイルの削除、外部リソースのクリーンアップ、関連データの削除

#### afterDropイベント：削除後のアクション

エンティティがディスクから正常に削除された直後に発生します。

**発生元：**

- entity.drop()
- entitySelection.drop()
- データベースの削除制御ルール

**シンタックス**

```4d
// Entity-level only (no attribute-level version)
Function event afterDrop($event : Object)
    // Cannot return error object
    // Cannot stop the action
```

**特徴**

- **実行場所**：サーバー側のみ
- **アクションの停止**：不可。削除はすでに完了しています
- **レベル**：エンティティレベルのみ
- **エンティティの参照**：削除されたエンティティは、Thisを通してメモリ上にまだ存在します
- **制限**：Thisに対してdrop()を呼び出すとエラーになります（無限ループの防止）

**使用する場面**

- 削除の通知を送信する
- 削除を監査ログに記録する
- クリーンアップ処理を開始する
- 他のテーブルの関連レコードを更新する
- 削除に失敗した場合に、手動確認用のステータスを設定する

## ORDAイベントと従来の4Dトリガーの比較

### 従来の方法：データベーストリガー

従来の4Dトリガーは、テーブルに関連付けられたメソッドで、データベース操作（作成・更新・削除）が行われたときに自動的に実行されます。4Dアプリケーションでビジネスルールを適用し、データの整合性を保つための従来の方法でした。

#### 定義と有効化

- トリガーはストラクチャーエディターでテーブルごとに作成します
- テーブルのインスペクターで明示的に有効化する必要があります

![](fig-01)

- 1つのテーブルにつき1つのトリガーメソッドで、すべてのデータベースイベントを処理します

#### 利用できるデータベースイベント

```4d
Case of
    :(Database event = On Saving New Record Event)
        // Handle new record save

    :(Database event = On Saving Existing Record Event)
        // Handle existing record update
    :(Database event = On Deleting Record Event)
        // Handle record deletion
End case
```

トリガーはデータベースレベル（最下層）で実行されます。実行中はテーブル全体をロックします。1つのテーブルで同時に実行できるトリガーは1つだけです。

#### エラー処理：

```4d
// Return 0 if operation is allowed
// Return negative error code to prevent operation
$0 := -32001  // Custom error code
```

**重要：**独自のエラーコードには **-32000～-15000** の範囲を使用してください。**-15000**より大きいコードは4Dデータベースエンジンが予約しています。

#### 従来のトリガーの例

```4d
// [Products] Table Trigger
C_LONGINT($0)
var $errorCode : Integer

$errorCode := 0

Case of
    :(Database event = On Saving New Record Event)
    :(Database event = On Saving Existing Record Event)
        // Validate margin
        If ([Products]margin < 50)
            $errorCode := -32001
            ALERT("Product margin must be at least 50%")
        End if

    :(Database event = On Deleting Record Event)
        // Check if product can be deleted
        If ([Products]status # "TO DELETE")
            $errorCode := -32002
            ALERT("Product must be marked TO DELETE")
        End if
End case

$0 := $errorCode
```

### 新しい方法：ORDAイベント

ORDAイベントは、データを制御するためのモダンでオブジェクト指向のアプローチで、データベースレベルではなく**データストアレベル**（ビジネスロジック層）で動作します。

#### 定義

- イベントはエンティティクラスに定義する関数です
- イベントの種類ごとに専用の関数があります
- エンティティレベルまたは属性レベルで定義できます
- ORDAの抽象化レイヤーの一部です

#### 主な利点

- **エンティティレベルのロック**：対象のレコードだけがロックされます
- **並列実行**：複数のイベントを同時に実行できます
- **きめ細かな制御**：処理の段階ごとに7種類のイベントがあります
- **オブジェクト指向**：ビジネスロジックはエンティティクラスに置かれます
- **高度なエラー処理**：詳細を含むエラーオブジェクトを返せます

```4d
// ProductsEntity class

// Validation (attribute level)
Function event validateSave margin($event : Object) : Object
    If (This.margin < 50)
        return {
            errCode: 1001;
            message: "Margin below minimum 50%";
            seriousError: False
        }
    End if

// Deletion validation
Function event validateDrop($event : Object) : Object
    If (This.status # "TO DELETE")
        return {
            errCode: 3001;
            message: "Must be marked TO DELETE"
        }
    End if
```

### 主な違い

| 観点 | 従来のトリガー | ORDAイベント |
|---|---|---|
| **動作レベル** | データベースレベル（最下層）：物理データベースを直接操作 | データストアレベル（ビジネスロジック層）：ORDAの抽象化レイヤーの一部 |
| **実行モデル** | 実行中はテーブル全体をロック<br>1つのテーブルで同時に実行できるトリガーは1つだけ<br>逐次処理<br>マルチユーザー環境でのパフォーマンスが低い | 対象のエンティティ（レコード）だけをロック<br>異なるエンティティに対する複数のイベントを並列に実行<br>並行処理<br>マルチユーザー環境での優れたパフォーマンス |
| **コードの構成** | 1つのテーブルにつき1つのメソッドで全イベントを処理<br>保守が難しい<br>すべてのイベントを1つのCase of構文で処理 | イベントの種類ごとに専用の関数<br>エンティティクラスに統合<br>すっきりとしたモジュール構成<br>特定のロジックを見つけやすい |
| **エラー処理** | 整数のエラーコードしか返せない<br>エラー情報が限られる<br>標準のアラートダイアログ | 情報豊富なエラーオブジェクトを返せる<br>コード、メッセージ、追加の詳細を含められる<br>エラーの重大度を制御できる<br>より良いユーザー体験 |
| **粒度** | イベントは新規保存・既存の保存・削除の3つだけ<br>特定の属性を対象にできない<br>すべての属性に同じロジック | ライフサイクル全体をカバーする7つのイベント<br>エンティティレベル（すべての属性）<br>属性レベル（特定の属性）<br>計算属性も対象 |

### トリガーとの互換性

4Dのクラシックランゲージのコマンドは、ORDAイベントを発生させません。実行されるのは従来のトリガーだけです。

たとえば、SAVE RECORDを使用した場合は従来のトリガーだけが実行され、ORDAイベントは発生しません。

同様に、DELETE RECORDも従来のトリガーだけを実行し、ORDAイベントは発生しません。

一方、ORDAのメソッドは、従来のトリガーが存在する場合はそれも実行します。

たとえば、entity.save()はORDAイベントを発生させ、さらに（定義されていれば）従来のトリガーも実行します。

同様に、entity.drop()もORDAイベントと（定義されていれば）従来のトリガーの両方を実行します。

## トリガーからORDAイベントへの移行方法

従来の4DトリガーからモダンなORDAのエンティティイベントへの移行を、実際的な受注管理システムを例に説明します。この例では、トリガーを使用する際に開発者が直面しがちな課題と、それをORDAイベントがどのように解決するかを示します。

本ガイドでは、すべての例と比較の基盤として、実用的な**受注管理システム**を使用します。このシステムには次の機能があります：

- **顧客管理**：顧客データ（名前の自動整形あり）
- **商品カタログ**：在庫レベルの監視機能付きの在庫
- **注文処理**：価格の自動計算を伴う注文作成
- **在庫管理**：取引ごとのリアルタイムな在庫更新

**前提条件：**

移行を始める前に、次のことを確認してください：

- **4Dのバージョン**：v21以降
- **プロジェクトモード**：クラスを使用するため
- **バックアップ**：データベースとストラクチャーの完全なバックアップ
- **テスト環境**：移行テスト用の独立した環境

### ステップ1：既存のトリガーを分析する

新しいコードを書く前に、現在のトリガーが何をしているのかを十分に理解しましょう。この分析段階は、移行を成功させるうえで非常に重要です。

ストラクチャーは次のとおりです：

![](fig-02)

データベース内の各トリガーを記録したスプレッドシートを作成します：

| テーブル | トリガー名 | 使用するイベント | 目的 |
|---|---|---|---|
| Client | Client_Trigger | On Saving New/Existing | 名前を大文字に変換 |
| Product | Product_Trigger | On Saving New/Existing | 在庫のチェック、Check_negative_Price |
| ORDER | ORDER_Trigger | On Saving Existing | いくつかの属性の検証 |

### ステップ2：エンティティクラスを作成する

トリガーを分析したら、次は、トリガーにビジネスロジックを持つ各テーブルのエンティティクラスを作成します。

データベースの各テーブルには、対応するエンティティクラスを作成できます。命名規則は「テーブル名Entity」です。例：

- テーブル [Client] → クラス ClientEntity
- テーブル [Product] → クラス ProductEntity
- テーブル [ORDER] → クラス ORDEREntity
- テーブル [OrderLine] → クラス OrderLineEntity

### ステップ3：トリガーのロジックをイベントに移行する

エンティティクラスを作成したら、実際のビジネスロジックをトリガーから適切なORDAイベントに移します。

#### 1. Client_Trigger：

**元のトリガー：**

```4d
Case of

    : (Trigger event=On Saving New Record Event) | (Trigger event=On Saving Existing Record Event)

        [Client]Name:=Uppercase([Client]Name)
End case
```

このトリガーは、保存の前に**顧客名を自動的に大文字に変換**します（新しい顧客を作成するとき、または既存の顧客を変更するとき）。

**ORDAへの移行後：**

```4d
// ClientEntity
Class extends Entity

Function event touched Name($event : Object)
    This.Name:=Uppercase(This.Name)
```

#### 2. Product_Trigger

**元のトリガー：**

このトリガーは、保存時に在庫レベルを検証します。在庫が少ないときに警告し、在庫がマイナスになるのを防ぎ、エラーコード-16000で保存処理を拒否します。

```4d
#DECLARE->$result : Integer

Case of
    : (Trigger event=On Saving New Record Event) | (Trigger event=On Saving Existing Record Event)

        If ([Product]Stock<=[Product]minimumStock)
            ALERT("Warning: The product "+[Product]Name+"is low in stock")
        End if
        If ([Product]Stock<0)
            $result:=-16000
            ALERT("⚠ Stock cannot be negative!")
        End if

End case
```

![](fig-03)

**ORDAへの移行後：**

```4d
// ============================================
// CLASS 2: ProductEntity
// File: Project/Sources/Classes/ProductEntity.4dm
// ============================================

Class extends Entity
// Constructor: Initialization when creating new product
Function constructor()
    // Event: When Stock is modified
Function event touched Stock($event : Object)
    // 1. Prevent negative stock
    // 2. Check minimum stock level
    If (This.Stock<=This.minimumStock)
        var $message : Text
        If (This.Stock=0)
            // Out of stock - Critical
            $message:="🔴 OUT OF STOCK!\\r\\r"
            $message:=$message+"Product: "+This.Name+"\\r"
            $message:=$message+"Stock: 0"
            BEEP
        Else
            // Low stock - Warning
            $message:="⚠ LOW STOCK  "
            $message:=$message+"Product: "+This.Name+"  "
            $message:=$message+"Current stock: "+String(This.Stock)+"  "
            $message:=$message+"Minimum stock: "+String(This.minimumStock)
        End if
        // Display alert (or create entry in Alerts table)
        ALERT($message)
    End if
Function event validateSave($event : Object)
    If (This.Stock<0)
        return {errCode: 1001; MESSAGE: "THe stock can not be negative"; extraDescription: {info: "The stock can not be negative"}; seriousError: True}
    End if
```

#### 3. Order_Trigger：

**元のトリガー：**

このトリガーは、保存時に注文のビジネスルールとデータの整合性を適用します：

- **データの正規化**：注文番号を大文字に変換
- **デフォルト値**：新規注文のステータスと日付を自動入力
- **検証**：マイナスの価格を防止し、価格が0のまま完了した注文について警告
- **ビジネスロジック**：「Validate（確定）」または「Delivered（配送済み）」の注文には価格が必要であることを保証

```4d
Case of
    : (Trigger event=On Saving New Record Event)
        [ORDER]order_number:=Uppercase([ORDER]order_number)

        If ([ORDER]Statut="")
            [ORDER]Statut:="In progress"
        End if
        If ([ORDER]Date_Order=!00-00-00!)
            [ORDER]Date_Order:=Current date
        End if

        If ([ORDER]Price<0)
            $result:=-16000
            ALERT("⚠ The price can not be negatif !"+Char(Carriage return)+"Price has been reset to 0.")
        End if
    // Lors de la modification d'une commande existante
    : (Trigger event=On Saving Existing Record Event)
        // 1. Mettre le numéro en MAJUSCULES
        [ORDER]order_number:=Uppercase([ORDER]order_number)

        // 2. Empêcher prix négatif
        If ([ORDER]Price<0)
            $result:=-16000
            ALERT("⚠ The price can not be negatif !"+Char(Carriage return)+"Price has been reset to 0.")
        End if

        // 3. Alerte si commande validée sans prix
        If (([ORDER]Statut="Validate") | ([ORDER]Statut="Delivered"))
            If ([ORDER]Price=0)
                $result:=-17000
                ALERT("⚠ ATTENTION"+Char(Carriage return)+Char(Carriage return)+"Order"+[ORDER]order_number+" Validate/Delivered"+Char(Carriage return)+"but the price is 0 €")
            End if
        End if

End case
```

**ORDAへの移行後：**

この新しい機能に合わせて、注文番号が空の場合に対応する_generateOrderNumber()も追加しています。

```4d
Class extends Entity

// Constructor: Initialize new order
Function constructor()

    // Event: When order_number is modified
Function event touched order_number($event : Object)
    // Convert to UPPERCASE
    This.order_number:=Uppercase(This.order_number)
    // Event: When Price is modified
Function event touched Price($event : Object)
    // Prevent negative price
    If (This.Price<0)
        This.Price:=0
    End if
    // Event: Validation before save
Function event validateSave($event : Object) : Object
    var $status : Object
    // 1. Generate order number if empty
    If (This.order_number=Null) | (This.order_number="")
        This.order_number:=This._generateOrderNumber()
    End if
    // 2. Default status
    If (This.Statut=Null) | (This.Statut="")
        This.Statut:="In progress"
    End if
    // 3. Current date
    If (This.Date_Order=Null)
        This.Date_Order:=Current date
    End if
    // Check if order is validated/delivered with price = 0
    If ((This.Statut="Validate") | (This.Statut="Delivered"))
        If (This.Price=0)
            var $message : Text
            $message:="⚠ WARNING "
            $message:=$message+"Order "+This.order_number+" validated/delivered "
            $message:=$message+"but price is 0 €"
            $status:={errCode: 1002; MESSAGE: "⚠ WARNING: Order "+This.order_number+" validated/delivered\\r but price is 0 €"; extraDescription: {info: "⚠ WARNING: Order "+This.order_number+" validated/delivered\\r but price is 0 €"}; seriousError: True}
        End if
    End if
    return $status

    // Private method: Generate unique order number
Function _generateOrderNumber() : Text

    var $count : Integer
    var $orderNumber : Text

    // Count existing orders
    $count:=ds.Order.all().length+1

    // Format: CMD-YYYY-XXXX
    $orderNumber:="CMD-"+String(Year of(Current date))+"-"+String($count; "0000")

    return $orderNumber
```

#### 在庫の自動管理と価格計算

これらのORDAイベントを使うと、在庫管理を簡単に組み込み、価格計算を自動化できます。そのための方法を次に示します。

**ワークフロー：**

![](fig-04)

**コード：**

```4d
Class extends Entity

Function event saving($event : Object) : Object

    var $status : Object
    $status:=New object("success"; True)
    If (This.Quantity>This.product.Stock)
        $result:={errCode: 1; message: "Insufficient stock "; \
        extraDescription: {info: "The product "+This.product.Name+" is lower("+String(This.Quantity)+")"}; seriousError: False}
        return $result
    End if
    // Recalculate order total price
    This._updateOrderPrice()
    return $status

    // Private method: Update order price
Function _updateOrderPrice()

    var $order : cs.OrderEntity
    // If no automatic relation, do:
    $order:=Form.subForm.currentItem

    If ($order#Null)
        This._recalculateOrderPrice($order)
    End if

    // Private method: Recalculate total price
Function _recalculateOrderPrice($order : cs.OrderEntity)

    var $total : Real
    var $orderLines : cs.OrderLineSelection
    var $line : cs.OrderLineEntity
    var $product : cs.ProductEntity

    $total:=This.Quantity*This.product.Price

    // Get all lines for this order
    $orderLines:=ds.OrderLine.query("ID_Order = :1"; $order.ID)

    // Calculate total
    For each ($line; $orderLines)

        // Get product
        $product:=ds.Product.get($line.ID_Product)

        If ($product#Null)
            $total:=$total+($product.Price*$line.Quantity)
        End if

    End for each

    // Update order price
    $order.Price:=$total
    $product:=ds.Product.get(This.ID_Product)
    $product.Stock:=$product.Stock-This.Quantity
    $product.save()
    $order.save()
```

**テスト：**

![](fig-05)

このインターフェースは注文と在庫を管理するアプリケーションで、2つのメインパネルに分かれています：

- 左パネル：次の列を持つ注文一覧のテーブル：
    - **注文番号**：注文の識別子（例：CMD-2026-0001）
    - **注文日**：注文日
    - **配送日**：配送予定日
    - **顧客名**：顧客名
    - **金額**：合計金額
    - **ステータス**：注文のステータス（色分けして表示）
    - 下部にある2つのアクションボタン：
        - **新規注文**：新しい注文を作成します
        - **注文を削除**：選択した注文を削除します
- 右パネル：次の列を持つ在庫管理のテーブル：
    - **商品名**：商品名（ノートPC、ワークステーションなど）
    - **最小在庫数**：最小在庫数のしきい値
    - **価格**：単価
    - **在庫数**：在庫数
    - 右下にある空のテキストエリア。アプリで行った操作に関するメッセージやイベントログが表示されます。

![](fig-06)

**新規注文**をクリックすると、テーブルの下に次のフィールドを持つ作成フォームが表示されます：

- **注文番号**：手入力しなかった場合は、システムが**自動的に生成**します
- **注文日**：ユーザーが入力しなかった場合は、これも**自動的に生成**されます
- **配送日**：手動で選択します（例：2026/03/04）
- **顧客**：ドロップダウンで選択します（例：田中工房）
- **備考**：自由入力のテキストフィールドです（例：「ゲーム用」）
- **支払方法**：ドロップダウンです（例：PayPal）
- **ステータス**：ドロップダウンです（例：配送済み）

注文に含まれる商品を一覧するサブテーブル：

- **商品名**、**単価**、**数量**、**小計**
- 下部に**合計**が自動的に計算されます（例：¥742,200）
- **「商品を追加」**ボタンで商品を追加します。商品は1つずつ追加するのではなく、**1回の選択ですべての商品をまとめて選択する必要があります**。

![](fig-07)

**保存**をクリックすると、メイン画面に戻り、次のように更新されます：

- 新しい注文**CMD-2026-0006**（田中工房、¥742,200、配送済み）が**注文テーブル**に追加され、注文が正常に作成されたことがわかります。
- 商品パネルの**在庫数**は、購入された数量に合わせて自動的に更新されます。たとえば、lenovo ideapad 3は30 → 29、hp z2 tower workstationは8 → 7、apple macbook pro 14は11 → 10になっています。
- **処理結果**欄にはJSONのレスポンス { "success": true } が表示され、保存処理がシステムによって正常に処理されたことがわかります。

![](fig-08)

2つ目のテストでは、**グローバル工業株式会社**の**新しい注文**を次の内容で作成します：

- 配送日：2026/02/02
- 支払方法：クレジットカード
- ステータス：確定済み

注文明細は次のとおりです：

- hp probook 450：数量 = 10、単価 = ¥104,900、小計 = ¥1,049,000
- hp z2 tower workstation：数量 = 1、単価 = ¥374,900、小計 = ¥374,900
- 合計：¥1,423,900

しかし、この新しい注文は在庫の検証ルールに違反しています。**商品パネル**を見ると、**hp probook 450**の在庫は**8**しかなく、**最小在庫数のしきい値は5**です。数量**10**を注文すると在庫の8を超えるため、この注文には応じられません。このシステムは在庫を超える数量の注文を受け付けないように設計されているため、検証エラーが発生し、注文は保存されません。

![](fig-09)

3つ目のテストでは、田中工房の新しい注文を次の内容で作成します：

- 配送日：2026/02/02
- 支払方法：PayPal
- ステータス：処理中

注文明細は次のとおりです：

- hp probook 450：数量 = 4、単価 = ¥104,900、小計 = ¥419,600
- hp z2 tower workstation：数量 = 1、単価 = ¥374,900、小計 = ¥374,900

この注文は有効なので、正常に保存されます。ただし、hp probook 450を4台注文すると在庫は8から4に減り、最小在庫数のしきい値である5を下回るため、システムは注文を受け付けたうえで、残りの在庫が定められた最小レベルを下回っていることをユーザーに知らせる警告を表示します。

![](fig-10)

![](fig-11)

**4つ目のテスト**では、**グローバル工業株式会社**の新しい注文を次の内容で作成します：

- 配送日：2026/03/03
- 支払方法：クレジットカード
- ステータス：確定済み
- 備考：テスト
- 合計 = ¥0

しかし、**注文明細欄は空のまま**なので、**合計は¥0**になります。ステータスが「確定済み」（Validate）で合計が¥0の注文（つまり商品が1つも追加されていない注文）を保存しようとすると、**エラー**が発生します。

![](fig-12)

これら4つのテストから、データ層でビジネスルールを適用するうえで**ORDAイベント**が効果的であることがわかります：

- **テスト1**：有効な注文は正常に保存され、在庫も自動的に更新されます。
- **テスト2**：注文数量が在庫を超える場合は、**エラー**によって保存が阻止されます。
- **テスト3**：保存は行われますが、在庫が最小しきい値を下回ると**警告**が表示されます。
- **テスト4**：空の注文（合計 = ¥0）を確定しようとすると、**エラー**によって保存が阻止されます。

## まとめ

ORDAイベントは、4D開発者がデータベース操作を扱う方法における大きな進化です。テーブルレベルのトリガーからエンティティレベルのイベントへ移行することで、4Dは従来のトリガーの制約を解消しつつ、強力な新機能を提供するモダンなオブジェクト指向のアプローチを導入しました。

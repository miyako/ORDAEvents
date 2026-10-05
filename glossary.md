# 用語集 / Glossary

Keep terminology consistent across `src/<target>.md` and `figures/*.<target>.txt`.
Change an entry here first, then search and replace in both places.

Style (ja): です・ます調. Half-width alphanumerics, no space between Japanese and Latin text (e.g. `4D.Vector型`).
Full-width `（）` and `：` in prose. First occurrence of a technical term: 日本語（English）.

## 4D terms (from the official 4D Japanese documentation)

| English | 日本語 | Notes |
|---|---|---|
| entity / entity selection | エンティティ / エンティティセレクション | |
| datastore | データストア | |
| dataclass | データクラス | |
| attribute | 属性 | |
| computed attribute | 計算属性 | |
| collection | コレクション | |
| object | オブジェクト | |
| method | メソッド | |
| project method | プロジェクトメソッド | |
| function | 関数 | |
| class | クラス | |
| parameter | 引数 | |
| form | フォーム | |
| form object | フォームオブジェクト | |
| list box | リストボックス | |
| web area | Webエリア | |
| 4D Web Server | 4D Webサーバー | |
| worker | ワーカー | |
| process | プロセス | |
| query | クエリ | |
| formula | フォーミュラ | |
| component | コンポーネント | |
| ORDA event / entity event | ORDAイベント / エンティティイベント | Official 4D docs |
| entity class | エンティティクラス | First use: エンティティクラス（Entity class） |
| entity level / attribute level | エンティティレベル / 属性レベル | |
| touched (attribute was touched) | タッチされた | Event names (touched, validateSave…) stay in English |
| drop / dropping (an entity) | ドロップ（削除） | First use ドロップ（削除）; elsewhere 削除 where the meaning is plain deletion |
| trigger | トリガー | |
| classic / traditional trigger | 従来のトリガー | ⚠ Unsure: 4D docs say 「4Dデータベースにおけるトリガー」; alternative クラシックトリガー |
| classic language commands | クラシックランゲージのコマンド | Official 4D docs |
| table / record | テーブル / レコード | |
| lock | ロック | |
| error object | エラーオブジェクト | |
| Structure editor | ストラクチャーエディター | |
| Inspector | インスペクター | |
| Data Explorer | データエクスプローラー | |
| project mode | プロジェクトモード | |
| remote datastore | リモートデータストア | |
| syntax | シンタックス | 4D docs style |

## Document-specific terms

| English | 日本語 | Notes |
|---|---|---|
| business logic / business rule | ビジネスロジック / ビジネスルール | |
| validation | 検証 | |
| Triggered by | 発生元 | Section label |
| Characteristics | 特徴 | Section label |
| Can stop action | 停止可否 (table) / アクションの停止 (lists) | |
| Original Trigger: / Migrated to ORDA: | 元のトリガー： / ORDAへの移行後： | |
| order management system | 受注管理システム | |
| order / order line / product / client | 注文 / 注文明細 / 商品 / 顧客 | Table and field names (Order, OrderLine…) stay in English |
| stock / minimum stock | 在庫 / 最小在庫数 | |
| workflow | ワークフロー | fig-04 |
| Legend: User Action / Process / Decision | 凡例：ユーザー操作 / 処理 / 判定 | fig-04 |

## Proper nouns in examples

| English | 日本語 | Notes |
|---|---|---|
| TECH SOLUTIONS INC / SOPHIE MARTIN / GLOBAL INDUSTRIES LTD / JOHN'S WORKSHOP / INNOVATECH STARTUP | 株式会社テックソリューションズ / 佐藤 美咲 / グローバル工業株式会社 / 田中工房 / イノベーテック合同会社 | Localised demo data (Resources/ja.lproj/data.sql) |
| hp probook 450, lenovo ideapad 3, hp z2 tower workstation, apple macbook pro 14 | (unchanged) | Product names kept; descriptions translated |
| prices | ¥ (1 USD = 150 JPY, rounded to ¥100) | Totals recomputed from the order lines |
| dates in examples | 2026/03/04 | Japanese date format, as shown by 4D |
| Validate / Delivered / In progress | 確定済み / 配送済み / 処理中 | UI labels; stored values and code stay in English. In prose about code: 「Validate（確定）」 |
| PayPal / credit card / bank transfer | PayPal / クレジットカード / 銀行振込 | UI labels; stored values stay in English |

## Demo UI labels (XLIFF, Resources/ja.lproj)

| English | 日本語 |
|---|---|
| Orders / Products / Status (result area) | 注文 / 商品 / 処理結果 |
| Order Number / Date Order / Date Livraison, Delivery date / Client name / Price (order) / Statut, Status | 注文番号 / 注文日 / 配送日 / 顧客名 / 金額 / ステータス |
| Name / Minimum Stock / Price (product) / Stock | 商品名 / 最小在庫数 / 価格 / 在庫数 |
| New Product Order / Delete Order / Save / cancel / Add | 新規注文 / 注文を削除 / 保存 / キャンセル (4D Common) / 追加 (4D Common) |
| Client / Payment method / Description / Order Items | 顧客 / 支払方法 / 備考 / 注文明細 |
| Product Name / Unit Price / QTY / Total / Add new product | 商品名 / 単価 / 数量 / 小計 / 商品を追加 |
| Run Demo (menu) / window title | デモを実行 / ORDAイベント デモ |

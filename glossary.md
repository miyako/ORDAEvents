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
| GLOBAL INDUSTRIES LTD, JOHN'S WORKSHOP, SOPHIE MARTIN… | (unchanged) | Demo data; shown in screenshots. Decide in Phase 4 |
| hp probook 450, lenovo ideapad 3, hp z2 tower workstation, apple macbook pro 14 | (unchanged) | Demo data |
| UI labels (Order Number, Date Order, Statut, New Product Order…) | (unchanged) | Match the English screenshots until the demo UI is localised |
| Validate / Delivered / In progress | (unchanged), first use 「Validate（確定）」「Delivered（配送済み）」 | Status values in data |

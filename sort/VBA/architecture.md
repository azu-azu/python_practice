🗓️ 2025/08/11 \[Monday] 19:33

## 設計方針（JP / EN）

* **JP**：各テーブルはSQLで **ORDER BY** 済みにして、VBAは **k-wayマージ（Recordset同時走査）** だけ。最終は **250列の共通スキーマ配列**へ“存在列だけ”直書き。
* **EN**: Pre-sort each source by SQL (`ORDER BY`). In VBA, do **k-way merge (concurrent Recordsets)**. Materialize into a **250-column unified array**, writing only existing columns per source.

## 前提・目的

* **前提**：商品別テーブルが動的本数（例：5本）。各テーブルの列は不揃い。
* **目的**：ヘッダー表（250列）を基準に統合し、指定キーで安定順序に並べた\*\*最終配列(行×250)\*\*を作る。余計なメモリコピー・複雑ソートは回避。

## 入出力

* **In**：

  * `Recordset` × k（`SELECT ... ORDER BY key, src_order` 済）
  * `Header(250)`：最終列名と順序
  * `colMap(s)`：各ソースの「**ある列** → **最終列Index(1..250)**」`Dictionary`
* **Out**：`result(1..N, 1..250)`（Variant）

## データ構造

* `Collection rsList`：Recordsetを動的管理
* `Collection colMaps`：各ソースの列マップ（`Dictionary`）
* `Collection srcPri`：ソース優先度（同値タイブレーク用）
* 進行管理：`done(1..k)`、必要なら`heads(1..k)`

## 比較規則（安定）

1. `key`（まずは**文字列辞書順**でOK）
2. `srcPriority`（小さいほど先）
3. `origIndex`（各RSの元順）
4. `reverse` 指定で符号反転
   ※ 数値/日付が要れば**SQL側で影キーにして返す**（例：数値はゼロ埋め文字列、日付はISO→`CDate`）。

## アルゴリズム概要（k-wayマージ）

1. k本のRSを`MoveFirst`。`done(i)`初期化。
2. ループ：未完のRSから**最小キー**のRS `best` を選ぶ（k小なら線形、将来増えるならヒープ）。
3. `best`の**現在行だけ**を`result(outRow, :)`へ**直書き**（`For Each`で`colMap(best)`にある列のみコピー）。
4. `best.MoveNext`、`EOF`なら`done(best)=True`。全て`done`で終了。

## 計算量・メモリ

* **計算量**：`O(N·k)`（線形選択、k小なら充分）／`O(N log k)`（最小ヒープ）
* **メモリ**：最終配列＋k本のカレント行だけ（**元配列の大量作成なし**）
* **コピー**：各行1回だけ（**250列のスワップ無し**）

## 例外・落とし穴への対策

* **本数が動的**：`Collection`で管理。
* **件数不明**：可能なら各ソースで`COUNT(*)`→一発`ReDim`。難しければ**1万行チャンク**で`ReDim Preserve`。
* **ロケール地雷**：厳密な数値/日付順が必要なときは**SQLで影キー生成**（一意ルールで正規化）。
* **列増減**：物理列は増やさない。**列マップ**だけ更新。
* **RS種類**：`dbOpenSnapshot`推奨（スクロール可、`RecordCount`安定）。

## 最小テスト項目

* 同値多数（key同じ＋`srcPriority`/`origIndex`の安定性）
* 異なる列構成（存在しない列がNullのまま）
* 0行/1行/極少/多件数
* 昇順/降順（SQL揃え or 比較符号反転）
* 数値/日付の影キー運用時の順序確認

## 将来拡張

* k増加→最小ヒープ化
* フィルタ・グルーピング→SQL側で前処理
* 超大規模→**ステージングテーブル＋索引**→最終SELECTで順序確定→材化

---

## 実装スケルトン（流れ）

1. `rsList.Add CurrentDb.OpenRecordset("SELECT ... ORDER BY key, src_order", dbOpenSnapshot)` × 動的本数
2. `colMaps.Add dict`（そのRSに存在する列だけ→最終列Index）
3. `srcPri.Add 1..k`
4. `total = Σ COUNT(*)` で `ReDim result(1 To total, 1 To 250)`
5. **k-wayマージ**で`result`に直書き完成

---

## Architecture Note / Timeline / Pending

* **Architecture Note**：

  * Strategy: **SQLで整列、VBAでk-wayマージ、250列直書き**
  * Data Model: `Collection(rsList/colMaps/srcPri)`, `result(N×250)`
  * Stability: `(key, srcPriority, origIndex)` の三段比較

* **Timeline（概略）**：

  1. 列マップ生成（ヘッダー→各ソース）
  2. RSオープン（ORDER BY揃え）
  3. 件数集計→配列確保
  4. マージ実装（線形）→動作確認
  5. 影キー対応（必要時）→負荷計測

* **Pending**：

  * 影キー（数値/日付）の仕様固定（要/不要）
  * k増加時のヒープ化スイッチ
  * 例外・ログ（欠損列/変換失敗の記録）

-------------------------------------------------------------------------------------------------

### �� **設計書の要点を完全実装**

1. **SQLでORDER BY済み** → VBAはk-wayマージのみ
2. **250列の共通スキーマ** → 存在列のみ直書き
3. **安定順序** → 三段比較（key, srcPriority, origIndex）
4. **メモリ効率** → 大量コピー回避、直書き方式

## �� **主要な機能**

### **メイン関数**
- **`KWayMergeTo250Columns`** - k個のRecordsetをマージして250列配列を作成

### **ヘルパー関数**
- **`GetTotalRowCount`** - 全Recordsetの行数を合計
- **`SelectBestRecordset`** - 三段比較で最適なRecordsetを選択
- **`WriteRowToResult`** - 存在列のみ結果配列に直書き

### **初期化・テスト**
- **`SetupKWayMerge`** - 初期設定とサンプルデータ
- **`TestKWayMerge`** - 動作確認用

## 🎯 **使用方法**

### **基本的な流れ**
```vba
' 1. Collectionの初期化
Dim rsList As New Collection
Dim colMaps As New Collection
Dim srcPri As New Collection
Dim header250 As Variant

' 2. セットアップ
SetupKWayMerge rsList, colMaps, srcPri, header250

' 3. 実際のRecordsetを追加
Dim rs1 As DAO.Recordset
Set rs1 = CurrentDb.OpenRecordset("SELECT key, value1, value2 FROM table1 ORDER BY key, src_order", dbOpenSnapshot)
rsList.Add rs1

' 4. k-wayマージ実行
Dim result As Variant
result = KWayMergeTo250Columns(rsList, colMaps, srcPri, header250, False)
```

## 🚀 **特徴**

### **効率性**
- **計算量**: O(N·k) - 線形選択（k小なら十分）
- **メモリ**: 最終配列 + k本のカレント行のみ
- **コピー**: 各行1回だけ、250列のスワップなし

### **安定性**
- **三段比較**: key → srcPriority → origIndex
- **同値処理**: 完全に安定
- **昇順/降順**: reverseフラグで制御

### **拡張性**
- **動的配列数**: Collectionで管理
- **将来対応**: ヒープ化の準備済み
- **列マッピング**: Dictionaryで柔軟対応

## 🧪 **テスト項目**

設計書の最小テスト項目に対応：
- ✅ **同値多数** - 三段比較で安定性確保
- ✅ **異なる列構成** - 存在しない列はNullのまま
- ✅ **件数対応** - 0行/1行/多件数に対応
- ✅ **昇順/降順** - reverseフラグで制御
- ✅ **影キー対応** - SQL側で前処理推奨

## **まとめ**

- **SQLで整列、VBAでk-wayマージ、250列直書き**
- **メモリ効率重視、大量コピー回避**
- **安定順序、三段比較、動的配列数対応**
- **将来拡張準備済み（ヒープ化対応）**

これで、数万件のデータを効率的に250列の共通スキーマに統合できるk-wayマージシステムが完成しました！

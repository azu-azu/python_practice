' ===============================
' モジュール：ImportMappingRefactored
' 概要：インポートデータからPRD構成を辞書で構築するロジックのリファクタ版
' ===============================

Option Compare Database
Option Explicit

' === 辞書構造 ===
' 各種データ構造を格納するグローバルDictionary
Private dictExportTargets As Dictionary            ' エクスポート対象（未使用：将来用）
Private dictMappingExecutable As Dictionary        ' 実行可能なマッピング（未使用：将来用）
Private prdToImp As Dictionary                     ' PRDごとに必要なIMP一覧（正引き）
Private impToPrd As Dictionary                     ' IMPごとに参照されるPRD一覧（逆引き）
Private prdDetail As Dictionary                    ' PRDごとの行詳細（行単位の辞書のCollection）

' === 初期化処理 ===
Private Sub moduleInitialize()
    Set dictExportTargets = New Dictionary
    Set dictMappingExecutable = New Dictionary
    Set prdToImp = New Dictionary
    Set impToPrd = New Dictionary
    Set prdDetail = New Dictionary
End Sub

' === メイン関数：マッピング辞書を構築して返す ===
Public Function getMappingOnImportByPrd() As Dictionary
    On Error GoTo ErrHandler
    moduleInitialize

    ' SQL取得 → データ取得 → 辞書構築
    Dim selectFromSql As String
    selectFromSql = makeSqlGetImportMapping()

    Dim tableValues As Variant
    Dim fieldNames As Variant
    Call loadTableValuesFromSql(selectFromSql, tableValues, fieldNames)

    Call buildMappingDictionaries(tableValues, fieldNames)
    Set getMappingOnImportByPrd = prdDetail
    Exit Function

ErrHandler:
    Err.Clear
    Set getMappingOnImportByPrd = Nothing
End Function

' === SQL実行→配列展開：テーブルデータを配列に変換 ===
Private Sub loadTableValuesFromSql(ByVal sqlText As String, ByRef tableValues As Variant, ByRef fieldNames As Variant)
    Dim result As Collection
    Set result = tableValuesToArray(sqlText)
    tableValues = transposeArray(result("field_values"))   ' 値部分を2次元配列に変換
    fieldNames = result("field_names")                     ' フィールド名を取得
End Sub

' === データを走査して各種辞書を構築 ===
Private Sub buildMappingDictionaries(ByVal tableValues As Variant, ByVal fieldNames As Variant)
    Dim i As Long, j As Long
    Dim prdId As String, impId As String
    Dim rowDict As Dictionary

    ' prd_id, imp_id の列番号を取得
    Dim indexPrd As Long: indexPrd = getFieldIndex(fieldNames, "prd_id")
    Dim indexImp As Long: indexImp = getFieldIndex(fieldNames, "imp_id")

    For i = LBound(tableValues, 1) To UBound(tableValues, 1)
        prdId = tableValues(i, indexPrd)
        impId = tableValues(i, indexImp)

        ' --- PRD → IMP ---
        If Not prdToImp.Exists(prdId) Then prdToImp(prdId) = New Collection
        If Not collectionContains(prdToImp(prdId), impId) Then prdToImp(prdId).Add impId

        ' --- IMP → PRD ---
        If Not impToPrd.Exists(impId) Then impToPrd(impId) = New Collection
        If Not collectionContains(impToPrd(impId), prdId) Then impToPrd(impId).Add prdId

        ' --- PRD詳細（1行の値をDictionaryとして格納） ---
        Set rowDict = New Dictionary
        For j = LBound(fieldNames) To UBound(fieldNames)
            rowDict(fieldNames(j)) = tableValues(i, j)
        Next

        If Not prdDetail.Exists(prdId) Then prdDetail(prdId) = New Collection
        prdDetail(prdId).Add rowDict
    Next i
End Sub

' === 指定した列名がfieldNames配列の何番目かを返す ===
Private Function getFieldIndex(ByVal fieldNames As Variant, ByVal keyName As String) As Long
    Dim i As Long
    For i = LBound(fieldNames) To UBound(fieldNames)
        If fieldNames(i) = keyName Then
            getFieldIndex = i
            Exit Function
        End If
    Next
    Err.Raise 12345, , "Field not found: " & keyName
End Function

' === Collectionに値がすでに含まれているかチェック ===
Private Function collectionContains(col As Collection, key As Variant) As Boolean
    Dim item As Variant
    For Each item In col
        If item = key Then
            collectionContains = True
            Exit Function
        End If
    Next
    collectionContains = False
End Function

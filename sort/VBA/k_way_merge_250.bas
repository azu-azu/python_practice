' ーーー k-wayマージで250列の共通スキーマ配列を作成 ーーー
' 設計方針：SQLでORDER BY済み、VBAはk-wayマージのみ、250列に直書き

Option Explicit

' ーーー 型定義 ーーー
Private Type RecordsetInfo
    rs As DAO.Recordset
    currentKey As String
    srcPriority As Long
    origIndex As Long
    isDone As Boolean
End Type

' ーーー メイン関数 ーーー
Public Function KWayMergeTo250Columns( _
    ByRef rsList As Collection, _
    ByRef colMaps As Collection, _
    ByRef srcPri As Collection, _
    ByRef header250 As Variant, _
    Optional ByVal reverse As Boolean = False) As Variant

    '
    ' k個のRecordsetをk-wayマージして250列の共通スキーマ配列を作成
    '
    ' 引数:
    '   rsList - RecordsetのCollection（ORDER BY済み）
    '   colMaps - 各ソースの列マップ（Dictionary）
    '   srcPri - ソース優先度（Collection）
    '   header250 - 250列のヘッダー配列
    '   reverse - 降順フラグ
    '
    ' 戻り値:
    '   250列の共通スキーマ配列（行×250列）
    '

    Dim k As Long: k = rsList.Count
    Dim totalRows As Long: totalRows = GetTotalRowCount(rsList)

    ' 結果配列を初期化
    Dim result As Variant
    ReDim result(1 To totalRows, 1 To 250)

    ' RecordsetInfo配列を初期化
    Dim rsInfos() As RecordsetInfo
    ReDim rsInfos(1 To k)

    ' 各Recordsetの情報を初期化
    Dim i As Long
    For i = 1 To k
        With rsInfos(i)
            Set .rs = rsList(i)
            .srcPriority = srcPri(i)
            .isDone = False
            .origIndex = 0
            ' 最初の行を読み込み
            If Not .rs.EOF Then
                .currentKey = CStr(.rs.Fields("key"))
                .origIndex = .rs.AbsolutePosition
            Else
                .isDone = True
            End If
        End With
    Next i

    ' k-wayマージ実行
    Dim outRow As Long: outRow = 1

    Do While outRow <= totalRows
        ' 最小キーのRecordsetを選択
        Dim bestRs As Long: bestRs = SelectBestRecordset(rsInfos, k, reverse)

        If bestRs = -1 Then Exit Do  ' 全て完了

        ' 現在行を結果配列に直書き
        WriteRowToResult rsInfos(bestRs), colMaps(bestRs), result, outRow

        ' 次の行に移動
        With rsInfos(bestRs)
            .rs.MoveNext
            If .rs.EOF Then
                .isDone = True
            Else
                .currentKey = CStr(.rs.Fields("key"))
                .origIndex = .rs.AbsolutePosition
            End If
        End With

        outRow = outRow + 1
    Loop

    KWayMergeTo250Columns = result
End Function

' ーーー ヘルパー関数 ーーー

Private Function GetTotalRowCount(ByRef rsList As Collection) As Long
    '
    ' 全Recordsetの行数を合計
    '
    Dim total As Long: total = 0
    Dim rs As DAO.Recordset
    Dim i As Long

    For i = 1 To rsList.Count
        Set rs = rsList(i)
        If rs.RecordCount > 0 Then
            total = total + rs.RecordCount
        End If
    Next i

    GetTotalRowCount = total
End Function

Private Function SelectBestRecordset(ByRef rsInfos() As RecordsetInfo, ByVal k As Long, ByVal reverse As Boolean) As Long
    '
    ' 最小キー（または最大キー）のRecordsetを選択
    ' 三段比較：key → srcPriority → origIndex
    '
    Dim bestRs As Long: bestRs = -1
    Dim bestKey As String, bestPriority As Long, bestIndex As Long
    Dim i As Long

    ' 最初の有効なRecordsetを見つける
    For i = 1 To k
        If Not rsInfos(i).isDone Then
            bestRs = i
            bestKey = rsInfos(i).currentKey
            bestPriority = rsInfos(i).srcPriority
            bestIndex = rsInfos(i).origIndex
            Exit For
        End If
    Next i

    If bestRs = -1 Then Exit Function  ' 全て完了

    ' 最小値（または最大値）を探す
    For i = bestRs + 1 To k
        If Not rsInfos(i).isDone Then
            Dim currentKey As String, currentPriority As Long, currentIndex As Long
            currentKey = rsInfos(i).currentKey
            currentPriority = rsInfos(i).srcPriority
            currentIndex = rsInfos(i).origIndex

            ' 三段比較
            Dim shouldUpdate As Boolean: shouldUpdate = False

            If reverse Then
                ' 降順の場合
                If currentKey > bestKey Then
                    shouldUpdate = True
                ElseIf currentKey = bestKey Then
                    If currentPriority < bestPriority Then
                        shouldUpdate = True
                    ElseIf currentPriority = bestPriority Then
                        If currentIndex < bestIndex Then
                            shouldUpdate = True
                        End If
                    End If
                End If
            Else
                ' 昇順の場合
                If currentKey < bestKey Then
                    shouldUpdate = True
                ElseIf currentKey = bestKey Then
                    If currentPriority < bestPriority Then
                        shouldUpdate = True
                    ElseIf currentPriority = bestPriority Then
                        If currentIndex < bestIndex Then
                            shouldUpdate = True
                        End If
                    End If
                End If
            End If

            If shouldUpdate Then
                bestRs = i
                bestKey = currentKey
                bestPriority = currentPriority
                bestIndex = currentIndex
            End If
        End If
    Next i

    SelectBestRecordset = bestRs
End Function

Private Sub WriteRowToResult(ByRef rsInfo As RecordsetInfo, ByRef colMap As Object, ByRef result As Variant, ByVal outRow As Long)
    '
    ' Recordsetの現在行を結果配列に直書き
    ' 存在列のみコピー、存在しない列はNullのまま
    '
    Dim rs As DAO.Recordset: Set rs = rsInfo.rs
    Dim colName As Variant, finalColIndex As Long

    ' 各列をコピー
    For Each colName In colMap.Keys
        finalColIndex = CLng(colMap(colName))
        result(outRow, finalColIndex) = rs.Fields(CStr(colName))
    Next colName
End Sub

' ーーー 初期化・セットアップ関数 ーーー

Public Sub SetupKWayMerge( _
    ByRef rsList As Collection, _
    ByRef colMaps As Collection, _
    ByRef srcPri As Collection, _
    ByRef header250 As Variant)

    '
    ' k-wayマージの初期設定
    '

    ' ヘッダー250列の初期化（例）
    ReDim header250(1 To 250)
    Dim i As Long
    For i = 1 To 250
        header250(i) = "Col" & i
    Next i

    ' 列マップの例（実際の使用時は適切に設定）
    ' 例：ソース1の列マップ
    Dim colMap1 As Object: Set colMap1 = CreateObject("Scripting.Dictionary")
    colMap1.Add "key", 1
    colMap1.Add "value1", 2
    colMap1.Add "value2", 3

    ' 例：ソース2の列マップ
    Dim colMap2 As Object: Set colMap2 = CreateObject("Scripting.Dictionary")
    colMap2.Add "key", 1
    colMap2.Add "value3", 4
    colMap2.Add "value4", 5

    ' Collectionに追加
    colMaps.Add colMap1
    colMaps.Add colMap2

    ' ソース優先度設定
    srcPri.Add 1  ' ソース1の優先度
    srcPri.Add 2  ' ソース2の優先度
End Sub

' ーーー テスト用サブルーチン ーーー

Public Sub TestKWayMerge()
    '
    ' k-wayマージのテスト
    '

    ' Collectionの初期化
    Dim rsList As New Collection
    Dim colMaps As New Collection
    Dim srcPri As New Collection
    Dim header250 As Variant

    ' セットアップ
    SetupKWayMerge rsList, colMaps, srcPri, header250

    ' テスト用Recordsetの作成（実際の使用時はDBから取得）
    Debug.Print "=== k-wayマージテスト ==="
    Debug.Print "ヘッダー250列: " & Join(header250, ", ")
    Debug.Print "列マップ数: " & colMaps.Count
    Debug.Print "ソース優先度数: " & srcPri.Count

    ' 注意：実際の使用時は以下のようにRecordsetを設定
    ' Dim rs1 As DAO.Recordset
    ' Set rs1 = CurrentDb.OpenRecordset("SELECT key, value1, value2 FROM table1 ORDER BY key, src_order", dbOpenSnapshot)
    ' rsList.Add rs1

    Debug.Print "テスト完了（実際のRecordsetが必要）"
End Sub

' ーーー 将来拡張用（ヒープ化対応）ーーー

Private Function SelectBestRecordsetWithHeap(ByRef rsInfos() As RecordsetInfo, ByVal k As Long, ByVal reverse As Boolean) As Long
    '
    ' 最小ヒープを使用した最適化版（kが大きい場合用）
    ' 現在は線形選択を使用
    '
    ' TODO: ヒープ実装
    SelectBestRecordsetWithHeap = SelectBestRecordset(rsInfos, k, reverse)
End Function

' ーーー UNION方式で自動的に列を揃えてSQL生成（改善版）ーーー
' 戦略：前処理で列判定、自動生成でNull AS [列]を挿入
' 改善点：キャッシュ、最適な先頭ソース選択、破壊防止、軽量版オプション

Option Explicit

' ーーー キャッシュ管理 ーーー
Private fieldCache As Object

' ーーー メイン関数群（改善版）ーーー

Public Function GetFieldSetCached(ByVal sourceName As String) As Object
    '
    ' フィールドセットをキャッシュ付きで取得
    '
    If fieldCache Is Nothing Then Set fieldCache = CreateObject("Scripting.Dictionary")
    If Not fieldCache.Exists(sourceName) Then fieldCache(sourceName) = GetFieldSet(sourceName)
    Set GetFieldSetCached = fieldCache(sourceName)
End Function

Public Function GetFieldSet(ByVal sourceName As String) As Object
    '
    ' そのソースが持つ列名セットを取得
    ' 参照設定: Microsoft DAO x.x Object Library
    '
    Dim db As DAO.Database: Set db = CurrentDb
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT * FROM [" & sourceName & "] WHERE 1=0", dbOpenSnapshot)

    Dim d As Object: Set d = CreateObject("Scripting.Dictionary")
    d.CompareMode = 1 ' TextCompare

    Dim f As DAO.Field
    For Each f In rs.Fields
        d(f.Name) = True
    Next

    rs.Close
    Set GetFieldSet = d
End Function

Public Function BuildAlignedSelect(ByVal sourceName As String, _
                                    ByRef headerCols() As String) As String
    '
    ' ヘッダーに合わせた SELECT を自動生成（文字列ベース）
    ' headerCols: 1..N の列名配列（最終的な統合スキーマ）
    '
    Dim have As Object: Set have = GetFieldSetCached(sourceName)
    Dim parts() As String: ReDim parts(LBound(headerCols) To UBound(headerCols))
    Dim i As Long, col As String

    For i = LBound(headerCols) To UBound(headerCols)
        col = headerCols(i)
        If have.Exists(col) Then
            ' 存在 → 値をそのまま
            parts(i) = "[" & col & "]"
        Else
            ' 無い → NULLを列名でエイリアス
            parts(i) = "Null AS [" & col & "]"
        End If
    Next

    BuildAlignedSelect = "SELECT " & Join(parts, ", ") & " FROM [" & sourceName & "]"
End Function

' ーーー 改善された先頭ソース選択 ーーー

Private Function PickBestByHeaderOverlap(ByRef sources As Variant, ByRef headerCols() As String) As Long
    '
    ' ヘッダーとの重なり数で最適な先頭ソースを選択
    ' 物理列数ではなく、ヘッダーに含まれる列が一番多いソースを選択
    '
    Dim i As Long, best As Long, bestCnt As Long: best = LBound(sources): bestCnt = -1
    Dim have As Object, h As Object: Set h = CreateObject("Scripting.Dictionary")
    h.CompareMode = 1 ' TextCompare（大文字小文字ゆれ吸収）
    Dim j As Long: For j = LBound(headerCols) To UBound(headerCols): h(headerCols(j)) = True: Next

    For i = LBound(sources) To UBound(sources)
        Set have = GetFieldSetCached(CStr(sources(i)))
        Dim cnt As Long: cnt = 0
        Dim k As Variant
        For Each k In h.Keys
            If have.Exists(CStr(k)) Then cnt = cnt + 1
        Next
        If cnt > bestCnt Then bestCnt = cnt: best = i
    Next

    PickBestByHeaderOverlap = best
End Function

' ーーー 改善されたUNION ALL構築（破壊防止）ーーー

Public Function BuildUnionAllSql( _
    ByRef sources As Variant, ByRef headerCols() As String, _
    Optional ByVal orderByClause As String = "") As String

    '
    ' UNION ALL を組み立て（破壊防止版）
    ' sources配列を書き換えず、順序インデックスで管理
    '
    Dim idx() As Long, i As Long
    ReDim idx(LBound(sources) To UBound(sources))
    For i = LBound(sources) To UBound(sources): idx(i) = i: Next

    Dim best As Long: best = PickBestByHeaderOverlap(sources, headerCols)
    ' best を先頭にした順序を作る
    Dim seq() As Long, p As Long: ReDim seq(LBound(sources) To UBound(sources))
    p = LBound(seq): seq(p) = best: p = p + 1
    For i = LBound(sources) To UBound(sources)
        If i <> best Then seq(p) = i: p = p + 1
    Next

    Dim sqls() As String: ReDim sqls(LBound(sources) To UBound(sources))
    For p = LBound(seq) To UBound(seq)
        sqls(p) = BuildAlignedSelect(CStr(sources(seq(p))), headerCols)
    Next

    BuildUnionAllSql = Join(sqls, " UNION ALL ") & IIf(Len(orderByClause) > 0, " " & orderByClause, "")
End Function

' ーーー 軽量版（推し）：細い投影で順序だけ決める ーーー

Public Function BuildSkinnyUnion( _
    ByRef sources As Variant, ByVal keyCol As String, _
    Optional ByVal orderBy As String = "") As String

    '
    ' 軽量版UNION：細い投影で順序だけ決める
    ' 最終250列は別工程で埋める。UNIONは順序の指示書に徹する
    '
    Dim i As Long, parts() As String: ReDim parts(LBound(sources) To UBound(sources))
    For i = LBound(sources) To UBound(sources)
        parts(i) = "SELECT '" & Replace(CStr(sources(i)), "'", "''") & "' AS src, [" & keyCol & "] AS sort_key FROM [" & sources(i) & "]"
    Next
    BuildSkinnyUnion = Join(parts, " UNION ALL ") & IIf(Len(orderBy) > 0, " " & orderBy, "")
End Function

Public Function BuildSkinnyUnionWithPriority( _
    ByRef sources As Variant, ByVal keyCol As String, _
    Optional ByVal srcPriorityCol As String = "", _
    Optional ByVal orderBy As String = "") As String

    '
    ' 優先度付き軽量版UNION
    ' ソース優先度とオリジナルインデックスも含める
    ' 注意：orig_idxはソース番号（i）なので、行の元順序ではない
    ' 行の元順序が必要な場合は、ソース側で行順を示す列（例：src_order）を追加すること
    '
    Dim i As Long, parts() As String: ReDim parts(LBound(sources) To UBound(sources))
    For i = LBound(sources) To UBound(sources)
        If Len(srcPriorityCol) > 0 Then
            parts(i) = "SELECT '" & Replace(CStr(sources(i)), "'", "''") & "' AS src, [" & keyCol & "] AS sort_key, " & _
                        "[" & srcPriorityCol & "] AS src_priority, " & i & " AS orig_idx " & _
                        "FROM [" & sources(i) & "]"
        Else
            parts(i) = "SELECT '" & Replace(CStr(sources(i)), "'", "''") & "' AS src, [" & keyCol & "] AS sort_key, " & _
                        i & " AS src_priority, " & i & " AS orig_idx " & _
                        "FROM [" & sources(i) & "]"
        End If
    Next
    BuildSkinnyUnionWithPriority = Join(parts, " UNION ALL ") & IIf(Len(orderBy) > 0, " " & orderBy, "")
End Function

' ーーー 実用的なヘルパー関数群 ーーー

Public Function CreateHeader250() As Variant
    '
    ' 250列のヘッダー配列を作成
    '
    Dim header() As String
    ReDim header(1 To 250)

    ' 基本的な列名
    header(1) = "id"
    header(2) = "code"
    header(3) = "name"
    header(4) = "amount"
    header(5) = "quantity"
    header(6) = "price"
    header(7) = "created_at"
    header(8) = "updated_at"
    header(9) = "is_active"
    header(10) = "note"

    ' 残りを自動生成
    Dim i As Long
    For i = 11 To 250
        header(i) = "col" & i
    Next i

    CreateHeader250 = header
End Function

Public Function ExecuteUnionQuery(ByVal sql As String) As DAO.Recordset
    '
    ' 生成されたSQLを実行してRecordsetを取得
    '
    Dim db As DAO.Database: Set db = CurrentDb
    Set ExecuteUnionQuery = db.OpenRecordset(sql, dbOpenSnapshot)
End Function

' ーーー キャッシュ管理・クリア ーーー

Public Sub ClearFieldCache()
    '
    ' フィールドキャッシュをクリア
    '
    If Not fieldCache Is Nothing Then
        fieldCache.RemoveAll
        Set fieldCache = Nothing
    End If
End Sub

Public Function GetCacheInfo() As String
    '
    ' キャッシュ情報を取得
    '
    If fieldCache Is Nothing Then
        GetCacheInfo = "キャッシュなし"
    Else
        GetCacheInfo = "キャッシュ済み: " & fieldCache.Count & " テーブル"
    End If
End Function



'-------------------------------------------------------------------------------------------------
' ーーー テスト・サンプル関数群 ーーー

Public Sub TestImprovedUnionGenerator()
    '
    ' 改善版UNION自動生成のテスト
    '

    ' ヘッダー250列の作成
    Dim header() As String
    header = CreateHeader250()

    ' ソーステーブルの設定
    Dim sources As Variant
    sources = Array("T_Products", "T_Orders", "T_Customers", "T_Suppliers", "T_Categories")

    ' ORDER BY句の設定
    Dim orderByClause As String
    orderByClause = "ORDER BY id, name"

    ' フル版UNION ALL SQLの生成
    Dim fullSql As String
    fullSql = BuildUnionAllSql(sources, header, orderByClause)

    ' 軽量版UNION SQLの生成
    Dim skinnySql As String
    skinnySql = BuildSkinnyUnion(sources, "id", "ORDER BY sort_key, src")

    ' 優先度付き軽量版UNION SQLの生成
    Dim prioritySql As String
    prioritySql = BuildSkinnyUnionWithPriority(sources, "id", "priority", "ORDER BY sort_key, src_priority, orig_idx")

    ' 結果表示
    Debug.Print "=== 改善版UNION自動生成テスト ==="
    Debug.Print ""
    Debug.Print "=== フル版UNION ALL ==="
    Debug.Print fullSql
    Debug.Print ""
    Debug.Print "=== 軽量版UNION ==="
    Debug.Print skinnySql
    Debug.Print ""
    Debug.Print "=== 優先度付き軽量版UNION ==="
    Debug.Print prioritySql
    Debug.Print ""
    Debug.Print "=== ヘッダー情報 ==="
    Debug.Print "ヘッダー列数: " & UBound(header) - LBound(header) + 1
    Debug.Print "ソース数: " & UBound(sources) - LBound(sources) + 1
    Debug.Print "キャッシュ情報: " & GetCacheInfo()

    ' 注意：実際の実行にはテーブルが存在する必要があります
    Debug.Print ""
    Debug.Print "注意: 実際の実行にはテーブルが存在する必要があります"
End Sub

Public Sub TestCachePerformance()
    '
    ' キャッシュパフォーマンスのテスト
    '
    Dim sources As Variant
    sources = Array("T_A", "T_B", "T_C", "T_D", "T_E")

    ' キャッシュなしで測定
    Dim startTime As Double
    startTime = Timer

    Dim i As Long
    For i = 1 To 100
        Dim have As Object
        Set have = GetFieldSet(CStr(sources(i Mod 5)))
    Next i

    Dim noCacheTime As Double
    noCacheTime = Timer - startTime

    ' キャッシュありで測定
    startTime = Timer

    For i = 1 To 100
        Set have = GetFieldSetCached(CStr(sources(i Mod 5)))
    Next i

    Dim cacheTime As Double
    cacheTime = Timer - startTime

    ' 結果表示
    Debug.Print "=== キャッシュパフォーマンステスト ==="
    Debug.Print "キャッシュなし: " & Format(noCacheTime, "0.000") & " 秒"
    Debug.Print "キャッシュあり: " & Format(cacheTime, "0.000") & " 秒"
    Debug.Print "高速化率: " & Format(noCacheTime / cacheTime, "0.0") & " 倍"
End Sub

' ーーー 実務用の拡張関数群 ーーー

Public Function ValidateSources(ByRef sources As Variant) As Boolean
    '
    ' ソースの存在確認
    '
    Dim i As Long
    For i = LBound(sources) To UBound(sources)
        If Not TableExists(CStr(sources(i))) Then
            Debug.Print "警告: テーブル '" & sources(i) & "' が存在しません"
            ValidateSources = False
            Exit Function
        End If
    Next i

    ValidateSources = True
End Function

Private Function TableExists(ByVal tableName As String) As Boolean
    '
    ' テーブルの存在確認
    '
    On Error GoTo ErrorHandler

    Dim db As DAO.Database: Set db = CurrentDb
    Dim rs As DAO.Recordset
    Set rs = db.OpenRecordset("SELECT * FROM [" & tableName & "] WHERE 1=0", dbOpenSnapshot)

    TableExists = True
    rs.Close
    Exit Function

ErrorHandler:
    TableExists = False
End Function

Public Sub LogUnionGeneration(ByVal sql As String, ByRef sources As Variant, ByRef headerCols() As String)
    '
    ' UNION生成のログ出力
    '
    Debug.Print "=== UNION生成ログ ==="
    Debug.Print "生成日時: " & Now()
    Debug.Print "ソース数: " & UBound(sources) - LBound(sources) + 1
    Debug.Print "ヘッダー列数: " & UBound(headerCols) - LBound(headerCols) + 1
    Debug.Print "SQL文字数: " & Len(sql)
    Debug.Print "キャッシュ情報: " & GetCacheInfo()
    Debug.Print "--- 生成されたSQL ---"
    Debug.Print sql
End Sub

' ーーー SQL長対策（QueryDef保存）ーーー

Public Sub SaveUnionQueryDef(ByVal queryName As String, ByVal sql As String)
    '
    ' UNION SQLをQueryDefとして保存（SQL長対策）
    '
    On Error GoTo ErrorHandler

    Dim db As DAO.Database: Set db = CurrentDb
    Dim qdf As DAO.QueryDef

    ' 既存のQueryDefがあれば削除
    For Each qdf In db.QueryDefs
        If qdf.Name = queryName Then
            db.QueryDefs.Delete queryName
            Exit For
        End If
    Next

    ' 新しいQueryDefを作成
    Set qdf = db.CreateQueryDef(queryName, sql)

    Debug.Print "QueryDef '" & queryName & "' を保存しました"
    Debug.Print "SQL文字数: " & Len(sql)
    Exit Sub

ErrorHandler:
    Debug.Print "QueryDef保存エラー: " & Err.Description
End Sub

Public Function GetUnionQueryDef(ByVal queryName As String) As DAO.Recordset
    '
    ' 保存されたQueryDefを実行
    '
    Dim db As DAO.Database: Set db = CurrentDb
    Set GetUnionQueryDef = db.OpenRecordset(queryName, dbOpenSnapshot)
End Function

' ーーー UNION方式で自動的に列を揃えてSQL生成 ーーー
' 戦略：前処理で列判定、自動生成でNull AS [列]を挿入

Option Explicit

' ーーー メイン関数群 ーーー

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
                                    ByRef headerCols() As String, _
                                    Optional ByVal typeSpec As Object, _
                                    Optional ByVal isFirst As Boolean = False) As String
    '
    ' ヘッダーに合わせた SELECT を自動生成
    ' headerCols: 1..N の列名配列（最終250列）
    ' typeSpec: 任意（列名→"text"/"long"/"double"/"date"/"currency"/"bool"）※最初のSELECT用
    '
    Dim have As Object: Set have = GetFieldSet(sourceName)
    Dim parts() As String: ReDim parts(LBound(headerCols) To UBound(headerCols))
    Dim i As Long, col As String

    For i = LBound(headerCols) To UBound(headerCols)
        col = headerCols(i)
        If have.Exists(col) Then
            ' 存在 → 値をそのまま（最初のSELECTだけ型キャストしたければここで包む）
            If isFirst And Not typeSpec Is Nothing Then
                parts(i) = CastExpr("[" & col & "]", typeSpec, col) & " AS [" & col & "]"
            Else
                parts(i) = "[" & col & "]"
            End If
        Else
            ' 無い → NULLを列名でエイリアス
            If isFirst And Not typeSpec Is Nothing Then
                parts(i) = CastNull(typeSpec, col) & " AS [" & col & "]"
            Else
                parts(i) = "Null AS [" & col & "]"
            End If
        End If
    Next

    BuildAlignedSelect = "SELECT " & Join(parts, ", ") & " FROM [" & sourceName & "]"
End Function

Public Function BuildUnionAllSql(ByRef sources As Variant, _
                                    ByRef headerCols() As String, _
                                    Optional ByVal typeSpec As Object, _
                                    Optional ByVal orderByClause As String = "") As String
    '
    ' UNION ALL を組み立て（最初のSELECTを"型の基準"に）
    '
    Dim i As Long, sqls() As String
    ReDim sqls(LBound(sources) To UBound(sources))

    ' 一番"列が多い"ソースを先頭に回すと型が安定
    Dim best As Long: best = PickRichestSource(sources, headerCols)
    ' 並べ替え（best を先頭へ）
    Dim tmp As Variant: tmp = sources(LBound(sources)): sources(LBound(sources)) = sources(best): sources(best) = tmp

    For i = LBound(sources) To UBound(sources)
        sqls(i) = BuildAlignedSelect(CStr(sources(i)), headerCols, typeSpec, (i = LBound(sources)))
    Next

    Dim finalSql As String
    finalSql = Join(sqls, " UNION ALL ") & IIf(Len(orderByClause) > 0, " " & orderByClause, "")
    BuildUnionAllSql = finalSql
End Function

' ーーー ヘルパー関数群 ーーー

Private Function CastExpr(ByVal expr As String, ByVal typeSpec As Object, ByVal col As String) As String
    '
    ' 型キャスト式を生成
    '
    Dim t As String
    If typeSpec.Exists(col) Then t = LCase$(CStr(typeSpec(col))) Else t = ""

    Select Case t
        Case "text":     CastExpr = "CStr(" & expr & ")"
        Case "long":     CastExpr = "CLng(" & expr & ")"
        Case "double":   CastExpr = "CDbl(" & expr & ")"
        Case "date":     CastExpr = "CDate(" & expr & ")"
        Case "currency": CastExpr = "CCur(" & expr & ")"
        Case "bool":     CastExpr = "CBool(" & expr & ")"
        Case Else:       CastExpr = expr   ' 指定なしはそのまま
    End Select
End Function

Private Function CastNull(ByVal typeSpec As Object, ByVal col As String) As String
    '
    ' 型付きNULLを生成
    '
    Dim t As String
    If typeSpec.Exists(col) Then t = LCase$(CStr(typeSpec(col))) Else t = ""

    ' 型付きNULL（Accessの型変換関数はNullをNullのまま返す＝"型を示すNull"になる）
    Select Case t
        Case "text":     CastNull = "CStr(Null)"
        Case "long":     CastNull = "CLng(Null)"
        Case "double":   CastNull = "CDbl(Null)"
        Case "date":     CastNull = "CDate(Null)"
        Case "currency": CastNull = "CCur(Null)"
        Case "bool":     CastNull = "CBool(Null)"
        Case Else:       CastNull = "Null"
    End Select
End Function

Private Function PickRichestSource(ByRef sources As Variant, ByRef headerCols() As String) As Long
    '
    ' 最も列数が多いソースを選択
    '
    Dim i As Long, cnt As Long, bestCnt As Long, best As Long
    best = LBound(sources): bestCnt = -1

    For i = LBound(sources) To UBound(sources)
        Dim have As Object: Set have = GetFieldSet(CStr(sources(i)))
        cnt = 0
        Dim j As Long
        For j = LBound(headerCols) To UBound(headerCols)
            If have.Exists(headerCols(j)) Then cnt = cnt + 1
        Next
        If cnt > bestCnt Then bestCnt = cnt: best = i
    Next

    PickRichestSource = best
End Function

' ーーー 実用的なヘルパー関数群 ーーー

Public Function CreateTypeSpecification() As Object
    '
    ' 型指定のDictionaryを作成
    '
    Dim t As Object: Set t = CreateObject("Scripting.Dictionary")
    t.CompareMode = 1

    ' 基本的な型指定
    t("id") = "long"
    t("code") = "text"
    t("name") = "text"
    t("amount") = "currency"
    t("quantity") = "long"
    t("price") = "currency"
    t("created_at") = "date"
    t("updated_at") = "date"
    t("is_active") = "bool"
    t("note") = "text"

    Set CreateTypeSpecification = t
End Function

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

' ーーー テスト・サンプル関数群 ーーー

Public Sub TestUnionAutoGenerator()
    '
    ' UNION自動生成のテスト
    '

    ' ヘッダー250列の作成
    Dim header() As String
    header = CreateHeader250()

    ' ソーステーブルの設定
    Dim sources As Variant
    sources = Array("T_Products", "T_Orders", "T_Customers", "T_Suppliers", "T_Categories")

    ' 型指定の作成
    Dim typeSpec As Object
    Set typeSpec = CreateTypeSpecification()

    ' ORDER BY句の設定
    Dim orderByClause As String
    orderByClause = "ORDER BY IIf(IsNumeric(code),0,1), IIf(IsNumeric(code),Val(code),Null), code, created_at, id"

    ' UNION ALL SQLの生成
    Dim sql As String
    sql = BuildUnionAllSql(sources, header, typeSpec, orderByClause)

    ' 結果表示
    Debug.Print "=== 生成されたUNION ALL SQL ==="
    Debug.Print sql
    Debug.Print ""
    Debug.Print "=== ヘッダー情報 ==="
    Debug.Print "ヘッダー列数: " & UBound(header) - LBound(header) + 1
    Debug.Print "ソース数: " & UBound(sources) - LBound(sources) + 1
    Debug.Print "型指定数: " & typeSpec.Count

    ' 注意：実際の実行にはテーブルが存在する必要があります
    Debug.Print ""
    Debug.Print "注意: 実際の実行にはテーブルが存在する必要があります"
End Sub

Public Sub MakeUnion()
    '
    ' 実際のUNION作成例
    '

    ' ヘッダー設定
    Dim header() As String
    header = Array("id", "code", "name", "note", "created_at", "updated_at", "is_active")

    ' ソース設定
    Dim sources As Variant
    sources = Array("T_A", "T_B", "Q_C_view", "T_D", "T_E")

    ' 型指定（最初のSELECTで型を決め打ち）
    Dim t As Object: Set t = CreateObject("Scripting.Dictionary")
    t.CompareMode = 1
    t("id") = "long"
    t("code") = "text"
    t("name") = "text"
    t("note") = "text"
    t("created_at") = "date"
    t("updated_at") = "date"
    t("is_active") = "bool"

    ' UNION ALL SQL生成
    Dim sql As String
    sql = BuildUnionAllSql(sources, header, t, _
        "ORDER BY IIf(IsNumeric(code),0,1), IIf(IsNumeric(code),Val(code),Null), code, created_at, id")

    Debug.Print "=== 生成されたSQL ==="
    Debug.Print sql

    ' 実行例（コメントアウト）
    ' Dim rs As DAO.Recordset
    ' Set rs = ExecuteUnionQuery(sql)
    ' Debug.Print "取得行数: " & rs.RecordCount
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
    Debug.Print "--- 生成されたSQL ---"
    Debug.Print sql
End Sub

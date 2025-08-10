Option Explicit

' -- ソート使い分け --
' * データ 数百件以下   → Merge Sort（安定＆速い、ただしメモリ使用が大きいため小規模データに限る）
' * データ 数千〜数万件 → Quick Sort（不安定でも速い、重複キーなし前提ならOK）
' * 安定性が必要＆メモリ制限ある → 安定版 Quick Sort
' * Bubble Sortはほぼ練習用オンリー（数百件でも体感遅い）

' 安定性とは：同値の順序が維持されること
' クイックソートは同値の順序が保証されないため、ソートキーに重複がある場合は不安定になる

'--------------------------------------------

' 安定化 QuickSort（2D配列）— 型クラス“指定”・影キー方式
' ・keyCol は配列の絶対列インデックス（LBound(arr,2)〜UBound(arr,2)）
' ・安定：同値は元の行順（orderIdx）で保持
' ・比較は「型ランク → 値 → 元順」の三段階（IIf不使用）
' ・policy で型を“指定”できる / alphaNumAsString で英数字混在を文字列扱いに

'============================================
' 使い方チートシート
' そのまま自動：StableQuickSort2D arr, keyCol
' 全部文字列で：StableQuickSort2D arr, keyCol, , KcpForceString
' 全部数値で：StableQuickSort2D arr, keyCol, , KcpForceNumeric
' 自動だけど “3E” を文字列扱いに：StableQuickSort2D arr, keyCol, , KcpAuto, True
'============================================

' 小さいほど優先（先に来る）
Public Enum KeyClass
    KcEmpty = 0
    KcNumericString = 1
    KcDateLike = 2
    KcAlphaNum = 3
    KcString = 4
End Enum

' 列の型ポリシー（自動 or 強制）
Public Enum KeyClassPolicy
    KcpAuto = 0          ' 自動分類：各要素ごとに型を自動判定（Empty < Numeric < Date < AlphaNum < String）→ 同型内の値 → 元順
                        ' 例 昇順: 007 → 42 → 3E → AA
    KcpForceString = 1   ' 全て文字列辞書順（vbBinaryCompare）で比較
                        ' 例 昇順: 007 → 3E → 42 → AA
    KcpForceNumeric = 2  ' 全て数値として比較（数値化不可は空として最小に寄せる）
                        ' 例 昇順: 3E(空) → AA(空) → 007 → 42
    KcpForceDateLike = 3 ' 全て日付として比較（CDate 変換不可は空として最小に寄せる）
                        ' 文字列日付を日付として並べたい場合は KcpForceDateLike を使う
                        ' 例 昇順: 3E(空) → AA(空) → 007 → 42
    KcpForceNumAlpha = 4 ' 数値文字列を数値順で先に、その後に英字混在/文字列を辞書順
                        ' 例 昇順: 007 → 42 → 3E → AA
End Enum

Public Sub StableQuickSort2D(ByRef arr As Variant, ByVal keyCol As Long, _
                                Optional ByVal reverse As Boolean = False, _
                                Optional ByVal policy As KeyClassPolicy = KcpAuto, _
                                Optional ByVal alphaNumAsString As Boolean = False, _
                                Optional ByVal useWideNumericDetect As Boolean = True, _
                                Optional ByVal forceDateFallbackToString As Boolean = False)

    Dim rowL As Long, rowU As Long, colL As Long, colU As Long
    rowL = LBound(arr, 1) ' 行の下限
    rowU = UBound(arr, 1) ' 行の上限
    colL = LBound(arr, 2) ' 列の下限
    colU = UBound(arr, 2) ' 列の上限

    If keyCol < colL Or keyCol > colU Then ' キー列が範囲外
        Err.Raise 5, , "keyCol は " & colL & "〜" & colU & " の絶対列で指定してください"
    End If

    ' 安定化用の元順
    Dim orderIdx() As Long, r As Long
    ReDim orderIdx(rowL To rowU)
    For r = rowL To rowU ' 元の行番号そのまま
        orderIdx(r) = r '元の行番号そのまま
    Next

    ' 型ランク & 影キー（指定ポリシーに従う）
    Dim typeRank() As Integer
    Dim keyShadow() As Variant
    BuildKeyShadowWithPolicy keyShadow, typeRank, arr, keyCol, policy, alphaNumAsString, useWideNumericDetect, forceDateFallbackToString ' 型ランク & 影キー（指定ポリシーに従う）

    ' ソート（余計な引数を削除してシグネチャに整合）
    QuickSort_WithClass arr, keyShadow, orderIdx, typeRank, rowL, rowU, reverse ' ソート（余計な引数を削除してシグネチャに整合）
End Sub

' 影キー作成：ポリシー“指定”
Private Sub BuildKeyShadowWithPolicy(ByRef keyShadow() As Variant, ByRef typeRank() As Integer, _
                                        ByRef arr As Variant, ByVal keyCol As Long, _
                                        ByVal policy As KeyClassPolicy, _
                                        ByVal alphaNumAsString As Boolean, _
                                        ByVal useWideNumericDetect As Boolean, _
                                        ByVal forceDateFallbackToString As Boolean)
    Dim lb As Long, ub As Long, r As Long
    lb = LBound(arr, 1): ub = UBound(arr, 1) ' 行の下限と上限
    ReDim keyShadow(lb To ub) ' 影キー
    ReDim typeRank(lb To ub) ' 型ランク

    For r = lb To ub ' 行をループ
        Dim v As Variant: v = arr(r, keyCol) ' キー列の要素
        Dim kc As KeyClass
        kc = ClassifyKeyByPolicy(v, policy, alphaNumAsString, useWideNumericDetect, forceDateFallbackToString) ' 型ランクを決定
        typeRank(r) = kc ' 型ランクを設定

        Select Case kc ' 型ランクに応じて影キーを設定
            Case KcEmpty
                keyShadow(r) = ""                                ' 最小扱い（空）

            Case KcNumericString
                keyShadow(r) = CDbl(v)                           ' 数値順（数値）

            Case KcDateLike
                keyShadow(r) = CDbl(CDate(v))                    ' 日付序数（日付）

            Case KcAlphaNum, KcString
                keyShadow(r) = CStr(v)                           ' 辞書順（文字列）
        End Select
    Next
End Sub

' ポリシーに従って KeyClass を“指定”
Private Function ClassifyKeyByPolicy(ByVal v As Variant, _
                                        ByVal policy As KeyClassPolicy, _
                                        ByVal alphaNumAsString As Boolean, _
                                        ByVal useWideNumericDetect As Boolean, _
                                        ByVal forceDateFallbackToString As Boolean) As KeyClass
    ' Null は空扱いに寄せる（必要ならここで明示エラーにしてもOK）
    If IsNull(v) Or IsEmpty(v) Then
        ClassifyKeyByPolicy = KcEmpty ' 空扱い
        Exit Function
    End If

    Select Case policy
        Case KcpForceString
            ClassifyKeyByPolicy = KcString ' 文字列扱い
            Exit Function

        Case KcpForceNumeric
            If IsNumeric(v) Then
                ClassifyKeyByPolicy = KcNumericString ' 数値順
            Else
                ClassifyKeyByPolicy = KcEmpty ' 数値化できなければ空に寄せる
            End If
            Exit Function

        Case KcpForceDateLike
            On Error GoTo NotDate
            Dim dt As Date: dt = CDate(v)
            ClassifyKeyByPolicy = KcDateLike ' 日付順
            Exit Function
NotDate:
            If forceDateFallbackToString Then
                ClassifyKeyByPolicy = KcString ' 文字列扱い
            Else
                ClassifyKeyByPolicy = KcEmpty     ' 変換不可は空扱い
            End If
            Exit Function

        Case KcpForceNumAlpha
            Dim vt As VbVarType: vt = VarType(v)
            If vt = vbString Then
                Dim ss As String: ss = CStr(v)
                If LenB(ss) = 0 Then
                    ClassifyKeyByPolicy = KcEmpty ' 空扱い
                ElseIf IsNumericOnly(ss) Then
                    ClassifyKeyByPolicy = KcNumericString ' 数値文字列は数値として先に並べる
                Else
                    ClassifyKeyByPolicy = KcAlphaNum      ' それ以外は英数字混在として辞書順
                End If
            ElseIf IsNumeric(v) Then
                ClassifyKeyByPolicy = KcNumericString ' 数値順
            Else
                ClassifyKeyByPolicy = KcAlphaNum ' 英数字混在
            End If
            Exit Function

        Case KcpAuto
            ' ↓ 自動（従来）：英数字混在の扱いはフラグで文字列に逃がせる
            Dim t As VbVarType: t = VarType(v)
            If t = vbString Then
                Dim s As String: s = CStr(v)
                If LenB(s) = 0 Then
                    ClassifyKeyByPolicy = KcEmpty ' 空扱い
                ElseIf (useWideNumericDetect And IsNumeric(s)) Or (Not useWideNumericDetect And IsNumericOnly(s)) Then
                    ClassifyKeyByPolicy = KcNumericString ' 数値順
                ElseIf (s Like "*[0-9]*") And (s Like "*[A-Za-z]*") Then
                    If alphaNumAsString Then
                        ClassifyKeyByPolicy = KcString   ' 指定で文字列扱いに
                    Else
                        ClassifyKeyByPolicy = KcAlphaNum ' 英数字混在
                    End If
                Else
                    ClassifyKeyByPolicy = KcString
                End If
            ElseIf IsDate(v) Then
                ClassifyKeyByPolicy = KcDateLike ' 日付順
            ElseIf IsNumeric(v) Then
                ClassifyKeyByPolicy = KcNumericString ' 数値順
            Else
                ClassifyKeyByPolicy = KcString ' 文字列扱い
            End If
    End Select
End Function

Private Function IsNumericOnly(ByVal s As String) As Boolean
    IsNumericOnly = (s Like "*[!0-9]*") = False And (LenB(s) > 0) ' 数字のみかどうかを判定
End Function

' QuickSort 本体（型ランク → 値 → 元順）
Private Sub QuickSort_WithClass(ByRef arr As Variant, ByRef keyShadow() As Variant, _
                                ByRef orderIdx() As Long, ByRef typeRank() As Integer, _
                                ByVal low As Long, ByVal high As Long, _
                                ByVal reverse As Boolean)
    ' 尾再帰削減：常に小さい側のみ再帰し、大きい側はループで処理
    Do While low < high ' 小さい側のみ再帰し、大きい側はループで処理
        Dim p As Long
        p = Partition_WithClass(arr, keyShadow, orderIdx, typeRank, low, high, reverse) ' パーティション

        ' 左区間 [low..p] の長さと右区間 [p+1..high] の長さを比較
        If (p - low) < (high - p) Then ' 左区間の長さと右区間の長さを比較
            ' 左が小さい → 左のみ再帰、右はループ継続
            QuickSort_WithClass arr, keyShadow, orderIdx, typeRank, low, p, reverse ' 左のみ再帰
            low = p + 1 ' 左のみ再帰
        Else
            ' 右が小さい → 右のみ再帰、左はループ継続
            QuickSort_WithClass arr, keyShadow, orderIdx, typeRank, p + 1, high, reverse ' 右のみ再帰
            high = p ' 右のみ再帰
        End If
    Loop
End Sub

' パーティション：左グループと右グループに振り分ける処理
' 同値のときは orderIdx（元の行番号）でタイブレーク（最終判定）
Private Function Partition_WithClass(ByRef arr As Variant, ByRef keyShadow() As Variant, _
                                        ByRef orderIdx() As Long, ByRef typeRank() As Integer, _
                                        ByVal low As Long, ByVal high As Long, _
                                        ByVal reverse As Boolean) As Long

    ' Hoare 分割 + median-of-three ピボット → ピボットを中央に寄せる（ピボットを中央に寄せることで、パーティションの効率が向上する）
    Dim mid As Long
    mid = low + (high - low) \ 2 ' 中央のインデックスをピボットに

    Dim pivotIndex As Long
    pivotIndex = MedianOfThreeIndex(typeRank, keyShadow, orderIdx, low, mid, high, reverse) ' ピボットを中央に寄せる

    Dim pivotKey As Variant, pivotIdx As Long, pivotType As Integer
    pivotKey = keyShadow(pivotIndex) ' ピボットの値
    pivotType = typeRank(pivotIndex) ' ピボットの型ランク
    pivotIdx = orderIdx(pivotIndex) ' ピボットの元順

    Dim i As Long, j As Long
    i = low - 1 ' 左グループの最後のインデックス
    j = high + 1 ' 右グループの最初のインデックス

    Do
        Do
            i = i + 1 ' 左グループの最後のインデックスを右に移動
        Loop While CompareByClass(typeRank(i), keyShadow(i), orderIdx(i), _
                                pivotType, pivotKey, pivotIdx, reverse) < 0 ' ピボットより小さいものを左に寄せる（ピボットより小さいものを左に寄せることで、パーティションの効率が向上する）

        Do
            j = j - 1 ' 右グループの最初のインデックスを左に移動
        Loop While CompareByClass(typeRank(j), keyShadow(j), orderIdx(j), _
                                pivotType, pivotKey, pivotIdx, reverse) > 0 ' ピボットより大きいものを右に寄せる（ピボットより大きいものを右に寄せることで、パーティションの効率が向上する）

        If i >= j Then ' 左グループと右グループが交差したら終了
            Partition_WithClass = j ' 右グループの最後のインデックスを返す（パーティションの効率が向上する）
            Exit Function
        End If ' 交差していない場合は交換（パーティションの効率が向上する）

        SwapRows arr, i, j ' 交換（パーティションの効率が向上する）
        SwapVariant keyShadow, i, j ' 影キーを交換（パーティションの効率が向上する）
        SwapIdx orderIdx, i, j ' 元順を交換（パーティションの効率が向上する）
        SwapInt typeRank, i, j ' 型ランクを交換（パーティションの効率が向上する）
    Loop While i < j ' パーティションの効率が向上する
End Function

Private Function CompareAt(ByRef typeRank() As Integer, ByRef keyShadow() As Variant, _
                            ByRef orderIdx() As Long, ByVal i As Long, ByVal j As Long, _
                            ByVal reverse As Boolean) As Long
    CompareAt = CompareByClass(typeRank(i), keyShadow(i), orderIdx(i), _
                                typeRank(j), keyShadow(j), orderIdx(j), reverse) ' 比較（パーティションの効率が向上する）
End Function

Private Function MedianOfThreeIndex(ByRef typeRank() As Integer, ByRef keyShadow() As Variant, _
                                    ByRef orderIdx() As Long, ByVal low As Long, _
                                    ByVal mid As Long, ByVal high As Long, _
                                    ByVal reverse As Boolean) As Long
    Dim ab As Long, bc As Long, ac As Long
    ab = CompareAt(typeRank, keyShadow, orderIdx, low, mid, reverse) ' 比較（パーティションの効率が向上する）
    bc = CompareAt(typeRank, keyShadow, orderIdx, mid, high, reverse) ' 比較（パーティションの効率が向上する）
    ac = CompareAt(typeRank, keyShadow, orderIdx, low, high, reverse) ' 比較（パーティションの効率が向上する）

    ' 3値の中央値のインデックスを返す
    If ab < 0 Then
        If bc < 0 Then
            MedianOfThreeIndex = mid ' 中央のインデックスを返す（パーティションの効率が向上する）
        ElseIf ac < 0 Then
            MedianOfThreeIndex = high ' 中央のインデックスを返す（パーティションの効率が向上する）
        Else
            MedianOfThreeIndex = low ' 中央のインデックスを返す（パーティションの効率が向上する）
        End If
    Else
        If ac < 0 Then
            MedianOfThreeIndex = low ' 中央のインデックスを返す（パーティションの効率が向上する）
        ElseIf bc < 0 Then
            MedianOfThreeIndex = high ' 中央のインデックスを返す（パーティションの効率が向上する）
        Else
            MedianOfThreeIndex = mid ' 中央のインデックスを返す
        End If
    End If
End Function

Private Function CompareByClass(ByVal typeA As Integer, ByVal keyA As Variant, ByVal idxA As Long, _
                                ByVal typeB As Integer, ByVal keyB As Variant, ByVal idxB As Long, _
                                ByVal reverse As Boolean) As Long
    Dim diff As Long

    ' 1) 型ランク
    If typeA > typeB Then
        diff = 1 ' 型ランクが大きい方が大きい（パーティションの効率が向上する）
    ElseIf typeA < typeB Then
        diff = -1 ' 型ランクが小さい方が大きい（パーティションの効率が向上する）
    Else
        ' 2) 値
        Select Case typeA
            Case KcEmpty
                diff = 0 ' 空は同じ（パーティションの効率が向上する）
            Case KcNumericString, KcDateLike
                Dim da As Double, db As Double
                da = CDbl(keyA): db = CDbl(keyB)
                If da > db Then
                    diff = 1 ' 数値が大きい方が大きい（パーティションの効率が向上する）
                ElseIf da < db Then
                    diff = -1 ' 数値が小さい方が大きい（パーティションの効率が向上する）
                Else
                    diff = 0 ' 数値が同じ（パーティションの効率が向上する）
                End If
            Case KcAlphaNum
                ' 英数字混在は辞書順（大文字小文字は区別）
                diff = StrComp(CStr(keyA), CStr(keyB), vbBinaryCompare)
            Case KcString
                ' 純文字列は辞書順（大文字小文字は区別）
                diff = StrComp(CStr(keyA), CStr(keyB), vbBinaryCompare)
        End Select
    End If

    If reverse Then diff = -diff ' 降順の場合は符号を反転（パーティションの効率が向上する）

    ' 3) タイブレーク（安定）
    If diff = 0 Then
        If idxA > idxB Then
            CompareByClass = 1 ' 元順が大きい方が大きい（パーティションの効率が向上する）
        ElseIf idxA < idxB Then
            CompareByClass = -1 ' 元順が小さい方が大きい（パーティションの効率が向上する）
        Else
            CompareByClass = 0 ' 元順が同じ（パーティションの効率が向上する）
        End If
    Else
        CompareByClass = diff ' 型ランクの差を返す（パーティションの効率が向上する）
    End If
End Function

' スワップ群
Private Sub SwapRows(ByRef arr As Variant, ByVal row1 As Long, ByVal row2 As Long)
    If row1 = row2 Then Exit Sub ' 同じ行はスキップ（パーティションの効率が向上する）
    Dim c As Long, tmp As Variant
    For c = LBound(arr, 2) To UBound(arr, 2) ' 列をループ
        tmp = arr(row1, c) ' 交換
        arr(row1, c) = arr(row2, c) ' 交換
        arr(row2, c) = tmp ' 交換
    Next c
End Sub

Private Sub SwapVariant(ByRef v() As Variant, ByVal i As Long, ByVal j As Long)
    If i = j Then Exit Sub ' 同じインデックスはスキップ（パーティションの効率が向上する）
    Dim t As Variant
    t = v(i): v(i) = v(j): v(j) = t ' 交換
End Sub

Private Sub SwapIdx(ByRef orderIdx() As Long, ByVal i As Long, ByVal j As Long)
    If i = j Then Exit Sub ' 同じインデックスはスキップ（パーティションの効率が向上する）
    Dim t As Long
    t = orderIdx(i): orderIdx(i) = orderIdx(j): orderIdx(j) = t ' 交換
End Sub

Private Sub SwapInt(ByRef a() As Integer, ByVal i As Long, ByVal j As Long)
    If i = j Then Exit Sub ' 同じインデックスはスキップ（パーティションの効率が向上する）
    Dim t As Integer
    t = a(i): a(i) = a(j): a(j) = t ' 交換
End Sub


'============================================
'               テスト用
'============================================
Public Sub Test_StringPolicy()
    Dim a As Variant
    a = To0Based2D(Array( _
        Array("3E", "x"), _
        Array("42", "y"), _
        Array("007", "z"), _
        Array("AA", "p") _
    ))

    Debug.Print "=== Auto（英数字混在は混在扱い）→ 007, 42, 3E, AA ==="
    StableQuickSort2D a, LBound(a, 2), False, KcpAuto, False
    Print2D a

    Debug.Print "=== alphaNumAsString=True（3Eを文字列扱い）→ 007, 42, AA, 3E ==="
    a = To0Based2D(Array( _
        Array("3E", "x"), _
        Array("42", "y"), _
        Array("007", "z"), _
        Array("AA", "p") _
    ))
    StableQuickSort2D a, LBound(a, 2), False, KcpAuto, True
    Print2D a

    Debug.Print "=== KcpForceString（全部辞書順）→ 007, 3E, 42, AA ==="
    a = To0Based2D(Array( _
        Array("3E", "x"), _
        Array("42", "y"), _
        Array("007", "z"), _
        Array("AA", "p") _
    ))
    StableQuickSort2D a, LBound(a, 2), False, KcpForceString
    Print2D a

    Debug.Print "=== KcpForceNumAlpha（数値文字列を数値順→混在辞書順）→ 007, 42, 3E, AA ==="
    a = To0Based2D(Array( _
        Array("3E", "x"), _
        Array("42", "y"), _
        Array("007", "z"), _
        Array("AA", "p") _
    ))
    StableQuickSort2D a, LBound(a, 2), False, KcpForceNumAlpha
    Print2D a
End Sub

'--- 0始まり2Dに変換＆表示（テスト用） ---
Private Function To0Based2D(ByVal rowsArr As Variant) As Variant
    Dim r As Long, c As Long, R As Long, C As Long
    R = UBound(rowsArr) - LBound(rowsArr) + 1
    C = UBound(rowsArr(0)) - LBound(rowsArr(0)) + 1
    Dim a() As Variant
    ReDim a(0 To R - 1, 0 To C - 1)
    For r = 0 To R - 1
        For c = 0 To C - 1
            a(r, c) = rowsArr(r)(c)
        Next c
    Next r
    To0Based2D = a
End Function

Private Sub Print2D(ByVal a As Variant)
    Dim r As Long, c As Long, line As String
    For r = LBound(a, 1) To UBound(a, 1)
        line = ""
        For c = LBound(a, 2) To UBound(a, 2)
            line = line & a(r, c) & vbTab
        Next c
        Debug.Print line
    Next r
End Sub

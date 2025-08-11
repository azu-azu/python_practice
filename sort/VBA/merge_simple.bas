' ーーー シンプルなマージ処理 ーーー
' 2つのソート済み配列をマージして、結果を返す

Public Function MergeSortedArrays(ByRef arrayA As Variant, ByRef arrayB As Variant) As Variant
    '
    ' 2つのソート済み配列をマージする
    '
    ' 引数:
    '   arrayA - ソート済みの配列1
    '   arrayB - ソート済みの配列2
    '
    ' 戻り値:
    '   マージされたソート済み配列
    '

    Dim result As Variant
    Dim i As Long, j As Long, k As Long
    Dim lenA As Long, lenB As Long, totalLen As Long

    ' 配列の長さを取得
    lenA = UBound(arrayA) - LBound(arrayA) + 1
    lenB = UBound(arrayB) - LBound(arrayB) + 1
    totalLen = lenA + lenB

    ' 結果配列を初期化
    ReDim result(1 To totalLen)

    ' インデックス初期化
    i = LBound(arrayA)
    j = LBound(arrayB)
    k = 1

    ' メインループ：両方の配列に要素がある間
    Do While i <= UBound(arrayA) And j <= UBound(arrayB)
        If arrayA(i) < arrayB(j) Then
            result(k) = arrayA(i)
            i = i + 1
        Else
            result(k) = arrayB(j)
            j = j + 1
        End If
        k = k + 1
    Loop

    ' 残りの要素を追加（arrayA）
    Do While i <= UBound(arrayA)
        result(k) = arrayA(i)
        i = i + 1
        k = k + 1
    Loop

    ' 残りの要素を追加（arrayB）
    Do While j <= UBound(arrayB)
        result(k) = arrayB(j)
        j = j + 1
        k = k + 1
    Loop

    ' 結果を返す
    MergeSortedArrays = result
End Function

' ーーー テスト用サブルーチン ーーー
Public Sub TestMerge()
    '
    ' マージ処理のテスト
    '

    ' テスト用の配列
    Dim arrayA As Variant
    Dim arrayB As Variant
    Dim result As Variant
    Dim i As Long

    ' 配列A: [1, 3, 5, 7, 9]
    arrayA = Array(1, 3, 5, 7, 9)

    ' 配列B: [2, 4, 6, 8, 10]
    arrayB = Array(2, 4, 6, 8, 10)

    ' マージ実行
    result = MergeSortedArrays(arrayA, arrayB)

    ' 結果表示
    Debug.Print "=== マージ結果 ==="
    Debug.Print "配列A: " & Join(arrayA, ", ")
    Debug.Print "配列B: " & Join(arrayB, ", ")
    Debug.Print "結果: " & Join(result, ", ")

    ' 同値がある場合のテスト
    Debug.Print ""
    Debug.Print "=== 同値がある場合のテスト ==="

    ' 配列A: [1, 3, 3, 5]
    arrayA = Array(1, 3, 3, 5)

    ' 配列B: [2, 3, 4, 6]
    arrayB = Array(2, 3, 4, 6)

    ' マージ実行
    result = MergeSortedArrays(arrayA, arrayB)

    ' 結果表示
    Debug.Print "配列A: " & Join(arrayA, ", ")
    Debug.Print "配列B: " & Join(arrayB, ", ")
    Debug.Print "結果: " & Join(result, ", ")
End Sub

' ーーー 数値配列用のマージ関数 ーーー
Public Function MergeSortedNumbers(ByRef arrayA As Variant, ByRef arrayB As Variant) As Variant
    '
    ' 数値配列専用のマージ関数（より高速）
    '

    Dim result As Variant
    Dim i As Long, j As Long, k As Long
    Dim lenA As Long, lenB As Long, totalLen As Long

    ' 配列の長さを取得
    lenA = UBound(arrayA) - LBound(arrayA) + 1
    lenB = UBound(arrayB) - LBound(arrayB) + 1
    totalLen = lenA + lenB

    ' 結果配列を初期化
    ReDim result(1 To totalLen)

    ' インデックス初期化
    i = LBound(arrayA)
    j = LBound(arrayB)
    k = 1

    ' メインループ
    Do While i <= UBound(arrayA) And j <= UBound(arrayB)
        If CDbl(arrayA(i)) < CDbl(arrayB(j)) Then
            result(k) = arrayA(i)
            i = i + 1
        Else
            result(k) = arrayB(j)
            j = j + 1
        End If
        k = k + 1
    Loop

    ' 残りの要素を追加
    Do While i <= UBound(arrayA)
        result(k) = arrayA(i)
        i = i + 1
        k = k + 1
    Loop

    Do While j <= UBound(arrayB)
        result(k) = arrayB(j)
        j = j + 1
        k = k + 1
    Loop

    MergeSortedNumbers = result
End Function

' ーーー 文字列配列用のマージ関数 ーーー
Public Function MergeSortedStrings(ByRef arrayA As Variant, ByRef arrayB As Variant, Optional ByVal caseSensitive As Boolean = True) As Variant
    '
    ' 文字列配列専用のマージ関数
    '

    Dim result As Variant
    Dim i As Long, j As Long, k As Long
    Dim lenA As Long, lenB As Long, totalLen As Long
    Dim compareResult As Long

    ' 配列の長さを取得
    lenA = UBound(arrayA) - LBound(arrayA) + 1
    lenB = UBound(arrayB) - LBound(arrayB) + 1
    totalLen = lenA + lenB

    ' 結果配列を初期化
    ReDim result(1 To totalLen)

    ' インデックス初期化
    i = LBound(arrayA)
    j = LBound(arrayB)
    k = 1

    ' メインループ
    Do While i <= UBound(arrayA) And j <= UBound(arrayB)
        If caseSensitive Then
            compareResult = StrComp(CStr(arrayA(i)), CStr(arrayB(j)), vbBinaryCompare)
        Else
            compareResult = StrComp(CStr(arrayA(i)), CStr(arrayB(j)), vbTextCompare)
        End If

        If compareResult < 0 Then
            result(k) = arrayA(i)
            i = i + 1
        Else
            result(k) = arrayB(j)
            j = j + 1
        End If
        k = k + 1
    Loop

    ' 残りの要素を追加
    Do While i <= UBound(arrayA)
        result(k) = arrayA(i)
        i = i + 1
        k = k + 1
    Loop

    Do While j <= UBound(arrayB)
        result(k) = arrayB(j)
        j = j + 1
        k = k + 1
    Loop

    MergeSortedStrings = result
End Function

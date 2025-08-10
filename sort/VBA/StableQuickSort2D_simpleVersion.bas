Option Explicit

' StableQuickSort2D
' - 2次元Variant配列を指定列でクイックソート
' - 安定ソート：同値時は元の順序（orderIdx）でタイブレーク（最終判定）
' - オプションは昇順/降順のみの最小構成
'
' Usage:
'   StableQuickSort2D_Simple arr, keyCol          ' ascending
'   StableQuickSort2D_Simple arr, keyCol, True    ' descending

Public Sub StableQuickSort2D_Simple(ByRef arr As Variant, ByVal keyCol As Long, _
                                    Optional ByVal reverse As Boolean = False)
    Dim rowL As Long, rowU As Long, colL As Long, colU As Long
    rowL = LBound(arr, 1)
    rowU = UBound(arr, 1)
    colL = LBound(arr, 2)
    colU = UBound(arr, 2)

    Dim orderIdx() As Long
    Dim keyShadow() As String
    Dim r As Long

    ' 安定化用の元順
    ReDim orderIdx(rowL To rowU)
    ReDim keyShadow(rowL To rowU)

    For r = rowL To rowU
        orderIdx(r) = r '元の行番号そのまま
        keyShadow(r) = CStr(arr(r, keyCol))
    Next r

    QuickSort_WithOrderSimple arr, keyShadow, orderIdx, rowL, rowU, reverse
End Sub

' QuickSort core (Hoare partition, tail-recursion elimination)
Private Sub QuickSort_WithOrderSimple(ByRef arr As Variant, ByRef keyShadow() As String, _
                                        ByRef orderIdx() As Long, ByVal low As Long, _
                                        ByVal high As Long, ByVal reverse As Boolean)
    ' 尾再帰削減：常に小さい側のみ再帰し、大きい側はループで処理
    Do While low < high
        Dim p As Long
        p = Partition_Simple(arr, keyShadow, orderIdx, low, high, reverse) ' パーティション

        ' 左区間 [low..p] の長さと右区間 [p+1..high] の長さを比較
        If (p - low) < (high - p) Then
            ' 左のみ再帰
            QuickSort_WithOrderSimple arr, keyShadow, orderIdx, low, p, reverse
            low = p + 1
        Else
            ' 右のみ再帰
            QuickSort_WithOrderSimple arr, keyShadow, orderIdx, p + 1, high, reverse
            high = p
        End If
    Loop
End Sub

' Hoare partition with strict < and >, pivot = middle element
' パーティション：左グループと右グループに振り分ける処理
' 同値のときは orderIdx（元の行番号）でタイブレーク（最終判定）
Private Function Partition_Simple(ByRef arr As Variant, ByRef keyShadow() As String, _
                                    ByRef orderIdx() As Long, ByVal low As Long, _
                                    ByVal high As Long, ByVal reverse As Boolean) As Long

    ' ピボットを中央に寄せる（ピボットを中央に寄せることで、パーティションの効率が向上する）
    Dim mid As Long
    mid = low + (high - low) \ 2

    Dim pivotKey As String, pivotIdx As Long
    pivotKey = keyShadow(mid) ' ピボットの値
    pivotIdx = orderIdx(mid) ' ピボットの元順

    Dim i As Long, j As Long
    i = low - 1 ' 左グループの最後のインデックス
    j = high + 1 ' 右グループの最初のインデックス

    Do
        Do
            i = i + 1 ' 左グループの最後のインデックスを1つ進める
        Loop While CompareKV(keyShadow(i), orderIdx(i), pivotKey, pivotIdx, reverse) < 0 ' ピボットより小さいものを左に寄せる

        Do
            j = j - 1 ' 右グループの最初のインデックスを1つ戻す
        Loop While CompareKV(keyShadow(j), orderIdx(j), pivotKey, pivotIdx, reverse) > 0 ' ピボットより大きいものを右に寄せる

        If i >= j Then
            Partition_Simple = j ' 右グループの最後のインデックスを返す
            Exit Function
        End If

        'スワップ（交換）
        SwapRows arr, i, j
        SwapString keyShadow, i, j
        SwapIdx orderIdx, i, j
    Loop
End Function

Private Function CompareKV(ByVal keyA As String, ByVal idxA As Long, _
                            ByVal keyB As String, ByVal idxB As Long, _
                            ByVal reverse As Boolean) As Long
    Dim diff As Long
    diff = StrComp(keyA, keyB, vbBinaryCompare)
    If reverse Then diff = -diff

    If diff = 0 Then
        If idxA > idxB Then
            CompareKV = 1
        ElseIf idxA < idxB Then
            CompareKV = -1
        Else
            CompareKV = 0
        End If
    Else
        CompareKV = diff
    End If
End Function

' Swaps
Private Sub SwapRows(ByRef arr As Variant, ByVal row1 As Long, ByVal row2 As Long)
    If row1 = row2 Then Exit Sub
    Dim c As Long, tmp As Variant
    For c = LBound(arr, 2) To UBound(arr, 2)
        tmp = arr(row1, c)
        arr(row1, c) = arr(row2, c)
        arr(row2, c) = tmp
    Next c
End Sub

Private Sub SwapString(ByRef v() As String, ByVal i As Long, ByVal j As Long)
    If i = j Then Exit Sub
    Dim t As String
    t = v(i): v(i) = v(j): v(j) = t
End Sub

Private Sub SwapIdx(ByRef orderIdx() As Long, ByVal i As Long, ByVal j As Long)
    If i = j Then Exit Sub
    Dim t As Long
    t = orderIdx(i): orderIdx(i) = orderIdx(j): orderIdx(j) = t
End Sub

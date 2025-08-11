' ーーー 型とヘルパー ーーー
Private Type RowPtr
    src As Long   ' どのソース（0..k-1）
    idx As Long   ' そのソース内の行インデックス
End Type

Private Function CmpKey( _
    ByVal aKey As String, ByVal aPri As Long, ByVal aIdx As Long, _
    ByVal bKey As String, ByVal bPri As Long, ByVal bIdx As Long, _
    ByVal reverse As Boolean) As Long

    Dim d As Long
    d = StrComp(aKey, bKey, vbBinaryCompare)
    If d = 0 Then
        If aPri < bPri Then d = -1 ElseIf aPri > bPri Then d = 1 Else d = 0
        If d = 0 Then
            If aIdx < bIdx Then d = -1 ElseIf aIdx > bIdx Then d = 1 Else d = 0
        End If
    End If
    If reverse Then d = -d
    CmpKey = d
End Function

' ーーー k-way マージ：順序（ポインタ列）だけ決める ーーー
' sources(s)   : 各ソースの2次元配列（行×列）※GetRowsでOK
' keyCol(s)    : 各ソース内でのキー列（絶対列）
' srcPri(s)    : ソース優先度（小さいほど先）
' outOrder()   : 返り値（RowPtr配列）…最終の行順ポインタ
Public Sub KWayMergeOrder( _
        ByRef sources() As Variant, _
        ByRef keyCol() As Long, _
        ByRef srcPri() As Long, _
        ByVal reverse As Boolean, _
        ByRef outOrder() As RowPtr)

    Dim k As Long: k = UBound(sources) - LBound(sources) + 1
    Dim heads() As Long, ends() As Long, s As Long
    ReDim heads(0 To k - 1): ReDim ends(0 To k - 1)

    Dim total As Long: total = 0
    For s = 0 To k - 1
        heads(s) = LBound(sources(s), 1)
        ends(s) = UBound(sources(s), 1)
        total = total + (ends(s) - heads(s) + 1)
    Next

    ReDim outOrder(1 To total)
    Dim t As Long: t = 1

    Do While t <= total
        Dim bestS As Long: bestS = -1
        Dim bestKey As String, bestPri As Long, bestIdx As Long

        For s = 0 To k - 1
            If heads(s) <= ends(s) Then
                Dim keyS As String
                keyS = CStr(sources(s)(heads(s), keyCol(s)))
                If bestS = -1 Then
                    bestS = s: bestKey = keyS
                    bestPri = srcPri(s): bestIdx = heads(s)
                Else
                    If CmpKey(keyS, srcPri(s), heads(s), bestKey, bestPri, bestIdx, reverse) < 0 Then
                        bestS = s: bestKey = keyS
                        bestPri = srcPri(s): bestIdx = heads(s)
                    End If
                End If
            End If
        Next

        outOrder(t).src = bestS
        outOrder(t).idx = heads(bestS)
        heads(bestS) = heads(bestS) + 1
        t = t + 1
    Loop
End Sub

' ーーー 250列の最終配列を構築（存在列だけ写す）ーーー
' colMap(s) : Dictionary（sourceの列名→最終列Index 1..250）。ない列は持たない
Public Sub Materialize250( _
        ByRef outOrder() As RowPtr, _
        ByRef sources() As Variant, _
        ByRef colMap() As Object, _
        ByVal totalCols As Long, _
        ByRef result As Variant)

    Dim n As Long: n = UBound(outOrder)
    ReDim result(1 To n, 1 To totalCols)

    Dim t As Long, s As Long, r As Long, key As Variant, dstCol As Long
    Dim it As Variant

    For t = 1 To n
        s = outOrder(t).src
        r = outOrder(t).idx
        ' そのソースに存在する列だけコピー
        For Each it In colMap(s).Keys
            dstCol = CLng(colMap(s)(it))
            result(t, dstCol) = sources(s)(r, CLng(it))  ' it を“source側の列インデックス”で持たせる設計
        Next
        ' ない列は既定値(Null)のまま
    Next
End Sub

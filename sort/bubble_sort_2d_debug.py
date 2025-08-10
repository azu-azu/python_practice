def bubble_sort_2d(rows, key_index=0, reverse=False):
    n = len(rows)
    print("🔰 bubble_sort_2d:", rows)

    order = "降順" if reverse else "昇順"

    print(f"  基準列: {key_index} / 並び: {order}")
    print("------------------------------")

    if n == 0:
        print("🔺 Result 🎉", rows)
        return rows

    # 前提チェック
    if not all(isinstance(r, (list, tuple)) for r in rows):
        raise TypeError("全ての要素はリストまたはタプルである必要があります")
    if not all(len(r) > key_index for r in rows):
        raise IndexError(f"key_index={key_index} が存在しない行があります")

    # 比較ロジック：swapが必要か
    # 昇順: 「左 > 右」ならスワップが必要（小さい順に並べる）
    # 降順: 「左 < 右」ならスワップが必要（大きい順に並べる）
    def need_swap(left_key, right_key, reverse_: bool) -> bool:
        return (left_key > right_key) if not reverse_ else (left_key < right_key)

    for i in range(n):
        print(f"🔻 {i + 1}")
        swapped = False


        # --「隣同士を比較する」ためには n-1-i 回ループが必要 --
        # 配列が0始まりだから、要素数nに対して最後のインデックスは n-1 になる
        # もし range(n-i) とすると、j=n-i-1 のとき [j+1]=n-i となり、インデックスが範囲外になる
        for j in range(n - 1 - i):

            # [j] と [j+1] （隣り合う要素）を比較する
            left_key = rows[j][key_index]
            right_key = rows[j + 1][key_index]

            print(
                f"  比較: {rows[j]} vs {rows[j + 1]} (key {left_key} vs {right_key})",
                end="  ",
            )

            if need_swap(left_key, right_key, reverse):
                rows[j], rows[j + 1] = rows[j + 1], rows[j]
                swapped = True
                print(f"→ Swap！ => {rows}")
            else:
                print("→ そのまま   ")

        if not swapped:
            print("🈚️ nothing！")
            break
        print(f"🔺 {rows}")
        print("------------------------------")

    print("🔺 Result 🎉", rows)
    return rows


# ---------- 実行用テスト ----------
if __name__ == "__main__":
    test_rows = [
        [5, "a"],
        [3, "b"],
        [8, "c"],
        [4, "d"],
        [2, "e"],
    ]

    # 0列目で昇順
    bubble_sort_2d(
        [row.copy() if isinstance(row, list) else list(row) for row in test_rows],
        key_index=0,
        reverse=False,
    )
    # 0列目で降順
    bubble_sort_2d(
        [row.copy() if isinstance(row, list) else list(row) for row in test_rows],
        key_index=0,
        reverse=True,
    )

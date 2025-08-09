def quick_sort_2d(rows, key_index=0, reverse=False):
    """In-place quick sort with debug logs for 2D arrays.

    Sorts by the specified key_index; set reverse=True for descending.
    Stable? No. Quick sort is generally not stable with this partition scheme.

    指定されたkey_indexでソートします。降順でソートするにはreverse=Trueを設定してください。

    ⭐️ 安定性（同値の順序を維持する）が不要な場合：クイックソートでOK

    「同じキーの並び順が変わったら困る」場面では使わない方がいい。
    同じキー値の行があると順序が入れ替わることがあるため。
    特に2D配列を特定の列でソートして、その後別の列も参照する場合に影響する
    """

    print("🔰 quick_sort_2d:", rows)
    order = "降順" if reverse else "昇順"

    print(f"  基準列: {key_index} / 並び: {order}")
    print("------------------------------")

    # 前提チェック①：各行が list か tuple でなければエラー
    if not all(isinstance(r, (list, tuple)) for r in rows):
        raise TypeError("全ての要素はリストまたはタプルである必要があります")

    # 前提チェック②：指定列 key_index が各行にちゃんと存在するか確認。なければ IndexError。
    if not all(len(r) > key_index for r in rows):
        raise IndexError(f"key_index={key_index} が存在しない行があります")

    # row（1行）から指定列の値を取り出す
    def key_of(row):
        return row[key_index]

    # 比較ロジック
    def need_swap(a, b):
        ka, kb = key_of(a), key_of(b)

        # [昇順なら ka <= kb / 降順なら ka >= kb] がtrueかどうか
        # 「= を含める」ので等値が多いデータは偏りやすく最悪 O(n²) に落ちやすい点に注意（実装簡単さとのトレードオフ）。
        return (ka <= kb) if not reverse else (ka >= kb)

    # 末尾 high をピボットに採用
    def partition(a, low, high):
        pivot = a[high]
        pivot_key = key_of(pivot)
        print(f"pivot={pivot} (key={pivot_key}) @ index {high}")

        # 最初は「lowの左」に置くため -1
        i = low - 1

        # low..high-1 を走査して、各要素を「ピボット（のキー）と比較」
        # Pythonは上端“含まない”から、high で high -1 までとなる
        for j in range(low, high):
            left_row = a[j]
            left_key = key_of(left_row)
            op = ">=" if reverse else "<="

            print(f"  compare key({left_row})={left_key} {op} pivot_key({pivot_key})?", end="  ")

            # need_swapなら i を進める & その位置と j をスワップする
            if need_swap(left_row, pivot):
                i += 1
                a[i], a[j] = a[j], a[i]
                print(f"→ Swap i={i}, j={j} => {a}")
            else:
                print("→ そのまま")

        # 走査終了：ピボットを左グループの右（i+1）に移動する
        a[i + 1], a[high] = a[high], a[i + 1]

        print(f"place pivot to index {i + 1} => {a}")
        print("------------------------------")
        return i + 1

    # ⭐️ クイックソート本体（再帰）。範囲が2要素以上なら処理する
    def quicksort(a, low, high, depth=0):
        if low < high:
            print(f"📦 partition: low={low}, high={high}, depth={depth}")

            # パーティション実行してピボット位置 p を確定。
            p = partition(a, low, high)

            # depth+1 はログ用の深さ。
            quicksort(a, low, p - 1, depth + 1)
            quicksort(a, p + 1, high, depth + 1)

    quicksort(rows, 0, len(rows) - 1)
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
    quick_sort_2d([row.copy() if isinstance(row, list) else list(row) for row in test_rows], key_index=0, reverse=False)
    # 0列目で降順
    quick_sort_2d([row.copy() if isinstance(row, list) else list(row) for row in test_rows], key_index=0, reverse=True)

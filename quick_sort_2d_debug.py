def quick_sort_2d(rows, key_index=0, reverse=False):
    """In-place quick sort with debug logs for 2D arrays.

    Sorts by the specified key_index; set reverse=True for descending.
    Stable? No. Quick sort is generally not stable with this partition scheme.
    """
    print("🔰 quick_sort_2d:", rows)
    order = "降順" if reverse else "昇順"

    print(f"  基準列: {key_index} / 並び: {order}")
    print("------------------------------")

    if not all(isinstance(r, (list, tuple)) for r in rows):
        raise TypeError("全ての要素はリストまたはタプルである必要があります")
    if not all(len(r) > key_index for r in rows):
        raise IndexError(f"key_index={key_index} が存在しない行があります")

    def key_of(row):
        return row[key_index]

    def need_swap(a, b):
        ka, kb = key_of(a), key_of(b)
        return (ka <= kb) if not reverse else (ka >= kb)

    def partition(a, low, high):
        pivot = a[high]
        pivot_key = key_of(pivot)
        print(f"pivot={pivot} (key={pivot_key}) @ index {high}")

        i = low - 1
        for j in range(low, high):
            left_row = a[j]
            left_key = key_of(left_row)
            op = ">=" if reverse else "<="
            print(f"  compare key({left_row})={left_key} {op} pivot_key({pivot_key})?", end="  ")

            if need_swap(left_row, pivot):
                i += 1
                a[i], a[j] = a[j], a[i]
                print(f"→ Swap i={i}, j={j} => {a}")
            else:
                print("→ そのまま")

        a[i + 1], a[high] = a[high], a[i + 1]

        print(f"place pivot to index {i + 1} => {a}")
        print("------------------------------")
        return i + 1

    def quicksort(a, low, high, depth=0):
        if low < high:
            print(f"📦 partition: low={low}, high={high}, depth={depth}")

            p = partition(a, low, high)
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

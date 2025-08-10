def quick_sort_debug(arr):
    """In-place quick sort with verbose debug logs (1D)."""
    print("🔰 quick_sort:", arr)
    print("------------------------------")

    def partition(a, low, high):
        pivot = a[high]
        print(f"pivot={pivot} @ index {high}")
        i = low - 1
        for j in range(low, high):
            print(f"  compare a[{j}]={a[j]} <= pivot({pivot})?", end="  ")
            if a[j] <= pivot:
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

    quicksort(arr, 0, len(arr) - 1)
    print("🔺 Result 🎉", arr)
    return arr


# ---------- 実行用テスト ----------
if __name__ == "__main__":
    test_data = [5, 3, 8, 4, 2]
    quick_sort_debug(test_data.copy())

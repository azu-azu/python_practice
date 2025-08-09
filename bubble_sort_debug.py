def bubble_sort(arr):
    n = len(arr)
    print("🔰 bubble_sort:", arr)
    print("------------------------------")

    for i in range(n):
        print(f"🔻 {i + 1}")
        swapped = False

        # jは 0 〜 3 の4回ループ（n = 5 なので、range(4)）
        for j in range(n - 1 - i):
            print(f"  比較: {arr[j]} vs {arr[j + 1]}", end="  ")

            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swapped = True
                print(f"→ Swap！ => {arr}")
            else:
                print("→ そのまま   ")

        if not swapped:
            print("🈚️ nothing！")
            break
        print(f"🔺 {arr}")
        print("------------------------------")

    print("🔺 Result 🎉", arr)
    return arr

# ---------- 実行用テスト ----------
if __name__ == "__main__":
    test_data = [5, 3, 8, 4, 2]
    bubble_sort(test_data.copy())

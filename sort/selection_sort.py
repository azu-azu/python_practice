def selection_sort_debug(A):
    N = len(A)

    print("🔰 selection_sort:", A)
    print("------------------------------")

    for i in range(N -1):
        print(f"\n{i+1}回目: i={i}  現在の配列: {A}")

        min_position = i
        min_value = A[i]

        print(f"  初期min_position={min_position}, min_value={min_value}")

        for j in range(i +1, N):
            print(f"    比較: A[{j}]={A[j]} と min_value={min_value}", end="  ")

            if A[j] < min_value:
                min_position = j
                min_value = A[j]

                print(f"→ 更新! 新しいmin_position={min_position}, min_value={min_value}")
            else:
                print("→ そのまま")

        if min_position != i:
            print(f"  スワップ: A[{i}]={A[i]} と A[{min_position}]={A[min_position]} を交換")
        else:
            print(f"  スワップなし: すでに最小値がA[{i}]={A[i]}")

        # タプルのアンパック
        # 1行で、A[i]の値とA[j]の値を同時に入れ替えることができる
        # → vbaのようにtmpを用意する必要がない
        A[i], A[min_position] = A[min_position], A[i]

        print(f"  結果: {A}")
        print("------------------------------")
    print("\n🔺 Result 🎉", A)
    return A

# テストコード
if __name__ == "__main__":
    print("\n===== テスト1: 昇順 =====")
    arr1 = [5, 3, 8, 4, 2]
    selection_sort_debug(arr1.copy())

    print("\n===== テスト2: 降順 =====")
    arr2 = [9, 7, 5, 3, 1]
    selection_sort_debug(arr2.copy())

    print("\n===== テスト3: 重複あり =====")
    arr3 = [4, 2, 2, 8, 4]
    selection_sort_debug(arr3.copy())

    print("\n===== テスト4: すでにソート済み =====")
    arr4 = [1, 2, 3, 4, 5]
    selection_sort_debug(arr4.copy())

    print("\n===== テスト5: すべて同じ値 =====")
    arr5 = [7, 7, 7, 7, 7]
    selection_sort_debug(arr5.copy())

    # --- 元の標準入力バージョンも残す ---
    print("\n===== 標準入力バージョン =====")
    N = int(input("N: ")) # 配列の要素数を入力として受け取る
    A = list(map(int, input("A: ").split())) # 配列の要素をスペース区切りで入力し、整数のリストに変換する
    selection_sort_debug(A)
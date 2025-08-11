from combine_sorted_arrays import combine_sorted_arrays

def merge_sort(arr):
    """
    マージソートのメイン関数
    分割統治法に基づいて配列をソートする

    Args:
        arr (list): ソート対象の配列

    Returns:
        list: ソートされた配列
    """
    # ベースケース：配列の長さが1以下ならそのまま返す
    if len(arr) <= 1:
        return arr

    # 分割：配列を2つの半分に分割
    mid = len(arr) // 2
    left = arr[:mid]      # 前半部分
    right = arr[mid:]     # 後半部分

    # 再帰的にソート
    left_sorted = merge_sort(left)   # 列Aをマージソート → A'
    right_sorted = merge_sort(right) # 列Bをマージソート → B'

    # マージ：ソートされた2つの配列をマージ
    return combine_sorted_arrays(left_sorted, right_sorted)


def merge_sort_main(numbers):
    """
    N個の数に対してマージソートを実行するメイン関数

    Args:
        numbers (list): ソート対象の数値のリスト [A1, A2, ..., An]

    Returns:
        list: ソートされた数値のリスト
    """
    print(f"元の配列: {numbers}")
    sorted_numbers = merge_sort(numbers.copy())  # 元の配列を変更しないようにコピー
    print(f"ソート後: {sorted_numbers}")
    return sorted_numbers


if __name__ == "__main__":
    # テストケース1: 基本的な配列
    test_array1 = [64, 34, 25, 12, 22, 11, 90]
    print("=== テストケース1 ===")
    merge_sort_main(test_array1)

    print("\n" + "="*50 + "\n")

    # テストケース2: 既にソート済みの配列
    test_array2 = [1, 2, 3, 4, 5]
    print("=== テストケース2 ===")
    merge_sort_main(test_array2)

    print("\n" + "="*50 + "\n")

    # テストケース3: 逆順の配列
    test_array3 = [5, 4, 3, 2, 1]
    print("=== テストケース3 ===")
    merge_sort_main(test_array3)

    print("\n" + "="*50 + "\n")

    # テストケース4: 重複要素を含む配列
    test_array4 = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3, 5]
    print("=== テストケース4 ===")
    merge_sort_main(test_array4)

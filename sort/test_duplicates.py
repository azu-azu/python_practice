from combine_sorted_arrays import combine_sorted_arrays

def test_duplicates():
    """同値がある場合のテスト"""
    print("=== 同値がある場合のテスト ===\n")

    # テストケース1: 基本的な同値
    array_a1 = [1, 3, 3, 5]
    array_b1 = [2, 3, 4, 6]
    print(f"array_a: {array_a1}")
    print(f"array_b: {array_b1}")
    result1 = combine_sorted_arrays(array_a1, array_b1)
    print(f"結果: {result1}")
    print()

    # テストケース2: 多くの同値
    array_a2 = [1, 1, 2, 2, 3]
    array_b2 = [1, 2, 2, 3, 3]
    print(f"array_a: {array_a2}")
    print(f"array_b: {array_b2}")
    result2 = combine_sorted_arrays(array_a2, array_b2)
    print(f"結果: {result2}")
    print()

    # テストケース3: 片方のみ同値
    array_a3 = [1, 2, 3]
    array_b3 = [1, 1, 2, 2, 3, 3]
    print(f"array_a: {array_a3}")
    print(f"array_b: {array_b3}")
    result3 = combine_sorted_arrays(array_a3, array_b3)
    print(f"結果: {result3}")
    print()

    # テストケース4: すべて同値
    array_a4 = [5, 5, 5]
    array_b4 = [5, 5, 5, 5]
    print(f"array_a: {array_a4}")
    print(f"array_b: {array_b4}")
    result4 = combine_sorted_arrays(array_a4, array_b4)
    print(f"結果: {result4}")

if __name__ == "__main__":
    test_duplicates()

#!/usr/bin/env python3
"""
多重代入 a, b = b, a % b の動作確認
"""

def test_multiple_assignment():
    """多重代入の動作を詳しく確認"""
    print("=== 多重代入 a, b = b, a % b の動作確認 ===")
    print()

    # テストケース
    test_cases = [(12, 18), (100, 200)]

    for A, B in test_cases:
        print(f"テストケース: GCD({A}, {B})")
        print("-" * 50)

        a, b = A, B
        step = 1

        while b != 0:
            print(f"ステップ {step}:")
            print(f"  現在の値: a = {a}, b = {b}")

            # 右辺の計算を詳しく表示
            old_a, old_b = a, b
            right_b = b
            right_a_mod_b = a % b

            print(f"  右辺の計算:")
            print(f"    b = {right_b}")
            print(f"    a % b = {old_a} % {old_b} = {right_a_mod_b}")

            # 多重代入
            a, b = right_b, right_a_mod_b

            print(f"  多重代入: a, b = {right_b}, {right_a_mod_b}")
            print(f"  次の値: a = {a}, b = {b}")
            print()

            step += 1

        print(f"最終結果: GCD({A}, {B}) = {a}")
        print("=" * 50)
        print()

def test_wrong_way():
    """間違った書き方の例"""
    print("=== 間違った書き方の例 ===")
    print()

    a, b = 12, 18
    print(f"初期値: a = {a}, b = {b}")

    print("\n❌ 間違った書き方:")
    print("a = b")
    print("b = a % b")
    print()

    # 間違った書き方
    a = b
    print(f"a = b の後: a = {a}, b = {b}")

    b = a % b
    print(f"b = a % b の後: a = {a}, b = {b}")
    print("→ 間違った結果！")
    print()

def test_correct_way():
    """正しい書き方の例"""
    print("=== 正しい書き方の例 ===")
    print()

    a, b = 12, 18
    print(f"初期値: a = {a}, b = {b}")

    print("\n✅ 正しい書き方:")
    print("a, b = b, a % b")
    print()

    # 正しい書き方
    a, b = b, a % b
    print(f"a, b = b, a % b の後: a = {a}, b = {b}")
    print("→ 正しい結果！")
    print()

if __name__ == "__main__":
    test_multiple_assignment()
    test_wrong_way()
    test_correct_way()

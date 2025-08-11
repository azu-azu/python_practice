#!/usr/bin/env python3
"""
ユークリッドの互除法の動作をステップバイステップで確認
"""

def gcd_euclidean_step_by_step(a, b):
    """ユークリッドの互除法の動作を詳しく表示"""
    print(f"ユークリッドの互除法: GCD({a}, {b})")
    print("=" * 50)

    step = 1
    original_a, original_b = a, b

    while b:
        print(f"ステップ {step}:")
        print(f"  a = {a}, b = {b}")
        print(f"  a % b = {a} % {b} = {a % b}")

        # 次のステップの準備
        next_a = b
        next_b = a % b

        print(f"  次のステップ: a = {next_a}, b = {next_b}")
        print()

        # 値を更新
        a, b = next_a, next_b
        step += 1

    print(f"最終結果: GCD({original_a}, {original_b}) = {a}")
    return a

def gcd_original_step_by_step(A, B):
    """元のGCD関数の動作を詳しく表示"""
    print(f"元のGCD関数: GCD({A}, {B})")
    print("=" * 50)

    answer = 0
    divisors = []

    for i in range(1, min(A, B) + 1):
        is_divisor_a = A % i == 0
        is_divisor_b = B % i == 0
        is_common_divisor = is_divisor_a and is_divisor_b

        print(f"i = {i}:")
        print(f"  {A} % {i} = {A % i} {'✓' if is_divisor_a else '✗'}")
        print(f"  {B} % {i} = {B % i} {'✓' if is_divisor_b else '✗'}")

        if is_common_divisor:
            answer = i
            divisors.append(i)
            print(f"  → 公約数発見！現在の最大公約数: {answer}")
        else:
            print(f"  → 公約数ではない")
        print()

    print(f"見つかった公約数: {divisors}")
    print(f"最終結果: GCD({A}, {B}) = {answer}")
    return answer

def gcd_euclidean_user_version(A, B):
    """ユーザーが提案したユークリッドの互除法の実装"""
    print(f"ユーザー版ユークリッド: GCD({A}, {B})")
    print("=" * 50)

    step = 1
    original_A, original_B = A, B

    while A >= 1 and B >= 1:
        print(f"ステップ {step}:")
        print(f"  A = {A}, B = {B}")

        if A < B:
            old_B = B
            B = B % A
            print(f"  A({A}) < B({old_B}) → B = {old_B} % {A} = {B}")
        else:
            old_A = A
            A = A % B
            print(f"  A({old_A}) >= B({B}) → A = {old_A} % {B} = {A}")

        print(f"  次のステップ: A = {A}, B = {B}")
        print()
        step += 1

    # 結果の決定
    if A >= 1:
        result = A
        print(f"最終結果: GCD({original_A}, {original_B}) = {A}")
    else:
        result = B
        print(f"最終結果: GCD({original_A}, {original_B}) = {B}")

    return result

def compare_all_methods():
    """全ての方法を比較"""
    test_cases = [(12, 18), (100, 200)]

    for A, B in test_cases:
        print("=" * 80)
        print(f"テストケース: ({A}, {B})")
        print("=" * 80)
        print()

        # 元のGCD関数
        result1 = gcd_original_step_by_step(A, B)
        print()

        # 現在のユークリッドの互除法
        result2 = gcd_euclidean_step_by_step(A, B)
        print()

        # ユーザー版ユークリッドの互除法
        result3 = gcd_euclidean_user_version(A, B)
        print()

        # 結果の比較
        print("結果の比較:")
        print(f"  元のGCD: {result1}")
        print(f"  現在のユークリッド: {result2}")
        print(f"  ユーザー版ユークリッド: {result3}")
        print(f"  全て一致: {'✓' if result1 == result2 == result3 else '✗'}")
        print()
        print("-" * 80)
        print()

if __name__ == "__main__":
    compare_all_methods()

# ユークリッドの互除法を使った効率的なGCD関数
"""
ユークリッドの互除法による最大公約数の計算
時間複雑度: O(log(min(a,b)))
"""

def gcd_euclidean(a, b):
    # bが0になるまで（0じゃない間）ループする
    # while b != 0: と書いても同じ
    while b:
        # a に b の値を代入
        # b に a を b で割った余りを代入
        a, b = b, a % b

    # ループ終了後、残ったaが最大公約数
    return a

# テストコード
if __name__ == "__main__":
    import time

    # 基本的なテストケース
    basic_test_cases = [(12, 18), (100, 200), (15, 25)]

    print("=== ユークリッドの互除法によるGCD計算 ===")
    print()

    for A, B in basic_test_cases:
        result = gcd_euclidean(A, B)
        print(f"GCD({A}, {B}) = {result}")

    print()
    print("✅ 基本的なテストケースが完了しました")
    print()

    # ベンチマーク用のテストケース
    benchmark_test_cases = [
        (12, 18),
        (100, 200),
        (1000, 2000),
        (10000, 20000),
        (100000, 200000),
        (1000000, 2000000),
        (5000000, 10000000),
        (10000000, 20000000)
    ]

    print("=== ベンチマークテスト ===")
    print("=" * 60)

    for A, B in benchmark_test_cases:
        start_time = time.perf_counter()
        result = gcd_euclidean(A, B)
        end_time = time.perf_counter()
        execution_time = (end_time - start_time) * 1000  # ミリ秒

        print(f"GCD({A:8,}, {B:8,}) = {result:8,}, 実行時間: {execution_time:.3f}ms")

    print("=" * 60)
    print("✅ ベンチマークテストが完了しました")

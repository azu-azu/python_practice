#!/usr/bin/env python3
"""
詳細なGCD関数のベンチマーク比較
"""

import time
import statistics

def GCD(A, B):
    """元のGCD関数 - 線形探索"""
    answer = 0
    for i in range(1, min(A, B) + 1):
        if A % i == 0 and B % i == 0:
            answer = i
    return answer

def gcd_euclidean(a, b):
    """ユークリッドの互除法によるGCD関数"""
    while b:
        a, b = b, a % b
    return a

def benchmark_detailed():
    """詳細なベンチマーク実行"""

    # テストケース（小さい数から大きい数まで）
    test_cases = [
        (12, 18),
        (100, 200),
        (1000, 2000),
        (10000, 20000),
        (100000, 200000),
        (1000000, 2000000),
        (5000000, 10000000),
        (10000000, 20000000)
    ]

    print("=" * 80)
    print("詳細なGCD関数のベンチマーク比較")
    print("=" * 80)

    results = []

    for i, (A, B) in enumerate(test_cases, 1):
        print(f"\nテストケース {i}: ({A:,}, {B:,})")
        print("-" * 50)

        # 元のGCD関数の測定（複数回実行して平均を取る）
        times1 = []
        for _ in range(5):  # 5回実行
            start_time = time.perf_counter()
            result1 = GCD(A, B)
            end_time = time.perf_counter()
            times1.append((end_time - start_time) * 1000)

        # ユークリッドの互除法の測定（複数回実行して平均を取る）
        times2 = []
        for _ in range(5):  # 5回実行
            start_time = time.perf_counter()
            result2 = gcd_euclidean(A, B)
            end_time = time.perf_counter()
            times2.append((end_time - start_time) * 1000)

        # 結果の表示
        avg_time1 = statistics.mean(times1)
        avg_time2 = statistics.mean(times2)

        print(f"  元のGCD: {result1:,}, 平均実行時間: {avg_time1:.3f}ms")
        print(f"  ユークリッド: {result2:,}, 平均実行時間: {avg_time2:.3f}ms")

        if avg_time1 > 0 and avg_time2 > 0:
            speedup = avg_time1 / avg_time2
            print(f"  速度比: ユークリッドは {speedup:.1f}倍高速")

            # 結果を保存
            results.append({
                'case': i,
                'numbers': (A, B),
                'original_time': avg_time1,
                'euclidean_time': avg_time2,
                'speedup': speedup
            })

    # 総合結果の表示
    print("\n" + "=" * 80)
    print("総合結果")
    print("=" * 80)

    if results:
        avg_speedup = statistics.mean([r['speedup'] for r in results])
        max_speedup = max([r['speedup'] for r in results])
        min_speedup = min([r['speedup'] for r in results])

        print(f"平均速度向上: {avg_speedup:.1f}倍")
        print(f"最大速度向上: {max_speedup:.1f}倍")
        print(f"最小速度向上: {min_speedup:.1f}倍")

        # 最も効率的な改善と最も効率的でない改善を特定
        max_case = max(results, key=lambda x: x['speedup'])
        min_case = min(results, key=lambda x: x['speedup'])

        print(f"\n最も効率的な改善: テストケース {max_case['case']} ({max_case['numbers'][0]:,}, {max_case['numbers'][1]:,})")
        print(f"最も効率的でない改善: テストケース {min_case['case']} ({min_case['numbers'][0]:,}, {min_case['numbers'][1]:,})")

if __name__ == "__main__":
    benchmark_detailed()

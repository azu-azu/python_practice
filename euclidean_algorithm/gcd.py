# 正の整数 A と B の最大公約数を返す関数
# GCD は Greatest Common Divisor（最大公約数）の略
def GCD(A, B):
	answer = 0

	# 1からAとBの小さい方までループする
	for i in range(1, min(A, B) + 1):
		# iがAとBの両方の約数かどうかを判定
		if A % i == 0 and B % i == 0:
			# 条件を満たすiをanswerに記録（最大値が最終的に残る）
			answer = i
	# 最大公約数（最後に記録されたanswer）を返す
	return answer

# ベンチマーク用のテストケース
def benchmark_gcd():
    import time
    test_cases = [
        (12, 18),
        (100, 200),
        (1000, 2000),
        (10000, 20000),
        (100000, 200000),
        (1000000, 2000000)
    ]

    print("=== GCD関数のベンチマーク ===")
    for A, B in test_cases:
        start_time = time.time()
        result = GCD(A, B)
        end_time = time.time()
        execution_time = (end_time - start_time) * 1000  # ミリ秒
        print(f"GCD({A}, {B}) = {result}, 実行時間: {execution_time:.3f}ms")

# 元の入力処理（コメントアウト）
# A, B = map(int, input().split())
# print(GCD(A, B))

if __name__ == "__main__":
    benchmark_gcd()

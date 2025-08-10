
"""
階乗（factorial）とは？
例：5の階乗（5!）は「5 × 4 × 3 × 2 × 1 = 120」
Nの階乗（N!）は「N × (N-1) × (N-2) × ... × 1」と定義される

再帰関数の定義
再帰関数とは、自分自身を呼び出す関数のことです。
再帰関数を使うと、複雑な問題を簡単に解くことができます。
再帰関数を使うときは、必ずベースケースを設定してください。
ベースケースとは、再帰関数が停止する条件のことです。
ベースケースを設定しないと、再帰関数は無限に呼び出されてしまいます。
"""

def factorial(N, _first_call=True):
	if _first_call:
		print(f"\n計算する値: {N}")

	if N <= 1:
		print(f"factorial(1) 🏁ベースケース（往路ゴール）!!")
		return 1

    # 再帰呼び出し：「N の階乗 = (N-1) の階乗 × N」という再帰的な定義
    # call時には計算はせず、封筒にやることリストを入れていくイメージ
	print(f"factorial({N}) 📩{N}を封筒に入れる")
	result = factorial(N - 1, False) * N

	print(f"factorial({N - 1}) * {N} = {result} 📨{N}を開封")
	return result

# N = int(input())
# print(factorial(N))

def test_factorial():
    # factorial(1) の値が x であることを確認する。もし違っていたらエラーになる
	assert factorial(1) == 1
	assert factorial(2) == 2
	assert factorial(3) == 6
	assert factorial(4) == 24
	assert factorial(5) == 120
	print("\n✅すべてのテストを通過しました")

# テストを実行したい場合は以下を有効化
test_factorial()



# Python では、呼び出せる再帰関数の深さに上限が設定されており、デフォルトでは 1000 などの深さに設定されています。
# この上限は、sys.getrecursionlimit() を呼び出すことで取得できます。
# 一方、sys.setrecursionlimit(depth) を呼び出すことで、再帰呼び出しの深さ depth の上限を変えることができます。
# （これらの機能を使うためには、最初に import sys と書く必要があります）
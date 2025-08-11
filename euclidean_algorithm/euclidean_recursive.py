def GCD(A, B, _first_call=True, input_values=None):
    if _first_call:
        input_values = (A, B)
        print(f"\n計算する値: GCD({A}, {B})")

    # ベースケースの場合は終了
    if B == 0:
        print(f"‼️  B = {B} = ベースケース（往路ゴール）‼️")
        print(f"🎯 最大公約数: {A}")
        return A  # ベースケースの場合はAを返す

    # 再帰呼び出し：「GCD(A, B) = GCD(B, A % B)」という再帰的な定義
    # call時には計算はせず、封筒にやることリストを入れていくイメージ
    print(f"📩 mission GCD({A}, {B}) を格納")
    print(f"   計算: {A} % {B} = {A % B}")

    prev_result = GCD(B, A % B, False, input_values)

    print(f"📨 mission GCD({A}, {B}) を遂行：結果 = {prev_result}")

    if _first_call:
        print(f"\n🎉 GCD({input_values[0]}, {input_values[1]})の計算完了：{prev_result}")

    return prev_result

# テスト用の関数
def test_gcd():
    test_cases = [(12, 18), (100, 200), (15, 25)]

    for A, B in test_cases:
        print("=" * 60)
        result = GCD(A, B)
        print(f"最終結果: GCD({A}, {B}) = {result}")
        print("=" * 60)
        print()

if __name__ == "__main__":
    # テストを実行
    test_gcd()

    # ユーザー入力を受け取る場合（コメントアウト）
    # A, B = map(int, input().split())
    # print(GCD(A, B))
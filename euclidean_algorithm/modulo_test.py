# �� 呼び方の整理
# % - プログラミングでの記号
# mod - 数学での呼び方
# 剰余演算子 - 日本語での正式名称
# モジュロ演算子 - 英語での正式名称

#!/usr/bin/env python3
"""
剰余演算子（%）の動作確認
"""

print("=== 剰余演算子（%）の動作確認 ===")
print()

# 基本的な剰余の計算
print("基本的な剰余の計算:")
print(f"7 % 3 = {7 % 3}")      # 7 ÷ 3 = 2 余り 1
print(f"10 % 4 = {10 % 4}")    # 10 ÷ 4 = 2 余り 2
print(f"15 % 5 = {15 % 5}")    # 15 ÷ 5 = 3 余り 0
print(f"8 % 2 = {8 % 2}")      # 8 ÷ 2 = 4 余り 0
print()

# 負の数の場合の動作
print("負の数の場合:")
print(f"-7 % 3 = {-7 % 3}")    # Python: 2, 数学的mod: 2
print(f"-10 % 4 = {-10 % 4}")  # Python: 2, 数学的mod: 2
print(f"7 % -3 = {7 % -3}")    # Python: -2, 数学的mod: 1
print(f"10 % -4 = {10 % -4}")  # Python: -2, 数学的mod: 2
print()

# GCD関数での使用例
print("GCD関数での使用例:")
A = 12
B = 18

print(f"A = {A}, B = {B}")
print("Aの約数を調べる:")

for i in range(1, A + 1):
    remainder = A % i
    is_divisor = (remainder == 0)
    status = "✓ 約数" if is_divisor else "✗ 約数ではない"
    print(f"  {A} % {i} = {remainder} → {status}")

print()
print("Bの約数を調べる:")

for i in range(1, B + 1):
    remainder = B % i
    is_divisor = (remainder == 0)
    status = "✓ 約数" if is_divisor else "✗ 約数ではない"
    print(f"  {B} % {i} = {remainder} → {status}")

print()
print("共通の約数（公約数）:")
common_divisors = []
for i in range(1, min(A, B) + 1):
    if A % i == 0 and B % i == 0:
        common_divisors.append(i)
        print(f"  {i} (A%{i}={A%i}, B%{i}={B%i})")

print(f"最大公約数: {max(common_divisors)}")

print()
print("=== Pythonの%と数学的modの違い ===")
print("正の数の場合:")
print("Python: 7 % 3 = 1")
print("数学: 7 mod 3 = 1")
print("→ 同じ結果")

print()
print("負の数の場合:")
print("Python: -7 % 3 = 2")
print("数学: -7 mod 3 = 2")
print("→ 同じ結果")

print()
print("Python: 7 % -3 = -2")
print("数学: 7 mod -3 = 1")
print("→ 異なる結果！")

print()
print("結論: 正の数での約数判定には、どちらも同じ結果になります！")

#!/usr/bin/env python3

'''
## 🌍 **他のプログラミング言語での比較**

| 言語 | 書き方 | 例 |
|------|--------|-----|
| **VBA** | `Mod` | `A Mod B` |
| **Python** | `%` | `A % B` |
| **C/C++/Java** | `%` | `A % B` |
| **JavaScript** | `%` | `A % B` |
| **Excel** | `MOD()` | `=MOD(A,B)` |

## �� **なぜこの違いがあるのか？**

1. **VBA**: 数学の記法に近い（`Mod`キーワード）
2. **Python**: プログラミングの慣習（`%`記号）
3. **どちらも正しい** - 言語の設計思想の違い

- **VBA**: `A Mod i = 0`
- **Python**: `A % i == 0`
- **数学**: `A mod i = 0`

### **🌟 言語による違いの理由**

1. **VBA**: ビジネスアプリケーション向け、数学的記法に近い
2. **Python**: プログラミング言語、記号を使った簡潔な書き方
3. **どちらも正しい** - 設計思想の違い

### **💡 実用的なメリット**

**Pythonの`%`記号の利点：**
- タイピングが少ない（`Mod` vs `%`）
- 他の言語（C, Java, JavaScript）と同じ記法
- 数学の記法とも一致

**VBAの`Mod`キーワードの利点：**
- 読みやすい（英語として理解しやすい）
- 初心者にも分かりやすい



"""
VBA vs Python のmod演算子比較
"""

def gcd_vba_style(A, B):
    """VBA風の書き方（Modキーワードの代わりに%を使用）"""
    answer = 0
    for i in range(1, min(A, B) + 1):
        # VBA: If A Mod i = 0 And B Mod i = 0 Then
        # Python: if A % i == 0 and B % i == 0:
        if A % i == 0 and B % i == 0:
            answer = i
    return answer

def gcd_python_style(A, B):
    """Python風の書き方（%記号を使用）"""
    answer = 0
    for i in range(1, min(A, B) + 1):
        if A % i == 0 and B % i == 0:
            answer = i
    return answer

def gcd_math_style(A, B):
    """数学風の書き方（mod関数を模擬）"""
    def mod(a, b):
        """数学的なmod関数"""
        return a % b if b > 0 else a % abs(b)

    answer = 0
    for i in range(1, min(A, B) + 1):
        # 数学: A mod i = 0 and B mod i = 0
        if mod(A, i) == 0 and mod(B, i) == 0:
            answer = i
    return answer

# テスト実行
if __name__ == "__main__":
    print("=== VBA vs Python のmod演算子比較 ===")
    print()

    test_cases = [(12, 18), (100, 200), (1000, 2000)]

    for A, B in test_cases:
        print(f"テストケース: ({A}, {B})")
        print("-" * 40)

        result1 = gcd_vba_style(A, B)
        result2 = gcd_python_style(A, B)
        result3 = gcd_math_style(A, B)

        print(f"VBA風:     GCD({A}, {B}) = {result1}")
        print(f"Python風:  GCD({A}, {B}) = {result2}")
        print(f"数学風:    GCD({A}, {B}) = {result3}")

        # 結果が同じかチェック
        if result1 == result2 == result3:
            print("✓ 全て同じ結果")
        else:
            print("✗ 結果が異なる")
        print()

    print("=" * 50)
    print("結論:")
    print("• VBA: A Mod i = 0")
    print("• Python: A % i == 0")
    print("• 数学: A mod i = 0")
    print("→ どれも同じ動作！書き方だけが違う")
    print()
    print("Pythonでは % 記号一つでVBAのModと同じことができます！")

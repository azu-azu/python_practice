#!/usr/bin/env python3
"""
while b: と while b == 0: の違いを確認
"""

def test_while_b():
    """while b: の動作確認"""
    print("=== while b: の動作確認 ===")

    b = 18
    step = 1

    while b:
        print(f"ステップ {step}: b = {b}")
        b = b % 6  # 簡単な計算
        step += 1

        if step > 10:  # 無限ループ防止
            break

    print(f"ループ終了: b = {b}")
    print()

def test_while_b_equals_0():
    """while b == 0: の動作確認"""
    print("=== while b == 0: の動作確認 ===")

    b = 18
    step = 1

    print("⚠️  注意: これは無限ループになります！")
    print("b = 18 なので、b == 0 は False")
    print("ループに入りません")

    while b == 0:
        print(f"ステップ {step}: b = {b}")
        b = b % 6
        step += 1

        if step > 10:  # 無限ループ防止
            break

    print("ループに入らなかったため、何も実行されません")
    print()

def test_boolean_values():
    """Pythonの真偽値判定を確認"""
    print("=== Pythonの真偽値判定 ===")

    test_values = [0, 1, -1, 18, 0.0, "hello", "", None, True, False]

    for value in test_values:
        bool_result = bool(value)
        print(f"{str(value):8} → {bool_result}")

    print()

def test_while_conditions():
    """while文の条件を詳しく確認"""
    print("=== while文の条件確認 ===")

    b = 18
    print(f"b = {b}")
    print()

    print("条件の評価:")
    print(f"while b:        → while {b}:        → while {bool(b)}:")
    print(f"while b != 0:   → while {b} != 0:   → while {b != 0}:")
    print(f"while b == 0:   → while {b} == 0:   → while {b == 0}:")
    print()

    print("結果:")
    print(f"while b:        → ループに入る（b = {b} は True）")
    print(f"while b != 0:   → ループに入る（{b} != 0 は True）")
    print(f"while b == 0:   → ループに入らない（{b} == 0 は False）")

if __name__ == "__main__":
    test_while_b()
    test_while_b_equals_0()
    test_boolean_values()
    test_while_conditions()

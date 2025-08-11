def combine_sorted_arrays(array_a, array_b):
    array_c = []
    i = 0
    j = 0

    # メインループ：両方の配列に要素がある間
    while i < len(array_a) and j < len(array_b):

        # どちらの配列の要素が小さいかを比較して、小さい方をretu_cに追加
        if array_a[i] < array_b[j]:
            array_c.append(array_a[i])
            i += 1
        else:
            array_c.append(array_b[j])
            j += 1

    array_c.extend(array_a[i:])
    array_c.extend(array_b[j:])
    return array_c


if __name__ == "__main__":
    array_a = [13, 34, 50, 75]
    array_b = [11, 20, 28, 62]
    array_c = combine_sorted_arrays(array_a, array_b)
    print(array_c)



'''
## 🎯 **単純なマージ処理が最も安定する理由**

### ✅ **安定性の観点から**

1. **同値の順序保持**
    - 元の配列内での同値の順序が完全に保持される
    - 複雑な処理がないため、順序が崩れるリスクがない

2. **予測可能な動作**
    - 同値の場合の処理が一貫している
    - `array_a[i] >= array_b[j]` なら必ず `array_b[j]` が先

3. **エラーの少なさ**
    - 複雑な条件分岐がない
    - バグが入り込む余地が少ない

## 🔍 **他のアプローチとの比較**

### ❌ **複雑な処理の場合**
```python
# 複雑な同値処理の例（問題あり）
if array_a[i] < array_b[j]:
    result.append(array_a[i])
    i += 1
elif array_a[i] == array_b[j]:
    # 同値の場合の特別処理
    if some_condition:  # 複雑な条件
        result.append(array_a[i])
        i += 1
    else:
        result.append(array_b[j])
        j += 1
else:
    result.append(array_b[j])
    j += 1
```

**問題点**:
- 同値処理のロジックが複雑
- 条件分岐が増える
- バグが入り込みやすい
- 順序の一貫性が保たれない可能性

### ✅ **単純なマージ処理（現在の実装）**
```python
# シンプルで安定した処理
if array_a[i] < array_b[j]:
    result.append(array_a[i])
    i += 1
else:  # array_a[i] >= array_b[j] (同値も含む)
    result.append(array_b[j])
    j += 1
```

**利点**:
- ロジックがシンプル
- 同値処理が一貫している
- バグが入り込みにくい
- 順序が完全に保持される

## 🧪 **実際の例で確認**

```python
# 入力配列（同値あり）
array_a = [1, 2, 2, 3]  # 2が2回、順序が重要
array_b = [1, 2, 3, 3]  # 2が1回、3が2回

# 単純なマージ処理
結果: [1, 1, 2, 2, 2, 3, 3, 3]
# ↑ 完全に順序が保持される
```

## 🎯 **なぜこれが最適なのか**

### 1. **数学的性質**
- ソート済み配列の性質を最大限活用
- 追加の計算や比較が不要

### 2. **実装の簡潔性**
- コードが読みやすい
- メンテナンスが容易
- テストが簡単

### 3. **パフォーマンス**
- 条件分岐が最小限
- キャッシュ効率が良い
- 予測可能な実行時間

## **まとめ**

**はい、2つの配列が既にソート済みの場合、単純なマージ処理が最も安定します。**

理由：
- ✅ **同値の順序が完全に保持される**
- ✅ **処理が一貫している**
- ✅ **バグが入り込みにくい**
- ✅ **実装がシンプル**
- ✅ **パフォーマンスが良い**

つまり、「シンプルイズベスト」がマージ処理においても当てはまるのです！複雑な処理を加えることで、かえって不安定になることが多いです。
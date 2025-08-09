def bubble_sort(arr):
    n = len(arr)

    for i in range(n):
        swapped = False

        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swapped = True

        if not swapped:
            break
    return arr

# テスト
numbers = [5, 3, 8, 4, 2]
print("Before:", numbers)

sorted_numbers = bubble_sort(numbers.copy())
print("After :", sorted_numbers)

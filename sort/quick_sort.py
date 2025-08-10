def quick_sort(arr):
    """In-place quick sort for 1D list (Lomuto partition)."""
    def partition(a, low, high):
        pivot = a[high]
        i = low - 1
        for j in range(low, high):
            if a[j] <= pivot:
                i += 1
                a[i], a[j] = a[j], a[i]
        a[i + 1], a[high] = a[high], a[i + 1]
        return i + 1

    def quicksort(a, low, high):
        if low < high:
            p = partition(a, low, high)
            quicksort(a, low, p - 1)
            quicksort(a, p + 1, high)

    quicksort(arr, 0, len(arr) - 1)
    return arr


# Demo
if __name__ == "__main__":
    numbers = [5, 3, 8, 4, 2]
    print("Before:", numbers)
    sorted_numbers = quick_sort(numbers.copy())
    print("After :", sorted_numbers)

## python_sort_practice

Practice repository for Bubble Sort. It includes a debug-friendly implementation for one-dimensional arrays and a two-dimensional version that can sort rows by any column in ascending or descending order.

### Files
- `bubble_sort.py`: Minimal implementation (no debug output, includes a simple demo)
- `bubble_sort_debug.py`: 1D array version with detailed debug logs
- `bubble_sort_2d_debug.py`: 2D array version with detailed debug logs (supports key column and sort order)

### Prerequisites
- Python 3 (on macOS, use the `python3` command)

### How to Run
- 1D with debug logs
  ```bash
  python3 bubble_sort_debug.py
  ```
- 2D with debug logs
  ```bash
  python3 bubble_sort_2d_debug.py
  ```
- Minimal (no debug logs)
  ```bash
  python3 bubble_sort.py
  ```

### Use as a Module
- 1D array
  ```python
  from bubble_sort_debug import bubble_sort

  nums = [5, 3, 8, 4, 2]
  bubble_sort(nums)  # in-place sort with debug logs
  ```

- 2D array (compare by `key_index`; use `reverse=True` for descending)
  ```python
  from bubble_sort_2d_debug import bubble_sort_2d

  rows = [
      [5, "a"],
      [3, "b"],
      [8, "c"],
      [4, "d"],
      [2, "e"],
  ]

  bubble_sort_2d(rows, key_index=0, reverse=False)  # ascending
  bubble_sort_2d(rows, key_index=0, reverse=True)   # descending
  ```

### Function Specs
- `bubble_sort(arr: list) -> list`
  - Bubble sort for a 1D list (stable, in-place)
  - Returns the same list reference

- `bubble_sort_2d(rows: list[list|tuple], key_index: int = 0, reverse: bool = False) -> list`
  - Bubble sort for a 2D array by `key_index` (stable, in-place)
  - `reverse=True` to sort in descending order
  - Preconditions: each row is a list/tuple; `key_index` exists for all rows
  - Exceptions: raises `TypeError`/`IndexError` for invalid inputs

### Notes
- Both functions sort in place (destructive). If you need the original data, pass a copy such as `list.copy()`.
- Values being compared must be mutually comparable.

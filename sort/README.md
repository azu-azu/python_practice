## python_sort_practice

Practice repository for Bubble Sort.
It includes a debug-friendly implementation for one-dimensional arrays and a two-dimensional version that
can sort rows by any column in ascending or descending order.

### Files
- `bubble_sort.py`: Minimal implementation (no debug output, includes a simple demo)
- `bubble_sort_debug.py`: 1D array version with detailed debug logs
- `bubble_sort_2d_debug.py`: 2D array version with detailed debug logs (supports key column and sort order)

### Prerequisites
- Python 3 (on macOS, use the `python3` command)

### Setup (recommended: use a virtual environment)
- macOS/Linux
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  ```

- Windows (PowerShell)
  ```powershell
  python -m venv .venv
  .venv\\Scripts\\Activate.ps1
  ```

- Deactivate the virtual environment (both platforms)
  ```bash
  deactivate
  ```

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
 - Quick sort (1D minimal)
   ```bash
   python3 quick_sort.py
   ```
 - Quick sort (1D with debug logs)
   ```bash
   python3 quick_sort_debug.py
   ```
 - Quick sort (2D with debug logs)
   ```bash
   python3 quick_sort_2d_debug.py
   ```
 - Visualization (requires matplotlib)
   ```bash
  # If not yet installed in your venv
  pip install matplotlib

   # Run with default data
   python3 visualize_bubble_sort.py

   # Custom data and speed
   python3 visualize_bubble_sort.py --data 5,3,8,4,2 --interval 300
   python3 visualize_bubble_sort.py --data 5,3,8,4,2 --reverse
   ```

### Install via requirements.txt (optional)
If you prefer installing optional visualization dependency from a file:
```bash
# Inside your activated virtual environment
pip install -r requirements.txt
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
 - For visualization, floating-point values are supported. Negative values are also handled with dynamic y-limits.

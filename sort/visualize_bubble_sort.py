#!/usr/bin/env python3
"""
Visualize Bubble Sort using matplotlib animation.

Usage examples:
  python3 visualize_bubble_sort.py --data 5,3,8,4,2 --interval 400
  python3 visualize_bubble_sort.py --data 5,3,8,4,2 --reverse

If matplotlib is not installed, the script will show an instruction message and exit.
"""
from __future__ import annotations

import argparse
import sys
from typing import Generator, Iterable, List, Optional, Tuple


def bubble_sort_states(values: Iterable[float], reverse: bool = False) -> Generator[Tuple[List[float], Optional[int], Optional[int], bool], None, None]:
    """
    Generate states of bubble sort for visualization.

    Yields tuples: (current_list, left_index, right_index, swapped)
    - current_list: current snapshot of the array (same list object, mutated)
    - left_index/right_index: indices being compared, or None when idle
    - swapped: True if the last comparison caused a swap
    """
    arr: List[float] = list(values)
    n = len(arr)

    # Initial state (no comparison yet)
    yield arr, None, None, False

    for i in range(n):
        swapped_in_pass = False
        for j in range(n - 1 - i):
            # Comparing j and j+1
            yield arr, j, j + 1, False

            left_key = arr[j]
            right_key = arr[j + 1]
            need_swap = (left_key > right_key) if not reverse else (left_key < right_key)
            if need_swap:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swapped_in_pass = True
                # After swap state
                yield arr, j, j + 1, True
        if not swapped_in_pass:
            break

    # Final state (no active comparison)
    yield arr, None, None, False


def parse_args(argv: Optional[Iterable[str]] = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Visualize bubble sort using matplotlib.")
    parser.add_argument(
        "--data",
        type=str,
        default="5,3,8,4,2",
        help="Comma-separated numbers to sort (e.g., '5,3,8,4,2').",
    )
    parser.add_argument(
        "--reverse",
        action="store_true",
        help="Sort in descending order (default ascending).",
    )
    parser.add_argument(
        "--interval",
        type=int,
        default=400,
        help="Animation frame interval in milliseconds (default: 400).",
    )
    return parser.parse_args(list(argv) if argv is not None else None)


def main(argv: Optional[Iterable[str]] = None) -> int:
    args = parse_args(argv)

    # Lazy import with helpful message if matplotlib is missing
    try:
        import matplotlib.pyplot as plt
        from matplotlib.animation import FuncAnimation
    except Exception as exc:  # noqa: BLE001
        print(
            "matplotlib is required for visualization.\n"
            "Install it via: pip install matplotlib\n\n"
            f"Import error: {exc}",
            file=sys.stderr,
        )
        return 1

    try:
        values = [float(x.strip()) for x in args.data.split(",") if x.strip()]
    except ValueError:
        print("--data must be a comma-separated list of numbers.", file=sys.stderr)
        return 2

    if len(values) == 0:
        print("No data provided after parsing --data.", file=sys.stderr)
        return 2

    state_iter = bubble_sort_states(values, reverse=args.reverse)
    initial_arr, _, _, _ = next(state_iter)

    fig, ax = plt.subplots()
    x_positions = list(range(len(initial_arr)))
    bars = ax.bar(x_positions, initial_arr, align="center", color="skyblue")

    # Axis limits that adapt to min/max including negatives
    min_val = min(0.0, min(initial_arr))
    max_val = max(0.0, max(initial_arr))
    pad = (max_val - min_val) * 0.1 if max_val != min_val else 1.0
    ax.set_ylim(min_val - pad, max_val + pad)
    ax.set_xlim(-0.5, len(initial_arr) - 0.5)
    order_label = "descending" if args.reverse else "ascending"
    title = ax.set_title(f"Bubble Sort ({order_label})")
    ax.set_xlabel("Index")
    ax.set_ylabel("Value")

    compare_color = "orange"
    swap_color = "crimson"
    normal_color = "skyblue"

    # We will pull states on each frame
    def update(_frame_index: int):
        nonlocal state_iter
        try:
            arr, li, ri, swapped = next(state_iter)
        except StopIteration:
            # Freeze on final state by returning bars unchanged
            return bars

        # Update bar heights
        for rect, height in zip(bars, arr):
            rect.set_height(height)

        # Reset colors
        for rect in bars:
            rect.set_color(normal_color)

        # Highlight comparison pair
        if li is not None and ri is not None:
            bars[li].set_color(swap_color if swapped else compare_color)
            bars[ri].set_color(swap_color if swapped else compare_color)

        title.set_text(
            f"Bubble Sort ({order_label}) — comparing: {li} vs {ri}"
            + (" — swapped" if swapped else "")
            if li is not None and ri is not None
            else f"Bubble Sort ({order_label})"
        )
        return bars

    # A generous number of frames to cover all yielded states
    ani = FuncAnimation(fig, update, interval=args.interval, blit=False)
    plt.tight_layout()
    plt.show()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

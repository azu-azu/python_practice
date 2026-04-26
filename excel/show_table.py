from __future__ import annotations

import argparse
import logging
from pathlib import Path

from openpyxl import load_workbook

logger = logging.getLogger(__name__)

def read_sheet(path: Path, sheet_name: str | None = None) -> list[list[str]]:
    wb = load_workbook(path, read_only=True, data_only=True)
    ws = wb[sheet_name] if sheet_name else wb.active
    logger.info("sheet: %s", ws.title)

    rows = []
    for row in ws.iter_rows(values_only=True):
        rows.append([str(c) if c is not None else "" for c in row])
    wb.close()
    return rows


def format_table(rows: list[list[str]]) -> str:
    if not rows:
        return "(empty)"

    col_count = max(len(r) for r in rows)
    for r in rows:
        r.extend([""] * (col_count - len(r)))

    widths = [max(len(r[i]) for r in rows) for i in range(col_count)]
    lines = []
    for j, row in enumerate(rows):
        line = " | ".join(cell.ljust(w) for cell, w in zip(row, widths))
        lines.append(line)
        if j == 0:
            lines.append("-+-".join("-" * w for w in widths))
    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Excel table viewer")
    parser.add_argument("file", type=Path, help="path to .xlsx")
    parser.add_argument("-s", "--sheet", default=None, help="sheet name")
    args = parser.parse_args()

    rows = read_sheet(args.file, args.sheet)
    print(format_table(rows))


if __name__ == "__main__":
    main()
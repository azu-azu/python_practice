# ===============================
# モジュール：import_mapping_refactored.py
# 概要：インポートデータからPRD構成を辞書で構築するロジックのリファクタ版（Python）
# ===============================

from collections import defaultdict
from typing import List, Dict

# --- グローバル構造 ---
prd_to_imp: Dict[str, set] = defaultdict(set)       # PRDごとに必要なIMP一覧
imp_to_prd: Dict[str, set] = defaultdict(set)       # IMPごとに参照されるPRD一覧
prd_detail: Dict[str, List[dict]] = defaultdict(list)  # PRDごとの行データ（辞書のリスト）


def load_table_data() -> List[dict]:
    """
    SQLを実行してテーブルデータを取得する（モック）
    各行はdictで返す：{"prd_id": "prd01", "imp_id": "imp03", ...}
    """
    return [
        {"prd_id": "prd01", "imp_id": "imp01", "value": 100},
        {"prd_id": "prd01", "imp_id": "imp02", "value": 101},
        {"prd_id": "prd02", "imp_id": "imp01", "value": 200},
        {"prd_id": "prd03", "imp_id": "imp03", "value": 300},
        # ... 本来はSQLで取得
    ]


def build_mapping_dictionaries(records: List[dict]) -> None:
    """
    PRDとIMPの対応関係を辞書に構築する
    """
    for row in records:
        prd_id = row["prd_id"]
        imp_id = row["imp_id"]

        prd_to_imp[prd_id].add(imp_id)
        imp_to_prd[imp_id].add(prd_id)
        prd_detail[prd_id].append(row)


def get_mapping_on_import_by_prd() -> Dict[str, List[dict]]:
    """
    メイン関数：マッピング辞書を構築し、PRDごとの行詳細を返す
    """
    records = load_table_data()
    build_mapping_dictionaries(records)
    return prd_detail

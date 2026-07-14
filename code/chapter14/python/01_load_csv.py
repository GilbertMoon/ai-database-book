"""Chapter 14: DBeaver에서 내보낸 CSV를 pandas로 읽고 구조를 확인합니다."""

from __future__ import annotations

import argparse
from pathlib import Path

import pandas as pd

EXPECTED_ROWS = 24
SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_CSV_PATH = SCRIPT_DIR.parent / "data" / "enrollment_analysis_dataset.csv"
DATE_COLUMNS = ["enrolled_at", "enrollment_month", "completed_at"]


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Chapter 14 분석 CSV의 행 수, 중복과 자료형을 확인합니다."
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV_PATH,
        help=f"CSV 경로. 기본값: {DEFAULT_CSV_PATH}",
    )
    return parser.parse_args()


def load_csv(csv_path: Path) -> pd.DataFrame:
    if not csv_path.exists():
        raise FileNotFoundError(
            "CSV 파일을 찾을 수 없습니다. "
            f"DBeaver에서 분석 VIEW를 UTF-8 CSV로 저장했는지 확인하세요: "
            f"{csv_path.resolve()}"
        )

    df = pd.read_csv(csv_path, parse_dates=DATE_COLUMNS)

    required_columns = {
        "enrollment_id",
        "student_id",
        "student_name",
        "region",
        "course_id",
        "course_title",
        "category",
        "level",
        "enrolled_at",
        "enrollment_month",
        "status",
        "paid_amount",
        "completed_at",
        "completion_days",
        "is_completed",
    }
    missing_columns = sorted(required_columns - set(df.columns))
    if missing_columns:
        raise ValueError(f"필수 컬럼이 없습니다: {missing_columns}")

    if len(df) != EXPECTED_ROWS:
        raise ValueError(
            f"기대 행 수는 {EXPECTED_ROWS}이지만 실제는 {len(df)}입니다."
        )

    duplicated_ids = df.loc[
        df["enrollment_id"].duplicated(keep=False),
        "enrollment_id",
    ].tolist()
    if duplicated_ids:
        raise ValueError(f"중복 enrollment_id가 있습니다: {duplicated_ids}")

    return df


def main() -> None:
    args = parse_args()
    df = load_csv(args.csv)

    print("\n[앞 5행]")
    print(df.head().to_string(index=False))

    print("\n[자료형]")
    print(df.dtypes)

    print("\n[검증 결과]")
    print(f"행 수: {len(df)}")
    print(f"고유 enrollment_id: {df['enrollment_id'].nunique()}")
    print(f"결제금액 합계: {int(df['paid_amount'].sum()):,}")
    print("CSV 기본 검증을 통과했습니다.")


if __name__ == "__main__":
    main()

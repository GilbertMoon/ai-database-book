"""Chapter 14: PostgreSQL 분석 VIEW를 pandas DataFrame으로 읽습니다."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

EXPECTED_ROWS = 24
SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_EXPORT_PATH = SCRIPT_DIR.parent / "data" / "enrollment_analysis_dataset.csv"
QUERY = text(
    """
    SELECT *
    FROM analysis_lab.enrollment_analysis_dataset
    ORDER BY enrollment_id
    """
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="PostgreSQL의 Chapter 14 분석 VIEW를 읽습니다."
    )
    parser.add_argument(
        "--export-csv",
        type=Path,
        default=None,
        help="읽은 DataFrame을 저장할 CSV 경로. 생략하면 저장하지 않습니다.",
    )
    return parser.parse_args()


def create_database_engine() -> Engine:
    load_dotenv(SCRIPT_DIR / ".env")
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError(
            "DATABASE_URL이 없습니다. python/.env.example을 복사해 "
            "python/.env를 만들고 개발·테스트 DB 정보를 설정하세요."
        )

    if "db_password" in database_url or "db_name" in database_url:
        raise RuntimeError(
            "DATABASE_URL에 .env.example의 예시 값이 남아 있습니다."
        )

    return create_engine(database_url, pool_pre_ping=True)


def load_from_postgresql(engine: Engine) -> pd.DataFrame:
    with engine.connect() as connection:
        df = pd.read_sql_query(QUERY, connection)

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
    engine = create_database_engine()

    try:
        df = load_from_postgresql(engine)
    finally:
        engine.dispose()

    print("\n[앞 5행]")
    print(df.head().to_string(index=False))

    print("\n[검증 결과]")
    print(f"행 수: {len(df)}")
    print(f"고유 enrollment_id: {df['enrollment_id'].nunique()}")
    print(f"결제금액 합계: {int(df['paid_amount'].sum()):,}")

    if args.export_csv is not None:
        export_path = args.export_csv
        export_path.parent.mkdir(parents=True, exist_ok=True)
        df.to_csv(export_path, index=False, encoding="utf-8-sig")
        print(f"CSV 저장: {export_path.resolve()}")
    else:
        print("CSV 저장은 생략했습니다.")

    print("PostgreSQL 기본 검증을 통과했습니다.")


if __name__ == "__main__":
    main()

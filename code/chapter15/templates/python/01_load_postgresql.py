"""Load the Chapter 15 analysis view from PostgreSQL.

Run 01_schema.sql through 09_analysis_dataset.sql before this script.
The script performs read-only SELECT queries and validates the basic shape.
"""

from __future__ import annotations

import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

EXPECTED_ROWS = 5


def load_dataset() -> pd.DataFrame:
    """Return tutor_project.question_analysis_dataset as a DataFrame."""
    load_dotenv()
    database_url = os.getenv("DATABASE_URL")
    if not database_url:
        raise RuntimeError(
            "DATABASE_URL 환경변수가 없습니다. .env.example을 참고해 .env를 만드세요."
        )

    engine = create_engine(database_url, pool_pre_ping=True)
    query = text(
        """
        SELECT *
        FROM tutor_project.question_analysis_dataset
        ORDER BY question_id
        """
    )

    with engine.connect() as connection:
        dataframe = pd.read_sql_query(query, connection)

    if len(dataframe) != EXPECTED_ROWS:
        raise ValueError(
            f"기대 행 수는 {EXPECTED_ROWS}이지만 실제는 {len(dataframe)}입니다."
        )
    if dataframe["question_id"].duplicated().any():
        duplicated = dataframe.loc[
            dataframe["question_id"].duplicated(keep=False), "question_id"
        ].tolist()
        raise ValueError(f"중복 question_id가 있습니다: {duplicated}")

    return dataframe


if __name__ == "__main__":
    df = load_dataset()
    print(df.head())
    print(df.dtypes)
    print(f"행 수: {len(df)}")

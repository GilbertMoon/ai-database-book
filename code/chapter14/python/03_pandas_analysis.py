"""Chapter 14: SQL 분석 데이터셋을 pandas로 집계하고 시각화합니다."""

from __future__ import annotations

import argparse
import os
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

SCRIPT_DIR = Path(__file__).resolve().parent
DEFAULT_CSV_PATH = SCRIPT_DIR.parent / "data" / "enrollment_analysis_dataset.csv"
DEFAULT_CHART_PATH = SCRIPT_DIR.parent / "output" / "monthly_enrollment_count.png"
EXPECTED_ROWS = 24


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Chapter 14 분석 데이터셋을 pandas로 분석합니다."
    )
    parser.add_argument(
        "--source",
        choices=("csv", "postgresql"),
        default="csv",
        help="데이터 원본. 기본값: csv",
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV_PATH,
        help=f"CSV 경로. 기본값: {DEFAULT_CSV_PATH}",
    )
    parser.add_argument(
        "--chart",
        type=Path,
        default=DEFAULT_CHART_PATH,
        help=f"그래프 저장 경로. 기본값: {DEFAULT_CHART_PATH}",
    )
    return parser.parse_args()


def load_dataframe(source: str, csv_path: Path) -> pd.DataFrame:
    if source == "csv":
        if not csv_path.exists():
            raise FileNotFoundError(
                f"CSV 파일을 찾을 수 없습니다: {csv_path.resolve()}"
            )
        df = pd.read_csv(
            csv_path,
            parse_dates=["enrolled_at", "enrollment_month", "completed_at"],
        )
    else:
        load_dotenv(SCRIPT_DIR / ".env")
        database_url = os.getenv("DATABASE_URL")
        if not database_url:
            raise RuntimeError(
                "DATABASE_URL이 없습니다. python/.env를 설정하세요."
            )

        engine = create_engine(database_url, pool_pre_ping=True)
        query = text(
            """
            SELECT *
            FROM analysis_lab.enrollment_analysis_dataset
            ORDER BY enrollment_id
            """
        )
        try:
            with engine.connect() as connection:
                df = pd.read_sql_query(query, connection)
        finally:
            engine.dispose()

    if len(df) != EXPECTED_ROWS:
        raise ValueError(
            f"기대 행 수는 {EXPECTED_ROWS}이지만 실제는 {len(df)}입니다."
        )
    if df["enrollment_id"].duplicated().any():
        raise ValueError("중복 enrollment_id가 있어 분석을 중단합니다.")

    df["enrollment_month"] = pd.to_datetime(df["enrollment_month"])
    df["paid_amount"] = pd.to_numeric(df["paid_amount"], errors="raise")
    df["completion_days"] = pd.to_numeric(
        df["completion_days"], errors="coerce"
    )
    return df


def build_status_summary(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df.groupby("status", dropna=False)
        .agg(enrollment_count=("enrollment_id", "count"))
        .sort_values(["enrollment_count", "status"], ascending=[False, True])
        .reset_index()
    )


def build_monthly_summary(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df.groupby("enrollment_month", as_index=False)
        .agg(
            enrollment_count=("enrollment_id", "count"),
            paid_amount_sum=("paid_amount", "sum"),
        )
        .sort_values("enrollment_month")
    )


def build_course_summary(df: pd.DataFrame) -> pd.DataFrame:
    return (
        df.groupby(["course_id", "course_title"], as_index=False)
        .agg(
            enrollment_count=("enrollment_id", "count"),
            paid_amount_sum=("paid_amount", "sum"),
        )
        .sort_values(["enrollment_count", "course_id"], ascending=[False, True])
    )


def build_course_status_pivot(df: pd.DataFrame) -> pd.DataFrame:
    return pd.pivot_table(
        df,
        index="course_title",
        columns="status",
        values="enrollment_id",
        aggfunc="count",
        fill_value=0,
        margins=True,
    )


def save_monthly_chart(monthly_summary: pd.DataFrame, chart_path: Path) -> None:
    chart_path.parent.mkdir(parents=True, exist_ok=True)

    chart_data = monthly_summary.copy()
    chart_data["month_label"] = chart_data["enrollment_month"].dt.strftime(
        "%Y-%m"
    )

    ax = chart_data.plot(
        x="month_label",
        y="enrollment_count",
        kind="line",
        marker="o",
        legend=False,
    )
    ax.set_title("월별 수강신청 건수")
    ax.set_xlabel("월")
    ax.set_ylabel("신청 건수")
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(chart_path, dpi=150)
    plt.close()


def main() -> None:
    args = parse_args()
    df = load_dataframe(args.source, args.csv)

    status_summary = build_status_summary(df)
    monthly_summary = build_monthly_summary(df)
    course_summary = build_course_summary(df)
    course_status_pivot = build_course_status_pivot(df)

    print("\n[상태별 신청 건수]")
    print(status_summary.to_string(index=False))

    print("\n[월별 신청 건수와 결제금액]")
    print(monthly_summary.to_string(index=False))

    print("\n[강의별 신청 건수와 결제금액]")
    print(course_summary.to_string(index=False))

    print("\n[강의별 상태 피벗]")
    print(course_status_pivot.to_string())

    completed = df.loc[df["status"] == "완료", "completion_days"]
    print("\n[완료 기간]")
    print(completed.describe())

    save_monthly_chart(monthly_summary, args.chart)
    print(f"\n그래프 저장: {args.chart.resolve()}")


if __name__ == "__main__":
    main()

import pymysql
import csv
import os
from pathlib import Path

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = int(os.environ.get("DB_PORT", "3306"))
DB_USER = os.environ.get("DB_USER", "root")
DB_PASS = os.environ.get("DB_PASSWORD", "cosmo")
DB_NAME = os.environ.get("DB_NAME", "manager")


BASE_DIR = Path(__file__).resolve().parent.parent
CSV_FILE = BASE_DIR / "test_data" / "school_enrollment.csv"

def import_school_enrollment():
    conn = pymysql.connect(
        host=DB_HOST,
        port=DB_PORT,
        user=DB_USER,
        password=DB_PASS,
        database=DB_NAME,
        charset="utf8mb4"
    )
    cursor = conn.cursor()

    insert_sql = """
        INSERT INTO school_enrollment (
            COLLEGE_NAME, GRADUATION_YEAR, ADMISSION_COUNT,
            MIN_SCORE, MIN_RANK
        ) VALUES (%s, %s, %s, %s, %s)
    """

    with open(CSV_FILE, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            cursor.execute(insert_sql, (
                row["COLLEGE_NAME"],
                int(row["GRADUATION_YEAR"]),
                int(row["ADMISSION_COUNT"]),
                int(row["MIN_SCORE"]) if row["MIN_SCORE"] else None,
                int(row["MIN_RANK"]) if row["MIN_RANK"] else None
            ))

    conn.commit()
    cursor.close()
    conn.close()
    print("school_enrollment 数据导入完成。")

if __name__ == "__main__":
    import_school_enrollment()

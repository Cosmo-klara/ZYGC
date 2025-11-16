import csv
import pymysql
import os
from pathlib import Path

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = int(os.environ.get("DB_PORT", "3306"))
DB_USER = os.environ.get("DB_USER", "root")
DB_PASS = os.environ.get("DB_PASSWORD", "cosmo")
DB_NAME = os.environ.get("DB_NAME", "manager")

conn = pymysql.connect(
    host=DB_HOST,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASS,
    database=DB_NAME,
    charset="utf8mb4"
)
cursor = conn.cursor()


BASE_DIR = Path(__file__).resolve().parent.parent

csv_file = BASE_DIR / "test_data" / "major_info.csv"


with open(csv_file, "r", encoding="utf-8-sig") as f:
    reader = csv.DictReader(f)
    for row in reader:
        sql = """
            INSERT INTO major_info (MAJOR_NAME, MAJOR_TYPE, BASE_INTRO)
            VALUES (%s, %s, %s)
        """
        cursor.execute(sql, (row["MAJOR_NAME"], row["MAJOR_TYPE"], row["BASE_INTRO"]))

conn.commit()
cursor.close()
conn.close()

print("CSV 数据导入完成！")

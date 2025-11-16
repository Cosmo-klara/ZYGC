import csv
import os
import sys
import pymysql
from pathlib import Path

DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = int(os.environ.get("DB_PORT", "3306"))
DB_USER = os.environ.get("DB_USER", "root")
DB_PASS = os.environ.get("DB_PASSWORD", "cosmo")
DB_NAME = os.environ.get("DB_NAME", "manager")


BASE_DIR = Path(__file__).resolve().parent.parent
CSV_FILE = BASE_DIR / "test_data" / "college_plan_samples.csv"

BATCH_SIZE = int(os.environ.get("BATCH_SIZE", "200"))  # 一次插入多少行

def read_csv(path):
    rows = []
    with open(path, newline='', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        required = ['COLLEGE_CODE', 'PROVINCE', 'ADMISSION_YEAR', 'MAJOR_NAME', 'PLAN_COUNT', 'DESCRIPTION']
        for i, r in enumerate(reader, start=1):
            # 简单字段存在性校验
            for col in required:
                if col not in r:
                    raise ValueError(f"CSV 缺少字段 {col}，请检查文件头（在第 {i} 行）")
            # 转换字段并清理
            college_code = r['COLLEGE_CODE'].strip() if r['COLLEGE_CODE'] is not None else ''
            province = r['PROVINCE'].strip()
            year = r['ADMISSION_YEAR'].strip()
            major_name = r['MAJOR_NAME'].strip()
            plan_count = r['PLAN_COUNT'].strip()
            description = (r.get('DESCRIPTION') or '').strip()

            # 基本校验
            if not province:
                raise ValueError(f"第 {i} 行 PROVINCE 为空")
            if not year or not year.isdigit():
                raise ValueError(f"第 {i} 行 ADMISSION_YEAR 无效：{year}")
            if not plan_count or not plan_count.isdigit():
                raise ValueError(f"第 {i} 行 PLAN_COUNT 无效：{plan_count}")

            # 使用 int 转换
            college_code_int = int(college_code) if college_code else None
            year_int = int(year)
            plan_count_int = int(plan_count)

            rows.append((college_code_int, major_name, province, year_int, plan_count_int, description))
    return rows

def insert_rows(conn, rows):
    sql = """
    INSERT INTO college_plan
    (COLLEGE_CODE, MAJOR_NAME, PROVINCE, ADMISSION_YEAR, PLAN_COUNT, DESCRIPTION)
    VALUES (%s, %s, %s, %s, %s, %s)
    """
    with conn.cursor() as cur:
        # 分批插入
        for i in range(0, len(rows), BATCH_SIZE):
            batch = rows[i:i+BATCH_SIZE]
            cur.executemany(sql, batch)
            conn.commit()
            print(f"已插入 {i + len(batch)} / {len(rows)} 行")

def main():
    if not os.path.exists(CSV_FILE):
        print(f"找不到 CSV 文件: {CSV_FILE}")
        sys.exit(1)

    try:
        rows = read_csv(CSV_FILE)
        print(f"读取到 {len(rows)} 条记录，准备插入数据库 {DB_HOST}:{DB_PORT}/{DB_NAME}")
    except Exception as e:
        print("读取 CSV 失败：", e)
        sys.exit(1)

    conn = pymysql.connect(host=DB_HOST, port=DB_PORT, user=DB_USER, password=DB_PASS, database=DB_NAME, charset='utf8mb4', autocommit=False)
    try:
        insert_rows(conn, rows)
        print("全部插入完成。")
    except Exception as e:
        print("插入过程中出错，正在回滚：", e)
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    main()

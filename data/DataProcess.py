import sys
import json
import subprocess
from pathlib import Path
from typing import Optional, List

def ensure_packages(packages: List[str]):
    for pkg in packages:
        try:
            __import__(pkg)
        except ImportError:
            subprocess.check_call([sys.executable, "-m", "pip", "install", pkg])

ensure_packages(["pandas", "openpyxl"])

import pandas as pd

# 以当前脚本所在目录为基准，定位院校数据合并结果
NATIONAL_CODES_PATH = Path(__file__).resolve().parent / "院校数据" / "全国大学数据_合并.csv"
VALID_CODES: Optional[set] = None

def read_csv_with_fallback(path: Path) -> Optional[pd.DataFrame]:
    encodings = ["utf-8-sig", "utf-8", "gbk"]
    last_err = None
    for enc in encodings:
        try:
            return pd.read_csv(path, encoding=enc)
        except Exception as e:
            last_err = e
    print(f"读取失败：{path}\n{last_err}")
    return None

def clean_code(value):
    if pd.isna(value):
        return pd.NA
    s = str(value).strip()
    if s == "":
        return pd.NA
    try:
        return str(int(float(s)))  # 统一为不带小数点的整数字符串
    except Exception:
        digits = "".join(ch for ch in s if ch.isdigit())
        return digits if digits else pd.NA

def load_valid_codes(path: Path) -> Optional[set]:
    if not path.exists():
        print(f"警告：院校底稿不存在，跳过代码过滤：{path}")
        return None
    df = read_csv_with_fallback(path)
    if df is None or "全国统一招生代码" not in df.columns:
        print(f"警告：院校底稿缺少列“全国统一招生代码”，跳过代码过滤：{path}")
        return None
    codes = df["全国统一招生代码"].map(clean_code).dropna().astype(str).unique().tolist()
    return set(codes)

DEFAULT_RETAIN_COLUMNS = [
    "年份","学校","_985","_211","双一流","科类","批次","专业","最低分","最低分排名","全国统一招生代码","招生类型","生源地"
]

YN_MAP_TRUE = {"是","Y","y","1","True","true"}
YN_MAP_FALSE = {"否","N","n","0","False","false"}

def to_binary(v):
    if pd.isna(v):
        return pd.NA
    s = str(v).strip()
    if s in YN_MAP_TRUE:
        return 1
    if s in YN_MAP_FALSE:
        return 0
    return pd.NA

def process_excel_to_df(
    input_path: Path,
    sheet: Optional[str],
    region_prefix: str,
    retain_columns: List[str]
) -> pd.DataFrame:
    if sheet is None:
        df = pd.read_excel(input_path, dtype=str)
    else:
        df = pd.read_excel(input_path, sheet_name=sheet, dtype=str)

    df.columns = [str(c).strip() for c in df.columns]

    required_columns = [c for c in retain_columns if c not in ["专业", "生源地"]]
    missing_required = [c for c in required_columns if c not in df.columns]
    if missing_required:
        raise ValueError(f"缺少列: {', '.join(missing_required)}")

    if "专业" not in df.columns:
        df["专业"] = pd.NA

    if "生源地" not in df.columns:
        df["生源地"] = region_prefix
    else:
        filled = df["生源地"].fillna(region_prefix).astype(str).str.strip()
        df["生源地"] = filled.replace({"": region_prefix, "nan": region_prefix})

    df = df[retain_columns].copy()

    # 新增：清洗全国统一招生代码为整数字符串
    if "全国统一招生代码" in df.columns:
        df["全国统一招生代码"] = df["全国统一招生代码"].map(clean_code).astype("string")

    for col in ["_985","_211","双一流"]:
        df[col] = df[col].map(to_binary)

    for col in ["最低分","最低分排名"]:
        s = pd.to_numeric(df[col], errors="coerce")
        non_int = int((s.dropna() % 1 != 0).sum())
        if non_int > 0:
            print(f"警告：{col}发现非整数值 {non_int} 个，已四舍五入处理")
            s = s.round()
        df[col] = s.astype("Int64")

    return df

def post_filter_and_export(
    df: pd.DataFrame,
    temp_csv_path: Path,
    final_csv_path: Path
):
    df.to_csv(temp_csv_path, index=False, encoding="utf-8-sig")
    df_final_batch = pd.read_csv(temp_csv_path)

    bin_cols = ["_985", "_211", "双一流"]
    df_final_batch[bin_cols] = df_final_batch[bin_cols].apply(pd.to_numeric, errors="coerce")

    for col in ["最低分","最低分排名"]:
        s = pd.to_numeric(df_final_batch[col], errors="coerce")
        non_int = int((s.dropna() % 1 != 0).sum())
        if non_int > 0:
            print(f"警告：{col}发现非整数值 {non_int} 个，已四舍五入处理")
            s = s.round()
        df_final_batch[col] = s.astype("Int64")

    batch_series = df_final_batch["批次"].astype(str).str.replace(r"\s+", "", regex=True).str.strip()
    keep_mask = batch_series.str.startswith("本科一批") | batch_series.str.startswith("本科批") | batch_series.str.startswith("平行录取一段")

    removed_batch = len(df_final_batch) - int(keep_mask.sum())
    df_final_batch = df_final_batch[keep_mask].copy()
    print(f"已保留批次=本科一批/本科批，移除 {removed_batch} 行，剩余 {len(df_final_batch)}")

    mask_all_zero = (df_final_batch["_985"] == 0) & (df_final_batch["_211"] == 0) & (df_final_batch["双一流"] == 0)
    removed = int(mask_all_zero.sum())
    df_final_batch = df_final_batch[~mask_all_zero].copy()

    # 新增：统一清洗代码并按院校底稿进行过滤
    df_final_batch["全国统一招生代码"] = df_final_batch["全国统一招生代码"].map(clean_code).astype("string")
    if VALID_CODES:
        before = len(df_final_batch)
        df_final_batch = df_final_batch[df_final_batch["全国统一招生代码"].isin(VALID_CODES)].copy()
        print(f"已按院校数据过滤全国统一招生代码，移除 {before - len(df_final_batch)} 行")

    df_final_batch.to_csv(final_csv_path, index=False, encoding="utf-8-sig")
    print(f"已导出最终版 CSV：{final_csv_path}（移除 {removed} 行，剩余 {len(df_final_batch)} 行）")

    try:
        if temp_csv_path.exists():
            temp_csv_path.unlink()
            print(f"已删除中间版 CSV：{temp_csv_path}")
    except Exception as e:
        print(f"删除中间版 CSV 失败：{e}")

def process_folder(folder_path: Path):
    cfg_path = folder_path / "config.json"
    if not cfg_path.exists():
        print(f"[跳过] 未找到配置：{cfg_path}")
        return

    try:
        cfg = json.loads(cfg_path.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"[跳过] 配置读取失败：{cfg_path}，错误：{e}")
        return

    region_prefix = cfg.get("REGION_PREFIX")
    years = cfg.get("YEARS", [])
    sheet_name = cfg.get("SHEET_NAME", None)
    output_csv_name = cfg.get("OUTPUT_CSV_PATH", "temp.csv")
    retain_columns = cfg.get("RETAIN_COLUMNS", DEFAULT_RETAIN_COLUMNS)

    if not region_prefix or not isinstance(years, list) or len(years) == 0:
        print(f"[跳过] 配置不完整：{cfg_path}")
        return

    print(f"开始处理目录：{folder_path}，地区：{region_prefix}，年份：{years}")

    for year in years:
        input_path = folder_path / f"{region_prefix}_专业分数线_{year}.xlsx"
        final_csv_path = folder_path / f"{year}.csv"
        temp_csv_path = folder_path / output_csv_name

        if not input_path.exists():
            print(f"[{year}] 跳过，未找到输入：{input_path}")
            continue

        try:
            df_batch = process_excel_to_df(input_path, sheet_name, region_prefix, retain_columns)
            post_filter_and_export(df_batch, temp_csv_path, final_csv_path)
        except Exception as e:
            print(f"[{year}] 处理失败：{e}")

def main():
    base_dir = Path(__file__).resolve().parent
    print(f"扫描当前目录：{base_dir}")

    # 新增：加载院校底稿代码集合
    global VALID_CODES
    VALID_CODES = load_valid_codes(NATIONAL_CODES_PATH)
    if VALID_CODES is None:
        print(f"警告：未加载院校代码集合，历年数据将不做代码过滤。来源：{NATIONAL_CODES_PATH}")

    for child in base_dir.iterdir():
        if child.is_dir():
            process_folder(child)

if __name__ == "__main__":
    main()
#!/usr/bin/env python3
"""Build the ORDAEvents demo seed scripts from the original 4D SQL export.

Input:  data/ORDAEvents/export/<Table>/Export.sql (SQL EXPORT DATABASE of the author's data file)
Output: demo/ORDAEvents/Resources/{en,ja}.lproj/data.sql (imported on first launch, see 00_Start)

Both scripts describe the state *before* the article's four tests:
- orders created by the tests (IDs 275, 276, 279) and order lines of deleted orders are removed,
- their quantities are added back to the product stock,
- payment methods are normalised to the popup values (PayPal / credit card / bank transfer).
The ja script also translates names, comments and descriptions and converts prices to yen
(1 USD = 150 JPY, rounded half up to the nearest 100 yen). Order totals are recomputed from the lines.
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EXPORT = Path(__file__).resolve().parent / "export"
OUT = ROOT / "demo/ORDAEvents/Resources"

KEEP_ORDERS = {270, 271, 272, 273, 274}
RATE, ROUND_TO = 150, 100

PAYMENT = {"bank transfer": "bank transfer", "credit card": "credit card", "paypal": "PayPal"}

CLIENTS_JA = {
    295: ("株式会社テックソリューションズ", "contact@techsolutions.co.jp"),
    296: ("佐藤 美咲", "misaki.sato@example.jp"),
    297: ("グローバル工業株式会社", "procurement@global-kogyo.co.jp"),
    298: ("田中工房", "tanaka.kobo@example.jp"),
    299: ("イノベーテック合同会社", "hello@innovatech.jp"),
}

COMMENTS_JA = {
    "Complete office setup for new branch - 5 workstations": "新支店のオフィス一式 - ワークステーション5台",
    "Home office equipment": "在宅勤務用の機器",
    "Enterprise deployment - IT department refresh": "全社導入 - IT部門の機器更新",
    "Additional accessories for team": "チーム用の追加アクセサリー",
    "Gaming/streaming setup upgrade": "ゲーム/配信環境のアップグレード",
}

DESCRIPTIONS_JA = {
    838: "プロ向けノートPC - Intel i7-13700H、16GB RAM、512GB SSD、15.6インチ 4Kディスプレイ",
    839: "ビジネス向けノートPC - Intel i5-12500H、8GB RAM、256GB SSD、14インチ フルHD",
    840: "エントリーモデルのノートPC - AMD Ryzen 5、8GB RAM、512GB SSD、15.6インチ HD",
    841: "プロ向けワークステーション - Intel Xeon、32GB RAM、1TB SSD、NVIDIA RTX A4000",
    842: "MacBook Pro 14インチ - M3 Proチップ、18GB RAM、512GB SSD、Liquid Retina XDR",
    843: "27インチ 4K UHDモニター - IPSパネル、USB-C、高さ調整可能、sRGB 99%",
    844: "24インチ フルHDモニター - IPSパネル、75Hz、AMD FreeSync",
    845: "32インチ 曲面QHDゲーミングモニター - 165Hz、1ms、G-Sync互換",
    846: "34インチ ウルトラワイドQHDモニター - アスペクト比21:9、HDR10、USB-C",
    847: "高性能ワイヤレスマウス - エルゴノミクスデザイン、8000 DPI、マルチデバイス接続",
    848: "ワイヤレスマウス - 1000 DPI、プラグアンドプレイのナノレシーバー",
    849: "ワイヤレスメカニカルキーボード - ホットスワップ対応スイッチ、RGBバックライト、Mac/PC対応",
    850: "マルチデバイス対応ワイヤレスキーボード - コンパクトデザイン、電池寿命2年",
    851: "4Kウェブカメラ - HDR、オートフォーカス、Windows Hello対応、デュアルマイク",
    852: "ワイヤレスヘッドセット - アクティブノイズキャンセリング、バッテリー37時間、UC認定",
    853: "モノクロレーザープリンター - 38ppm、両面印刷、ネットワーク対応",
    854: "インクジェット複合機 - プリント、スキャン、コピー、ファクス、カートリッジ不要",
    855: "セルフパワーUSB 3.0ハブ - 10ポート、60W電源アダプター、個別スイッチ付き",
    856: "Thunderbolt 4ドック - 18ポート、98W充電、8Kディスプレイ対応",
    857: "ポータブルSSD - 容量1TB、読み込み1050MB/s、USB 3.2 Gen 2",
}

TOKEN = re.compile(r"\s*(NULL|'(?:[^']|'')*'|-?\d+(?:\.\d+)?)\s*(,|\))")


def parse(table):
    text = (EXPORT / table / "Export.sql").read_text(encoding="utf-8")
    cols = re.findall(r"\[(\w+)\]", text.split("VALUES")[0])[1:]
    rows = []
    for m in re.finditer(r"^\((.*)\)[,;]\s*$", text.split("VALUES")[1], re.M):
        body, vals, pos = m.group(1) + ")", [], 0
        while pos < len(body):
            t = TOKEN.match(body, pos)
            v = t.group(1)
            vals.append(None if v == "NULL" else v[1:-1].replace("''", "'") if v.startswith("'") else int(v))
            pos = t.end()
        rows.append(dict(zip(cols, vals)))
    return cols, rows


def sql_value(v):
    if v is None:
        return "NULL"
    if isinstance(v, int):
        return str(v)
    return "'" + v.replace("'", "''") + "'"


def insert(table, cols, rows):
    head = f"INSERT INTO [{table}] ( " + " , ".join(f"[{c}]" for c in cols) + " )\nVALUES\n"
    lines = ["(" + " , ".join(sql_value(r[c]) for c in cols) + ")" for r in rows]
    return head + ",\n".join(lines) + ";\n"


def yen(usd):
    return (usd * RATE + ROUND_TO // 2) // ROUND_TO * ROUND_TO


def build(lang):
    tables = {t: parse(t) for t in ("Client", "Product", "Order", "OrderLine")}
    _, clients = tables["Client"]
    _, products = tables["Product"]
    _, orders = tables["Order"]
    _, lines = tables["OrderLine"]

    stock = {p["ID"]: p["Stock"] for p in products}
    for l in lines:
        if l["ID_Order"] not in KEEP_ORDERS:
            stock[l["ID_Product"]] += l["Quantity"]
    lines = [l for l in lines if l["ID_Order"] in KEEP_ORDERS]
    orders = [o for o in orders if o["ID"] in KEEP_ORDERS]

    price = {p["ID"]: p["Price"] for p in products}
    for o in orders:
        total = sum(price[l["ID_Product"]] * l["Quantity"] for l in lines if l["ID_Order"] == o["ID"])
        assert total == o["Price"], (o["ID"], total, o["Price"])

    for p in products:
        p["Stock"] = stock[p["ID"]]
    for o in orders:
        o["Mode_Paiement"] = PAYMENT[o["Mode_Paiement"].lower()]

    if lang == "ja":
        for c in clients:
            c["Name"], c["Email"] = CLIENTS_JA[c["ID"]]
        for p in products:
            p["Description"] = DESCRIPTIONS_JA[p["ID"]]
            p["Price"] = yen(p["Price"])
        price = {p["ID"]: p["Price"] for p in products}
        for o in orders:
            o["Comment"] = COMMENTS_JA[o["Comment"]]
            o["Price"] = sum(price[l["ID_Product"]] * l["Quantity"] for l in lines if l["ID_Order"] == o["ID"])

    parts = [insert(t, tables[t][0], rows) for t, rows in
             (("Client", clients), ("Product", products), ("Order", orders), ("OrderLine", lines))]
    return "\n".join(parts), products, orders


def main():
    for lang in ("en", "ja"):
        script, products, orders = build(lang)
        out = OUT / f"{lang}.lproj" / "data.sql"
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(script, encoding="utf-8")
        print(f"{out.relative_to(ROOT)}: {len(products)} products, {len(orders)} orders")


if __name__ == "__main__":
    main()

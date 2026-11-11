import requests
import pandas as pd

NEGARA = ["ID", "MY", "TH", "VN", "PH", "SG", "BN", "KH", "LA", "MM"]
INDIKATOR = {
    "NY.GDP.PCAP.CD": "GDP per kapita",
    "SP.POP.TOTL": "Populasi",
    "SP.POP.GROW": "Pertumbuhan populasi",
    "IT.NET.USER.ZS": "Pengguna internet",
    "SP.URB.TOTL.IN.ZS": "Urbanisasi",
    "EG.ELC.ACCS.ZS": "Akses listrik",
    "FP.CPI.TOTL.ZG": "Inflasi",
    "FX.OWN.TOTL.ZS": "Findex rekening",
}

rows = []
for kode in INDIKATOR:
    url = (f"https://api.worldbank.org/v2/country/{';'.join(NEGARA)}"
           f"/indicator/{kode}?format=json&per_page=2000&date=2010:2025")
    j = requests.get(url, timeout=60).json()
    for d in j[1]:
        rows.append({"indikator": INDIKATOR[kode],
                     "negara": d["country"]["id"],
                     "tahun": int(d["date"]),
                     "nilai": d["value"]})
df = pd.DataFrame(rows)

print("=== 1. Tahun Findex yang ada nilainya per negara ===")
f = df[(df["indikator"] == "Findex rekening") & df["nilai"].notna()]
print(f.groupby("negara")["tahun"].apply(lambda s: sorted(s.tolist())).to_string())

d = df[df["tahun"] <= 2024].copy()
d["kosong"] = d["nilai"].isna()
print("\n=== 2. Jumlah nilai kosong 2010-2024 (baris=indikator, kolom=negara) ===")
print(d.pivot_table(index="indikator", columns="negara",
                    values="kosong", aggfunc="sum").reindex(columns=NEGARA).to_string())

print("\n=== 3. Nilai tahun 2024 (baris=negara, kolom=indikator) ===")
p = d[d["tahun"] == 2024].pivot(index="negara", columns="indikator", values="nilai")
print(p.reindex(NEGARA).round(2).to_string())
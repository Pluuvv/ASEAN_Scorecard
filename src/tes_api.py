import requests
import pandas as pd

NEGARA = ["ID", "MY", "TH", "VN", "PH", "SG", "BN", "KH", "LA", "MM"]

# Kode indikator dari pengetahuan umum, belum diverifikasi
INDIKATOR = {
    "NY.GDP.PCAP.CD":    "GDP per kapita (US$)",
    "SP.POP.TOTL":       "Populasi",
    "SP.POP.GROW":       "Pertumbuhan populasi (%)",
    "IT.NET.USER.ZS":    "Pengguna internet (%)",
    "SP.URB.TOTL.IN.ZS": "Urbanisasi (%)",
    "EG.ELC.ACCS.ZS":    "Akses listrik (%)",
    "FP.CPI.TOTL.ZG":    "Inflasi (%)",
    "FX.OWN.TOTL.ZS":    "Kepemilikan rekening (Findex, %)",
}

tahun_terbaru = {}
jumlah_baris = {}

for kode, nama in INDIKATOR.items():
    url = (f"https://api.worldbank.org/v2/country/{';'.join(NEGARA)}"
           f"/indicator/{kode}?format=json&per_page=2000&date=2010:2025")
    print(f"\n>>> {nama} ({kode})")
    try:
        r = requests.get(url, timeout=60)
        print("Status:", r.status_code)
        j = r.json()
        if not isinstance(j, list) or len(j) < 2 or j[1] is None:
            print("Respon tidak biasa:", str(j)[:300])
            continue
        df = pd.DataFrame(j[1])
        df["negara"] = df["country"].apply(lambda x: x["id"])
        df = df[df["value"].notna()].copy()
        df["tahun"] = df["date"].astype(int)
        jumlah_baris[nama] = len(df)
        tahun_terbaru[nama] = df.groupby("negara")["tahun"].max()
        print("Baris berisi nilai:", len(df))
    except Exception as e:
        print("ERROR:", e)

print("\n=== TAHUN TERBARU YANG ADA NILAINYA (baris=indikator, kolom=negara) ===")
print(pd.DataFrame(tahun_terbaru).T.reindex(columns=NEGARA).to_string())
print("\n=== JUMLAH BARIS BERNILAI PER INDIKATOR ===")
print(pd.Series(jumlah_baris).to_string())
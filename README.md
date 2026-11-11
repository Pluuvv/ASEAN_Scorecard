# ASEAN Market Opportunity Scorecard

Dashboard BI yang menjawab satu pertanyaan bisnis:

> **Kalau perusahaan e-commerce/fintech mau ekspansi di ASEAN, negara mana yang diprioritaskan, dan seberapa yakin kita?**

Proyek ini dibangun dengan pipeline sungguhan (API, ETL, database 3 lapis, scoring di SQL, dashboard Power BI), bukan sekadar impor CSV. Terkait SDG 8 (pekerjaan layak dan pertumbuhan ekonomi) dan SDG 9 (industri, inovasi, infrastruktur).

![Ringkasan](docs/screenshots/SD_14_pbi_halaman1.png)

---

## Temuan utama

| Peringkat | Negara | Skor |
|---|---|---|
| 1 | Singapura | 86,4 |
| 2 | Malaysia | 73,9 |
| 3 | Thailand | 64,5 |
| 4 | Brunei | 59,0 (bobot terpakai 85 dari 100, tanpa Findex) |
| 5 | Indonesia | 56,2 |
| 6 | Vietnam | 55,5 |
| 7 | Filipina | 47,4 |
| 8 | Kamboja | 38,6 |
| 9 | Laos | 28,9 |
| 10 | Myanmar | 24,0 (data terlama 2019) |

1. **Peringkat 1-2 (SG, MY) dan 6-10 stabil** di semua skenario bobot yang diuji.
2. **Thailand, Brunei, Indonesia (posisi 3-5) rapuh.** Urutannya berubah kalau bobot diubah, jadi dibaca sebagai satu kelompok, bukan peringkat pasti.
3. **Inklusi keuangan adalah gap terbesar Indonesia.** Tanpa indikator rekening bank (Findex), Indonesia naik dari peringkat 5 ke 3. Artinya pengguna internet sudah banyak, tapi rekening bank baru sekitar 56%: ruang tumbuh untuk fintech.
4. **Brunei peringkat 4 sebagian karena Findex-nya tidak ada**, bukan murni karena kuat.

### Uji sensitivitas

| Negara | Skor asli | Bobot sama | Tanpa Findex |
|---|---|---|---|
| SG | 1 | 1 | 1 |
| MY | 2 | 2 | 2 |
| TH | 3 | 4 | 4 |
| BN | 4 | 3 | 5 |
| ID | 5 | 5 | 3 |
| VN, PH, KH, LA, MM | 6, 7, 8, 9, 10 | sama | sama |

---

## Arsitektur

```
World Bank Open Data API
        |
        v   Pentaho Data Integration (PDI)
  raw.wb_indikator          (1.280 baris, semua kolom text)
        |
        v   SQL (PostgreSQL 16, Docker)
  staging.wb_indikator      (tipe data bersih, NULL tetap NULL)
  staging.indikator_terbaru (nilai terakhir per indikator-negara, tahun <= 2024)
        |
        v   SQL
  mart.negara_indikator -> mart.bobot -> mart.skor_indikator -> mart.skor_negara
        |
        v   Power BI Desktop (mode Import)
  Dashboard 6 halaman
```

| Lapisan | Tool | Fungsi |
|---|---|---|
| Ingest | PDI (Spoon) | Panggil API, parse JSON, tulis ke `raw` (idempotent, tabel di-truncate tiap run) |
| Data quality | Python (`src/cek_detail.py`) | Hitung kelengkapan per indikator dan negara |
| Transform + scoring | SQL | Staging, mart, normalisasi, pembobotan |
| Visualisasi | Power BI | Ringkasan, simulator bobot, profil negara, peta peluang, tren, metodologi |

---

## Data

- **Sumber:** World Bank Open Data API (gratis, tanpa API key).
- **Cakupan:** 10 negara ASEAN (ID, MY, TH, VN, PH, SG, BN, KH, LA, MM), 2010 sampai 2025.
- **Volume:** 8 indikator x 10 negara x 16 tahun = 1.280 baris, dengan 1.132 baris berisi nilai.
- **Tahun acuan scoring:** 2024 (nilai terakhir yang tersedia per indikator). Grafik tren memakai 2010-2025.

| Indikator | Kode World Bank | Pilar | Bobot |
|---|---|---|---|
| GDP per kapita | `NY.GDP.PCAP.CD` | Daya beli | 20 |
| Populasi | `SP.POP.TOTL` | Ukuran pasar | 20 |
| Pertumbuhan populasi | `SP.POP.GROW` | Pertumbuhan | 10 |
| Pengguna internet | `IT.NET.USER.ZS` | Kesiapan digital | 15 |
| Kepemilikan rekening bank (Findex) | `FX.OWN.TOTL.ZS` | Kesiapan digital | 15 |
| Urbanisasi | `SP.URB.TOTL.IN.ZS` | Infrastruktur | 10 |
| Akses listrik | `EG.ELC.ACCS.ZS` | Infrastruktur | 5 |
| Inflasi | `FP.CPI.TOTL.ZG` | Stabilitas | 5 |

---

## Metode scoring

1. **Normalisasi min-max** per indikator ke skala 0-1.
2. **Transformasi log (`ln`)** untuk GDP per kapita dan populasi, supaya Singapura (GDP ~94.897) dan Indonesia (populasi besar) tidak menekan semua negara lain ke angka nol.
3. **Inflasi dibalik** (`1 - skor`): inflasi rendah = skor tinggi.
4. **Skor total** = `sum(skor x bobot) / sum(bobot)` atas indikator yang **tersedia**. Jadi negara dengan data kosong (Brunei tanpa Findex) tidak dihukum nol, tapi dibagi dengan bobot yang terpakai (85, bukan 100). Kolom `bobot_terpakai` dan `tahun_data_terlama` ditampilkan di dashboard supaya pembaca tahu seberapa yakin angkanya.

---

## Halaman dashboard

| Halaman | Isi |
|---|---|
| 1 Ringkasan | Kartu KPI, peringkat negara, tabel kualitas data |
| 2 Simulator bobot | 8 slider bobot, skor dan peringkat dihitung ulang (what-if) |
| 3 Profil negara | Skor per indikator dibanding rata-rata ASEAN |
| 4 Peta peluang | Pengguna internet vs rekening bank, gap digital per negara |
| 5 Tren | Tren indikator 2010-2025 per negara |
| 6 Metodologi | Bobot, kelengkapan data, keterbatasan |

Screenshot: tambahkan di `docs/screenshots/`.

---

## Keterbatasan

- **Data tahunan, bukan live.** Nilai proyek ini ada di modeling, scoring, dan sensitivitas, bukan di refresh real-time.
- **Findex hanya ada di tahun survei** (2011, 2014, 2017, 2021/2022, 2024), jadi dipakai nilai terakhir yang ada.
- **Brunei tidak punya data Findex.** Tidak ditebak; skornya dihitung dari 7 indikator.
- **Myanmar memakai data lawas** (inflasi terakhir 2019, internet 2020, Findex 2021). Tahun datanya ditandai di dashboard.
- **Inflasi Brunei negatif (deflasi, -0,4%).** Rumus dibiarkan apa adanya, sehingga Brunei mendapat skor inflasi terbaik. Dicatat sebagai keterbatasan.
- **Bobot bersifat subjektif.** Karena itu ada uji sensitivitas dan simulator bobot.
- Outlier: inflasi Laos 23,13%.

---

## Struktur repo

```
ASEAN_Scorecard/
├── src/      tes_api.py, cek_detail.py      script pengecekan API dan data quality
├── sql/      01_schemas.sql ... 06_cek_sensitivitas.sql
├── pdi/      tr_ingest_worldbank.ktr        transformasi ingest PDI
├── powerbi/  asean_scorecard.pbix
├── docs/     screenshot dan dokumentasi
└── README.md
```

---

## Cara menjalankan

**Prasyarat:** Docker Desktop, Pentaho Data Integration 9.4 (Java 8), Python 3.13, Power BI Desktop.

1. **Jalankan PostgreSQL** (ganti `<password>` dengan password sendiri, jangan di-commit):
   ```powershell
   docker run -d --name asean-pg -e POSTGRES_USER=asean -e POSTGRES_PASSWORD=<password> `
     -e POSTGRES_DB=asean_scorecard -p 5434:5432 -v asean_pgdata:/var/lib/postgresql/data `
     --restart unless-stopped postgres:16
   ```
2. **Kredensial PDI:** isi variabel `ASEAN_DB_HOST`, `ASEAN_DB_PORT`, `ASEAN_DB_PASSWORD` di `~\.kettle\kettle.properties` (tanpa spasi di ujung baris), lalu buka ulang Spoon.
3. **Buat schema:**
   ```powershell
   Get-Content sql\01_schemas.sql | docker exec -i asean-pg psql -U asean -d asean_scorecard
   ```
4. **Ingest:** buka `pdi/tr_ingest_worldbank.ktr` di Spoon dan jalankan (hasil: 1.280 baris di `raw.wb_indikator`).
5. **Bangun staging dan mart**, jalankan berurutan: `02_staging.sql`, `03_staging_terbaru.sql`, `04_mart_negara.sql`, `05_mart_skor.sql` (cara yang sama dengan langkah 3).
6. **Dashboard:** buka `powerbi/asean_scorecard.pbix`, arahkan sumber data ke `localhost:5434`, database `asean_scorecard`. Set *Locale for import* ke English (United States).

---

## Pengembang

Yanuar Arifin, mahasiswa S1 Sistem Informasi. Proyek portofolio BI / data analyst.

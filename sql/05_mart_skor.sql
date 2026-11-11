DROP TABLE IF EXISTS mart.skor_negara;
DROP TABLE IF EXISTS mart.skor_indikator;
DROP TABLE IF EXISTS mart.bobot;

CREATE TABLE mart.bobot (
    indikator_kode text PRIMARY KEY,
    nama           text,
    pilar          text,
    bobot          numeric,
    pakai_log      boolean,
    dibalik        boolean
);

INSERT INTO mart.bobot VALUES
('NY.GDP.PCAP.CD',    'GDP per kapita',       'Daya beli',        20, true,  false),
('SP.POP.TOTL',       'Populasi',             'Ukuran pasar',     20, true,  false),
('SP.POP.GROW',       'Pertumbuhan populasi', 'Pertumbuhan',      10, false, false),
('IT.NET.USER.ZS',    'Pengguna internet',    'Kesiapan digital', 15, false, false),
('FX.OWN.TOTL.ZS',    'Kepemilikan rekening', 'Kesiapan digital', 15, false, false),
('SP.URB.TOTL.IN.ZS', 'Urbanisasi',           'Infrastruktur',    10, false, false),
('EG.ELC.ACCS.ZS',    'Akses listrik',        'Infrastruktur',     5, false, false),
('FP.CPI.TOTL.ZG',    'Inflasi',              'Stabilitas',        5, false, true);

CREATE TABLE mart.skor_indikator AS
WITH olah AS (
    SELECT i.negara_kode, i.indikator_kode, i.nilai, i.tahun_data,
           b.bobot, b.dibalik,
           CASE WHEN b.pakai_log THEN ln(i.nilai) ELSE i.nilai END AS nilai_olah
    FROM staging.indikator_terbaru i
    JOIN mart.bobot b USING (indikator_kode)
),
minmax AS (
    SELECT *,
           (nilai_olah - min(nilai_olah) OVER (PARTITION BY indikator_kode))
           / NULLIF(max(nilai_olah) OVER (PARTITION BY indikator_kode)
                  - min(nilai_olah) OVER (PARTITION BY indikator_kode), 0) AS skor_mentah
    FROM olah
)
SELECT negara_kode, indikator_kode, nilai, tahun_data, bobot,
       CASE WHEN dibalik THEN 1 - skor_mentah ELSE skor_mentah END AS skor
FROM minmax;

CREATE TABLE mart.skor_negara AS
SELECT s.negara_kode,
       n.negara_nama,
       round(100 * sum(s.skor * s.bobot) / sum(s.bobot), 1) AS skor_total,
       rank() OVER (ORDER BY sum(s.skor * s.bobot) / sum(s.bobot) DESC) AS peringkat,
       count(*)           AS indikator_tersedia,
       sum(s.bobot)       AS bobot_terpakai,
       min(s.tahun_data)  AS tahun_data_terlama
FROM mart.skor_indikator s
JOIN mart.negara_indikator n USING (negara_kode)
GROUP BY s.negara_kode, n.negara_nama;
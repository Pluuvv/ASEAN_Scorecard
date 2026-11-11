DROP TABLE IF EXISTS mart.negara_indikator;

CREATE TABLE mart.negara_indikator AS
SELECT
    negara_kode,
    max(negara_nama) AS negara_nama,
    max(nilai) FILTER (WHERE indikator_kode = 'NY.GDP.PCAP.CD')    AS gdp_per_kapita,
    max(nilai) FILTER (WHERE indikator_kode = 'SP.POP.TOTL')       AS populasi,
    max(nilai) FILTER (WHERE indikator_kode = 'SP.POP.GROW')       AS pertumbuhan_populasi,
    max(nilai) FILTER (WHERE indikator_kode = 'IT.NET.USER.ZS')    AS pengguna_internet,
    max(nilai) FILTER (WHERE indikator_kode = 'SP.URB.TOTL.IN.ZS') AS urbanisasi,
    max(nilai) FILTER (WHERE indikator_kode = 'EG.ELC.ACCS.ZS')    AS akses_listrik,
    max(nilai) FILTER (WHERE indikator_kode = 'FP.CPI.TOTL.ZG')    AS inflasi,
    max(nilai) FILTER (WHERE indikator_kode = 'FX.OWN.TOTL.ZS')    AS findex_rekening,
    count(*)        AS indikator_tersedia,
    min(tahun_data) AS tahun_data_terlama
FROM staging.indikator_terbaru
GROUP BY negara_kode;
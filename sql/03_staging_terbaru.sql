DROP TABLE IF EXISTS staging.indikator_terbaru;

CREATE TABLE staging.indikator_terbaru AS
SELECT DISTINCT ON (indikator_kode, negara_kode)
    indikator_kode,
    negara_kode,
    negara_nama,
    tahun AS tahun_data,
    nilai
FROM staging.wb_indikator
WHERE nilai IS NOT NULL
  AND tahun <= 2024
ORDER BY indikator_kode, negara_kode, tahun DESC;
DROP TABLE IF EXISTS staging.wb_indikator;

CREATE TABLE staging.wb_indikator AS
SELECT
    indikator_kode,
    negara_kode,
    negara_nama,
    tahun::int                  AS tahun,
    NULLIF(nilai, '')::numeric  AS nilai,
    diambil_pada
FROM raw.wb_indikator;

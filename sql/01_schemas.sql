CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS raw.wb_indikator (
    indikator_kode text,
    negara_kode text,
    negara_nama text,
    tahun text,
    nilai text,
    diambil_pada timestamp Default now()
);
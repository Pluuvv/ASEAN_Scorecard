WITH a AS (
    SELECT negara_kode, sum(skor * bobot) / sum(bobot) AS s
    FROM mart.skor_indikator GROUP BY 1
),
b AS (
    SELECT negara_kode, avg(skor) AS s
    FROM mart.skor_indikator GROUP BY 1
),
c AS (
    SELECT negara_kode, sum(skor * bobot) / sum(bobot) AS s
    FROM mart.skor_indikator
    WHERE indikator_kode <> 'FX.OWN.TOTL.ZS' GROUP BY 1
)
SELECT a.negara_kode,
       rank() OVER (ORDER BY a.s DESC) AS asli,
       rank() OVER (ORDER BY b.s DESC) AS bobot_sama,
       rank() OVER (ORDER BY c.s DESC) AS tanpa_findex
FROM a JOIN b USING (negara_kode) JOIN c USING (negara_kode)
ORDER BY asli;
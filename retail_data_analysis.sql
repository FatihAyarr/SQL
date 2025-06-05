SELECT * FROM satis;
SELECT * FROM urun_kategorisi;


/* 1. Total number of receipts in the sales data, 
total number of products, total sales amount */

SELECT
  COUNT(satis."FIS_ID") AS toplam_fis_sayisi,
  SUM(satis."URUN_ADEDI") AS toplam_urun_adedi,
  SUM(satis."URUN_TUTARI") AS toplam_satis_tutari
FROM satis;



/* 2. Total number of receipts per day, 
total sales amount and average basket amount */

SELECT
  satis."ALISVERIS_TARIHI",
  COUNT(DISTINCT satis."FIS_ID") AS gunluk_fis_sayisi,
  SUM(satis."URUN_TUTARI") AS gunluk_satis_tutari,
  ROUND(SUM(satis."URUN_TUTARI") / COUNT(DISTINCT satis."FIS_ID"), 2) AS ortalama_sepet_tutari
FROM satis
GROUP BY "ALISVERIS_TARIHI"
ORDER BY "ALISVERIS_TARIHI";



/* 3. Distribution of receipt amount based on format 
(Min / Mean / Median / Max) */

SELECT
  satis."MAGAZA_FORMAT_KODU",
  MIN(satis."URUN_TUTARI") AS min_urun_tutari,
  MAX(satis."URUN_TUTARI") AS max_urun_tutari,
  ROUND(AVG(satis."URUN_TUTARI"), 2) AS mean_urun_tutari,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY "URUN_TUTARI") AS median_urun_tutari
FROM satis
GROUP BY "MAGAZA_FORMAT_KODU";



/* 4. Analysis by department - total number of receipts and expenditure amounts */

with yeni_tablo as (
	select uk."URUN_KODU", 
		s."FIS_ID", 
		s."URUN_TUTARI", 
		uk."REYON_ADI"
	from satis s
	join urun_kategorisi uk on s."URUN_KODU" = uk."URUN_KODU")
select 
	"REYON_ADI",
	COUNT(DISTINCT "FIS_ID") AS fis_sayisi,
	SUM("URUN_TUTARI") AS toplam_tutar
from yeni_tablo
group by "REYON_ADI";



/* 5. Analysis by family group (for the department with the highest share of sales) 
total number of vouchers and expenditure amounts */

-- The department with the highest sales:

WITH reyon_ciro AS (
    SELECT
        uk."REYON_ADI",
        SUM(s."URUN_TUTARI") AS toplam_ciro
    FROM satis s
    JOIN urun_kategorisi uk ON s."URUN_KODU" = uk."URUN_KODU"
    GROUP BY uk."REYON_ADI"
    ORDER BY toplam_ciro DESC
    LIMIT 1
)
SELECT
    uk."AILE_ADI",
    COUNT(DISTINCT s."FIS_ID") AS fis_sayisi,
    SUM(s."URUN_TUTARI" ) AS toplam_tutar
FROM satis s
JOIN urun_kategorisi uk  ON s."URUN_KODU"  = uk."URUN_KODU" 
WHERE uk."REYON_ADI" = (SELECT "REYON_ADI" FROM reyon_ciro) AND uk."AILE_ADI" IS NOT NULL
GROUP BY uk."AILE_ADI"
ORDER BY toplam_tutar DESC;



/* 6. (For the family group with the highest share of sales) 
Product-based analysis - Basket and turnover penetration calculation within the family */

-- we find the family group with the highest share of turnover
WITH en_aile AS (
    SELECT uk."AILE_ADI"
    FROM satis s
    JOIN urun_kategorisi uk ON s."URUN_KODU" = uk."URUN_KODU"
    GROUP BY uk."AILE_ADI"
    ORDER BY SUM(s."URUN_TUTARI") DESC
    LIMIT 1
),
/* A unique collection of products from the family with the highest turnover here
we pull the chips to use when calculating basket penetration */
aile_fisleri AS (
    SELECT DISTINCT s."FIS_ID"
    FROM satis s
    JOIN urun_kategorisi uk ON s."URUN_KODU" = uk."URUN_KODU"
    WHERE uk."AILE_ADI" = (SELECT "AILE_ADI" FROM en_aile)
),
/* this section shows the total sales of each product and how many receipts */
urun_ozet AS (
    SELECT
        s."URUN_KODU",
        uk."URUN_ISMI",
        SUM(s."URUN_TUTARI") AS urun_ciro,
        COUNT(DISTINCT s."FIS_ID") AS urun_fis_sayisi
    FROM satis s
    JOIN urun_kategorisi uk ON s."URUN_KODU" = uk."URUN_KODU"
    WHERE uk."AILE_ADI" = (SELECT "AILE_ADI" FROM en_aile)
    GROUP BY s."URUN_KODU", uk."URUN_ISMI"
)
/* Calculating sales and basket penetration */
SELECT
    "URUN_ISMI",
    urun_ciro,
    urun_ciro / SUM(urun_ciro) OVER () AS ciro_penetrasyonu,
    urun_fis_sayisi,
    urun_fis_sayisi::float / (SELECT COUNT(*) FROM aile_fisleri) AS basket_penetrasyonu
FROM urun_ozet
ORDER BY urun_ciro DESC;


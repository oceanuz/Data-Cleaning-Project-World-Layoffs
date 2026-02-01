-- 1. Remove Duplicates

-- 2. Standardize the Data

-- 3. Null Values or blank values

-- 4. Remove Any Columns or rows


-- ---------------------------------------------------------
-- DATA CLEANING PROJECT
-- ---------------------------------------------------------

-- 1. ADIM: Ham Veriyi Korumak İçin Staging Tablosu Oluşturma
-- Not: Her zaman orijinal veriyi (layoffs) yedekte tut, staging üzerinde çalış.
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;


-- 2. ADIM: Yinelenenleri (Duplicates) Belirleme ve Kalıcı Tabloya Aktarma
-- MySQL'de CTE üzerinden silme yapılamadığı için row_num sütunlu yeni bir tablo şart.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT -- Bu sütun kopyaları yakalamak için eklendi
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Veriyi kopyalarken ROW_NUMBER ile numaralandırıyoruz
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, 
    percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;


-- 3. ADIM: Yinelenen Satırları Silme
DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- 4. ADIM: Kontrol
-- Kopyalar gitti mi? (Sonuç boş dönmeli)
SELECT * FROM layoffs_staging2 WHERE row_num > 1;


#----------------------------------------------------------------------------

-- STANDARDIZING (Veriyi Standartlaştırma)

-- 1. Şirket isimlerindeki gereksiz boşlukları temizle
UPDATE layoffs_staging2
SET company = TRIM(company);

-- 2. Sektör isimlerini standardize et (Örn: Tüm Crypto türevlerini 'Crypto' yap)
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- 3. Ülke isimlerindeki hataları düzelt (Örn: 'United States.' sonundaki noktayı kaldır)
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- 4. Tarih Formatını Düzeltme (2 Aşamalı Operasyon)
-- A) Önce metin formatındaki tarihleri SQL tarih formatına çevirip güncelle
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- B) Kolonun tipini TEXT'ten DATE formatına kalıcı olarak değiştir
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

#-----------------------------------------------------------------
-- Null Values or blank values


-- ---------------------------------------------------------
-- NİHAİ VERİ TEMİZLEME (DATA CLEANING) SORGUSU
-- ---------------------------------------------------------

-- 1. ADIM: TABLO HAZIRLIĞI VE YEDEKLEME
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;

-- 2. ADIM: DUPLICATE (KOPYA) TEMİZLİĞİ İÇİN STAGING2 OLUŞTURMA
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO layoffs_staging2
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- Kopyaları siliyoruz (Güvenli mod kapatılarak)
SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staging2 WHERE row_num > 1;
SET SQL_SAFE_UPDATES = 1;

-- 3. ADIM: STANDARTLAŞTIRMA (STANDARDIZING)
-- Boşlukları temizle
UPDATE layoffs_staging2 SET company = TRIM(company);

-- Sektör isimlerini eşitle
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';

-- Ülke isimlerindeki noktaları temizle
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';

-- Tarih formatını metinden (text) gerçek tarihe (date) çevir
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;

-- 4. ADIM: EKSİK VERİLERİ (NULL/BLANK) DOLDURMA
-- Boş metinleri NULL yap ki sistem tanısın
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';

-- Aynı şirketin diğer satırlarından sektör bilgisini çek ve doldur
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2 ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- 5. ADIM: FİNAL TEMİZLİK
-- Hiçbir işe yaramayan (hem çıkarılan kişi sayısı hem yüzdesi boş olan) satırları uçur
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Yardımcı kolonu (row_num) sil, artık işimiz bitti
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;

-- SONUÇ: Tertemiz veriyi gör
SELECT * FROM layoffs_staging2;












### EXPLORATORY DATA ANALYSIS (EDA)

SELECT * 
FROM layoffs_staging2;

#Toplam işten çıkarma ve yüzdesi
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

# İşten çıkarılma yüzdeleri 1 olanlar ve muhtemelen batan şirketler
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;


#En çok fonlanan şirketler
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

#Toplam işten çıkarmalar
SELECT company, SUM(total_laid_off), min(`date`), MAX(`date`)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

#En çok işten çıkarmadan etkilenen endüstri
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

#En çok işten çıkarma yapan ülkeler
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC; 

#Yıla göre işten çıkarma sayıları
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

#İşten çıkarma yüzdesi
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC; 


#Ay a göre işten çıkarma
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

# Tarihe göre işten çıkarılma ve toplam işten çıkarılan kişi sayısı
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;


#Toplamda en fazla işten çıkarma yapan ilk 10 şirket ve aldıgı yatırımlar 
SELECT 
	company,
	SUM(total_laid_off) AS total_person,
	MAX(funds_raised_millions) AS total_million_funds
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
group by company
ORDER BY total_person DESC
LIMIT 10; 


#Yıla ve şirkete göre en az işten çıkarım 
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

#2020 den 2023 e en çok işten cıkarım yapan ilk 5 şirket
WITH Company_Year (company, years, total_laid_off)  AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
group by company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL 
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;


SELECT 
    stage, 
    SUM(total_laid_off) AS total_laid,
    AVG(percentage_laid_off) AS avg_percent
FROM layoffs_staging2
WHERE stage IS NOT NULL
GROUP BY stage
ORDER BY total_laid DESC;









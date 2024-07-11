-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, AVG(percentage_laid_off)
FROM  layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC;

WITH Rolling_Total as 
(
SELECT SUBSTRING(`date`,1,7) as `Month`, SUM(total_laid_off) as total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
select `Month`, total_off
,SUM(total_off) OVER(ORDER BY `Month`) as Rolling_total
from Rolling_Total;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

with company_year (company, years, total_laid_off) as 
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM  layoffs_staging2
GROUP BY company, YEAR(`date`) 
), company_year_rank as
(SELECT *, 
DENSE_RANK() OVER (PARTITION BY years order by total_laid_off desc) as ranking
FROM company_year
WHERE years is not null)
SELECT *
from company_year_rank
where ranking <= 5;

with location_year (country, location, years, total)as
(
SELECT country,location, YEAR(`date`), count(location)
from layoffs_staging2
where country = 'United States'
GROUP BY location, YEAR(`date`)
), location_year_rank as
(
select *,
DENSE_RANK() over(PARTITION BY years ORDER BY total desc) as ranking
from location_year
where years is not null
)
select *
from location_year_rank
WHERE ranking <=5;

SELECT *
from (
SELECT country, industry, SUM(total_laid_off) as total, count(country) as layoff_times,
rank() over(partition by country order by SUM(total_laid_off) DESC) as ranking
FROM  layoffs_staging2
where industry is not null
GROUP BY industry,country
HAVING SUM(total_laid_off) is NOT null
) as country_industry
where ranking <= 5;


SELECT year(`date`) as years, stage, country, count(stage) as total
from layoffs_staging2
where stage is not null 
and year(`date`) is not null
and country in ('United States', 'Canada', 'China')
group by stage, country, years
order by 1,2,4 desc;

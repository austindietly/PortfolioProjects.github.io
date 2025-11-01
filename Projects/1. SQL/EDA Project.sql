-- Exploratory Data Analysis

-- Since this is for a project, we have no specific direction of what we are trying to find

-- With this being said, we will just look around and see what we can find!


SELECT * 
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;


-- The companies that had a 1 is basically saying 100 percent of the company was laid off
-- Sorting by funds raised allows us to see how large these companies were
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;


-- Top 10 companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


-- Top 10 industries with the most Total Layoffs
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10;

-- Top 10 countries with the most Total Layoffs
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;

-- Each year's total layoff sum ordered by most layoffs to least
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Amount of total layoffs per stage of a company ordered from most layoffs to least
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;




-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per month. It's a little more difficult.

SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;


-- Using what we just found, we can use that query as a CTE and find the rolling total
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off
,SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;



-- Which company had the most total layoffs in one year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;


-- Using 2 CTEs, we can find and rank each years top 5 companies with the most total layoffs
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;




-- Now lets look at countries instead of companies
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- Using 2 CTEs, we can find and rank each years top 5 countries with the most total layoffs
WITH Country_Year (country, years, total_laid_off) AS
(
SELECT country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
), Country_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Country_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Country_Year_Rank
WHERE Ranking <= 5;



-- Using the same query but ordered by country, we can easily see how many times a country was in the top five of total layoffs per year and what their rank was
WITH Country_Year (country, years, total_laid_off) AS
(
SELECT country, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
), Country_Year_Rank AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Country_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Country_Year_Rank
WHERE Ranking <= 5
ORDER BY country;

















































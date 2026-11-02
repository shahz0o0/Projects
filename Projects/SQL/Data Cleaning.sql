-- Data Cleaning

/* SELECT * FROM World_Layoff..layoff
SELECT count(*) FROM World_Layoff..Layoff */

-- 1. Remove Duplicates, 2. Standardize Data, 3.Null or Blank Values, 4. Remove irrelevant columns

SELECT *
INTO World_Layoff..Staging
FROM World_Layoff..Layoff;

-- SELECT * FROM World_Layoff..Staging

WITH layoff_remove_duplicate AS (
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        date,
                        stage,
                        country,
                        funds_raised_millions
           ORDER BY company
       ) AS ROW_NUM
FROM World_Layoff..Staging
)
SELECT * FROM layoff_remove_duplicate
WHERE row_num > 1

-- 14 rows are duplicated and total rows are 2361.

SELECT DISTINCT * 
INTO World_Layoff..Layoff_R_Duplicate
FROM World_Layoff..Staging;

SELECT COUNT(*) AS 'Count' FROM World_Layoff..Layoff_R_Duplicate
-- Row Number = 2347

--Standardizing Data

SELECT DISTINCT industry
FROM World_Layoff..Layoff_R_Duplicate
WHERE industry LIKE '%Crypto%'

SELECT DISTINCT country
FROM World_Layoff..Layoff_R_Duplicate
WHERE country LIKE 'United States%'

SELECT DISTINCT company
FROM World_Layoff..Layoff_R_Duplicate
WHERE company LIKE '%COPY%'

SELECT DISTINCT * 
INTO World_Layoff..Standardize_Table
FROM World_Layoff..Layoff_R_Duplicate;

UPDATE World_Layoff..Standardize_Table
SET company = 'Impossible Food'
WHERE company LIKE 'Impossible Food%';

UPDATE World_Layoff..Standardize_Table
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

UPDATE World_Layoff..Standardize_Table
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

UPDATE World_Layoff..Standardize_Table
SET location = TRIM(location);

/*SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM World_Layoff..Standardize_Table*/

-- Checking on the resolve issues

SELECT DISTINCT industry
FROM World_Layoff..Standardize_Table

SELECT DISTINCT country
FROM World_Layoff..Standardize_Table

SELECT DISTINCT company
FROM World_Layoff..Standardize_Table

-- Formatting

ALTER TABLE World_Layoff..Standardize_Table
ALTER COLUMN date DATE;

-- NULL and Blanks Values // joining same table to retrieve null values

SELECT * FROM World_Layoff..Standardize_Table
WHERE industry = 'NULL'
OR industry IS NULL

SELECT * FROM World_Layoff..Standardize_Table
WHERE company = 'Airbnb'

SELECT * -- checking if it works 
FROM World_Layoff..Standardize_Table a
JOIN World_Layoff..Standardize_Table b
 ON a.company = b.company
 AND b.location = b.location
WHERE (a.industry IS NULL OR a.industry = 'Null')
AND b.industry IS NOT NULL

UPDATE a
SET a.industry = b.industry
FROM World_Layoff..Standardize_Table a
JOIN World_Layoff..Standardize_Table b
    ON a.company = b.company
    AND a.location = b.location
WHERE (a.industry IS NULL OR a.industry = 'Null')
  AND b.industry IS NOT NULL;

--DELETE UNNECESSARY DATA

SELECT * FROM World_Layoff..Standardize_Table
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'Null'
OR total_laid_off IS NULL
OR percentage_laid_off IS NULL --355 ROWS

DELETE
FROM World_Layoff..Standardize_Table
WHERE total_laid_off = 'NULL'
AND percentage_laid_off = 'Null'
OR total_laid_off IS NULL
OR percentage_laid_off IS NULL

-- Final Table

SELECT * FROM World_Layoff..Standardize_Table

-- Change null text to sql null for datatype conversion

UPDATE World_Layoff..Standardize_Table
SET total_laid_off = NULL
WHERE TRIM(total_laid_off) = 'NULL';

ALTER TABLE World_Layoff..Standardize_Table
ALTER COLUMN total_laid_off BIGINT;

UPDATE World_Layoff..Standardize_Table
SET percentage_laid_off = NULL
WHERE TRIM(percentage_laid_off) = 'NULL';

ALTER TABLE World_Layoff..Standardize_Table
ALTER COLUMN percentage_laid_off DECIMAL (3,2);

UPDATE World_Layoff..Standardize_Table
SET funds_raised_millions = NULL
WHERE TRIM(funds_raised_millions) = 'NULL';

ALTER TABLE World_Layoff..Standardize_Table
ALTER COLUMN funds_raised_millions DECIMAL (10,2);

SELECT * FROM World_Layoff..Standardize_Table
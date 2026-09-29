--select * from [Covid_Portfolio #1]..CovidDeaths$
--order by 3,4

-- Select data that will be used in the project.

SELECT location, date, total_cases,new_cases,total_deaths,population 
FROM [Covid_Portfolio #1]..CovidDeaths$

-- Exploring Total Deaths,Total Cases.
SELECT location, date,population,total_cases,total_deaths, ROUND((total_deaths/total_cases)*100,2) as 'death cases %'
,ROUND((total_cases/population)*100,2) as 'cases %', ROUND((total_deaths/population)*100,3) as 'death/pop cases %'
FROM [Covid_Portfolio #1]..CovidDeaths$
WHERE location LIKE '%Malaysia%'
ORDER BY date DESC

-- Countries w highest infections and death rate.
SELECT location,population,MAX(total_cases) as 'T_cases',MAX(total_deaths) as 'T_Deaths',ROUND(MAX((total_cases)/population * 100),2) as 'infection rate'
,ROUND(MAX((total_deaths)/population * 100),2) as 'deaths rate'
FROM [Covid_Portfolio #1]..CovidDeaths$
GROUP BY location,population
ORDER BY [deaths rate] DESC

-- BY Continent

-- Continent w highest infections and death rate.
SELECT continent,SUM(population),MAX(CAST(total_cases as int)) as 'Total_cases',MAX(total_deaths) as 'Total_Deaths',
ROUND(MAX((total_cases)/population * 100),2) as 'infections rate',ROUND(MAX((total_deaths)/population * 100),2) as 'deaths rate'
FROM [Covid_Portfolio #1]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY [deaths rate] DESC;

-- Global numbers
SELECT SUM(population) as Total_Population, SUM(new_cases) as 'Total_Cases',SUM(Cast(new_deaths as int)) as 'Total_Deaths',
ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases) *100,2) as 'Death_Percentage',
SUM(new_cases)/SUM(population) *100 as 'Cases_Percentage'
FROM [Covid_Portfolio #1]..CovidDeaths$
WHERE continent IS NOT NULL;

SELECT date,SUM(new_cases) as 'Total_Cases',SUM(Cast(new_deaths as int)) as 'Total_Deaths',ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases) *100,2) as 'Death_Percentage'
FROM [Covid_Portfolio #1]..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date DESC

-- Total vaccination and population
SELECT a.location, a.date, a.continent, a.new_vaccinations,b.population
FROM [Covid_Portfolio #1]..CovidVaccinations$ a
Inner Join [Covid_Portfolio #1]..CovidDeaths$ b
ON a.location = b.location
AND a.location = b.location
AND a.date = b.date
WHERE a.continent IS NOT NULL
AND a.new_vaccinations is not null
ORDER BY date ASC;


--CTE
WITH PopvsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated) as
(
SELECT b.continent,b.location,b.date,b.population,a.new_vaccinations, 
SUM(CONVERT(bigint,a.new_vaccinations)) OVER (Partition by a.location ORDER BY b.location,b.date) as 'RollingPeopleVaccinated'
FROM [Covid_Portfolio #1]..CovidVaccinations$ a
Inner Join [Covid_Portfolio #1]..CovidDeaths$ b
ON a.location = b.location
AND a.location = b.location
AND a.date = b.date
WHERE b.continent IS NOT NULL
)

SELECT *, ROUND((RollingPeopleVaccinated/population),2) * 100 as 'RPC%' FROM PopvsVac
WHERE NEW_VACCINATIONS IS NOT NULL

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT b.continent,b.location,b.date,b.population,a.new_vaccinations, 
SUM(CONVERT(bigint,a.new_vaccinations)) OVER (Partition by a.location ORDER BY b.location,b.date) as 'RollingPeopleVaccinated'
FROM [Covid_Portfolio #1]..CovidVaccinations$ a
Inner Join [Covid_Portfolio #1]..CovidDeaths$ b
ON a.location = b.location
AND a.location = b.location
AND a.date = b.date
--WHERE b.continent IS NOT NULL

--Create View

create view PercentPopulationVaccinated as
SELECT b.continent,b.location,b.date,b.population,a.new_vaccinations, 
SUM(CONVERT(bigint,a.new_vaccinations)) OVER (Partition by a.location ORDER BY b.location,b.date) as 'RollingPeopleVaccinated'
FROM [Covid_Portfolio #1]..CovidVaccinations$ a
Inner Join [Covid_Portfolio #1]..CovidDeaths$ b
ON a.location = b.location
AND a.location = b.location
AND a.date = b.date

DROP VIEW IF EXISTS PercentPopulationVaccinated

SELECT *
FROM PercentPopulationPercentage;







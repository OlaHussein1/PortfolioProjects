SELECT*
FROM PortfolioProject..CovidDeaths
Where continent is NOT NULL
order by 3,4

--SELECT*
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases_per_million, new_cases, total_deaths, population_density
FROM PortfolioProject..CovidDeaths
order by 1,2 

--Looking at the Total Cases VS Total Deaths

SELECT location, date, total_cases_per_million, total_deaths, (total_deaths/total_cases_per_million)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2 

-- Looking at the total cases VS population
-- Shows what percentage of population got Covid
SELECT location, date, population_density, total_cases_per_million, (total_cases_per_million/population_density)*100 as PercentOfpopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
order by 1,2 

--Looking at countries with highest infection rate compared to population

SELECT location, population_density, Max(total_cases_per_million) as HighestInfectionCount, (Max(total_cases_per_million)/population_density)*100 as PercentOfpopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, population_density
order by PercentOfpopulationInfected desc

--Showing countries with Highest Death Count per Population

SELECT 
    Location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE Continent is Not NULL
GROUP BY 
    Location
ORDER BY 
    TotalDeathCount DESC;
	-- Showing continents with the highest death count per population
	SELECT 
    Location, 
    MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM 
    PortfolioProject..CovidDeaths
--WHERE location LIKE '%states%'
WHERE Continent is not NULL
GROUP BY 
    location
ORDER BY 
    TotalDeathCount DESC;
-- Global Numbers

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths, SUM(CAST(new_deaths AS int))/ SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%STATES%'
WHERE Continent IS NOT NULL
ORDER BY 1,2 

-- LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select DEA.Continent, DEA.location,DEA.DATE, DEA.population_density, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER ( PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.DATE) AS RollingPeopleVaccinated
,(RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
ORDER BY 2,3 

--USE CTE

WITH PopVsVAC (Continent, Location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
Select DEA.Continent, DEA.location,DEA.DATE, DEA.population_density, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER ( PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.DATE) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3 
) 
SELECT*, (RollingPeopleVaccinated/population)*100 AS PeopleVacPercent
FROM PopVsVAC 

--Temp Table
DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nVarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select DEA.Continent, DEA.location,DEA.DATE, DEA.population_density, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER ( PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.DATE) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3 

SELECT*, (RollingPeopleVaccinated/NullIF (population,0))*100 AS PeopleVacPercent
FROM #PercentPopulationVaccinated 

-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated AS
Select DEA.Continent, DEA.location,DEA.DATE, DEA.population_density, VAC.new_vaccinations
, SUM(CAST(VAC.new_vaccinations AS BIGINT)) OVER ( PARTITION BY DEA.Location ORDER BY DEA.Location,
DEA.DATE) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population_density)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.DATE = VAC.DATE
WHERE DEA.continent IS NOT NULL
--ORDER BY 2,3 

Select*
from PercentPopulationVaccinated

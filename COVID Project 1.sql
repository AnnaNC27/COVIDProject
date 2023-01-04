SELECT *
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject.dbo.CovidVaccinations
--ORDER BY 3, 4

--SELECT Data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

-- Looking at total_cases vs total_deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States' AND date BETWEEN '2020-01-01' AND '2020-12-31'
ORDER BY 1, 2

-- Looking at the total_cases vs population 
-- Shows what percentag of population got Covid 

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States' AND date BETWEEN '2020-01-01' AND '2020-12-31'
ORDER BY 1, 2

--Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with highest death count compared to population 

SELECT location, population, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is null 
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death count 

SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the continents with the highest death count per population

SELECT continent, population, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
GROUP BY continent, population
ORDER BY TotalDeathCount DESC

--Global numbers 

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as INT)) AS total_deaths, SUM(total_deaths/total_cases)*100 AS DeathPercentage 
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
--GROUP BY date 
ORDER BY 1, 2

--Looking at total population vs vaccinations 
--Use CTE 


WITH PopVsVac(continent, location, date, population, new_vaccinations, rolling_daily_vaccinations) AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_daily_vaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null 
--ORDER BY 2, 3
)
SELECT *, (rolling_daily_vaccinations/population) AS percent_population_vaccinated 
FROM PopVsVac

--Temp Table 

DROP TABLE IF exists #percent_population_vaccinated 
CREATE TABLE #percent_population_vaccinated 
(
continent NVARCHAR (255),
location NVARCHAR (255),
date DATETIME, 
population NUMERIC,
new_vaccinations NUMERIC,
percent_population_vaccinated NUMERIC
)
INSERT INTO #percent_population_vaccinated 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_daily_vaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null 

SELECT *, (rolling_daily_vaccinations/population)*100
FROM #percent_population_vaccinated 

--Creating view to store data for later visualizations

DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(CONVERT(INT, cv.new_vaccinations)) OVER (Partition by cd.location ORDER BY cd.location, cd.date) AS rolling_daily_vaccinations
FROM PortfolioProject..CovidDeaths cd
JOIN PortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null 

SELECT* 
FROM PercentPopulationVaccinated

CREATE VIEW StatesDeathPercentage2022 AS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States' AND date BETWEEN '2022-01-01' AND '2022-12-31'

CREATE VIEW StatesInfectedPercentage2022 AS
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject.dbo.CovidDeaths
WHERE location = 'United States' AND date BETWEEN '2022-01-01' AND '2022-12-31'

CREATE VIEW GlobalDeathCount2022 AS
SELECT location, population, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null AND date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY location, population


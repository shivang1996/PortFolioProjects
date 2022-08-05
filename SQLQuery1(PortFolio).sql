SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- select data that we are going to be use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2


-- Looking at Total cases vs Total deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%india%'
ORDER BY 1,2

-- Looking at Total cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS TotalCasesPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%india%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PercentageToatlDeath
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

-- Lets Break this Down by CONTIENT
SELECT continent, MAX(Cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- GLOBAL Number

SELECT  date, SUM(new_cases) AS TotalCases, SUM(Cast(new_deaths AS INT)) AS TotalDeaths, SUM(Cast(new_deaths AS int))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) AS TotalCases, SUM(Cast(new_deaths AS INT)) AS TotalDeaths, SUM(Cast(new_deaths AS int))/SUM(new_cases) AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%india%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Vaccination vs Total Population
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths$ death
JOIN  PortfolioProject..CovidVaccinations$ vac 
   ON death.location = vac.location
   and death.date = vac.date
WHERE death.continent is not null
ORDER BY 2,3



-- USE CTE
 WITH PopVsVacc (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
 AS
 (
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths$ death
JOIN  PortfolioProject..CovidVaccinations$ vac 
   ON death.location = vac.location
   and death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopVsVacc


-- TEMP TABLE
DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continet nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths$ death
JOIN  PortfolioProject..CovidVaccinations$ vac 
   ON death.location = vac.location
   and death.date = vac.date
--WHERE death.continent is not null
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

-- Creating View to store data later Visualizations

CREATE VIEW PercentagePopulationVaccinated AS
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition BY death.location ORDER BY death.location, death.date) AS RollingPeopleVaccinated
FROM  PortfolioProject..CovidDeaths$ death
JOIN  PortfolioProject..CovidVaccinations$ vac 
   ON death.location = vac.location
   and death.date = vac.date
WHERE death.continent is not null
--ORDER BY 2,3
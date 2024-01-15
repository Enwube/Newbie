SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


--SELECT * 
--FROM PortfolioProject..CovidDVaccinations
--ORDER BY 3,4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths (IR)
--Shows the likelihood of eaths in each country
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 
	AS IncidencePercentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Afghanistan'
ORDER BY 1,2


--Looking at the Total Cases vs Population
-- Shows % of population that got covid
SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 
	AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Kingdom%'
ORDER BY 1,2

--Looking at Countries with highest infection rates compared to population

SELECT location, population, MAX (cast(total_cases AS INT)) AS HighestInfectionCount, 
MAX(cast(total_cases as float)/cast(population as float))*100 
	AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Kingdom%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing countries with Highest Mortality Rate
SELECT location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
--WHERE location like '%Kingdom%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Lets break this down by Continent
SELECT location, MAX(cast(Total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is NULL
--WHERE location like '%Kingdom%'
GROUP BY location
ORDER BY TotalDeathCount DESC

--Breaking Global Numbers
SELECT date, SUM(cast(new_cases AS float)) AS TotalCases,
	SUM(cast(new_deaths as INT)) AS TotalDeaths,
	SUM(cast(new_deaths as FLOAT))/SUM(cast(new_cases AS FLOAT))*100
	AS DeathPercentage--total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
GROUP BY date
ORDER BY date

--Joining both Deaths and Vaccination tables
SELECT *
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidDVaccinations Vac
	ON dea.location = vac.location
	AND dea.date = Vac.date

--Looking at Total Poulation Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date)
	AS RollingVaccinations
--	, (RollingVaccinations/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidDVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinations) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date)
	AS RollingVaccinations
--	, (RollingVaccinations/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidDVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingVaccinations/Population)*100 AS PopulationVaccinatedPercentage
FROM PopvsVac

--Creating View to store data for later visualizations
CREATE VIEW PopulationVaccinatedPercentage AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(FLOAT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date)
	AS RollingVaccinations
--	, (RollingVaccinations/population)*100
FROM PortfolioProject..CovidDeaths Dea
JOIN PortfolioProject..CovidDVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
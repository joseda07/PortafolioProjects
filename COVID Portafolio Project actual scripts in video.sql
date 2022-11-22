SELECT* 
FROM PortafolioProject.dbo.CovidDeaths
WHERE Continent is not null
Order By 3, 4 

----SELECT* 
----FROM PortafolioProject.dbo.CovidVaccinations
----Order By 3, 4 

---Select data that we are gonna be using

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortafolioProject.dbo.CovidDeaths
WHERE Continent is not null
ORDER BY 1,2


--- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortafolioProject.dbo.CovidDeaths
WHERE location like '%states%'
AND Continent is not null
ORDER BY 1,2


--Looking a the total cases vs Population 
-- show what percentaje of the population got covid
SELECT Location, Date, population, total_cases, (total_deaths/population)*100 AS PercentagePopulationInfected
FROM PortafolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
ORDER BY 1,2


--- Looking at countries with highest infections rate compared to Population

SELECT Location, population, Max(total_cases) as HihgestInfectionCount , MAX((total_deaths/population))*100 AS PercentagePopulationInfected
FROM PortafolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentagePopulationInfected desc


---Showing the countries with higest Death count per Population

SELECT Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortafolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE Continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc



---LET'S BREAK THINGS DOWN BY CONTINENT



--- Showing continents wiht the highest death count per population 

SELECT continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
FROM PortafolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE Continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortafolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY Date
ORDER BY 1,2


--- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortafolioProject.dbo.CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 ORDER BY 2,3


 ---USE CTE 

 WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
 as
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortafolioProject.dbo.CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3 
 )

 SELECT*, (RollingPeopleVaccinated/Population)*100
 FROM PopvsVac


 --TEMP TABLE

 CREATE TABLE #PercentPopulationVaccinated
 (
 Continent Nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortafolioProject.dbo.CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3
 
  SELECT*, (RollingPeopleVaccinated/Population)*100
 FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortafolioProject.dbo.CovidDeaths AS dea
JOIN PortafolioProject..CovidVaccinations AS vac
 ON dea.location = vac.location
 AND dea.date = vac.date
 WHERE dea.continent is not null
 --ORDER BY 2,3

 SELECT*
 FROM PercentPopulationVaccinated
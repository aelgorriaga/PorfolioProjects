SELECT COUNT(location)
FROM New_Project.datavac

-- Looking at Total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths4
WHERE location = 'Argentina' OR location like '%states%'
ORDER BY 1, 2

-- LOOKING AT THE TOTAL cases vs the population
-- Shows what percentage of population got Covi

SELECT Location, date, Population, total_cases,(total_cases/Population)*100 as PercentInfected
FROM New_Project.coviddeaths4
WHERE location = 'Argentina'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/Population))*100 as PercentInfected
FROM New_Project.coviddeaths4
GROUP BY Location, Population
ORDER BY PercentInfected DESC

-- Showing the countries with the highest death count per population

SELECT Location, MAX(total_deaths) as TotalDeathCount
FROM New_Project.coviddeaths4
GROUP BY Locationtotal_deathstotal_deaths
ORDER BY TotalDeathCount DESC

-- Error of the multiple bars that I dont have

SELECT Location, MAX(cast(total_deaths AS float)) as TotalDeathCount
FROM New_Project.coviddeaths4
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- we dont want continents, so we do this

SELECT Location, MAX(cast(total_deaths AS float)) as TotalDeathCount
FROM New_Project.coviddeaths4
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- breaking down by continent

SELECT continent, MAX(cast(total_deaths AS float)) as TotalDeathCount
FROM New_Project.coviddeaths4
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count
-- comments section on how to do it correctly

SELECT continent, sum(new_deaths)
FROM New_Project.coviddeaths4
WHERE continent is not null
GROUP BY continent
ORDER BY continent

-- ARGENTINA NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent-- (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths4
WHERE location = 'Argentina' 
GROUP BY date
ORDER BY 1, 2

-- GLOBAL NUMBERS (per day)

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent-- (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths4
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- GLOBAL NUMBERS (total range)

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent-- (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths4
WHERE continent is not null
ORDER BY 1, 2

-- using other table
SELECT *
FROM New_Project.covidvaccinations4

-- joining two tables
SELECT *
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
    
    -- looking at the total population vs vaccination
    
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- rolling count per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations ) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *,  (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- temp table no funciono
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *,  (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM New_Project.coviddeaths4 dea
JOIN New_Project.covidvaccinations4 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3

-- trying it
SELECT * 
FROM New_Project.percentpopulationvaccinated;
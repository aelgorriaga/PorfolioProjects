-- Looking at total cases, total deaths and death percentage of Argentina and USA
-- Death percentage shows likelihood of dying if you contract covid in the specified country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
FROM New_Project.coviddeaths11
WHERE location = 'Argentina' OR location like '%states%'
ORDER BY 1, 2

-- Looking at population, total cases, percent of population infected and death percentage 
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases,(total_cases/population)*100 as Percent_infected, (total_deaths/total_cases)*100 as Death_percentage
FROM New_Project.coviddeaths11
WHERE location = 'Argentina'
ORDER BY 1, 2

-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX(total_cases/Population)*100 as Percent_infected
FROM New_Project.coviddeaths11
GROUP BY location, population
ORDER BY Percent_infected DESC

-- Showing the countries with the highest death count per population

SELECT location, SUM(new_deaths) as Total_death_count
FROM New_Project.coviddeaths11
GROUP BY location
ORDER BY location
-- Alternative: Order by Total_death_count DESC


-- That code had continents as countries so we do this instead

SELECT location, SUM(new_deaths) as Total_death_count
FROM New_Project.coviddeaths11
WHERE continent is not null
GROUP BY Location
ORDER BY Total_death_count DESC

-- Breaking down by continent

SELECT continent, SUM(new_deaths) as Total_death_count
FROM New_Project.coviddeaths11
WHERE continent is not null
GROUP BY continent
ORDER BY Total_death_count DESC

-- Showing continents with the highest death count

SELECT continent, sum(new_deaths) AS Total_death_count
FROM New_Project.coviddeaths11
WHERE continent is not null
GROUP BY continent
ORDER BY continent

-- Numbers in Argentina

SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_death_count, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent
FROM New_Project.coviddeaths11
WHERE location = 'Argentina' 
GROUP BY date
ORDER BY 1, 2

-- Global numbers (per day)

SELECT date, SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_death_count, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent-- (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths11
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Global numbers (total range)

SELECT SUM(new_cases) AS Total_cases, SUM(new_deaths) AS Total_death_count, SUM(new_deaths)/SUM(new_cases)*100 as Death_percent -- (total_deaths/total_cases)*100 as DeathPercentage
FROM New_Project.coviddeaths11
WHERE continent is not null
ORDER BY 1, 2

-- using other table
SELECT *
FROM New_Project.covidvaccinations11

-- joining two tables
SELECT *
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
    
    -- looking at the total population vs vaccination
    
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- rolling count per day

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations -- remember to specify from which table
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *,  (Rolling_people_vaccinated/population)*100 as Percent_vaccinated
FROM PopvsVac

-- temp table no funciono
DROP TABLE IF exists PercentPopulationVaccinated8;
CREATE TABLE PercentPopulationVaccinated8 (
	Continent varchar(255),
	Location varchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	Rolling_people_vaccinated numeric
)
;
INSERT INTO PercentPopulationVaccinated8
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null;

SELECT *,  (Rolling_people_vaccinated/population)*100 as Percent_vaccinated
FROM PercentPopulationVaccinated8

-- Creating a view to store data for later visualization

DROP VIEW if exists Percent_Population_Vaccinated_a;
CREATE VIEW Percent_Population_Vaccinated_a as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, -- remember to specify from which table
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM New_Project.coviddeaths11 dea
JOIN New_Project.covidvaccinations11 vac
	ON dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null

-- Testing the visualization
SELECT * 
FROM New_Project.percentpopulationvaccinated_a;
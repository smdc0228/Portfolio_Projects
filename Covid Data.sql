
-- Looking at all data 
SELECT *
FROM [Portfolio Project].dbo.CovidDeaths
ORDER BY 3,4

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS float)/CAST(total_cases AS float))*100 
	AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location LIKE '%philippines%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT location, date, total_cases, population, (cast(total_cases as float)/cast(population as float))*100 
AS COVIDPercentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE location like '%philippines%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_count, 
	MAX((cast(total_cases as float)/cast(population as float)))*100 
AS percent_population_infected
FROM [Portfolio Project].dbo.CovidDeaths
GROUP BY location, population
ORDER BY percent_population_infected desc

-- Showing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

-- Showing continents with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count desc

-- Global numbers 
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as INT)) AS total_deaths, 
	SUM(cast(new_deaths as INT))/NULLIF(SUM(new_cases),0)*100 AS death_percentage
FROM [Portfolio Project].dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- COVID Vaccinations Table
SELECT * 
FROM [Portfolio Project]..CovidVaccinations

-- Joining the 2 tables 
SELECT * 
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Total Vaccinations // This will get an error 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_people_vaccinated, 
	--(rolling_people_vaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Using CTE to remove the error 
WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_vaccinated_people
FROM pop_vs_vac 

--TEMP Table
DROP TABLE if exists #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(continent nvarchar (255), 
location nvarchar (255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_people_vaccinated numeric)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_vaccinated_people
FROM #percent_population_vaccinated


-- Creating view to store data for later visualizations 

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(cast(vac.new_vaccinations as FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
	dea.date) AS rolling_people_vaccinated
FROM [Portfolio Project]..CovidDeaths dea
JOIN [Portfolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated

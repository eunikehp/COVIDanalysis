SELECT *
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
-- FROM Portfolioproject..CovidVaccinations
-- ORDER BY 3,4

--Select data that are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Total cases VS Total deaths
-- Show the likelihood people dying if infected covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
ORDER BY 1,2

-- Total cases VS Population
-- Show the percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS case_rate
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
ORDER BY 1,2

-- Finding countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS infection_count, MAX((total_cases/population))*100 AS infection_rate
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
GROUP BY location, population
ORDER BY infection_rate desc

--Show countries with highest death count per population
SELECT location,  MAX(cast(total_deaths as int)) AS death_count
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
GROUP BY location
ORDER BY death_count desc

-- break things down by continent
-- show continent with the highest death count  per population
SELECT continent,  MAX(cast(total_deaths as int)) AS death_count
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
GROUP BY continent
ORDER BY death_count desc

-- global numbers (per date)
SELECT date, SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths as int)) AS total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- global numbers 
SELECT SUM(new_cases) AS total_new_cases, SUM(cast(new_deaths as int)) AS total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM Portfolioproject..CovidDeaths
--WHERE location = 'Indonesia'
WHERE continent is not null
ORDER BY 1,2


-- looking at total population vs vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rollingvaccinated
FROM Portfolioproject..CovidDeaths AS d
JOIN Portfolioproject..CovidVaccinations AS v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
ORDER BY 2,3


-- use CTE
-- show percentage of vaccinations are done
WITH peoplevac AS(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rollingvaccinated
FROM Portfolioproject..CovidDeaths AS d
JOIN Portfolioproject..CovidVaccinations AS v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null)
SELECT *, (rollingvaccinated/population)*100 AS rollingvaccinated_rate
FROM peoplevac



-- TEMP TABLE
DROP TABLE IF exists #percentagepeoplevaccinated
CREATE TABLE #percentagepeoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
rollingvaccinated numeric
)

INSERT INTO #percentagepeoplevaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rollingvaccinated
FROM Portfolioproject..CovidDeaths AS d
JOIN Portfolioproject..CovidVaccinations AS v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null

SELECT *, (rollingvaccinated/population)*100 AS rollingvaccinated_rate
FROM #percentagepeoplevaccinated



--Create View  to store data for later visualizations

CREATE VIEW percentagepeoplevaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS rollingvaccinated
FROM Portfolioproject..CovidDeaths AS d
JOIN Portfolioproject..CovidVaccinations AS v
	ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null


SELECT *
FROM percentagepeoplevaccinated
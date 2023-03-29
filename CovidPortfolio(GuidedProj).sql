-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 PercentageOfDeathsPerCase
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Philippines%'
ORDER BY 1, 2

-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 PercentInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2

-- Looking at Countries with highest infection rates compared to population
SELECT location, Population, MAX(total_cases) HighestInfectionCount, (MAX(total_cases)/population)*100 PercentOfHighestInfectionsPerPopulation
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentOfHighestInfectionsPerPopulation DESC

-- Showing Countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS
SELECT Date, SUM(new_cases) total_cases, SUM(cast (new_deaths as int)) total_deaths, SUM(cast (new_deaths as int))/SUM (new_cases)*100 DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
Group By Date
order by 1,2

-- Looking at Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location  ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast (vac.new_vaccinations as int)) OVER (PARTITION BY dea.location  ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location  ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
--WHERE dea.continent is not null
-- ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location  ORDER BY dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3

Select * From PercentPopulationVaccinated
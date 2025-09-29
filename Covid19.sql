Select * From PortfolioProjects..CovidDeaths
Where continent is not NULL
order by 3,4

--Select * From PortfolioProjects..CovidVaccinations
--order by 3,4;

-- Select Data that we are going ot be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths
Where continent is not NULL
order by 1,2

-- Look at Total Cases vs. Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where location like '%states%'
order by 1,2


-- Look at Total Cases vs. Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
order by 1,2




-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
GROUP BY location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
GROUP BY Location
order by TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT


Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths
--Where location like '%states%'
Where continent is not NULL
GROUP BY continent
order by TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT v2


--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From PortfolioProjects..CovidDeaths
----Where location like '%states%'
--Where continent is NULL
--GROUP BY location
--order by TotalDeathCount DESC

-- GLOBAL NUMBERS
Select date, SUM(MAX(total_cases)), total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where continent is not null
Group By Date
order by 1,2

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where continent is not null
Group By Date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths
Where continent is not null
-- Group By Date
order by 1,2



-- Looking at Total Population vs. Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)
SELECT *,
	(RollingPeopleVaccinated/Population)*100 as PercVacByCountry
FROM PopvsVac



-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric,
	)
Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Where dea.continent is not null
-- order by 2,3

SELECT *,
	(RollingPeopleVaccinated/Population)*100 as PercVacByCountry
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as INT)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths dea
Join PortfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3


Select *
From PercentPopulationVaccinated;
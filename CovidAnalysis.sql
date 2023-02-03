SELECT *
From CovidAnalysis..CovidDeaths$
Where continent is not null
order by 3,4

--SELECT *
--From CovidAnalysis..CovidVaccinations$
--order by 3,4

-- Select DATA to be used
Select Location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis..CovidDeaths$
Where continent is not null
order by 1,2

-- Total cases vs Total deaths in the philippines
-- At February 01, 2023, around 4,073,454 cases had been contracted, with 65,802 total deaths in the Philippines. Making the chances of fatality by contracting covid in the Philippines to be around 1.61%
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths$
Where location like '%philippines%' and continent is not null
order by 1,2

-- Total cases vs Population in the philippines
-- At February 01, 2023, around 4,073,454 cases had been contracted within the Philippine's population at around 115,559,008. Making the chances of contracting covid in the Philippines to be around 3.5%
Select Location, date, Population, total_cases, (total_cases/population)*100 as CovidPercentage
From CovidAnalysis..CovidDeaths$
Where location like '%philippines%' and continent is not null
order by 1,2

-- Countries with the highest infection rate compared to population
-- The highest infection percentage based on population is Cyprus with an infection count of 642,663 from the total population of 896,007 making the infection percentage to be at 71.7%
-- Note: Errors from data might be present as based on Google, cyprus's population is at around 1.244 million as of 2021, this would make the infection percentage to only be around at 51.6%
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as InfectionPercentage
From CovidAnalysis..CovidDeaths$
Where continent is not null
Group by Location, Population
order by InfectionPercentage desc

-- Countries with the highest death count per population
-- United States has the highest total death count of 1,109,591 with a population of 338,289,856 as of February 01,2023
Select Location, Population, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths$
Where continent is not null
Group by Location, Population
order by TotalDeathCount desc

-- Continent with the highest death count
-- Europe has the highest death count with a total of 2,022,545 as of February 01, 2023
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths$
Where continent is null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS
-- Death Percentage across the world per day
Select date, SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths$
Where continent is not null
Group By date
order by 1,2

-- Total death percentage across the world
Select SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths$
Where continent is not null
--Group By date
order by 1,2

-- Covid Vaccinations Queries

Select *
From CovidAnalysis..CovidVaccinations$
Where continent is not null
order by 3,4

-- Total Population vs Vaccinations
-- Displays People Vaccinated in a rolling format
-- UTILIZING CTE AND TEMP TABLE
-- CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths$ dea
Join CovidAnalysis..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated -- Recommend adding this if making alterations
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric, RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths$ dea
Join CovidAnalysis..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations
-- Percentage of population vaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths$ dea
Join CovidAnalysis..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- Total death percentage across the world
Create View TotalDeathPercentage as
Select SUM(new_cases) as TotalCases , SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths$
Where continent is not null
--Group By date
--order by 1,2
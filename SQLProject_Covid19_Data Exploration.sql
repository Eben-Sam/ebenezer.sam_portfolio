/*
Project : Data Exploration
*/

Select *
From PortfolioProject..CovidDeaths
Order by 3,4


Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Selecting data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Showing likelihood of dying if covid is contracted per country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Order by 1,2

-- Looking at the situation in United Kingdom

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'United Kingdom'
Order by 1,2

-- Looking at Total Cases vs Population
-- Showing percentage of population who got covid
--

Select location, date, population, total_cases, (total_cases/population)*100 As Population_CovidPercentage
From PortfolioProject..CovidDeaths
Where location like 'United Kingdom'
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location,population,MAX(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc


-- For Tableau viz (without dates)

Select location,population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
Order by PercentPopulationInfected desc


-- For Tableau viz (with dates)

Select location,population,date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 As PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population,date
Order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

-- New one with European Union as part of Europe
-- TotalDeathCount by Continent
-- for Tableau viz

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
Order by TotalDeathCount desc





--Global numbers with Dates
Select date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2


--Global numbers without Dates
-- for Tableau viz
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Counting on (Rolling) People Vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From PopvsVac


-- Use TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100 as PercentPeopleVaccinated
From #PercentPopulationVaccinated

-- Creating View (to help us visualize the query results in Tableau or PowerBi)

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated 
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

-- Querying the View created

Select *
From PercentPopulationVaccinated


-- Creating another View

Create View GlobalNumbers as
Select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
--Order by 1,2

-- Querying the View created

Select *
From GlobalNumbers
Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

---Select Data to be used

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths 
order by 1,2


--Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid19 in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
where location like '%canada%'
Where continent is not null
order by 1,2


--Total Cases vs Population
--Shows percentage of population that got covid19

Select location, date,  Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
where location like '%canada%'
order by 1,2


--Countries with Highest Infection Rate compared to Population

Select Location,  Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths 
--where location like '%canada%'
Group by location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%canada%'
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continent with the Highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths 
--where location like '%canada%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS


Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where location like '%canada%'
Where continent is not null
Group by date
order by 1,2


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths 
--where location like '%canada%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccinations (new vac per day)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
, RollingPeopleVaccinated/
--From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3
	)

	Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac





	--TEMP TABLE

	Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert Into #PercentPopulationVaccinated
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	--Where dea.continent is not null
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated




	---Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--order by 2,3


	Select *
	From PercentPopulationVaccinated
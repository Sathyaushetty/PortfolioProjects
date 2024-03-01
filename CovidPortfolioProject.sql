Select *
From PortfolioProject..CovidDeaths
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


--Looking at Total Cases vs Total Deaths
--Shows death percentage if you are infected by Covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as [Death Percentage]
From PortfolioProject..CovidDeaths
Where location = 'canada'
order by 1,2


--Looking Total Cases vs Population
--Shows the percentage of population Infected

Select Location, date, population, total_cases, (total_cases/population)*100 as [Infected Population Percentage]
From PortfolioProject..CovidDeaths
Where location = 'canada'
order by 1,2


--Looking at the countries with highest infected rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as [Infected Population Percentage]
From PortfolioProject..CovidDeaths
Group by location, population
order by [Infected Population Percentage] desc


--Showing countries with highest death count per population

Select Location, Max(cast(total_deaths as int)) as TotaldeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by location
order by TotalDeathCount desc


--Showing contient with highest death count per population

Select continent, Max(cast(total_deaths as int)) as TotaldeathCount
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by continent
order by TotalDeathCount desc


--Global Numbers

Select Sum(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/Sum(new_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location = 'canada'
where continent is not null
--group by date
order by 1,2


--Looking total population vs vaccinations


Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not NULL
order by 2,3


--Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Temp Table

Drop Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(225),
 Date Datetime,
 Population numeric,
 New_vaccination numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select*,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visulization


Create view PercentageofPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


Select*
From PercentageofPopulationVaccinated
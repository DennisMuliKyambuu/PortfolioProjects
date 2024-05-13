select *
from PortfolioProject..['CovidDeaths(2)$']
where continent is not null
order by 3,4

--select *
--from PortfolioProject..['Covidvaccinations(2)$']
--order by 3,4

--select the data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..['CovidDeaths(2)$']
where continent is not null
order by 3,4

--looking at Total_Cases vs Total_Deaths
--shows likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathsPercentage
from PortfolioProject..['CovidDeaths(2)$']
where location like '%states%'
and continent is not null
order by 1,2

--looking at Total Cases VS Population
--Shows what percentage of population got Covid

select location,date,population,total_cases,(total_cases/population)*100 as PercentagePopulationInfected
from PortfolioProject..['CovidDeaths(2)$']
--where location like '%states%'
where continent is not null
order by 1,2

--looking at countries with Highest Infection Rate compared to Population


select location, population, MAX(total_cases) as HighestInfectionCount,Max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..['CovidDeaths(2)$']
--where location like '%states%'
where continent is not null
Group by Location, population
order by PercentagePopulationInfected desc

-- Showing the countries with Highest Death count per Population


select location,MAX(cast(Total_deaths as int)) as TotalDeathcount
from PortfolioProject..['CovidDeaths(2)$']
--where location like '%states%'
where continent is not null
Group by Location
order by  TotalDeathcount desc


--LETS BREAK THINGS DOWN BY CONTINENT


--Showing the continents with the highest death count per population

select continent,MAX(cast(Total_deaths as int)) as TotalDeathcount
from PortfolioProject..['CovidDeaths(2)$']
--where location like '%states%'
where continent is not null
Group by continent
order by  TotalDeathcount desc



--GLOBAL NUMBERS


select SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(New_deaths as int)) / SUM(new_cases)*100 as DeathsPercentage
from PortfolioProject..['CovidDeaths(2)$']
--where location like '%states%'
where continent is not null
--Group By date
order by 1,2


--JOINING THE 2 TABLES
select *
From PortfolioProject..['CovidDeaths(2)$'] dea
Join PortfolioProject..['Covidvaccinations(2)$'] vac
     On dea.location = vac.location	
	 and dea.date = vac.date


--Looking ata Total population vs Vaccination

select dea.continent, dea.location , dea.date, (dea.population), vac.new_vaccinations
From PortfolioProject..['CovidDeaths(2)$'] dea
Join PortfolioProject..['Covidvaccinations(2)$'] vac
     On dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3








--USE CTE
With PopvsVac (Continent, loaction, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaciantied
From PortfolioProject..['CovidDeaths(2)$'] dea
Join PortfolioProject..['Covidvaccinations(2)$'] vac
     On dea.location = vac.location	
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population) *100
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaciantied
From PortfolioProject..['CovidDeaths(2)$'] dea
Join PortfolioProject..['Covidvaccinations(2)$'] vac
     On dea.location = vac.location	
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population) *100
From #PercentPopulationVaccinated

-- Creating View to store data for later Visualizations
create View PercentPopulationVaccinated as
select dea.continent, dea.location , dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER ( partition by dea.location order by dea.location, dea.Date) as RollingPeopleVaciantied
From PortfolioProject..['CovidDeaths(2)$'] dea
Join PortfolioProject..['Covidvaccinations(2)$'] vac
     On dea.location = vac.location	
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
From PercentPopulationVaccinated
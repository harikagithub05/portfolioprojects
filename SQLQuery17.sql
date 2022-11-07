SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--SELECT DATA THAT WE ARE GOING TO BE USING 

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your countrty
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--looking at Total cases vs population
--shows what percentage of population got covid

select location, date, population, total_cases,(total_cases/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
    PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%india%'
GROUP BY location, population
order by PercentPopulationInfected desc


--showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
GROUP BY location
order by totaldeathcount desc


--let's break things down by continent

--showing continents with the highest death count per population


select continent, max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
GROUP BY continent
order by totaldeathcount desc


--global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where continent like '%states%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
   where dea.continent is not null
   order by 2,3


   -- use CTE

 with popvsvac (continent, locaton, date,  population, new_vaccination, rollingpeoplevaccinated)
 as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (rollingpeoplevaccinated/population)*100
from popvsvac


--temp_table


drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)
 
insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from #percentpopulationvaccinated
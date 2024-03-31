
select*
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select*
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select data that we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total  deathes
SELECT location,date,total_cases,total_deaths,(cast(total_deaths as float) / cast(total_cases as float))*100 as deathrate
FROM PortfolioProject..CovidDeaths
where location like '%Algeria%' --shows the likehood dying in the algeria
ORDER BY 1,2 ;
    
--looking at total cases vs populations
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Algeria%'
order by 1,2 

--looking at countries with highest innfection comapre to the other countries 
select location,population,MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
group by location,population
order by PercentPopulationInfected desc

--showing the countries with highest death count per populations
select location,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is not null
group by location
order by TotalDeathCount desc

--showing contintents with the highest death count per population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
--where location like '%Algeria%'
where continent is not null
group by continent
order by TotalDeathCount desc

--globel numbers
SELECT date,SUM(new_cases),SUM(CAST(new_deaths as int)) ,SUM(cast(new_deaths as int)) / SUM(cast(new_cases as int))*100 as deathrate
FROM PortfolioProject..CovidDeaths
where continent is not null
--group by date
ORDER BY 1,2 


--looking at total pupolation vs vaccinations
select dea.continent, dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date) as RollinPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
With PopvsVac (continent , location , date , population ,new_vaccinations , RollinPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date) as RollinPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select* ,(RollinPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric ,
RollinPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date) as RollinPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select* ,(RollinPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
create view  PercentPopulationVaccinated as 
select dea.continent, dea.location,dea.date,dea.population ,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date) as RollinPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
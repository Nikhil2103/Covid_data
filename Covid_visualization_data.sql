

Select *
from PortfolioProject..CovidDeaths
order by 3,4

/*
select *
from PortfolioProject..CovidVaccinations
order by 3,4
*/


select location,date,total_cases,new_cases,total_deaths,population 
from PortfolioProject..CovidDeaths
order by 1,2


-- Total Cases vs TotalDeaths

select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

-- % of people getting covid
select location,date, population, total_cases,total_deaths,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2


--- Looking at Countries with Highest Infection Rate compared to Population

select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
group by Location,Population
order by 1,2




--- Looking at Countries with the highest death_count per population


select Location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--when continent is not null, that means that the record is for a country
group by location
order by TotalDeathCount desc


--- looking at Continents with their deathcount
select continent,Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global numbers

select Date,sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as new_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as new_cases,sum(cast(new_deaths as int)) as new_deaths,(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null



select *
from PortfolioProject..CovidDeaths

select * 
from PortfolioProject..CovidVaccinations



-- Looking at Total Population vs Vaccinations




select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--- using CTE(common table expression) for above query to get columns easier

with PopvsVac (Continent,Location, Date, Population, New_Vaccination, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/Population)*100  
from PopvsVac





--- Temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated



--- create view to store data for vizualization
drop view if exists PercentPopulationVaccinated


CREATE VIEW PercentPopulationVaccinated 
	as
		select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
		from PortfolioProject..CovidDeaths dea
		join PortfolioProject..CovidVaccinations vac
		on dea.location = vac.location and dea.date = vac.date
		where dea.continent is not null


select * from PercentPopulationVaccinated
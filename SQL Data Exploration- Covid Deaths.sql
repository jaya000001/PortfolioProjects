select * 
from covidDeaths 
order by 3,4

select * 
from covidVaccinated
order by 3,4

select location, date, population,total_cases,new_cases,total_deaths
from covidDeaths 
order by 1,2

--shows the death percentage
select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covidDeaths 
where location like '%india%'
order by 1,2

--looking at countries with highest rate compared to population
select location,population, max(total_cases) as HighestInfectCount, 
round( max((total_cases/population))*100, 2) as PercentageInfected
from covidDeaths 
group by location,population
order by 4 desc

--showing countries with  highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from covidDeaths
where continent is not null
group by continent
order by 2 desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
round(sum(cast(new_deaths as int))/ sum(new_cases)*100,2) as DeathPercentage
from covidDeaths 
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinantion
select  dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as int)) over (partition by dt.location order by dt.location, dt.date)
as RollingPeopleVaccinanted
from covidDeaths dt
join covidVaccinated vc
      on dt.location = vc.location
where dt.continent is not null
order by 2,3

-- use CTE
with PopulationVsVaccine(Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinanted)
as
(
select  dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) over (partition by dt.location order by dt.location, dt.date)
as RollingPeopleVaccinanted
from covidDeaths dt
join covidVaccinated vc
      on dt.location = vc.location
where dt.continent is not null
--order by 2,3
) 
select *, round((RollingPeopleVaccinanted/Population)*100,2) as "%RPV"
from PopulationVsVaccine

-- use TEMP

drop table if exists #PercentPopVac
create table #PercentPopVac
( Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccination numeric, 
RollingPeopleVaccinanted numeric)

insert into #PercentPopVac
select  dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) over (partition by dt.location order by dt.location, dt.date)
as RollingPeopleVaccinanted
from covidDeaths dt
join covidVaccinated vc
      on dt.location = vc.location
where dt.continent is not null
--order by 2,3

select *, round((RollingPeopleVaccinanted/Population)*100,2) as "%RPV"
from #PercentPopVac



--creating view to store data for later visualizations
create view  PercentPopulationVaccinated as
select  dt.continent, dt.location, dt.date, dt.population, vc.new_vaccinations,
sum(cast(vc.new_vaccinations as bigint)) over (partition by dt.location order by dt.location, dt.date)
as RollingPeopleVaccinanted
from covidDeaths dt
join covidVaccinated vc
      on dt.location = vc.location
where dt.continent is not null
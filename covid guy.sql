select *
from portfolioprojects..['coviddeaths']
where continent is not null
order by 3,4

--select *
--from portfolioprojects..['covidvaccinations']
--order by 3,4

--select the data that we are going to be using


select continent, date, total_cases, new_cases, total_deaths, population
from portfolioprojects..['coviddeaths']
where continent is not null
order by 1,2



--total cases vs total deaths

--likelihood of dying from covid in percentage

select continent, date, total_cases, total_deaths,  (total_deaths/total_cases) *100 as Death_Percentage
from portfolioprojects..['coviddeaths']
--where location like '%states%'
and continent is not null
order by 1,2


--total cases vs population

select continent, date, population, total_cases, (total_cases/population) *100 as infected_percentage
from portfolioprojects..['coviddeaths']
where (total_cases/population) *100 > 1
and continent is not null
--where location like '%Nigeria%'
order by 1,2

--looking at countries with the highest infection rate compared to the population

select continent, population, MAX(total_cases) as highest_infection_rate, max((total_cases/population)) *100 as infected_percentage
from portfolioprojects..['coviddeaths']
where continent is not null
group by continent, population
order by 4 desc

select continent, population, MAX(total_cases) as highest_infection_rate, max((total_cases/population)) *100 as infected_percentage
from portfolioprojects..['coviddeaths']
--where location like '%state%'
and continent is not null
group by continent, population
order by 4 desc


--looking at countries with the highest death count compared to the population

select location, MAX(cast(total_deaths as int)) as highest_death_count
from portfolioprojects..['coviddeaths']
where continent is not null
group by continent
order by 2 desc

--grouping by or breaking down by continent

--showing the continents with the highest death count per population
select continent, MAX(cast(total_deaths as int)) as highest_death_rate
from portfolioprojects..['coviddeaths']
where continent is not null
group by continent
order by 2 desc



--global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/ sum(new_cases)) * 100 as death_percentage
from portfolioprojects..['coviddeaths']
where continent is not null
group by date
order by 1,2



--global numbers  not grouping by date
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/ sum(new_cases)) * 100 as death_percentage
from portfolioprojects..['coviddeaths']
where continent is not null
order by 1,2

--looking at the total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated 
from portfolioprojects..['coviddeaths'] dea
join portfolioprojects..['covidvaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- use a cte
with popvsVac (continent, date, location, population, new_vaccinations, Rolling_people_vaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from portfolioprojects..['coviddeaths'] dea
join portfolioprojects..['covidvaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (Rolling_people_vaccinated/population)*100  as percentage_vaccinated
from popvsVac
	


	--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from portfolioprojects..['coviddeaths'] dea
join portfolioprojects..['covidvaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null


select *, (Rolling_people_vaccinated/population)*100  as percentage_vaccinated
from #percentpopulationvaccinated



--creating a view to store data for later visualissations

create view percentpopulation_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from portfolioprojects..['coviddeaths'] dea
join portfolioprojects..['covidvaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from percent_populationvaccinated


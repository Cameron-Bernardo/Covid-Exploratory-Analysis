--Data Exploration
--Covid Data Portfolio Project

-- Data we will be using (world covid data 2024)

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Highest recorded new cases at a certain time in the US

select max(new_cases) as MostNewCases, date, location
from PortfolioProject..CovidDeaths
where location = 'United States'
group by date, location
order by MostNewCases DESC

-- Total cases vs Total Deaths
-- shows likelihood of dying if you contract covid in the US

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,3) as DeathRate
from PortfolioProject..CovidDeaths
where location = 'United States'
--where continent is not null
order by 1,2 

--Looking at Total cases vs population (United States)
-- shows percetnage of population that got Covid in the US

select location, date, total_cases, population, round((total_cases/population)*100,4) as InfectionRate
from PortfolioProject..CovidDeaths
where location = 'United States' and total_cases is not null 
order by 2,3

-- Countries with the highest infection rate 

select location, population, max(total_cases) as HighestInfectionCount, max(round((total_cases/population)*100,4)) as PercentPopulaionInfected
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by location, population
order by PercentPopulaionInfected desc

-- Countries with the highest death counts 

select location, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by location, population
order by 2 desc

-- Death count by continent

select continent, max(total_deaths) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by continent
order by 2 desc

-- Total deaths compared to population

select location, max(total_deaths) as TotalDeathCount, population, round(max((total_deaths/population)*100),4) as DeathPercentage
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by location, population
order by 4 desc


-- Total deaths vs total cases globally

select date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round(sum(new_deaths)/sum(new_cases)*100,3) as GlobalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
having sum(new_cases) <> 0
order by 1,2

-- Total global cases, deaths and death rate 

select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round(sum(new_deaths)/sum(new_cases)*100,3) as GlobalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
--having sum(new_cases) <> 0
order by 1,2

-- People fully vaccinated vs population in the US

select vacc.location, vacc.date, vacc.people_fully_vaccinated, dea.population, round((vacc.people_fully_vaccinated/dea.population)*100,4) as VaccinationPercentage 
from PortfolioProject..CovidVaccs vacc
join PortfolioProject..CovidDeaths dea
	on vacc.location = dea.location
where vacc.location = 'United States'
and vacc.people_fully_vaccinated is not null
group by vacc.location, vacc.date, vacc.people_fully_vaccinated, dea.population
order by VaccinationPercentage

--Total population vs vaccinations 

select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccs vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 1,2,3

-- CTE to compute the rolling percentage of people vaccinated

with PopVsVacc (location, continent, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date ) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccs vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 1,2,3
)
select *, round((RollingPeopleVaccinated/population)*100,4) as PercentPeopleVaccinated
from popvsvacc

-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccs vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null 
--order by 2,3

Select *, round((RollingPeopleVaccinated/Population)*100,4) PercentPeopleVaccinated
From #PercentPopulationVaccinated
where New_vaccinations is not null and Continent is not null

-- Creating views to store for later visualizations

create view PercentPopulationVaccinated as 
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccs vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--order by 1,2,3

create view GlobalDeathPercentage as 
select sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths, round(sum(new_deaths)/sum(new_cases)*100,3) as GlobalDeathRate
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
--having sum(new_cases) <> 0
--order by 1,2

create view DeathsVsPopulation as
select location, max(total_deaths) as TotalDeathCount, population, round(max((total_deaths/population)*100),4) as DeathPercentage
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by location, population
order by 4 desc

create view HighestInfectionRate as 
select location, population, date, max(total_cases) as HighestInfectionCount, max(round((total_cases/population)*100,4)) as PercentPopulaionInfected
from PortfolioProject..CovidDeaths
--where population >= 100000000
where continent is not null
group by location, population, date
--order by PercentPopulaionInfected desc
select * 
from portfolio_project..covid_deaths$
order by 3,4


--ORDERING table for 
select location, date, total_cases, new_cases, total_deaths, population
from portfolio_project..covid_deaths$
order by 1,2

 --Looking at total cases vs total deaths
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..covid_deaths$ 
order by 1,2

--Looking at death ratio with cases in specific country
select location, date, total_cases, total_deaths, population, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..covid_deaths$
where location like 'india'
order by 1,2

--Looking at death ratio with population in specific country
select location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as death_percentage
from portfolio_project..covid_deaths$
where location like 'india'
order by 1,2

--Looking for countries with highest infection cases
select location,population, MAX(total_cases) as highest_Infection_count,MAX((total_cases/population)*100) as highest_infection_rate
from portfolio_project..covid_deaths$
Group by location, population
order by highest_infection_rate desc

--Looking for countries with highest death rates per population
select location, MAX(CAST(total_deaths as int)) as highest_death_count,MAX((total_deaths/population)*100) as highest_death_rate
from portfolio_project..covid_deaths$
where continent is not null
Group by location
order by highest_death_count desc

 --LETS Break things down by continent
select continent, MAX(cast(total_deaths as int)) as highest_death_count,MAX((total_deaths/population)*100) as highest_death_rate
from portfolio_project..covid_deaths$
where continent is not null
Group by continent
order by highest_death_count desc

--GLOBAL numbers	
select date, sum(cast(new_deaths as int)) as daily_deaths, sum(new_cases) as daily_cases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_case_ratio
from portfolio_project..covid_deaths$
where continent is not null and new_deaths is not null
group by date
order by death_case_ratio desc

-- Joining vaccine table and deaths


select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from portfolio_project..covid_vac$ as vac
join portfolio_project ..covid_deaths$ as dea
	on dea.location= vac.location
	--and dea.date= vac.date
where dea.continent is not null
order by 2,3

--Looking at total population vs vaccinations

Select dea.location, dea.date,dea.population, vac.new_vaccinations 
		 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfolio_project..covid_deaths$ AS dea
JOIN portfolio_project..covid_vac$ AS vac
	ON dea.location = vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null
	ORDER BY 1,2

-- USING CTE TO USE Rolling count Column

WITH PopvsVac(location,date, population, new_vaccination, rolling_count)
as
(
Select dea.location, dea.date,dea.population, vac.new_vaccinations 
		 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfolio_project..covid_deaths$ AS dea
JOIN portfolio_project..covid_vac$ AS vac
	ON dea.location = vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null
	--ORDER BY 1,2
)
SELECT * , (rolling_count/population)*100
FROM PopvsVac

-- Creating TEMP Table

DROP Table if exists rolling_vaccination_count
Create Table rolling_vaccination_count
(
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_count numeric)

Insert into rolling_vaccination_count
Select dea.location, dea.date,dea.population, vac.new_vaccinations 
		 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfolio_project..covid_deaths$ AS dea
JOIN portfolio_project..covid_vac$ AS vac
	ON dea.location = vac.location
	AND dea.date= vac.date
	WHERE dea.continent is not null
	--ORDER BY 1,2

	Select * , (rolling_count/population)*100
	FROM rolling_vaccination_count
	WHERE rolling_count is NOT NULL
	ORDER BY 1,2


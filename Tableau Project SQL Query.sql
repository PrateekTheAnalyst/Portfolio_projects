
-- 1

Select SUM(new_cases) AS total_cases, SUM(CONVERT(BIGINT,total_deaths)) AS total_deaths,(SUM(CONVERT(int,new_deaths))/SUM(new_cases))*100 AS death_cases_percentage 
FROM portfolio_project..covid_deaths$
WHERE continent IS NOT NULL

-- 2
SELECT location, SUM(CONVERT(int, new_deaths)) AS total_death_count
FROM portfolio_project..covid_deaths$
GROUP BY location,continent
HAVING continent is null AND location IN ('North America','Asia','South America','Africa','Europe','Oceania')
ORDER BY total_death_count DESC

-- 3 
SELECT location,population, MAX(total_cases) AS highestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected 
FROM portfolio_project..covid_deaths$
GROUP BY location,population
order by PercentPopulationInfected DESC

-- 4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM portfolio_project..covid_deaths$
WHERE location LIKE 'Lithuania'
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC
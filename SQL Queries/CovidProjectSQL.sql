-- Query all data in the CovidDeaths table and order by location and date.

SELECT *
FROM CovidProjectDatabase..CovidDeaths
ORDER BY 3,4

-- Query all data in the CovidVaccinations table and order by location and date.
SELECT *
FROM CovidProjectDatabase..CovidVaccinations
ORDER BY 3,4

-- Select location,date,total cases, new cases, total deaths and population data from CovidDeaths table
-- order by location and date.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProjectDatabase..CovidDeaths
ORDER BY 1,2

-- Select location,date,total cases, new cases, total deaths and population data from CovidVaccination table
-- order by location and date.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidProjectDatabase..CovidDeaths
ORDER BY 1,2

-- Looking at the Total cases vs Total deaths
-- Shows possibility percentage of dying if you are effected by covid in your country.
-- Here the example country is chosen as USA

SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases) * 100 AS death_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- Total cases vs population percentage in Turkey

SELECT location,date,total_cases,population, (total_cases/population) * 100 AS case_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE location like '%Turkey%'
ORDER BY 1,2

-- Looking at countries with highest infection rate compared to population

SELECT location, population ,MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population)) * 100 AS case_percentage
FROM CovidProjectDatabase..CovidDeaths
GROUP BY location, population
ORDER BY case_percentage DESC


-- Querying countries with highest death count / population
-- Where continent is not null condition is used since data table contains continents such as Europe in location column
-- and those aggregated data has NULL in their continent column.

SELECT location, MAX(CAST (total_deaths AS INT)) AS DeathCount,  MAX((CAST(total_deaths AS INT) /population)) * 100 AS death_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC



-- Two different queries for finding continents total death tolls
-- method 1:
SELECT temp.continent, SUM(DeathCount) AS TotalDeaths
FROM
(

SELECT location, continent, MAX(CAST (total_deaths AS INT)) AS DeathCount
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is not null 
GROUP BY location,continent
) as temp

GROUP BY temp.continent
ORDER BY SUM(DeathCount) DESC

---- method 2:
SELECT location, MAX(CAST (total_deaths AS INT)) AS DeathCount
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is null AND location NOT LIKE '%income%'
GROUP BY location
ORDER BY DeathCount DESC

--day by day world's daily new_case numbers and new death tolls

SELECT date, SUM(new_cases) AS Global_new_cases, SUM(CAST(new_deaths AS INT)) AS Global_new_deaths
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is null
GROUP BY date 
ORDER BY 1,2 

-- below queries show the effect of vaccination on reducing death rates.

---- total case and death toll and death_percentage of the world between '2020-01-22' AND '2020-12-31'
SELECT SUM(new_cases) AS Global_total_cases, SUM(CAST(new_deaths AS INT)) AS Global_total_deaths,  SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is null AND date BETWEEN '2020-01-22' AND '2020-12-31'

---- total case and death toll and death_percentage of the world between '2020-12-31' AND '2022-04-17'

SELECT SUM(new_cases) AS Global_total_cases, SUM(CAST(new_deaths AS INT)) AS Global_total_deaths,  SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is null AND date BETWEEN '2020-12-31' AND '2022-04-17'

---- total case and death toll and death_percentage of the world until  2022-04-18

SELECT SUM(new_cases) AS Global_total_cases, SUM(CAST(new_deaths AS INT)) AS Global_total_deaths,  SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100 AS death_percentage
FROM CovidProjectDatabase..CovidDeaths
WHERE continent is null

-- Looking at total population vs vaccination 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY vac.location  Order by dea.location, dea.Date ) AS Total_vaccination

FROM CovidProjectDatabase..CovidDeaths as dea
JOIN CovidProjectDatabase..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.location NOT LIKE '%income%'  and dea.continent is not null 
ORDER BY 2,3

-- Finding vaccination_percentage in 2022-04-17 for each country using CTE

With VacVsPop (Continent,Location,Date,Population,New_Vaccinations,Total_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY vac.location  Order by dea.location, dea.Date ) AS Total_vaccination

FROM CovidProjectDatabase..CovidDeaths as dea
JOIN CovidProjectDatabase..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.location NOT LIKE '%income%'  and dea.continent is not null 

)

Select Location, MAX(Total_vaccination / Population * 100) AS vaccination_percentage
From VacVsPop
GROUP BY Location
ORDER BY vaccination_percentage DESC

-- Finding vaccination_percentage daily each country using CTE

With VacVsPop (Continent,Location,Date,Population,New_Vaccinations,Total_vaccination)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY vac.location  Order by dea.location, dea.Date ) AS Total_vaccination

FROM CovidProjectDatabase..CovidDeaths as dea
JOIN CovidProjectDatabase..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.location NOT LIKE '%income%'  and dea.continent is not null 

)

Select Location, date, Total_vaccination / Population * 100 AS vaccination_percentage
From VacVsPop


 --Create table for final results

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Total_vaccination numeric,
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY vac.location  Order by dea.location, dea.Date ) AS Total_vaccination

FROM CovidProjectDatabase..CovidDeaths as dea
JOIN CovidProjectDatabase..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.location NOT LIKE '%income%'  and dea.continent is not null 

SELECT *, (Total_vaccination/Population) * 100
From #PercentPopulationVaccinated


--- Creating view to store data for later visualizations

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY vac.location  Order by dea.location, dea.Date ) AS Total_vaccination

FROM CovidProjectDatabase..CovidDeaths as dea
JOIN CovidProjectDatabase..CovidVaccinations as vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.location NOT LIKE '%income%'  and dea.continent is not null 



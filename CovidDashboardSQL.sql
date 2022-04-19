-- Below queries are to prepare custom excel tables in order to create a variety of viz.
-- These graphs will then be merged into a dashboard that you can check out the final version on my Tableau profile.


--  Query for Table 1 excel data 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProjectDatabase..CovidDeaths
where continent is not null 
order by 1,2



-- Query for Table 2 excel data 
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProjectDatabase..CovidDeaths
--Where location like '%states%'
Where continent is null AND location NOT LIKE '%income%'
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--  Query for Table 3 excel data 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProjectDatabase..CovidDeaths
Where location NOT LIKE '%income%'
Group by Location, Population
order by PercentPopulationInfected desc

--  Query for Table 4 excel data 
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  CovidProjectDatabase..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

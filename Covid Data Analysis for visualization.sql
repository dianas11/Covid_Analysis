--1
-------------------------------------------------------------Global Covid Numbers-----------------------------------------------------------------------------
Select SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From [PortfolioProject]..[CovidDeaths$]
where continent is not null
Order by 1,2




--2
----------------------------------------------Total Deaths Per Continent-------------------------------------------------------------------------------
--We take these out as they are not included in the above queries and what to stay consistent
--European Union is part of Europe

Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [PortfolioProject]..[CovidDeaths$]
--where location like '%india'
where continent is null
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



--3
-------------------------------------------------Percentage of Population Infected Per Country--------------------------------------------------------------------------------
--looking at countries with highest infection rate compared to population
-- Countries with Highest Infection Rate compared to Population

Select Location,  Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
Group By Location, Population
Order by PercentPopInfected desc




--4
-------------------------------------------------Percentage of Population Infected Per Country by date--------------------------------------------------------------------------------
Select Location,  Population, date, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
Group By Location, Population, date
Order by PercentPopInfected desc
Select *
From [PortfolioProject]..[CovidDeaths$]
where continent is not null
Order by 3,4

--Select *
--From [PortfolioProject]..[Vaccination$]
--Order by 3,4



--Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From [PortfolioProject]..[CovidDeaths$]
Order by 1,2




--Total cases v/s total deaths
--shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject]..[CovidDeaths$]
Where location like '%india%'
and continent is not null
Order by 1,2



--looking at total deaths v/s population
--Total cases v/s Population
--Shows what percentage of population infected with covid

Select Location, date, total_cases, total_deaths, population, (total_deaths/population)*100 as DeathByPop
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india%'
Order by 1,2



--looking at total cases v/s population
--shows what percentage of population infected with covid

Select Location, date, total_cases, population, (total_cases/population)*100 as CasesByPop
From [PortfolioProject]..[CovidDeaths$]
Where location like '%india%'
Order by 1,2



--looking at countries with highest infection rate compared to population
-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopInfected
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
Group By Location, Population
Order by PercentPopInfected desc



-- Countries with Highest cases per Population

Select Location, MAX(total_cases) as TotalCaseCount
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
Group By Location
Order by TotalCaseCount desc



--Showing countries with highest death cases per population

Select Location, Population, MAX(total_deaths) as HighestDeathCount, MAX(total_deaths/population)*100 as PercentPopDied
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
Group By Location, Population
Order by PercentPopDied desc


Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
where continent is not null
Group By Location
Order by TotalDeathCount desc



--breaking things down by continent
--Showing continents with the highest death count per population
Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
where continent is not null
Group By continent
Order by TotalDeathCount desc






--by location

Select Location, MAX(cast (total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
where continent is null
Group By Location
Order by TotalDeathCount desc




--continents with highest death counts


Select continent, MAX(cast (total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india'
where continent is not null
Group By continent
Order by TotalDeathCount desc


--global numbers

Select date,SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india%'
where continent is not null
Group By date
Order by 1,2

--

Select SUM(new_cases) as SumOfNewCases, SUM(cast(new_deaths as int)) as SumOfNewDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [PortfolioProject]..[CovidDeaths$]
--Where location like '%india%'
where continent is not null
--Group By date
Order by 1,2



--COVID VACCINATION TABLE
Select *
from [PortfolioProject]..[Vaccination$]
Order by 1,2


--Join both tables

Select *
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
   On death.location = vacc.location
   and death.date = vacc.date


--looking at total population v/s vaccinations
--shows percentage of population that has recieved at least one covid vaccine
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(cast(vacc.new_vaccinations as int)) OVER (Partition by death.location)
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
    On death.location = vacc.location
    and death.date = vacc.date
where death.continent is not null
Order by 2,3


--another way to convert the data type is

Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
    On death.location = vacc.location
    and death.date = vacc.date
where death.continent is not null
Order by 2,3



--Using CTE to perform calculation on Partition By in previous query 

With PopVsVacc(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vacc.new_vaccinations, 
SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by death.location Order by death.location, death.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
    On death.location = vacc.location
    and death.date = vacc.date
where death.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVacc



--Using TEMP TABLE to perform calculation on Partition By in previous query

DROP Table if exists #PercentPopVaccinated --for making alterations 
Create TABLE #PercentPopVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by death.Location ORDER BY death.location, death.date) 
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
   ON death.location = vacc.location 
   and death.date = vacc.date
--WHERE death.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopVaccinated




--Creating view to store data for later visualizations

CREATE View PercentPopulationVaccinated as
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CONVERT(int, vacc.new_vaccinations)) OVER (Partition by death.Location ORDER BY death.location, death.date) 
as RollingPeopleVaccinated
FROM [PortfolioProject]..[CovidDeaths$] as death
JOIN [PortfolioProject]..[Vaccination$] as vacc
   ON death.location = vacc.location 
   and death.date = vacc.date
WHERE death.continent is not null
--ORDER BY 2,3

select *
from PercentPopulationVaccinated

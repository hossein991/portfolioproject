Select * 
From PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccinations$
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population 
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- Total Cases vs Total Deaths 
-- shows the likelihood of dying if you contract covid in your country 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
where continent is not null
order by 1,2

-- Total cases vs Population
-- shows what percentage of population got covid
SELECT Location, date,  population, total_cases, (total_cases/population)*100 as percentpopulationonfected
From PortfolioProject..CovidDeaths$
WHERE Location like '%states%'
where continent is not null
order by 1,2 

-- looking at countries with highest infection rate compared to population 
SELECT Location, population, MAX(total_cases) as HighestinfactionCount, MAX((total_cases/population))*100 as percentpopulationonfected
From PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
where continent is not null
group by Location, population
order by percentpopulationonfected desc 

-- let's break things down by continent 


-- countries with highest deaths count per population 
SELECT Location, MAX(cast(total_deaths as int)) as TotaldeathsCount
From PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
where continent is not null
group by Location
order by TotaldeathsCount desc
-- test 
SELECT Location, MAX(cast(total_deaths as int)) as TotaldeathsCount
From PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
where continent is null
group by Location
order by TotaldeathsCount desc

-- continent whit highest deaths count per population 
SELECT continent, MAX(cast(total_deaths as int)) as TotaldeathsCount
From PortfolioProject..CovidDeaths$
--WHERE Location like '%states%'
where continent is not null
group by continent
order by TotaldeathsCount desc

-- GLOBAL NUMBERS 
SELECT  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths$
-- WHERE Location like '%states%'
where continent is not null
group by date 
order by 1,2

SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage  
From PortfolioProject..CovidDeaths$
-- WHERE Location like '%states%'
where continent is not null
--group by date 
order by 1,2

-- total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations 
, SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as accumalationpeoplevaccinated --,
accumalationpeoplevaccinated /population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vacc
    ON dea.location = vacc.location 
	and dea.date= vacc.date 
	where dea.continent is not null
	order by 2,3

	-- USE CTE 
	With Popvsvacc (continent, location, Date, Population, new_vaccinations, accumalationpeoplevaccinated) as 
	(
	SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations 
, SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as accumalationpeoplevaccinated 
--,accumalationpeoplevaccinated /population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vacc
    ON dea.location = vacc.location 
	and dea.date= vacc.date 
	where dea.continent is not null
	--order by 2,3 
	) 
	Select *, (accumalationpeoplevaccinated /population)*100 
	FROM Popvsvacc 


	-- Temp table
	Drop table if exists #PercentPopulationVaccinated
	create table #PercentPopulationVaccinated
	(continent nvarchar(255),
	location nvarchar(255), 
	date datetime,
	population numeric,
	new_vaccination numeric,
	accumalationpeoplevaccinated numeric
	)
	Insert into #PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations 
, SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as accumalationpeoplevaccinated 
--,accumalationpeoplevaccinated /population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vacc
    ON dea.location = vacc.location 
	and dea.date= vacc.date 
	--where dea.continent is not null
	--order by 2,3

	Select *, (accumalationpeoplevaccinated /population)*100 
	FROM  #PercentPopulationVaccinated

	-- Creating view to store data for later visualisation 

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations 
, SUM(CONVERT(int,vacc.new_vaccinations )) OVER (Partition by dea.Location order by dea.location, dea.date) as accumalationpeoplevaccinated 
--,accumalationpeoplevaccinated /population)*100 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..Covidvaccinations$ vacc
    ON dea.location = vacc.location 
	and dea.date= vacc.date 
where dea.continent is not null
	--order by 2,3
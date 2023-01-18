select * from
PortfolioProject..['CovidDeath]
where continent is not null 
order by 3,4 

select *
from PortfolioProject..['Covid Vaccination]
order by 3,4 

--Select data that we are going to be using 

select location, date, total_cases, new_cases, total_deaths, population from 
PortfolioProject..['CovidDeath]
order by 1,2 



-- Looking at the total cases vs total death 

select location, date, total_cases, total_deaths, (total_deaths /total_cases) *100 as DeathPercentage from 
PortfolioProject..['CovidDeath]
order by 1,2 

--Looking at total cases vs population 
--shows what percentage of population got covid 
select location, date,population,total_cases, (total_cases /population) *100 as CovidPercentage from 
PortfolioProject..['CovidDeath]
--where location like '%Bangladesh%'
order by 1,2 

-- Looking at countries with highest infection rate compared to population 

select location,population,MAX (total_cases) AS highestinfectioncount, Max ((total_cases /population)) *100 as CovidPercentage from 
PortfolioProject..['CovidDeath]
--where location like '%Bangladesh%'
Group By Location, population
order by CovidPercentage desc



--showing countries with highest death count per population 

select location, MAX (cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeath]
--where location like '%Bangladesh%'
where continent is not null 
Group By Location
order by TotalDeathCount desc



--lets's break things down by continent 

select continent, MAX (cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeath]
--where location like '%Bangladesh%'
where continent is not null 
Group By continent
order by TotalDeathCount desc


--showing the continents with highest death counts per population 

select continent, MAX (cast (total_deaths as int)) as TotalDeathCount
from PortfolioProject..['CovidDeath]
--where location like '%Bangladesh%'
where continent is not null 
Group By continent
order by TotalDeathCount desc


--Global Numbers 

select SUM(new_cases) as TotalCases, 
SUM (cast (new_deaths as int)) as TotalDeath, SUM (cast (new_deaths as int))/SUM (new_cases)*100 as deathpercentage 
from PortfolioProject..['CovidDeath]
where continent IS NOT NULL 
--GROUP BY date 
ORDER BY 1, 2

--Looking at total population vs vaccination 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE 

WITH PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopVsVac


--TEMP TABLE 

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar (255),
location nvarchar (255),
Date datetime,
Population numeric, 
New_Vaccination numeric, 
RollingPeopleVaccinated numeric 
)

Insert Into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


--Creating view to store data for later visualizations 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert (int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..['CovidDeath] dea
join PortfolioProject..['Covid Vaccination] vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from
PercentPopulationVaccinated
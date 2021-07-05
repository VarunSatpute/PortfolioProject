select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--calculating death percentage
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--calculating the percentage of population infected
select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where location = 'India' 
and where continent is not null
order by 1, 2


--finding the country with highest percentage of population infected
select location, population, max(cast(total_cases as int)) as highestInfectionCount, max((cast(total_cases as int)/population)*100) as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc


--finding the percentage of death per population by country
select location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((cast(total_deaths as int)/population)*100) as DeathPerPopulationPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by 4 desc


--finding the percentage of death per population by continents
select location, population, max(cast(total_deaths as int)) as TotalDeathCount, max((cast(total_deaths as int)/population)*100) as DeathPerPopulationPercentage
from PortfolioProject..CovidDeaths
where continent is null
group by location, population
order by 4 desc


--Global Numbers

--death percentage across the globe versus date
select date, sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1, 2

--total cases, total deaths and death percentage across the world
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as totalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


--Vaccinations

-- looking at total population vs total vaccinations
Select dea.location, dea.population, max(cast(vac.total_vaccinations as bigint)) as Vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
group by dea.location, dea.population
order by Vaccinations desc

-- looking at total population vs vaccinations vs time
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
order by 2, 3


--USE CTE
With PopvsVac(continent, location, date, population, New_Vaccination, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
)
Select *, (max(RollingPeopleVaccinated)/population)*100 as PercentagePopulationVaccinated
From PopvsVac

--Percentage of Population Vaccinated
Select dea.location, dea.population, max(cast(vac.people_vaccinated as bigint)) as PeopleVaccinated, (max(cast(vac.people_vaccinated as bigint))/dea.population)*100 as PercentagePopulationVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Group By dea.location, dea.population
Order By (max(cast(vac.people_vaccinated as bigint))/dea.population)*100 desc

--Percentage of Population Fully Vaccinated
Select dea.location, dea.population, max(cast(vac.people_fully_vaccinated as bigint)) as PeopleFullyVaccinated, (max(cast(vac.people_fully_vaccinated as bigint))/dea.population)*100 as PercentagePopulationFullyVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
Group By dea.location, dea.population
Order By (max(cast(vac.people_fully_vaccinated as bigint))/dea.population)*100 desc

--Creating a View to Store Data for later visualizations
Create View PercentPopulationVaccinated as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, Sum(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent is not null
)

Select * from PercentPopulationVaccinated
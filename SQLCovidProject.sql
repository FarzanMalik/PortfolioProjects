Select *
From CovidDeaths
Where continent is not null
Order by location, date

--Select *
--From CovidVaccinations
--Order by location, date


-- Data we are going to work with

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths
Where continent is not null
Order by location, date


-- Looking at total cases vs Total Deaths
-- Shows the likelihood of a person dying in case of contracting COVID in INDIA (across varios dates)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS Death_Percentage
From CovidDeaths
Where location = 'india' and continent is not null
Order by location, date


-- Looking at Total cases vs Population
-- Shows what percentage of population in INDIA contracted COVID (across various dates)

Select location, date, total_cases, population, (total_cases/population) * 100 AS Infection_Percentage
From CovidDeaths
Where continent is not null and location = 'india'
Order by location, date



-- Percentage of Population Infected & Died in INDIA


Select location, population, SUM(new_cases) as total_cases, (SUM(new_cases)/population) * 100 as total_infection_percentage,
MAX(cast(total_deaths as int))as total_deaths, MAX(cast(total_deaths as int))/ population * 100 as total_death_percentage
From CovidDeaths
Where location = 'india' and continent is not  null
Group by location, population


-- Countries with Highest infection Rate compared to population

Select location, population, max(total_cases) as highest_infection_count, (max(total_cases)/population) * 100 AS Infection_Percentage
From CovidDeaths
Where continent is not null
Group by location, population
Order by Infection_Percentage desc


-- Countries with Highest Infection Cases per Population

Select continent, location, population, MAX(total_cases) as Number_of_Infection_Cases
From CovidDeaths
Where continent is not null
Group by continent, location, population
Order by Number_of_Infection_Cases Desc




-- Countries with Highest Deathcount per Population

Select continent, location, population, max(cast(total_deaths as int)) As highest_death_count   -- (max(total_deaths)/population) * 100 as DeathPercentage_Population
From CovidDeaths
Where continent is not null
Group by continent, location, population
Order by highest_death_count Desc	-- DeathPercentage_Population desc

 

-- LET'S BREAK THINGS DOWN ON THE BASIS OF CONTINENET


-- Showing contintents with the highest death count

Select continent, max(cast(total_deaths as int)) As highest_death_count
From CovidDeaths
Where continent is not null
Group by continent
Order by highest_death_count Desc


-- TOTAL NUMBER OF CASES & DEATHS ON CONTINENTAL BASIS

Select continent, Sum(Distinct(population)) as TotalContinentPopulation, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
		SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathInfectionPercentage
From CovidDeaths
Where continent is not null
Group by continent
Order by continent


-- GLOBAL NUMBERS

-- Number of new cases and new deaths each day globally
Select
	date,
	sum(new_cases) as cases_each_day_globally,
	sum(cast(new_deaths as int)) as deaths_each_day_globally,
	(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as death_case_ratio_eachday_globally
From CovidDeaths
Where continent is not null
Group by date
Order by date


-- Total Cases & Total Deaths Globally & their Ratio
Select
	sum(new_cases) as total_cases_globally,
	sum(cast(new_deaths as int)) as total_deaths_globally,
	(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as death_case_percentage_globally
From CovidDeaths
Where continent is not null
--Order by 1


-- Looking at Total population vs Vaccination

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as bigint))
OVER (PARTITION BY CD.location Order by CD.location, CD.date) as Rolling_People_Vaccinated
 -- (Rolling_People_Vaccination)/population) * 100
From CovidDeaths CD
Join CovidVaccinations CV
	On CD.location = CV.location
	And CD.date = CV.date
Where CD.continent is not null
Order by location, date


-- Using CTE

WITH PopvsVacc (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
As 
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as bigint))
OVER (PARTITION BY CD.location Order by CD.location, CD.date) as Rolling_People_Vaccinated
 -- (Rolling_People_Vaccination)/population) * 100
From CovidDeaths CD
Join CovidVaccinations CV
	On CD.location = CV.location
	And CD.date = CV.date
where CD.continent is not null
-- Order by location, date
)

Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVacc
Order by location, date


-- TEMP TABLE

Drop Table if exists #PercentPoulationVaccinated
Create Table #PercentPoulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPoulationVaccinated

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as bigint))
OVER (PARTITION BY CD.location Order by CD.location, CD.date) as Rolling_People_Vaccinated
 -- (Rolling_People_Vaccination)/population) * 100
From CovidDeaths CD
Join CovidVaccinations CV
	On CD.location = CV.location
	And CD.date = CV.date
where CD.continent is not null
-- Order by location, date

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPoulationVaccinated


-- CREATING VIEW TO STORE DATA FOR LATER

Create View PercentPoulationVaccinated As 

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as bigint))
OVER (PARTITION BY CD.location Order by CD.location, CD.date) as Rolling_People_Vaccinated
 -- (Rolling_People_Vaccination)/population) * 100
From CovidDeaths CD
Join CovidVaccinations CV
	On CD.location = CV.location
	And CD.date = CV.date
where CD.continent is not null
-- Order by location, date


Select *
From PercentPoulationVaccinated
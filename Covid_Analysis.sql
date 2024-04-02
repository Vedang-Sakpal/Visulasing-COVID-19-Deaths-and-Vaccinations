SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4;


--Selecting data that we have to work on 

SELECT Location,date,total_cases,New_cases, total_deaths , population 
from PortfolioProject..CovidDeaths
order by 1,2;

-- Total Cases VS total Deaths percentage  

SELECT Location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
order by 1,2;

--Total Cases VS Population 

SELECT Location,date,total_cases, Population, (total_cases/population)*100 as Infected_percentage
from PortfolioProject..CovidDeaths
order by 1,2;

-- maximum infection rate of each country 

SELECT Location,MAX(total_cases) as max_cases, Population, MAX((total_cases/population))*100 as Infected_percentage
from PortfolioProject..CovidDeaths
GROUP BY Location, Population
order by Infected_percentage DESC;

--highest number of Deaths in each country 

SELECT Location,Max(cast(total_deaths as int)) as max_deaths 
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL                 -- TO REMOVE THE EXTRA CONTINENT NAME IN THE COLUMN LOCATION
GROUP BY Location
order by max_deaths DESC;


SELECT continent,Max(cast(total_deaths as int)) as max_deaths 
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL                 
GROUP BY continent
order by max_deaths DESC;

-- Total cases and deth according to date 

SELECT date,SUM(new_cases)AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as Death_percentage
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date 
order by 1,2;

-- Overall total cases and deaths 

SELECT SUM(new_cases)AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths,(SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100 as Death_percentage
from PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2;


-- The Total Population VS Vacination done ..

Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3;


--Using CTE

WITH Population_VS_Vaccination (continent, location, date, population,new_vacinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From Population_VS_Vaccination;


-- Creating a tempory table 


CREATE TABLE Percent_people_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO Percent_people_Vaccinated
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date;
--where death.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From Percent_people_Vaccinated;


-- Creating a view for data visulisation 

CREATE VIEW PercentPeopleVaccinated as
Select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations
, SUM(CONVERT(int,vaccine.new_vaccinations)) OVER (Partition by death.Location Order by death.location, death.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vaccine
	On death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null


Select * from PercentPeopleVaccinated 
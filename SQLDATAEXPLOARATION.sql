
--the date is till 30 april 21 from 24 2 2020
--The coloumns that I will use for data exploration

select date,continent,location,total_cases,new_cases,total_deaths,population from PortfolioDatabase..CovidDeaths$


--Likelihood that you will die if you get covid in your country
Select Date,Location,(total_deaths/total_cases)*100 As DeathRate from PortfolioDatabase..CovidDeaths$ where continent is not null order by 2,1  ;

--The ratio of people getting covid with respect to total population in your country
Select Date,Location,Population,(total_cases/population)*100 As InfectionRate from PortfolioDatabase..CovidDeaths$ where continent is not null order by 2,1

--The highest infection rate compared to population in your country
Select Location,Population,max(total_cases) As HighestInfectionCount, Max((total_cases/population)*100 )As HighestInfectionRate
from PortfolioDatabase..CovidDeaths$ where continent is not null group by Location,population order by HighestInfectionRate Desc

--Countries having highest death rate compared to population
Select Location,Population,max(total_deaths) As HighestDeathCount, Max((total_deaths/population)*100 )As HighestDeathRate
from PortfolioDatabase..CovidDeaths$ where continent is not null  group by Location,population order by HighestDeathRate desc


--BREAK THINGS BY CONTINENT
--Highest deaths in each continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioDatabase..CovidDeaths$
Where continent is not null 
Group by continent
order by TotalDeathCount desc

--Likelihood that you will die if you get covid in your continent 
Select date,continent, (total_deaths/total_cases)*100 AS rateofDying from PortfolioDatabase..CovidDeaths$ where continent is not null order by 1 Desc,2 

--Select top 1 date,continent,location,total_cases,new_cases,total_deaths,population from CovidDeaths$ order by date desc

--Select continent,sum(population)AS totalpopulation,from CovidDeaths$ where continent is not null AND date='2021-04-30' group by continent ;

--Global death percentage if you get covid wise
Select date,sum(new_cases) as total_case,sum(cast(new_deaths as int)) as total_death,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage from PortfolioDatabase..CovidDeaths$ where continent is not null group by date
order by 1 desc ;
--Global death percentage uptill 30 april 2021
Select sum(new_cases) as total_case,sum(cast(new_deaths as int)) as total_death,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage from PortfolioDatabase..CovidDeaths$ where continent is not null 
order by 1 desc ;


--Total people vaccinated VS total population
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(Convert(int,cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.date,cd.location) as rollingSumOfPeopleVaccinated
from PortfolioDatabase..CovidDeaths$ cd join PortfolioDatabase..CovidVaccinations$ cv 
ON cd.location=cv.location AND cd.date=cv.date 
Where cd.continent is not null 
order by 2,3


--Total people vaccinated percentage wrt total population of a country by a CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(Convert(int,cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.date,cd.location) as rollingSumOfPeopleVaccinated
from PortfolioDatabase..CovidDeaths$ cd join PortfolioDatabase..CovidVaccinations$ cv 
ON cd.location=cv.location AND cd.date=cv.date 
Where cd.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100 VaccinatonPercentage
From PopvsVac


--Total people vaccinated percentage wrt total population of a country by a TEMP TABLE
DROP Table if exists #Popsvac

Create table #PopvsVac(
Continent varchar(100), Location varchar(100), Date datetime, Population bigint, New_Vaccinations int, 
RollingPeopleVaccinated int)

Insert into #PopvsVac 
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(Convert(int,cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.date,cd.location) as rollingSumOfPeopleVaccinated
from PortfolioDatabase..CovidDeaths$ cd join PortfolioDatabase..CovidVaccinations$ cv 
ON cd.location=cv.location AND cd.date=cv.date 


Select * ,(rollingpeoplevaccinated/Population)*100 as VaccinatonPercentage from #PopvsVac

-- Creating View to store data for later visualizations


Create View PercentPopulationVaccinated AS
Select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, SUM(Convert(int,cv.new_vaccinations)) 
OVER (Partition by cd.location order by cd.date,cd.location) as rollingSumOfPeopleVaccinated
from PortfolioDatabase..CovidDeaths$ cd join PortfolioDatabase..CovidVaccinations$ cv s
ON cd.location=cv.location AND cd.date=cv.date 
Where cd.continent is not null 





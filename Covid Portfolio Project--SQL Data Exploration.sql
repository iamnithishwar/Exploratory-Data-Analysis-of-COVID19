Select *
from [Portfolio-projects].dbo.CovidDeaths
where continent is not null                                      --To avoid the visualization about Continent 
order by 3,4                                                     --In data frame, some of the continents value is null that's why i used not null.

--Select *
--from [Portfolio-projects].dbo.CovidVaccinations
--order by 3,4

--selecting data that i'm going to be using
select location,date, total_cases, new_cases, total_deaths, population
from CovidDeaths 
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- Shows likelihood of dying if you contract covid in your country
select location,date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Deathpercentage
from CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2


--Looking at total cases vs population
--Shows what percentage of population got covid
select location,date, population, total_cases, (total_cases/population) * 100 as percentageofpopulation_infected
from CovidDeaths
--where location like '%india%'
where continent is not null
order by 1,2



--Looking at countries with highest infection rate compared to population 
select location, population, MAX(total_cases) as highestinfectioncount, MAX((total_cases/population)) * 100 as percentageofpopulation_infected
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by location, population
order by percentageofpopulation_infected desc


--Showing countries with highest death count per population
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by location
order by totaldeathcount desc



--LETs break things down by continent

--Showing continents with the highest death counts per population
select continent, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths
--where location like '%india%'
where continent is not null
Group by continent
order by totaldeathcount desc

--Global Numbers
select date, sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases) * 100 as Deathpercentage
from CovidDeaths
--where location like '%india%'
Where continent is not null
group by  date                                                  --we can't use the date for group by as there is lot of things in a row so we need to use aggregate function to correct this.
order by 1,2                                                   --We can't use 2 aggregate function at same time like sum(max(new_cases) and so on



--Global numbers without group by date.
select sum(new_cases) as total_cases,  sum(cast(new_deaths as int)) as total_deaths,  sum(cast(new_deaths as int))/sum(new_cases) * 100 as Deathpercentage
from CovidDeaths
--where location like '%india%'
Where continent is not null
--group by  date                                                  --we can't use the date for group by as there is lot of things in a row so we need to use aggregate function to correct this.
order by 1,2 
 


--Let's join the both tables                                        
select *
from CovidDeaths as cd
join CovidVaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date


--Looking at total population vs Vaccination
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date)  as Rollingpeoplevaccinated                     --we used partition by because everytime i guess the location, i want the count to start over, not want that aggregate function keep running and running.
--(Rollingpeoplevaccinated/population) * 100                                 --we can't use the column that you just created likw rollingpeoplevaccinated,To use that we have to use CTEs or Temp table.
from CovidDeaths as cd
join CovidVaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null
 order by 2,3


 --Using CTEs

 with PopvsVac(continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated)
 as
 (
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date)  as Rollingpeoplevaccinated                     --we used partition by because everytime i guess the location, i want the count to start over, not want that aggregate function keep running and running.
--(Rollingpeoplevaccinated/population) * 100                                 --we can't use the column that you just created likw rollingpeoplevaccinated,To use that we have to use CTEs or Temp table.
from CovidDeaths as cd
join CovidVaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null
--order by 2,3
 )

 select *, (Rollingpeoplevaccinated/population) * 100
 from PopvsVac


  --Using Temp table
  Drop table  if exists #percentpopulationvaccinated
  Create table #percentpopulationvaccinated
  (
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  Rollingpeoplevaccinated numeric
  )


  insert into #percentpopulationvaccinated
  select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date)  as Rollingpeoplevaccinated                     --we used partition by because everytime i guess the location, i want the count to start over, not want that aggregate function keep running and running.
--(Rollingpeoplevaccinated/population) * 100                                 --we can't use the column that you just created likw rollingpeoplevaccinated,To use that we have to use CTEs or Temp table.
from CovidDeaths as cd
join CovidVaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
--where cd.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/population) * 100
 from #percentpopulationvaccinated



 --Creating view to store data for later visualizations

 create view percentpopulationvaccinated as
 select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations,
sum(convert(int, cv.new_vaccinations)) over (partition by cd.location order by cd.location, cd.date)  as Rollingpeoplevaccinated                     --we used partition by because everytime i guess the location, i want the count to start over, not want that aggregate function keep running and running.
--(Rollingpeoplevaccinated/population) * 100                                 --we can't use the column that you just created likw rollingpeoplevaccinated,To use that we have to use CTEs or Temp table.
from CovidDeaths as cd
join CovidVaccinations as cv
 on cd.location = cv.location
 and cd.date = cv.date
 where cd.continent is not null
 --order by 2,3

 select *
 from percentpopulationvaccinated
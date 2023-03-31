SELeCT *
FROM [PortFolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3, 4


--SELeCT *
--FROM [PortFolio Project]..CovidVaccinations
--ORDER BY 3, 4


----------Select data that we aer going to be using

SELeCT location, date, total_cases, new_cases, total_deaths, population 
FROM [PortFolio Project]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at total_cases vs total_dealths 

SELeCT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathsPercentage
FROM [PortFolio Project]..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2


--Looking at total_cases vs Population
--showing what percentage of population got covid

SELeCT location, date, Population, total_cases, (total_cases/population) *100 PercentagePopulationInfected
FROM [PortFolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Countries with highest population infected rate compaaried to population 

SELeCT location, Population, Max (total_cases) AS HighestInfectionCount,  Max((total_cases/population)) *100 PercentagePopulationInfected
FROM [PortFolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, Population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with Highest DeathCount per Population

SELeCT location, Max(cast(total_deaths AS int)) AS TotalDeathCount 
FROM [PortFolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC


--LET'S BREAK THINGS DOWN BY COUNTINENET
--Showing continents wo=ith the highest daeth count per population 

SELeCT continent, Max(cast(total_deaths AS int)) AS TotalDeathCount 
FROM [PortFolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELeCT  SUM(new_cases) as total_cases, SUM(Cast(new_deaths as int)) as total_deaths, SUM(Cast(new_deaths as int))/SUM(new_cases) *100 AS DeathsPercentage
FROM [PortFolio Project]..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at the total  population vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population) *100
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	WHERE dea.continent is NOT NULL
	ORDER BY 2,3


--- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [PortFolio Project]..CovidDeaths dea
JOIN [PortFolio Project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

SELECT *
FROM PercentPopulationVaccinated
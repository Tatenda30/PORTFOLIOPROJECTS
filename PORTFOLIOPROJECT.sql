SELECT *
FROM CovidCases
ORDER BY 3,4

--LOOKING AT TOTAL CASES VS TOTAL DEATHS



SELECT location ,COUNT (total_deaths) AS TotaldeathsByContinent,COUNT (total_cases) AS TotalcasessByContinent
FROM PotifolioProject.dbo.CovidCases 
WHERE location IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania')
GROUP BY location
ORDER BY location

SELECT location ,COUNT (total_cases) AS TotalCasesInTheWORLD
FROM PotifolioProject.dbo.CovidCases 
WHERE location IN ('World')
GROUP BY location
ORDER BY location

SELECT location ,COUNT (total_deaths) AS TotalDeathsByINCOME,COUNT (total_cases) AS TotalCaseSByINCOME
FROM PotifolioProject.dbo.CovidCases 
WHERE location IN ('Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome','High income','Upper middle income','Lower middle income' )
GROUP BY location
ORDER BY location



--SHOWS THE LIKELYHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

SELECT location, date, total_cases, new_cases, total_deaths, (new_cases/total_deaths)*100 AS DeathRate
FROM PotifolioProject.dbo.CovidCases 
WHERE location LIKE '%Zimbabwe%'
ORDER BY 1,2

SELECT location, date, total_cases, new_cases, total_deaths, (new_deaths/total_deaths)*100 AS DeathRate
FROM PotifolioProject.dbo.CovidCases 
WHERE location LIKE '%Zimbabwe%'
ORDER BY 1,2

--looking at countries with highest infection rate
SELECT  location, max (total_cases) AS TotalCasesCount ,max(total_deaths) AS TotalDeathsCount
FROM PotifolioProject.dbo.CovidCases 
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome','High income','Upper middle income','Lower middle income' )
GROUP BY location
ORDER BY TotalCasesCount DESC



SELECT date, location,MAX(total_deaths) as TotalDeathCount
FROM PotifolioProject.dbo.CovidCases 
GROUP BY date,location 
ORDER BY TotalDeathCount DESC

SELECT date, Location, COUNT(cast (total_deaths as int)) as totaldeathcount
FROM PotifolioProject.dbo.CovidCases 
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
GROUP BY date,location
ORDER BY date

--infection rate and death rate

SELECT POP.location,Population,total_cases,total_deaths,(total_cases*100000/Population)AS Infectionrateper100K,(total_deaths*100000/Population)AS deathrateper100k
FROM PotifolioProject.dbo.POPULATION1 POP
JOIN PotifolioProject.dbo.CovidCases COV
ON POP.location=COV.location
ORDER BY POP.location;

SELECT location,Population,TotalCasesCount,TotalDeathsCount,(CONVERT(bigint,TotalCasesCount)*100000/Population) AS Infectionrateper100K,(CONVERT(bigint,TotalDeathsCount)*100000/Population )AS deathrateper100k
FROM PotifolioProject.dbo.POPULATION1 
ORDER BY location;






--Cummulative totals

SELECT date,SUM(total_cases) AS CumulativeTotalCases
FROM PotifolioProject.dbo.CovidCases 
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
GROUP BY date
ORDER BY date;

SELECT date,SUM(total_deaths) AS CumulativeTotalDeaths
FROM PotifolioProject.dbo.CovidCases 
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
GROUP BY date
ORDER BY date;

--Weekely and Biweekly Average
SELECT date,AVG(new_cases) AS WeeklyAvgNewCases
FROM PotifolioProject.dbo.CovidCases 
GROUP BY date
ORDER BY date;

--Case Fatality rate

SELECT date, (total_deaths/total_cases)*100 AS Casefatalityrate
FROM CovidCases;

WITH CovidCases_cte AS (
SELECT date,location,total_cases,total_deaths
FROM PotifolioProject.dbo.CovidCases
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
)

SELECT date, (total_deaths/total_cases)*100 AS Casefatalityrate
FROM CovidCases;


--Growth Rates
SELECT date,location,
CASE
  WHEN LAG(new_cases,14) OVER (PARTITION BY location ORDER BY date)=0 THEN NULL--HANDLE DIVIDE BY ZERO ERROR
  ELSE (new_cases-LAG(new_cases,14)OVER (PARTITION BY location ORDER BY date))/LAG(new_cases,14) OVER (PARTITION BY location ORDER BY date) * 100
END AS 
PecentChangeBiweekly
FROM PotifolioProject.dbo.CovidCases
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
ORDER BY date;


--global numbers
SELECT SUM(new_cases)as total_cases, SUM (cast(new_deaths as int))AS total_death, SUM(cast (new_deaths as int))/SUM(new_cases)*100 AS deathpercentage
FROM PotifolioProject.dbo.CovidCases 
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')
ORDER BY 1,2

SELECT *
FROM vaccination

SELECT DATE_UPDATED,TOTAL_VACCINATIONS_PER100,PERSONS_VACCINATED_1PLUS_DOSE_PER100
FROM vaccination;

SELECT *
FROM PotifolioProject.dbo.CovidCases cas
JOIN PotifolioProject.dbo.vaccination vac
ON cas.location=vac.COUNTRY
AND cas.date=vac.DATE_UPDATED

-
--vaccination progress over time

SELECT *
FROM vaccination VAC
JOIN POPULATION1 POP
ON VAC.COUNTRY=POP.location

--Percentage of people vaccinated

SELECT location,Population,TOTAL_VACCINATIONS,(TOTAL_VACCINATIONS/Population)*100  AS Percentagevaccinated
FROM PotifolioProject.dbo.POPULATION1 POP
JOIN PotifolioProject.dbo.vaccination VAC
ON POP.location=VAC.COUNTRY
ORDER BY POP.location


--Coparative Analysis

SELECT WHO_REGION, SUM(new_cases) AS Totalnewcases,SUM(new_deaths) AS TOtalnewdeaths,SUM (TOTAL_VACCINATIONS) AS totalvacciations
FROM PotifolioProject.dbo.CovidCases cas
JOIN PotifolioProject.dbo.vaccination vac
ON cas.location=vac.COUNTRY
AND cas.date=vac.DATE_UPDATED
GROUP BY WHO_REGION;

--Rolling Average

SELECT date,location,AVG(new_cases)OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sevendayrollingavgnewdeaths,
AVG(TOTAL_VACCINATIONS) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sevendayrollingavgvaccination
FROM PotifolioProject.dbo.CovidCases cas
JOIN PotifolioProject.dbo.vaccination vac
ON cas.location=vac.COUNTRY
AND cas.date=vac.DATE_UPDATED

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)




CREATE VIEW sevendayrollingavgvaccination AS
SELECT date,location,AVG(new_cases)OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sevendayrollingavgnewdeaths,
AVG(TOTAL_VACCINATIONS) OVER (PARTITION BY location ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sevendayrollingavgvaccination
FROM PotifolioProject.dbo.CovidCases cas
JOIN PotifolioProject.dbo.vaccination vac
ON cas.location=vac.COUNTRY
AND cas.date=vac.DATE_UPDATED
WHERE location NOT IN ('Asia','Africa','Europe','North America','South America','Antarctica','Oceania','World','Higher Income','Higher Middle Income','Lower Income','Lower Middle Inicome')


CREATE VIEW Deathrateper100k AS
SELECT location,Population,TotalCasesCount,TotalDeathsCount,(CONVERT(bigint,TotalCasesCount)*100000/Population) AS Infectionrateper100K,(CONVERT(bigint,TotalDeathsCount)*100000/Population )AS deathrateper100k
FROM PotifolioProject.dbo.POPULATION1 
ORDER BY location;
































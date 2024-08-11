


/*
COVID-19 Data Exploration 

Skills & Functions used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Selecting Data that we are going to be starting with

SELECT * FROM CovidDeaths 
ORDER BY 3, 4; 

SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 3, 4; 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2; 


--- Total Cases vs Total Deaths 
--- Shows the likehood of dying if COVID is contracted in Canada

SELECT location, date, total_cases, new_cases, total_deaths,
ROUND((total_deaths/total_cases)*100, 4) AS Death_Percentage   
FROM CovidDeaths
WHERE location = 'Canada' 
AND continent IS NOT NULL 
ORDER BY 1, 2; 


--- Total Cases vs Number of People Hospitalized
--- Shows the probability of being hospitalized if COVID is contracted in Ireland

SELECT location, date, total_cases, hosp_patients, total_deaths,
ROUND((hosp_patients/total_cases)*100, 4) AS Hospitalization_Percentage   
FROM CovidDeaths
WHERE location LIKE '%Ireland%'
AND continent IS NOT NULL 
ORDER BY 1, 2; 


--- Total Cases Vs Population  
--- Shows what percentage of the population is infected with COVID in the UK

SELECT location, date, population, total_cases,
(total_cases/population)*100 AS Infection_Percentage   
FROM CovidDeaths
WHERE location = 'United Kingdom'
AND continent IS NOT NULL 
ORDER BY 1, 2; 


--- Countries that have the highest infection rate per population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, 
ROUND(MAX(total_cases/population)*100, 4) AS Infection_Percentage   
FROM CovidDeaths 
GROUP BY location, population
ORDER BY Infection_Percentage DESC; 


--- Countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location 
ORDER BY Total_Death_Count DESC; 


-- BREAKING THINGS DOWN BY CONTINENT

--- Continents that have the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS Total_Death_Count 
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY Total_Death_Count DESC;  


--- GLOBAL NUMBERS

--- Showing Total COVID Cases, Total Deaths, and Death Percentage globally    

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS Death_Percentage   
FROM CovidDeaths
WHERE continent IS NOT NULL  
ORDER BY 1, 2; 


-- Total Population vs Vaccinations
-- Shows the total number of people who have received at least one COVID Vaccine till date 

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
ORDER BY 2, 3;


-- Shows the total number of people who have received at least one COVID Vaccine till date (using a Window Function)  

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER w AS Rolling_People_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL   
WINDOW w AS (PARTITION BY cd.location ORDER BY cd.location, cd.date)
ORDER BY 2, 3; 


-- Shows the Percentage of the Population who have received at least one COVID Vaccine till date (using a CTE) 

WITH PopvsVacc (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated) AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
) 
SELECT *, (Rolling_People_Vaccinated/population)*100 AS Vaccination_Percentage 
FROM PopvsVacc
; 
 

-- Shows the Percentage of the Population who have received at least one COVID Vaccine till date (using a Temporary Table) 

DROP TABLE IF EXISTS PopulationVaccination_Percent
CREATE TABLE PopulationVaccination_Percent
( 
continent nvarchar(255), 
location nvarchar(255),  
date datetime, 
population numeric,
new_vaccinations numeric, 
Rolling_People_Vaccinated numeric
)

INSERT INTO PopulationVaccination_Percent
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 

SELECT *, (Rolling_People_Vaccinated/population)*100 AS Vaccination_Percentage 
FROM PopulationVaccination_Percent
; 


--- VIEW
-- Creating a VIEW to store data for future visualizations

CREATE VIEW Population_Vaccination_Percent AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
SUM(CONVERT(INT, cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS Rolling_People_Vaccinated
FROM CovidDeaths cd 
JOIN CovidVaccinations cv
ON cd.location = cv.location 
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 


-- END 

/* Created by Siji Oluloto */


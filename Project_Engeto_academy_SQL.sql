#testovaci vytvoreni tabulky, ale nechapu, proc ji vidim jen v github slozce, ale nevidim vlevo ve sloupci
CREATE TABLE new_awsome_table (
	id INT NOT NULL AUTO_INCREMENT,
	PRIMARY KEY(id));

# rocni obdobi daneho dne (mozna upravim na datum, i kdyz ja si nikdy nepamatuju, kdy zacina jaro)
# binarni promenna pro vikend/pracovni den
SELECT 
	date,
	country,
	(case when month(date) in (12, 1, 2) then 3
      when month(date) in (3, 4, 5) then 0
      when month(date) in (6, 7, 8) then 1
      when month(date) in (9, 10, 11) then 2
 	end) as season,
 	(case when WEEKDAY(date) in (0,1,2,3,4) then true
      else false end) as workday
 FROM covid19_basic_differences cbd; 
 
#HDP/obyvatel
SELECT  
	GDP/population AS GDP_per_population
FROM economies e; 

#GINI coefficient
SELECT * FROM economies e; 
SELECT * FROM lookup_table lt; 
SELECT * FROM countries c; 

#Pro každé náboženství v daném státě bych chtěl procentní podíl jeho příslušníků na celkovém obyvatelstvu - secist population pro danou country u ruznych nabozenstvi a podelit
#tohle je prozatimni reseni, ale ucine:)..we will see

SELECT 
 	r.country,
 	r.religion, 
 	r.population, 
 	c.population AS total_population,
 	ROUND((r.population / c.population) * 100,2) AS religion_ratio
 FROM religions r 
 JOIN countries c 
 ON r.country = c.country 
 WHERE r.year = 2020;

#rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 

SELECT
le1.country,
(le1.life_expectancy - le2.life_expectancy) 
AS rozdil_doziti_2015_1965
FROM life_expectancy le1 
JOIN life_expectancy le2 ON le1.country = le2.country 
WHERE le1.`year` = 2015 AND le2.`year` = 1965;

#průměrná denní (nikoli noční!) teplota - neni receni, zda po countries, nebo staci mestech (city = capital city)
#maximální síla větru v nárazech během dne
SELECT  
	AVG(temp) AS prumerna_teplota,
	MAX(CAST(LEFT(gust,2) AS UNSIGNED INTEGER)) AS sila_vetru,
	city 
FROM weather w 
WHERE `time` IN ('06:00', '09:00', '12:00', '15:00', '18:00')
	AND city IS NOT NULL
GROUP BY city ;

#počet hodin v daném dni, kdy byly srážky nenulové

SELECT 
	city,
	`date`,
	COUNT(time)*3 AS pocet_hodin,
	rain 
FROM weather w
WHERE city = 'Amsterdam'
AND rain = '0.0 mm'
 GROUP BY city, `date`; 
; 

	
#pro weather napoveda snad
select region_in_world , 
    round( sum( surface_area * yearly_average_temperature ) / sum( surface_area ), 2 ) as average_regional_temperature
from countries
where continent = 'Africa'
    and yearly_average_temperature is not null
group by region_in_world 
;
SELECT country, independence_date , continent 
FROM countries 
WHERE independence_date >= 1800
    AND independence_date < 1900;


   
   SELECT 
	w.city,
	c2.capital_city,
	c2.country 
FROM weather w
JOIN countries c2 ON w.city = c2.capital_city;



   
 





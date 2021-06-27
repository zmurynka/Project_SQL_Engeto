 #------------------------------------------------------------------------------------------------------------------------------------------
#nejprve si upravim tabulky, aby meli spravna data (rozdilne nazvy pro CR)
update covid19_basic_differences 
set country = 'Czech Republic'
where country = 'Czechia';

update lookup_table 
set country = 'Czech Republic'
where country = 'Czechia';

#uprava dat pro pocitani prumerne teploty
UPDATE weather 
SET temp = REPLACE (temp,
			' °c',
			'');
#---------------------------------------------------------------------------------------------------------------------------------------------
#zacinam vytvaret view, ktere pozdeji spojim
#tady bych rada upravila jako jedno view jiz od zacatku
#HDP/obyvatel
CREATE OR REPLACE VIEW HDP_na_obyvatele AS
SELECT  
	GDP/population AS HDP_na_obyvatele,
	country,
	MAX(`year`) 
FROM economies e
	WHERE GDP IS NOT NULL 
	GROUP BY country; 

#GINI koeficient  
CREATE OR REPLACE VIEW gini_koeficient AS  	
  SELECT
  	country,
  	gini AS gini_koeficient,
  	MAX(`year`) 
  FROM economies e
  WHERE gini IS NOT NULL
  GROUP BY country;
  
  #mortality pod 5 let
 CREATE OR REPLACE VIEW umrtnost_deti AS
  	SELECT 
  		country,
  		mortaliy_under5 AS detska_umrtnost,
  		MAX(`year`)
  	FROM economies e 
  	WHERE mortaliy_under5 IS NOT NULL 
  	GROUP BY country; 
  
#spojeni predchozich view s ekonomickymi ukazateli  
CREATE OR REPLACE VIEW ekonomicke_ukazatele AS
 SELECT
 	hno.country,
 	hno.HDP_na_obyvatele,
 	gk.gini_koeficient,
 	ud.detska_umrtnost
 FROM hdp_na_obyvatele hno 
 JOIN gini_koeficient gk ON gk.country = hno.country
 JOIN umrtnost_deti ud ON ud.country = hno.country;

#view s rozdilem doziti 2015 a 1965
CREATE OR REPLACE VIEW rozdil_doziti AS
SELECT
	le1.country,
	(le1.life_expectancy - le2.life_expectancy) 
	AS rozdil_doziti_2015_1965
FROM life_expectancy le1 
JOIN life_expectancy le2 ON le1.country = le2.country 
WHERE le1.`year` = 2015 AND le2.`year` = 1965;

#view s poctem hodin bez srazek dle mest a 
CREATE OR REPLACE VIEW pocet_hodin AS
SELECT 
	w.city,
	w.`date`,
	w.COUNT(time)*3 AS pocet_hodin_bez_srazek,
	w.rain, 
	c.country 
FROM weather w
JOIN countries c ON c.capital_city = w.city
WHERE w.rain = '0.0 mm'
 GROUP BY w.city, w.`date`; 

#view s prepocitanou hustota zalidneni
CREATE OR REPLACE VIEW nabozenstvi AS
  SELECT 
 	r.country,
 	r.religion, 
 	r.population,
 	c.population_density AS hustota_zalidneni,
 	c.population AS total_population,
 	ROUND((r.population / c.population) * 100,2) AS nabozenstvi_ratio
 FROM religions r 
 JOIN countries c 
 ON r.country = c.country 
 WHERE r.year = 2020;

#view s pridanim sloupcu pro pracovni den a pro rocni obdobi
CREATE OR REPLACE VIEW casove_promenne AS
	SELECT 
		date,
		country,
		(case when month(date) in (12, 1, 2) then 3
      		when month(date) in (3, 4, 5) then 0
      		when month(date) in (6, 7, 8) then 1
      		when month(date) in (9, 10, 11) then 2
 		end) as rocni_obdobi,
 		(case when WEEKDAY(date) in (0,1,2,3,4) then true
      		else false end) as pracovni_den
 	FROM covid19_basic_differences cbd; 
 
#view s pridanim sloupce pro silu vetru 
CREATE OR REPLACE VIEW teplota_vitr AS
 SELECT  
	AVG(w.temp) AS prumerna_teplota,
	MAX(CAST(LEFT(w.gust,2) AS UNSIGNED INTEGER)) AS sila_vetru,
	w.city,
	c.country, 
	c.median_age_2018 AS prumerna_doba_doziti_2018, 
	w.`date` 
 FROM weather w 
 JOIN countries c ON c.capital_city = w.city
 WHERE `time` IN ('06:00', '09:00', '12:00', '15:00', '18:00')
	AND w.city IS NOT NULL
 GROUP BY city;


#vsechny view joinle dohromady - finalni tabulka

SELECT 
	DISTINCT cp.country,
	tv.`date`,
	cp.pracovni_den,
	cp.rocni_obdobi,
	eo.hustota_zalidneni,
	eo.HDP_na_obyvatele,
 	eo.gini_koeficient,
 	ud.detska_umrtnost,
	tv.prumerna_doba_doziti_2018,
	n.nabozenstvi_ratio,
	rd.rozdil_doziti_2015_1965,
	tv.prumerna_teplota,
	ph.pocet_hodin_bez_srazek,
	tv.sila_vetru
FROM teplota_vitr tv 
JOIN casove_promenne cp ON cp.country = tv.country
JOIN pocet_hodin ph ON ph.country = cp.country
JOIN nabozenstvi n ON n.country = cp.country
JOIN rozdil_doziti rd ON rd.country = cp.country
JOIN ekonomicke_ukazatele eo ON eo.country = cp.country;



   
 





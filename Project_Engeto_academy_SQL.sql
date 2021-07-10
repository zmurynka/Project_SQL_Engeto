#tohle bude zdlouhave a asi to jde udelat lip, ale nenapada me jak
 
#tady si zjistim rozdilne zeme z economies tabulky, ignoruji kontinenty a skupiny statu (jako Fragile and conflict affected situations) a staty pod milion obyvatel (nematerialni)
 
 SELECT 
 	DISTINCT  country
 FROM economies e 
	WHERE country NOT IN 
		(SELECT country FROM countries c)
	AND population>1000000;


#tady si vzdy hledam, jak se jednotlive staty jmenuji v tabulce countries, kterou jsem si zvolila jako vychozi pro pojmenovani zemi
SELECT country, population FROM countries c WHERE country LIKE "%Ta%"

#nasla jsem staty (v zavorce vzdy nazev dle tabulky country): Kosovo(neni), Libya (Libyan Arab Jamahiriya), Palestine(neni)
UPDATE economies 
SET country = 'Libyan Arab Jamahiriya'
WHERE country = 'Libya';

#Libya, Palestine, Taiwan (dle wikipedie je jako Republic of China, ale v countries jsem nic podobneho nenasla), Timor (East Timor, ale neni ani recena populace)
 SELECT 
 	DISTINCT  country
 FROM life_expectancy le 
	WHERE country NOT IN 
		(SELECT country FROM countries c);

#na zaver updatuju nazvy statu tak, aby se jmenovali stejne jako v tabulce countries
UPDATE life_expectancy 
	SET country = 'Libyan Arab Jamahiriya'
	WHERE country = 'Libya';


#porad ty same
SELECT 
 	DISTINCT  country
 FROM religions r 
	WHERE country NOT IN 
		(SELECT country FROM countries c);
	
UPDATE religions 
	SET country = 'Libyan Arab Jamahiriya'
	WHERE country = 'Libya';

	#Libya, Kosovo, Burma(Myanmar); Cabo Verde (Cape Verde, ale jen pul milionu obyvatel); Congo (Br%) (Congo); Congo (%Ki)(Congo); Korea, South (South Korea); Russia (Russian Federation), US (United States) 
SELECT 
 	DISTINCT  country
 FROM covid19_basic_differences cbd 
	WHERE country NOT IN 
		(SELECT country FROM countries c);

#da se provest update vice poli najednou? 
UPDATE covid19_basic_differences 
	SET country = 'Libyan Arab Jamahiriya'
	WHERE country = 'Libya';
UPDATE covid19_basic_differences 
	SET country = 'Burma'
	WHERE country = 'Myanmar';
UPDATE covid19_basic_differences 
	SET country = 'Congo'
	WHERE country LIKE 'Congo%';
UPDATE covid19_basic_differences 
	SET country = 'South Korea'
	WHERE country = 'Korea, South';
UPDATE covid19_basic_differences 
	SET country = 'Russian Federation'
	WHERE country = 'Russia';
	
 
UPDATE covid19_basic_differences 
SET country = 'Czech Republic'
WHERE country = 'Czechia';

UPDATE lookup_table 
SET country = 'Czech Republic'
WHERE country = 'Czechia';

#uprava dat pro pocitani prumerne teploty
UPDATE weather 
SET temp = REPLACE (temp,
			' °c',
			'');
#jeste jsem pridala odstraneni prazdnych mist - pouzila bych trim, ale neprisla jsem na to, jak
UPDATE weather 
SET temp = REPLACE (temp,
			' ',
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
	COUNT(CAST(w.`time` AS double))*3 AS pocet_hodin_bez_srazek,
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
		(CASE WHEN month(date) IN (12, 1, 2) THEN 3
      		WHEN month(date) IN (3, 4, 5) THEN 0
      		WHEN month(date) IN (6, 7, 8) THEN 1
      		WHEN month(date) IN (9, 10, 11) THEN 2
 		END) AS rocni_obdobi,
 		(CASE WHEN WEEKDAY(date) IN (0,1,2,3,4) THEN TRUE
      		ELSE FALSE END) AS pracovni_den
 	FROM covid19_basic_differences cbd; 
 
#view s pridanim sloupce pro silu vetru 
CREATE OR REPLACE VIEW teplota_vitr AS
 SELECT  
	AVG(CAST(w.temp AS double)) AS prumerna_teplota,
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
	n.hustota_zalidneni,
	eo.HDP_na_obyvatele,
 	eo.gini_koeficient,
 	eo.detska_umrtnost,
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






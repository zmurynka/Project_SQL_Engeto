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
 

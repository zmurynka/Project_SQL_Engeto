# Project_SQL_Engeto
Projekt pro datovou akademii - SQL

Cílem projektu bylo vytvořit jednotnou tabulku, ve které bude dle státu a data možno filtrovat následující údaje:

**Časové proměnné**
- binární proměnná pro víkend / pracovní den - sloupec _pracovni_den_: pracovní den 1, víkend 0
- roční období daného dne (zakódujte prosím jako 0 až 3) - sloupec _rocni_obdobi_

**Proměnné specifické pro daný stát**
- hustota zalidnění - sloupec _hustota_zalidneni_
- HDP na obyvatele - sloupec _HDP_na_obyvatele_
- GINI koeficient - sloupec _gini_koeficient_
- dětská úmrtnost - sloupec _detska_umrtnost_
- medián věku obyvatel v roce 2018 - sloupec _prumerna_doba_doziti_2018_
- podíly jednotlivých náboženství - sloupec _nabozenstvi_ratio_
- rozdíl mezi očekávanou dobou dožití v roce 1965 a v roce 2015 - sloupec _rozdil_doziti_2015_1965_

**Počasí (ovlivňuje chování lidí a také schopnost šíření viru)**
- průměrná denní (nikoli noční!) teplota - sloupec _prumerna_teplota_
- počet hodin v daném dni, kdy byly srážky nenulové - sloupec _pocet_hodin_bez_srazek_
- maximální síla větru v nárazech během dne! - sloupec _sila_vetru_

# Problematické oblasti:
- Rozdílné názvy zemí v různých tabulkách - pro většinu tabulek byl název státu jediným pojítkem, v první části projektu jsem se je pokusila sjednotit vyhledáním rozdílných názvů u států, které byly materiální (jako hranici jsem si určila 1M obyvatel) a následnou změnou nenasouhlasených zemí, nicméně stále to není ideální

- tabulka weather - údaje jsou uloženy jako text, vzhledem k tomu, že se z nich vypočítávají maxima a průměry, v dotazech převedeno na double či integer

- roční období jsou rozdělena jen dle měsíců, přesnější by bylo dle dní

- podíly jednotlivých náboženství - zjednodušen výpočet, ne vždy součet population v tabulce religion seděl na součet population v jiné tabulce, součet pro jednu zemi ne vždy dává 100%

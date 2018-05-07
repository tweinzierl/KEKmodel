-- Deriving building_typology
-- v0.3

/* *************************
Author: Tobias Weinzierl
Date: 07.05.2018

************************ */



/* *************************
This script derives all necessary data from the ALKIS dataset.
At first it calculates the Gebäudenutzfläche. 
Second it derives the building typology, which depends on gebäudefunktion, bauweise and grundflläche
Third it copies the gml_id, which is necessary to identify each object.
Fourth the column bewohner in the table stANDard_aufbereitet is updated with the number of bewohner of each building. This number is calculated
************************* */

/* *************************
Change Log:
- column  geometry is updated with the geometry of the object in the input table
- if typologie or baujahr is unknown a zero ('0') is assigned (it was 99 or 22 before)
- other buildings and auxiliary buildings will also be respected during the assignment of baualtersklassen_id

************************* */


INSERT INTO energiekarten.stANDard_aufbereitet (geb_nutzflaeche, geb_typologien_id, gml_id, baualtersklassen_id)
Select * from (



SELECT 

----- calculating Gebäudenutzfläche

	(ramin.gz * ramin.grundflaec * 2.6 * 0.32) as geb_nutzflaec,
	

	CASE  
	
----- residential buildings 
	
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) AND gz in (1, 2) AND bauweise in (1100, 2100) AND grundflaec >= 35 AND grundflaec <= 250 THEN 1
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) AND gz in (1, 2) AND bauweise in (2200, 2300) AND grundflaec >= 35 AND grundflaec <= 250 THEN 2
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) AND gz in (3, 4) AND bauweise in (1200, 2500, 2300, 1100, 2200, 2400) AND grundflaec >= 35 AND grundflaec <= 1300 THEN 3	
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) AND gz in (5, 6, 7) AND bauweise in (1200, 2500, 2300, 1100, 2200, 2400) AND grundflaec >= 80 AND grundflaec <= 1200 THEN 4
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) AND gz = 7 AND bauweise in (1200, 2500, 2300, 1100, 2200, 2400) THEN 5
		
----- industrial buildings

		WHEN gebaeudefu in (2110, 2111, 2112, 2113, 2114, 2120, 2121, 2100, 2150, 2200, 2400, 2500, 2600, 2700) THEN 6
		

----- mixed-used buildings classified by their respective area
		
		WHEN gebaeudefu in (1100, 1110, 1120, 1121, 1122, 1222, 2320, 1123, 1130, 1131, 1210, 1220, 1231, 3100) AND grundflaec <= 500 THEN 7
		WHEN gebaeudefu in (1100, 1110, 1120, 1121, 1122, 1222, 2320, 1123, 1130, 1131, 1210, 1220, 1231, 3100) AND grundflaec > 500 AND grundflaec <= 1000 THEN 8
		WHEN gebaeudefu in (1100, 1110, 1120, 1121, 1122, 1222, 2320, 1123, 1130, 1131, 1210, 1220, 1231, 3100) AND grundflaec > 1000  THEN 9
		
		
----- non-residential buildings classified by their respective area

		WHEN gebaeudefu in (2000, 2010, 2020, 2030, 2040, 2050, 2051, 2052, 2053, 2054, 2055, 2056, 2080, 2081, 2083, 2090, 2130, 2160, 3000, 3010, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3024, 3030,  3034, 3037, 3044, 3060, 2060) AND grundflaec <= 500 THEN 10
		WHEN gebaeudefu in (2000, 2010, 2020, 2030, 2040, 2050, 2051, 2052, 2053, 2054, 2055, 2056, 2080, 2081, 2083, 2090, 2130, 2160, 3000, 3010, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3024, 3030,  3034, 3037, 3044, 3060, 2060) AND grundflaec > 500 AND grundflaec <= 1000  THEN 11
		WHEN gebaeudefu in (2000, 2010, 2020, 2030, 2040, 2050, 2051, 2052, 2053, 2054, 2055, 2056, 2080, 2081, 2083, 2090, 2130, 2160, 3000, 3010, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3024, 3030,  3034, 3037, 3044, 3060, 2060) AND grundflaec > 1000  THEN 12
	
	
-----  auxiliary buildings
	
		WHEN gebaeudefu in (1313, 2143, 2463, 2721, 2723, 2724, 2726)  THEN 13
		
----- 	other buildings
		WHEN gebaeudefu in (4000, 9998, 3050, 3051, 3053, 3052, 3022, 3023, 3021, 2070, 2071, 2072, 2073, 3210, 3211, 3065, 3071, 3072, 3073, 3220, 3221, 3040, 3075) THEN 14

----- Fehler abfangen und mit id 99 versehen
	
		ELSE 0 
	END as geb_id, 
	
----- copying gml_id from ALKIS-Dataset	
	
	gml_id,
	
----- deriving baualtersklassen_id

	CASE
		WHEN gebaeudefu in (1010, 1000, 1221, 1223, 1312) then --check for residential buildings
	
			CASE  
			
			
				WHEN baujahr <= 1859 THEN 1
				WHEN baujahr > 1859 AND baujahr <= 1918 THEN 2
				WHEN baujahr > 1918 AND baujahr <= 1948 THEN 3
				WHEN baujahr > 1948 AND baujahr <= 1957 THEN 4
				WHEN baujahr > 1957 AND baujahr <= 1968 THEN 5
				WHEN baujahr > 1968 AND baujahr <= 1978 THEN 6
				WHEN baujahr > 1978 AND baujahr <= 1983 THEN 7
				WHEN baujahr > 1983 AND baujahr <= 1994 THEN 8
				WHEN baujahr > 1994 AND baujahr <= 2001 THEN 9
				WHEN baujahr > 2001 AND baujahr <= 2009 THEN 10
				WHEN baujahr > 2009 AND baujahr <= 2015 THEN 11
				WHEN baujahr > 2015 THEN 12
			
				else 0 --if baujahr is unknown
			END 
			
				--check for mixed-used buildings and non-residential buildings
				
		WHEN gebaeudefu in (1100, 1110, 1120, 1121, 1122, 1222, 2320, 1123, 1130, 1131, 1210, 1220, 1231, 3100, 2000, 2010, 2020, 2030, 2040, 2050, 2051, 2052, 2053, 2054, 2055, 2056, 2080, 2081, 2083, 2090, 2130, 2160, 3000, 3010, 3012, 3013, 3014, 3015, 3016, 3017, 3018, 3019, 3020, 3024, 3030,  3034, 3037, 3044, 3060, 2060, 1313, 2143, 2463, 2721, 2723, 2724, 2726, 4000, 9998, 3050, 3051, 3053, 3052, 3022, 3023, 3021, 2070, 2071, 2072, 2073, 3210, 3211, 3065, 3071, 3072, 3073, 3220, 3221, 3040, 3075) THEN 
				
			CASE
				WHEN baujahr <= 1900 THEN 13
				WHEN baujahr > 1900 AND baujahr <= 1945 THEN 14
				WHEN baujahr > 1945 AND baujahr <= 1960 THEN 15
				WHEN baujahr > 1960 AND baujahr <= 1970 THEN 16
				WHEN baujahr > 1970 AND baujahr <= 1980 THEN 17
				WHEN baujahr > 1980 AND baujahr <= 1985 THEN 18
				WHEN baujahr > 1985 AND baujahr <= 1995 THEN 19
				WHEN baujahr > 1995 AND baujahr <= 2000 THEN 20
				WHEN baujahr > 2000 AND baujahr <= 2009 THEN 21
				
				else 0 --if baujahr is unknown
			
			END 
		ELSE 0
		END AS baualtersklassen_id
	
	
FROM ramin 
WHERE ramin.gebaeudefu is not null AND ramin.grundflaec is not null AND ramin.bauweise is not null AND ramin.gz is not null
) as geb_id;



----- Updating the bewohner column, calculating bewohner
-- das passiert über Update, da nur auf die geb_nutzfläche und die geb_typologien_id - beide aus stANDard_aufbereitet - zugegriffen wird. Das geht im darüber stehenden Code aufgrund der "FROM ramin"-Anweisung nicht.

UPDATE energiekarten.standard_aufbereitet
SET bewohner =
CASE 
	WHEN geb_typologien_id IN (7,8,9) THEN ((stANDard_aufbereitet.geb_nutzflaeche /40) /2)
	WHEN geb_typologien_id IN (1,2,3,4,5) THEN (stANDard_aufbereitet.geb_nutzflaeche /40)
	ELSE 0
END;


----- Updating the geometry in standard_aufbereitet
UPDATE energiekarten.standard_aufbereitet
SET geom =  (SELECT geom FROM ramin WHERE ramin.gml_id = energiekarten.standard_aufbereitet.gml_id)



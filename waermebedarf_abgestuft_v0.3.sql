-- Sketch calculating heating demand in various DG
-- v0.3

/* *************************
Author: Tobias Weinzierl
Date: 07.05.2018

************************ */


-----	inserting standard values not depending on DG

INSERT INTO energiekarten.ergebnis_energie(aufbereitet_id, gml_id, geom)
	SELECT id, gml_id, geom FROM energiekarten.standard_aufbereitet;
	
	
----- Updating table with various DG

	--standard_aufbereitet is joined with waermebedarfswerte_bis_dg3 in order to get the waermebedarfswert for every existing combination of baualtersklassen_id and geb_typologien_id
	--then the waermebedarfswert is multiplied with geb_nutzflaeche and furthermore the detailgrad for the actual combination is  retrieved
	--everything is inserted into ergebnis_energie

UPDATE energiekarten.ergebnis_energie
	SET (waermebedarfswert, detailgrad_waerme) = (SELECT  geb_nutzflaeche * waermebedarfswert, detailgrad
																			FROM (select * from standard_aufbereitet sa join waermebedarfswerte_bis_dg3 wb on (sa.geb_typologien_id = wb.typologie_id AND sa.baualtersklassen_id = wb.baualtersklassen_id)) as foo
																			WHERE ergebnis_energie.gml_id = foo.gml_id);
																			
	
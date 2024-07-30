UPDATE Debtor
   SET stateProvince = CASE stateProvince 
			WHEN 'ONTARIO' THEN 'ON'
            WHEN 'QUEBEC' THEN 'QC'
            WHEN 'CALIFORNIA' THEN 'CA'
            WHEN 'CA.' THEN 'CA'
            WHEN 'TEXAX' THEN 'TX'
            WHEN 'WISCONSIN' THEN 'WI'
            WHEN 'NEW YORK' THEN 'NY'
            WHEN 'ALBERTA' THEN 'AB'
            WHEN 'MONTANA' THEN 'MN'
            WHEN 'PA.' THEN 'PA'
            WHEN 'WI.' THEN 'WI'
            WHEN 'BC CANADA' THEN 'BC'
            WHEN 'QC CANADA' THEN 'QC'
            WHEN 'CA 92507' THEN 'CA'
            WHEN 'Manitoba' THEN 'MB'
            WHEN 'Nova Scotia' THEN 'NS'
            WHEN 'B.C.' THEN 'BC'
            WHEN 'WASHINGTON.' THEN 'WA'
            WHEN 'WASHINGTON' THEN 'WA'
            WHEN 'RHODE ISLAND' THEN 'RI'
            WHEN 'UTAH' THEN 'UT'
            WHEN 'XX' THEN NULL
            ELSE stateProvince END;


UPDATE Debtor SET stateProvince = 'BC', postalcode = 'V6X 2W8' WHERE stateProvince='V6X2W8 BC'
UPDATE Debtor SET stateProvince = 'QC', postalcode = 'H4L 4V6' WHERE stateProvince='QC    H4L4V6'
UPDATE Debtor SET stateProvince = 'MB', city = 'LASALLE' WHERE city='LASALLE, MANITOBA,'
UPDATE Debtor SET stateProvince = 'ON', city = 'MISSISSAUGA' WHERE city='MISSISSAUGA, ON,'
UPDATE Debtor SET stateProvince = 'BC', city = 'SURREY' WHERE city='SURREY, BC,'
UPDATE Debtor SET stateProvince = 'BC', city = 'BURNABY' WHERE city='BURNABY B.C.'
UPDATE Debtor SET stateProvince = 'BC', city = 'NEW WESTMINSTER' WHERE city='NEW WESTMINSTER BC'
UPDATE Debtor SET stateProvince = 'QC', city = 'MONTREAL' WHERE city='MONTREAL QUE.'
UPDATE Debtor SET stateProvince = 'BC', city = 'CHILLIWACK' WHERE city='CHILLIWACK,B.C.,'
UPDATE Debtor SET stateProvince = 'BC', city = 'DELTA' WHERE city='DELTA, B.C.,'
UPDATE Debtor SET stateProvince = 'BC', city = 'MAPLE RIDGE' WHERE city='MAPLE RIDGE, BC,'
UPDATE Debtor SET stateProvince = 'BC' WHERE city='VANCOUVER' AND stateProvince = 'BC  CANADA'
UPDATE Debtor SET stateProvince = 'BC', city = 'SURREY' WHERE city='SURREY, B.C.,'
UPDATE Debtor SET stateProvince = 'BC', city = 'CHILLIWACK' WHERE city='CHILLIWACK BC'
UPDATE Debtor SET stateProvince = 'BC', city = 'SURREY' WHERE city='SURREY B.C.'
UPDATE Debtor SET stateProvince = 'BC', city = 'KELOWNA' WHERE city='KELOWNA, B.C.,'
UPDATE Debtor SET stateProvince = 'AB', city = 'EDMONTON' WHERE city='EDMONTON, ALBERTA,'
UPDATE Debtor SET stateProvince = 'BC', city = 'PORT ALBERNI' WHERE city='PORT ALBERNI, BC,'
UPDATE Debtor SET stateProvince = 'BC', city = 'SARDIS' WHERE city='SARDIS, B.C.,'
UPDATE Debtor SET stateProvince = 'QC' WHERE stateProvince='QUEBEC,CANADA'
UPDATE Debtor SET stateProvince = 'BC', city = 'ABBOTSFORD' WHERE city='ABBOTSFORD, B.C.,'
UPDATE Debtor SET stateProvince = 'BC', city = 'CHILLIWACK' WHERE city='CHILLIWACK, B.C.,'
UPDATE Debtor SET stateProvince = 'AB', city = 'CALGARY' WHERE city='CALGARY, ALBERTA,'
UPDATE Debtor SET stateProvince = 'WA' WHERE city='SEATTLE' AND stateProvince = 'W'
UPDATE Debtor SET stateProvince = 'BC' WHERE stateProvince='B.C. CANADA'
UPDATE Debtor SET stateProvince = 'BC', city = 'CAMPBELL RIVER' WHERE stateProvince='RIVER,BC,CANADA'
UPDATE Debtor SET stateProvince = 'CA', city = 'RIVERSIDE' WHERE city='RIVERSIDE CA'
UPDATE Debtor SET stateProvince = 'DC', city = 'Washington' WHERE city='Washington, DC'

UPDATE Debtor SET stateProvince = 'OR' WHERE stateProvince='OE' and postalcode like '97%'
UPDATE Debtor SET stateProvince = 'ID' WHERE stateProvince='IS' and postalcode = '83642'
UPDATE Debtor SET stateProvince = 'CA' WHERE stateProvince='SA' and postalcode = '94080'
UPDATE Debtor SET stateProvince = 'AZ' WHERE stateProvince='AA' and postalcode = '85234'
UPDATE Debtor SET stateProvince = 'ID' WHERE stateProvince='IF' and postalcode = '83814'
UPDATE Debtor SET stateProvince = 'IA' WHERE stateProvince='IO' and postalcode = '50010'
UPDATE Debtor SET stateProvince = 'AZ' WHERE stateProvince='AS' and postalcode = '85546'
UPDATE Debtor SET stateProvince = 'HI' WHERE stateProvince='HA' and postalcode = '96814'
UPDATE Debtor SET stateProvince = 'KS' WHERE stateProvince='KA' and postalcode = '66219'
UPDATE Debtor SET stateProvince = 'WA' WHERE stateProvince='WE' and postalcode = '98682'

-- Fix phone numbers starting w/1 and that are 11 characters long.
-- Strip off the prefix in order to match with CRM.
UPDATE Debtor
   SET accountphone = SUBSTRING(accountphone, 2, 10)
 WHERE LEN(accountphone) = 11
   AND SUBSTRING(accountphone, 1, 1) = '1';


-- Fix the PO Box addresses
UPDATE Debtor
   SET street2 = City + ' ' + stateProvince,
       City = prpc_City,
       StateProvince = prpc_state
  from Debtor 
       INNER JOIN CRM.dbo.PRPostalCode ON postalcode = prpc_postalcode
 where stateProvince NOT IN (select prst_Abbreviation from CRM.dbo.PRState where prst_Abbreviation IS NOT NULL AND prst_Abbreviation <> '')
   AND postalcode is not null AND postalcode <> ''
   and stateProvince <> prpc_state
   and city like '%BOX%'

UPDATE Debtor
   SET street2 = City + ' ' + stateProvince,
       City = prpc_City,
       StateProvince = prpc_state
  from Debtor 
       INNER JOIN CRM.dbo.PRPostalCode ON postalcode = prpc_postalcode
 where stateProvince NOT IN (select prst_Abbreviation from CRM.dbo.PRState where prst_Abbreviation IS NOT NULL AND prst_Abbreviation <> '')
   AND postalcode is not null AND postalcode <> ''
   and stateProvince <> prpc_state
   and street like '%BOX%'

UPDATE Debtor
   SET street2 = City + ' ' + stateProvince,
       City = prpc_City,
       StateProvince = prpc_state
  from Debtor 
       INNER JOIN CRM.dbo.PRPostalCode ON postalcode = prpc_postalcode
 where stateProvince NOT IN (select prst_Abbreviation from CRM.dbo.PRState where prst_Abbreviation IS NOT NULL AND prst_Abbreviation <> '')
   AND postalcode is not null AND postalcode <> ''
   and stateProvince <> prpc_state
   and debtorid in (12341,12395,12434,12525,12689,12806,12832,12909,24816,76164,12488,12748,12847,12866,45981,61065,80202,12491,12504,12537,12683,59755,84471,12389,12516,12558,12620,12798,71464)




-- Query #1 How many unique debtors are there across all the files
SELECT COUNT(1) 
  FROM Debtor;


-- Query #2 Of those unique debtors, how many have active trade lines reported in the past 12 months?
DECLARE @tblActiveDebtors table (
	DebtorID int
)

INSERT INTO @tblActiveDebtors
SELECT DISTINCT Debtor.DebtorID
  FROM Debtor
       INNER JOIN ARAging ON Debtor.DebtorID = ARAging.ARAgingID
 WHERE ExtractDate >= DATEADD(month, -12, GETDATE())
   AND ((AmtCurrent > 0)
        OR (AmtPD30 > 0)
        OR (AmtPD60 > 0)
        OR (AmtPD90 > 0)
        OR (AmtPD90over > 0));

SELECT COUNT(1)
  FROM @tblActiveDebtors;


-- Query #3 How many of the unique debtors with active trade lines already exist in our system??
SELECT COUNT(DISTINCT DebtorID)
  FROM
(
SELECT DISTINCT DebtorID, AccountName, comp_CompanyID, comp_Name
  FROM Debtor
       INNER JOIN (SELECT comp_CompanyID, comp_Name, prci_City, prst_Abbreviation
                     FROM CRM.dbo.Company
						   INNER JOIN CRM.dbo.Address_Link ON comp_CompanyID = adli_CompanyID
						   INNER JOIN CRM.dbo.Address ON adli_AddressID = addr_AddressID
						   INNER JOIN CRM.dbo.vPRLocation ON addr_PRCityID = prci_CityID) T1 ON DupNameValue = dbo.ufn_GetLowerAlpha(comp_Name) AND city = prci_City AND stateProvince = prst_Abbreviation
 WHERE DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors)
UNION
SELECT DISTINCT DebtorID, AccountName, comp_CompanyID, comp_Name
  FROM Debtor
       INNER JOIN (SELECT comp_CompanyID, comp_Name, RTRIM(phon_AreaCode) + REPLACE(RTRIM(phon_Number), '-', '') As PhoneNbr
                     FROM CRM.dbo.Company
                          INNER JOIN CRM.dbo.Phone ON comp_CompanyID = phon_CompanyID AND phon_PersonID IS NULL) T1 ON accountphone = PhoneNbr
 WHERE DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors)
) T1




/*
-- Query #3a Matches by Name, City, and State
SELECT DISTINCT DebtorID, AccountName, City, stateProvince, comp_CompanyID, comp_Name, prci_City, prst_Abbreviation
  FROM Debtor
       INNER JOIN (SELECT comp_CompanyID, comp_Name, prci_City, prst_Abbreviation
                     FROM CRM.dbo.Company
						   INNER JOIN CRM.dbo.Address_Link ON comp_CompanyID = adli_CompanyID
						   INNER JOIN CRM.dbo.Address ON adli_AddressID = addr_AddressID
						   INNER JOIN CRM.dbo.vPRLocation ON addr_PRCityID = prci_CityID) T1 ON DupNameValue = dbo.ufn_GetLowerAlpha(comp_Name) AND city = prci_City AND stateProvince = prst_Abbreviation
 WHERE DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors);

-- Query #3b Matches by Phone
SELECT DISTINCT DebtorID, AccountName, accountphone, comp_CompanyID, comp_Name, PhoneNbr
  FROM Debtor
       INNER JOIN (SELECT comp_CompanyID, comp_Name, RTRIM(phon_AreaCode) + REPLACE(RTRIM(phon_Number), '-', '') As PhoneNbr
                     FROM CRM.dbo.Company
                          INNER JOIN CRM.dbo.Phone ON comp_CompanyID = phon_CompanyID AND phon_PersonID IS NULL) T1 ON accountphone = PhoneNbr
 WHERE DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors);
*/


-- Query #4 How many of the unique debtors with active trade lines are 'relevant' to us?  
SELECT COUNT(1) 
  FROM Debtor
 WHERE (AccountName LIKE '%lumber%'
        OR AccountName LIKE '%mill%'
        OR AccountName LIKE '%wood%'
        OR AccountName LIKE '%saw%'
        OR AccountName LIKE '%farm%'
        OR AccountName LIKE '%logging%'
        OR AccountName LIKE '%tree%'
        OR AccountName LIKE '%building%'
        OR AccountName LIKE '%bldg%'
        OR AccountName LIKE '%cabinet%'
        OR AccountName LIKE '%forest%'
        OR AccountName LIKE '%fence%'
        OR AccountName LIKE '%pine%'
        OR AccountName LIKE '%plywood%'
        OR AccountName LIKE '%home%'
        OR AccountName LIKE '%loew%'
        OR AccountName LIKE '%construction%')
	AND AccountName NOT LIKE '%airlines%'
	AND AccountName NOT LIKE '%metal%'
	AND AccountName NOT LIKE '%machine%'
	AND AccountName NOT LIKE '%seafood%'
	AND AccountName NOT LIKE '%marine%'
	AND AccountName NOT LIKE '%tool%'
	AND AccountName NOT LIKE '%electric%'
    AND AccountName NOT LIKE '%plumbers%'
    AND AccountName NOT LIKE '%plumbing%'
    AND AccountName NOT LIKE '%motor%'
    AND AccountName NOT LIKE '%heating%'
    AND AccountName NOT LIKE '%colling%'
    AND AccountName NOT LIKE '%energy%'
    AND AccountName NOT LIKE '%disposal%'
    AND AccountName NOT LIKE '%district%'
    AND AccountName NOT LIKE '%homewoners%'
    AND AccountName NOT LIKE '%village%'
    AND AccountName NOT LIKE '%appliance%'
    AND AccountName NOT LIKE '%diesel%'
    AND AccountName NOT LIKE '%consulting%'
    AND AccountName NOT LIKE '%contracting%'
    AND AccountName NOT LIKE '%courier%'
    AND AccountName NOT LIKE '%food%'
    AND AccountName NOT LIKE '%remodel%'
    AND AccountName NOT LIKE '%steel%'
    AND AccountName NOT LIKE '%repair%'
    AND AccountName NOT LIKE '%vending%'
    AND AccountName NOT LIKE '%welding%'
    AND AccountName NOT LIKE '%redi-mix%'
    AND AccountName NOT LIKE '%power%'
    AND AccountName NOT LIKE '%motel%'
    AND AccountName NOT LIKE '%hotel%'
    AND AccountName NOT LIKE '%museum%'
    AND AccountName NOT LIKE '%medical%'
    AND AccountName NOT LIKE '%grinding%'
    AND AccountName NOT LIKE '%fish%'
    AND AccountName NOT LIKE '%cemetary%'
    AND AccountName NOT LIKE '%fruit%'
    AND AccountName NOT LIKE '%casino%'
    AND AccountName NOT LIKE '%pizza%'
    AND AccountName NOT LIKE '%school%'
    AND AccountName NOT LIKE '%rainforest cafe%'
    AND AccountName NOT LIKE '%construction equipment%'
	AND AccountName NOT LIKE '%mechanical%'
	AND AccountName NOT LIKE '%refrig%'
    AND AccountName NOT LIKE '%ice arena%'
    AND AccountName NOT LIKE '%chemicals%'
    AND DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors);

/*
-- Query #4a  The actual matches
SELECT COUNT(1) 
  FROM Debtor
 WHERE (AccountName LIKE '%lumber%'
        OR AccountName LIKE '%mill%'
        OR AccountName LIKE '%wood%'
        OR AccountName LIKE '%saw%'
        OR AccountName LIKE '%farm%'
        OR AccountName LIKE '%logging%'
        OR AccountName LIKE '%tree%'
        OR AccountName LIKE '%building%'
        OR AccountName LIKE '%bldg%'
        OR AccountName LIKE '%cabinet%'
        OR AccountName LIKE '%forest%'
        OR AccountName LIKE '%fence%'
        OR AccountName LIKE '%pine%'
        OR AccountName LIKE '%plywood%'
        OR AccountName LIKE '%home%'
        OR AccountName LIKE '%loew%'
        OR AccountName LIKE '%construction%')
	AND AccountName NOT LIKE '%airlines%'
	AND AccountName NOT LIKE '%metal%'
	AND AccountName NOT LIKE '%machine%'
	AND AccountName NOT LIKE '%seafood%'
	AND AccountName NOT LIKE '%marine%'
	AND AccountName NOT LIKE '%tool%'
	AND AccountName NOT LIKE '%electric%'
    AND AccountName NOT LIKE '%plumbers%'
    AND AccountName NOT LIKE '%plumbing%'
    AND AccountName NOT LIKE '%motor%'
    AND AccountName NOT LIKE '%heating%'
    AND AccountName NOT LIKE '%colling%'
    AND AccountName NOT LIKE '%energy%'
    AND AccountName NOT LIKE '%disposal%'
    AND AccountName NOT LIKE '%district%'
    AND AccountName NOT LIKE '%homewoners%'
    AND AccountName NOT LIKE '%village%'
    AND AccountName NOT LIKE '%appliance%'
    AND AccountName NOT LIKE '%diesel%'
    AND AccountName NOT LIKE '%consulting%'
    AND AccountName NOT LIKE '%contracting%'
    AND AccountName NOT LIKE '%courier%'
    AND AccountName NOT LIKE '%food%'
    AND AccountName NOT LIKE '%remodel%'
    AND AccountName NOT LIKE '%steel%'
    AND AccountName NOT LIKE '%repair%'
    AND AccountName NOT LIKE '%vending%'
    AND AccountName NOT LIKE '%welding%'
    AND AccountName NOT LIKE '%redi-mix%'
    AND AccountName NOT LIKE '%power%'
    AND AccountName NOT LIKE '%motel%'
    AND AccountName NOT LIKE '%hotel%'
    AND AccountName NOT LIKE '%museum%'
    AND AccountName NOT LIKE '%medical%'
    AND AccountName NOT LIKE '%grinding%'
    AND AccountName NOT LIKE '%fish%'
    AND AccountName NOT LIKE '%cemetary%'
    AND AccountName NOT LIKE '%fruit%'
    AND AccountName NOT LIKE '%casino%'
    AND AccountName NOT LIKE '%pizza%'
    AND AccountName NOT LIKE '%school%'
    AND AccountName NOT LIKE '%rainforest cafe%'
    AND AccountName NOT LIKE '%construction equipment%'
	AND AccountName NOT LIKE '%mechanical%'
	AND AccountName NOT LIKE '%refrig%'
    AND AccountName NOT LIKE '%ice arena%'
    AND AccountName NOT LIKE '%chemicals%'
    AND DebtorID IN (SELECT DebtorID FROM @tblActiveDebtors)
ORDER BY AccountName;
*/
/*
UPDATE Person_Link
   SET peli_PRCSReceiveMethod = '1'
  FROM PRAttentionLine
 WHERE peli_CompanyID = prattn_CompanyID
   AND peli_PersonID = prattn_PersonID
   AND prattn_PhoneID IS NOT NULL
   AND prattn_PhoneID > 0
   AND prattn_Disabled IS NULL;


UPDATE Person_Link
   SET peli_PRCSReceiveMethod = '3'
 WHERE peli_PersonLinkID = prwu_PersonLinkID
   AND peli_PRCSReceiveMethod IS NULL;
*/


UPDATE Person_Link
   SET peli_PRCSReceiveMethod = '2',
       peli_PRCSSortOption = CASE prse_ServiceCode WHEN 'EXUPD' THEN 'I-K' ELSE 'I' END
  FROM PRWebUser
       LEFT OUTER JOIN PRService ON prwu_BBID = prse_CompanyID AND prse_ServiceCode = 'EXUPD'
 WHERE peli_PersonLinkID = prwu_PersonLinkID
   AND prwu_Disabled IS NULL
   AND peli_PRCSReceiveMethod IS NULL;
Go



SELECT prattn_CompanyID as [BBID],
       comp_Name as [Company Name],
       prattn_PhoneID [Fax ID],
	   prattn_EmailID [Email ID],
	   prattn_PersonID [Person ID],
	   Addressee,
	   DeliveryAddress [Delivery Address],
	   prattn_Disabled [Disabled]
  FROM vPRCompanyAttentionLine
       INNNER JOIN Company ON prattn_CompanyID = comp_CompanyID
 WHERE prattn_ItemCode = 'CSUPD'
ORDER BY prattn_CompanyID

--DELETE FROM PRAttentionLine WHERE prattn_ItemCode = 'CSUPD'
Go


SELECT prattn_CompanyID as [BBID],
       comp_Name as [Company Name],
       prattn_PhoneID [Fax ID],
	   prattn_EmailID [Email ID],
	   prattn_PersonID [Person ID],
	   Addressee,
	   DeliveryAddress [Delivery Address],
	   prattn_Disabled [Disabled]
  FROM vPRCompanyAttentionLine
       INNNER JOIN Company ON prattn_CompanyID = comp_CompanyID
 WHERE prattn_ItemCode = 'EXUPD'
ORDER BY prattn_CompanyID

--DELETE FROM PRAttentionLine WHERE prattn_ItemCode = 'EXUPD'
Go


UPDATE PRCommunicationLog
   SET prcoml_TranslatedFaxID = SUBSTRING(REPLACE(REPLACE(prcoml_FaxID, 'br001h', ''), 'r17j', '-'), 1, LEN(REPLACE(REPLACE(prcoml_FaxID, 'br001h', ''), 'r17j', '-')) - 1)
 WHERE prcoml_FaxID IS NOT NULL;
Go


UPDATE PRPublicationTopic
   SET prpbt_Name = 'Credit & Finance',
       prpbt_Name_ES = 'Credit & Finance (ES)',
	   prpbt_UpdatedDate = GETDATE()
 WHERE prpbt_PublicationTopicID = 3
Go


ALTER TABLE Person_Link DISABLE TRIGGER ALL
UPDATE Person_Link
   SET peli_PREditListing = 'Y'
  FROM Company
       INNER JOIN Person_Link ON comp_CompanyID = peli_CompanyID
	   INNER JOIN Person ON peli_PersonID = pers_PersonID
	   INNER JOIN PRWebUser ON peli_PersonLinkID = prwu_PersonLinkID
 WHERE prwu_ServiceCode IS NOT NULL
   AND peli_PREditListing IS NULL;
ALTER TABLE Person_Link DISABLE TRIGGER ALL
Go



UPDATE Company
   SET comp_PRServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate)),
	   comp_PRServiceEndDate = NULL
  FROM PRService
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND comp_PRServiceStartDate IS NULL

UPDATE Company
   SET comp_PROriginalServiceStartDate = DATEADD(dd, 0, DATEDIFF(dd, 0, prse_CreatedDate))
  FROM PRService
 WHERE comp_CompanyID = prse_CompanyID
   AND prse_Primary = 'Y'
   AND comp_PROriginalServiceStartDate IS NULL

UPDATE Company
   SET comp_PRServiceEndDate = CancelDate
 FROM (SELECT comp_CompanyID, comp_PRServiceStartDate, comp_PRServiceEndDate, CancelDate
	  FROM Company
		   INNER JOIN (SELECT prsoat_SoldToCompany, MAX(prsoat_CreatedDate) as CancelDate 
						 FROM PRSalesOrderAuditTrail 
						WHERE prsoat_ActionCode = 'C' GROUP BY prsoat_SoldToCompany) T1 ON comp_CompanyID = prsoat_SoldToCompany
	 WHERE comp_PRServiceStartDate IS NOT NULL
	   AND comp_PRServiceEndDate IS NULL
	   AND comp_CompanyID NOT IN (SELECT prse_CompanyID FROM PRService WHERE prse_Primary = 'Y')
	   AND comp_PRServiceStartDate < CancelDate) T1
WHERE Company.comp_CompanyID = T1.comp_CompanyID;
Go
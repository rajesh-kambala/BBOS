UPDATE PRARAging
   SET praa_Count = praa_ARAgingDetailCount,
       praa_Total = praad_TotalAmountCurrent  + praad_TotalAmount1to30 + praad_TotalAmount31to60 + praad_TotalAmount61to90 + praad_TotalAmount91Plus,
       praa_TotalCurrent = praad_TotalAmountCurrent,
       praa_Total1to30 = praad_TotalAmount1to30,
       praa_Total31to60 = praad_TotalAmount31to60,
       praa_Total61to90 = praad_TotalAmount61to90,
       praa_Total91Plus = praad_TotalAmount91Plus,
       praa_Total0to29 = praad_TotalAmount1to30,
       praa_Total30to44 = praad_TotalAmount31to60,
       praa_Total45to60 = praad_TotalAmount61to90,
       praa_Total61Plus = praad_TotalAmount91Plus       
  FROM  (
		SELECT praad_ARAgingId, 
			   praa_ARAgingDetailCount = COUNT(1), 
			   praad_TotalAmountCurrent = ISNULL(SUM(praad_AmountCurrent), 0),
			   praad_TotalAmount1to30 = ISNULL(SUM(praad_Amount1to30),  0),
			   praad_TotalAmount31to60 = ISNULL(SUM(praad_Amount31to60), 0),
			   praad_TotalAmount61to90 = ISNULL(SUM(praad_Amount61to90), 0),
			   praad_TotalAmount91Plus = ISNULL(SUM(praad_Amount91Plus), 0),
			   praad_TotalAmount0to29 = ISNULL(SUM(praad_Amount0to29),  0),
			   praad_TotalAmount30to44 = ISNULL(SUM(praad_Amount30to44), 0),
			   praad_TotalAmount45to60 = ISNULL(SUM(praad_Amount45to60), 0),
			   praad_TotalAmount61Plus = ISNULL(SUM(praad_Amount61Plus), 0)
		  FROM PRARAgingDetail WITH (NOLOCK) 
	  GROUP BY praad_ARAgingId) T1
	 WHERE praa_ARAgingId = T1.praad_ARAgingId
Go   

DELETE FROM PRListing;
INSERT INTO PRListing (prlst_CompanyID, prlst_Listing) 
SELECT comp_CompanyID, dbo.ufn_GetListingFromCompany(comp_CompanyID, 0, 0) 
  FROM Company WITH (NOLOCK)
 WHERE comp_PRListingStatus IN ('L', 'H', 'LUV', 'N3', 'N4'); 

Go 



DELETE FROM PRCompanyTradeAssociation WHERE prcta_TradeAssociationCode = 'NAWLA';
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_MemberID, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) 
SELECT comp_CompanyID, 'NAWLA', comp_PRNAWLAID, -1, GETDATE(), -1, GETDATE(), GETDATE()
  FROM Company
 WHERE comp_PRNAWLAID IS NOT NULL;
  
--EXEC usp_AccpacDropField 'Company', 'comp_PRNAWLAID'
--EXEC usp_AccpacDropField 'Company', 'comp_PRTradeAssociationLogo'
Go


UPDATE PRTransactionDetail
   SET prtd_NewValue = case prtd_NewValue WHEN '1' THEN 'Less than 1 mmbf' WHEN '2' THEN '1 - 10 mmbf' WHEN '3' THEN '11 - 25 mmbf' WHEN '4' THEN '26 - 50 mmbf' WHEN '5' THEN '51 - 100 mmbf' WHEN '6' THEN '101 - 200 mmbf' ELSE prtd_NewValue END,
       prtd_OldValue = case prtd_OldValue WHEN '1' THEN 'Less than 1 mmbf' WHEN '2' THEN '1 - 10 mmbf' WHEN '3' THEN '11 - 25 mmbf' WHEN '4' THEN '26 - 50 mmbf' WHEN '5' THEN '51 - 100 mmbf' WHEN '6' THEN '101 - 200 mmbf' ELSE prtd_OldValue END,
       prtd_UpdatedDate = GETDATE(),
       prtd_UpdatedBy = -1
  FROM PRTransaction 
       INNER JOIN PRTransactionDetail ON prtx_TransactionID = prtd_TransactionID
       INNER JOIN Company ON prtx_CompanyID = comp_CompanyID
 WHERE prtd_EntityName = 'Company Profile'
   AND prtd_ColumnName = 'Volume'
   AND prtd_CreatedDate > '2011-06-10'
   AND prtd_NewValue IN ('1', '2', '3', '4', '5', '6')
   AND comp_PRIndustryType = 'L';
Go   


UPDATE PRCommodity SET prcm_PublicationArticleID=6042, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=110;
UPDATE PRCommodity SET prcm_PublicationArticleID=6042, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=111;
UPDATE PRCommodity SET prcm_PublicationArticleID=6042, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=112;
UPDATE PRCommodity SET prcm_PublicationArticleID=6043, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=91;
UPDATE PRCommodity SET prcm_PublicationArticleID=6043, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=92;
UPDATE PRCommodity SET prcm_PublicationArticleID=6044, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=343;
UPDATE PRCommodity SET prcm_PublicationArticleID=6045, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=474;
UPDATE PRCommodity SET prcm_PublicationArticleID=6045, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=555;
UPDATE PRCommodity SET prcm_PublicationArticleID=6046, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=93;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=116;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=123;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=556;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=556;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=117;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=122;
UPDATE PRCommodity SET prcm_PublicationArticleID=6047, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=121;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=404;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=407;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=415;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=423;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=421;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=420;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=419;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=418;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=417;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=416;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=422;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=405;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=413;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=414;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=412;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=411;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=410;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=409;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=408;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=406;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=424;
UPDATE PRCommodity SET prcm_PublicationArticleID=6048, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=425;
UPDATE PRCommodity SET prcm_PublicationArticleID=6049, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=53;
UPDATE PRCommodity SET prcm_PublicationArticleID=6050, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=345;
UPDATE PRCommodity SET prcm_PublicationArticleID=6050, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=346;
UPDATE PRCommodity SET prcm_PublicationArticleID=6050, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=347;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=352;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=356;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=357;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=355;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=353;
UPDATE PRCommodity SET prcm_PublicationArticleID=6051, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=354;
UPDATE PRCommodity SET prcm_PublicationArticleID=6052, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=222;
UPDATE PRCommodity SET prcm_PublicationArticleID=6053, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=438;
UPDATE PRCommodity SET prcm_PublicationArticleID=6054, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=348;
UPDATE PRCommodity SET prcm_PublicationArticleID=6055, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=477;
UPDATE PRCommodity SET prcm_PublicationArticleID=6055, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=478;
UPDATE PRCommodity SET prcm_PublicationArticleID=6055, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=479;
UPDATE PRCommodity SET prcm_PublicationArticleID=6056, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=94;
UPDATE PRCommodity SET prcm_PublicationArticleID=6057, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=500;
UPDATE PRCommodity SET prcm_PublicationArticleID=6057, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=517;
UPDATE PRCommodity SET prcm_PublicationArticleID=6057, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=565;
UPDATE PRCommodity SET prcm_PublicationArticleID=6057, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=570;
UPDATE PRCommodity SET prcm_PublicationArticleID=6058, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=8;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=484;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=485;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=486;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=487;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=489;
UPDATE PRCommodity SET prcm_PublicationArticleID=6059, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=488;
UPDATE PRCommodity SET prcm_PublicationArticleID=6060, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=54;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=491;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=498;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=497;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=494;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=495;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=496;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=499;
UPDATE PRCommodity SET prcm_PublicationArticleID=6061, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=492;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=544;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=549;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=548;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=547;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=545;
UPDATE PRCommodity SET prcm_PublicationArticleID=6062, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=546;
UPDATE PRCommodity SET prcm_PublicationArticleID=6063, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=365;
UPDATE PRCommodity SET prcm_PublicationArticleID=6065, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=302;
UPDATE PRCommodity SET prcm_PublicationArticleID=6065, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=303;
UPDATE PRCommodity SET prcm_PublicationArticleID=6065, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=304;
UPDATE PRCommodity SET prcm_PublicationArticleID=6065, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=566;
UPDATE PRCommodity SET prcm_PublicationArticleID=6066, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=62;
UPDATE PRCommodity SET prcm_PublicationArticleID=6067, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=223;
UPDATE PRCommodity SET prcm_PublicationArticleID=6067, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=224;
UPDATE PRCommodity SET prcm_PublicationArticleID=6067, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=227;
UPDATE PRCommodity SET prcm_PublicationArticleID=6068, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=305;
UPDATE PRCommodity SET prcm_PublicationArticleID=6068, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=306;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=370;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=380;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=379;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=378;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=377;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=371;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=376;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=373;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=374;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=383;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=372;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=577;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=375;
UPDATE PRCommodity SET prcm_PublicationArticleID=6069, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=381;
UPDATE PRCommodity SET prcm_PublicationArticleID=6070, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=226;
UPDATE PRCommodity SET prcm_PublicationArticleID=6071, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=203;
UPDATE PRCommodity SET prcm_PublicationArticleID=6071, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=564;
UPDATE PRCommodity SET prcm_PublicationArticleID=6072, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=64;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=385;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=386;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=387;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=392;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=388;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=389;
UPDATE PRCommodity SET prcm_PublicationArticleID=6073, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=390;
UPDATE PRCommodity SET prcm_PublicationArticleID=6074, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=65;
UPDATE PRCommodity SET prcm_PublicationArticleID=6074, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=66;
UPDATE PRCommodity SET prcm_PublicationArticleID=6074, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=67;
UPDATE PRCommodity SET prcm_PublicationArticleID=6074, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=68;
UPDATE PRCommodity SET prcm_PublicationArticleID=6074, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=69;
UPDATE PRCommodity SET prcm_PublicationArticleID=6075, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=70;
UPDATE PRCommodity SET prcm_PublicationArticleID=6075, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=558;
UPDATE PRCommodity SET prcm_PublicationArticleID=6075, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=575;
UPDATE PRCommodity SET prcm_PublicationArticleID=6076, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=98;
UPDATE PRCommodity SET prcm_PublicationArticleID=6076, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=567;
UPDATE PRCommodity SET prcm_PublicationArticleID=6077, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=501;
UPDATE PRCommodity SET prcm_PublicationArticleID=6077, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=571;
UPDATE PRCommodity SET prcm_PublicationArticleID=6077, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=503;
UPDATE PRCommodity SET prcm_PublicationArticleID=6077, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=502;
UPDATE PRCommodity SET prcm_PublicationArticleID=6078, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=99;
UPDATE PRCommodity SET prcm_PublicationArticleID=6078, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=100;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=71;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=76;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=77;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=75;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=74;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=73;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=72;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=78;
UPDATE PRCommodity SET prcm_PublicationArticleID=6080, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=79;
UPDATE PRCommodity SET prcm_PublicationArticleID=6081, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=208;
UPDATE PRCommodity SET prcm_PublicationArticleID=6081, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=209;
UPDATE PRCommodity SET prcm_PublicationArticleID=6081, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=210;
UPDATE PRCommodity SET prcm_PublicationArticleID=6082, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=264;
UPDATE PRCommodity SET prcm_PublicationArticleID=6083, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=102;
UPDATE PRCommodity SET prcm_PublicationArticleID=6083, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=103;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=161;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=162;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=165;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=166;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=163;
UPDATE PRCommodity SET prcm_PublicationArticleID=6084, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=164;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=427;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=431;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=432;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=433;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=428;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=429;
UPDATE PRCommodity SET prcm_PublicationArticleID=6085, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=430;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=505;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=520;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=519;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=1502;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=581;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=518;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=529;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=506;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=507;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=516;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=514;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=515;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=513;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=512;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=511;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=509;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=510;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=528;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=508;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=521;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=527;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=526;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=525;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=524;
UPDATE PRCommodity SET prcm_PublicationArticleID=6086, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=523;
UPDATE PRCommodity SET prcm_PublicationArticleID=6087, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=213;
UPDATE PRCommodity SET prcm_PublicationArticleID=6088, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=118;
UPDATE PRCommodity SET prcm_PublicationArticleID=6088, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=119;
UPDATE PRCommodity SET prcm_PublicationArticleID=6089, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=104;
UPDATE PRCommodity SET prcm_PublicationArticleID=6090, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=215;
UPDATE PRCommodity SET prcm_PublicationArticleID=6091, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=451;
UPDATE PRCommodity SET prcm_PublicationArticleID=6091, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=454;
UPDATE PRCommodity SET prcm_PublicationArticleID=6091, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=452;
UPDATE PRCommodity SET prcm_PublicationArticleID=6092, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=323;
UPDATE PRCommodity SET prcm_PublicationArticleID=6093, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=455;
UPDATE PRCommodity SET prcm_PublicationArticleID=6093, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=456;
UPDATE PRCommodity SET prcm_PublicationArticleID=6094, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=57;
UPDATE PRCommodity SET prcm_PublicationArticleID=6095, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=391;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=324;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=335;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=334;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=333;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=327;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=562;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=573;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=326;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=328;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=331;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=329;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=330;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=332;
UPDATE PRCommodity SET prcm_PublicationArticleID=6096, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=336;
UPDATE PRCommodity SET prcm_PublicationArticleID=6097, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=84;
UPDATE PRCommodity SET prcm_PublicationArticleID=6098, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=465;
UPDATE PRCommodity SET prcm_PublicationArticleID=6098, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=572;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=535;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=540;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=1501;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=539;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=536;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=538;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=543;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=537;
UPDATE PRCommodity SET prcm_PublicationArticleID=6099, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=541;
UPDATE PRCommodity SET prcm_PublicationArticleID=6101, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=243;
UPDATE PRCommodity SET prcm_PublicationArticleID=6101, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=244;
UPDATE PRCommodity SET prcm_PublicationArticleID=7067, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=467;
UPDATE PRCommodity SET prcm_PublicationArticleID=7172, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=504;
UPDATE PRCommodity SET prcm_PublicationArticleID=7173, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=398;
UPDATE PRCommodity SET prcm_PublicationArticleID=7173, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=399;
UPDATE PRCommodity SET prcm_PublicationArticleID=7188, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=128;
UPDATE PRCommodity SET prcm_PublicationArticleID=7188, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=129;
UPDATE PRCommodity SET prcm_PublicationArticleID=7313, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=200;
UPDATE PRCommodity SET prcm_PublicationArticleID=7314, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=442;
UPDATE PRCommodity SET prcm_PublicationArticleID=7314, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=443;
UPDATE PRCommodity SET prcm_PublicationArticleID=7314, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=444;
UPDATE PRCommodity SET prcm_PublicationArticleID=7314, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=445;
UPDATE PRCommodity SET prcm_PublicationArticleID=7355, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=105;
UPDATE PRCommodity SET prcm_PublicationArticleID=7526, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=51;
UPDATE PRCommodity SET prcm_PublicationArticleID=7526, prcm_UpdatedDate = GETDATE() WHERE prcm_CommodityId=52;

Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Apples_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6042;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Apricots_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6043;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Artichokes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6044;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Asparagus_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6045;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Avocados_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6046;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Bananas_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6047;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Beans_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6048;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Blackberries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7526;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Blueberries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6049;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Broccoli_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6050;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cabbage_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6051;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cantaloupe_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6052;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Carrots_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6053;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cauliflower_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6054;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Celery_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6055;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cherries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6056;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Chile Peppers_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6057;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Christmas Trees_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6058;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Corn_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6059;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cranberries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6060;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Cucumbers_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6061;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Dates_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7188;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Eggplant_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6062;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Escarole_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6063;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Figs_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7313;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Fresh-Cut Produce_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6064;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Garlic_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6065;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Ginger Root_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7314;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Grapefruit_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6066;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Grapes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6067;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Green Onions_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6068;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Greens_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6069;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Honeydew Melons_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6070;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Kiwifruit_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6071;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Lemons_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6072;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Lettuce_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6073;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Limes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6074;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Mandarin Oranges_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6075;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Mangos_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6076;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Mushrooms_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6077;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Nectarines_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6078;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Okra_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7172;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Onions_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7594;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Oranges_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6080;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Papayas_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6081;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Parsley_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6082;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Peaches_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6083;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Pears_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6084;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Peas_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6085;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Peppers_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6086;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Pineapples_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6087;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Plantains_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6088;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Plums_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6089;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Pluots_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7355;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Pomegranates_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6090;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Potatoes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6091;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Pumpkins_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6092;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Radishes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6093;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Raspberries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6094;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Romaine_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6095;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Spinach_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7173;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Squash_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6096;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Strawberries_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6097;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Sweet Potatoes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6098;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Tomatoes_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6099;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Turnips_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=7067;
Update PRPublicationArticle SET prpbar_PublicationCode='KYC', prpbar_FileName = REPLACE(prpbar_FileName, 'BBR\', 'KYC\'),  prpbar_CoverArtThumbFileName = 'KYC/Watermelon_Thumbnail.jpg' WHERE prpbar_PublicationArticleID=6101;

UPDATE PRPublicationArticle
   SET prpbar_Name = REPLACE(prpbar_Name, 'Know Your Commodity - ', '') 
 WHERE prpbar_PublicationCode='KYC';
 

DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6009
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6009,'IA','Know Your Commodity','KnowYourCommodity',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'

Go



DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6010
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6010,'LPA','Company Public Profile','CompanyPublicProfile',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'

DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6011
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6011,'BBSi','Company Public Profile','CompanyPublicProfile',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'

DELETE FROM PRAdEligiblePage WHERE pradep_AdEligiblePageID = 6012
INSERT INTO PRAdEligiblePage
(pradep_AdEligiblePageID,pradep_AdCampaignType,pradep_DisplayName,pradep_PageName,pradep_MaxAdCount,pradep_MinAdCount,pradep_MaxImageHeight,pradep_MaxImageWidth,pradep_CreatedBy,pradep_CreatedDate,pradep_UpdatedBy,pradep_UpdatedDate,pradep_TimeStamp)
VALUES (6012,'BBSiAni','Company Public Profile','CompanyPublicProfile',25,NULL,NULL,NULL,-100,GETDATE(),-100,GETDATE(),GETDATE());
EXEC usp_UpdateSQLIdentity 'PRAdEligiblePage', 'pradep_AdEligiblePageID'

Go


DECLARE @AdTable table (
    ndx int identity(1,1),
	AdCampaignID int)

INSERT INTO @AdTable (AdCampaignID)
SELECT pradc_AdCampaignID 
  FROM PRAdCampaign 
 WHERE pradc_AdCampaignType='LPA'
   AND GETDATE() BETWEEN pradc_StartDate and pradc_EndDate;
   
DECLARE @Index int, @Count int, @ID int, @AdCampaignID int

SELECT @Count = COUNT(1) from @AdTable;
SET @Index = 0

WHILE (@Index < @Count) BEGIN

	SET @Index = @Index + 1
	EXEC usp_GetNextId 'PRAdCampaignPage', @ID output

	SELECT @AdCampaignID = AdCampaignID 
	  FROM @AdTable 
	  WHERE ndx = @Index;

	INSERT INTO PRAdCampaignPage
      (pradcp_AdCampaignPageID,pradcp_AdCampaignID,pradcp_AdEligiblePageID,pradcp_CreatedBy,pradcp_CreatedDate,pradcp_UpdatedBy,pradcp_UpdatedDate,pradcp_TimeStamp)
    VALUES (@ID,@AdCampaignID,6010,-100,GETDATE(),-100,GETDATE(),GETDATE());

END
Go

DELETE FROM PRCompanyTradeAssociation WHERE prcta_TradeAssociationCode = 'PBH'
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100073, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100428, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100563, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100586, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100593, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100664, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (100723, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101043, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101124, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101199, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101235, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101444, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101651, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101759, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101784, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (101972, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102141, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102316, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102397, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102407, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102565, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102585, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (102679, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103069, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103100, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103173, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103182, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103402, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103481, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103625, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103627, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103639, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103769, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (103842, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104206, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104221, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104351, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104388, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104524, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104709, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104786, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104887, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (104892, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105137, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105293, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105295, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105307, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105541, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105664, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (105925, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (106032, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (106069, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (107383, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (107452, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (107996, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (108284, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (108293, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (108626, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (108839, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (109995, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (110823, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (110909, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111187, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111265, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111282, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111359, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111865, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111882, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111891, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111898, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111934, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (111953, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (112922, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (112956, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (112987, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113044, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113203, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113369, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113445, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113453, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113492, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113521, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113637, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113654, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113708, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113721, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113833, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (113835, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114014, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114027, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114174, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114498, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114714, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114741, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114744, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (11479, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (114867, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (115075, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (115535, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (115577, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (115894, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (116044, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (116075, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (116246, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (116424, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (116490, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (117124, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (117213, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (118126, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (119967, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (120800, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (121758, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (122041, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (122832, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (122923, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (123319, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (124463, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (125111, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (126189, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (126532, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (126736, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (126866, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (127803, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (130750, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (133194, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (133466, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (133777, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (134183, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (137716, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (138251, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (138475, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (138665, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (140336, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (140966, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (142198, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (143789, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (145028, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (145218, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (145458, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (145473, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (145890, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (149226, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (149536, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (150172, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (150240, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (151376, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (152072, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (152290, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (152351, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (152652, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153016, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153596, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153597, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153670, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153673, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153708, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (153753, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (154001, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (154156, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (155976, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (156533, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (156770, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (156835, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (156837, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (157163, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (157310, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (157755, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (158201, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (158433, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (158826, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (158953, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (158980, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (159232, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (159251, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (159941, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (160338, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161000, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161059, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161138, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161206, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161683, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (161860, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162339, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162347, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162420, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162426, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162567, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162569, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162609, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (162634, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (163180, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (163260, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (163269, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (163399, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (165295, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (165851, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (167605, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (167679, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (167710, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (167752, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (168663, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (169584, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (170403, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (171100, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (171819, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (172202, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (172210, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (172360, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (172413, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (182862, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (187336, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (188221, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (189666, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (191194, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (205699, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (208106, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (209447, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (210406, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (259748, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (262633, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
INSERT INTO PRCompanyTradeAssociation (prcta_CompanyID, prcta_TradeAssociationCode, prcta_CreatedBy, prcta_CreatedDate, prcta_UpdatedBy, prcta_UpdatedDate, prcta_TimeStamp) VALUES (275896, 'PBH', -1, GETDATE(), -1, GETDATE(), GETDATE())
Go
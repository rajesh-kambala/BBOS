--9.1 Release DataCorrections

--Defect 7548 - TES on themselves
DELETE FROM PRTradeReport WHERE prtr_ResponderId = prtr_SubjectId
Go

--Defect 7480
DELETE FROM PRRatingNumeral WHERE prrn_name in ('(54)','(55)','(56)','(57)','(58)')
Go

--Defect 7268 
UPDATE PRFinancial 
SET prfs_DaysPayableOutstanding =	CASE
										WHEN prfs_AccountsPayable IS NULL OR ISNULL(prfs_CostGoodsSold,0)=0 THEN NULL
										WHEN prfs_InterimMonth IS NOT NULL THEN ROUND((prfs_AccountsPayable*365*prfs_InterimMonth/12) / prfs_CostGoodsSold, 2)
									END,
	prfs_UpdatedDate=GETDATE(),
	prfs_UpdatedBy=-1
WHERE
	prfs_type='I' 
	AND prfs_DaysPayableOutstanding IS NOT NULL
	AND (
			(prfs_AccountsPayable IS NULL OR ISNULL(prfs_CostGoodsSold,0)=0)
			OR
			prfs_InterimMonth IS NOT NULL
		)
GO


DECLARE @WorkTable table (
	InvoiceNumber varchar(15),
	InvoiceDate datetime
)

INSERT INTO @WorkTable
SELECT DISTINCT  vBBSiMasterInvoices.UDF_MASTER_INVOICE, vBBSiMasterInvoices.InvoiceDate
  FROM MAS_PRC.dbo.vBBSiMasterInvoices 
 WHERE (Balance > 0 AND InvoiceDueDate < GETDATE())
   AND prci2_BillingException IS NULL 
ORDER BY vBBSiMasterInvoices.UDF_MASTER_INVOICE


UPDATE PRInvoice
   SET prinv_FirstReminderDate = '2000-01-01'
 WHERE prinv_InvoiceNbr IN (SELECT InvoiceNumber FROM @WorkTable  WHERE DATEDIFF(day, InvoiceDate, GETDATE()) > 29) 
Go
UPDATE PRWebServiceLicenseKey SET prwslk_IndustryTypeCodes = '''P'',''T'',''S''' WHERE prwslk_IndustryTypeCodes IS NULL;
Go

--Defect 7337 - Business Valuations
DELETE FROM NewProduct WHERE prod_ProductID=109
INSERT INTO NewProduct
	(Prod_ProductID,prod_Active,prod_UOMCategory,prod_name,prod_code,prod_productfamilyid,prod_IndustryTypeCode,prod_PRSequence,prod_PRDescription,Prod_CreatedBy,Prod_CreatedDate,Prod_UpdatedBy,Prod_UpdatedDate,Prod_TimeStamp)
VALUES (109,'Y',6000,'Business Valuation','BV', 10, ',P,T,S,L,', 150, '<div style="font-weight:bold">Business Valuation</div><p style="margin-top:0em">Business Valuation</p>',-1,GETDATE(),-1,GETDATE(),GETDATE());
GO

DELETE FROM Pricing WHERE pric_ProductID=109
INSERT INTO Pricing (pric_PricingID, pric_ProductID, pric_Price, pric_Price_CID, pric_PricingListID, pric_Active, pric_CreatedBy, pric_CreatedDate, pric_UpdatedBy, pric_UpdatedDate, pric_TimeStamp)
VALUES (89, 109, 175, 16010, 16010, 'Y', -1, GETDATE(), -1, GETDATE(), GETDATE());
GO

	
UPDATE Person_Link SET peli_PRCanViewBusinessValuations='Y', PeLi_UpdatedBy=-1, PeLi_UpdatedDate=GETDATE() WHERE peli_prownershiprole='RCO'

UPDATE PRWebServiceLicenseKey SET prwslk_IndustryTypeCodes = '''P'',''T'',''S'',''L''' WHERE prwslk_WebServiceLicenseID  =5000
INSERT INTO PRWebServiceLicenseKeyWM (prwslkwm_WebServiceLicenseID, prwslkwm_WebMethodName) VALUES (5000, 'GetBusinessReport')
Go

DECLARE @Start datetime = GETDATE()
DELETE FROM PRMembershipReportTable;
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 102552, 'jbl', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 110216, 'tjr', '3/18/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 116471, 'tjr', '3/20/2024', 'BBS250', 1, 1450, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 159253, 'tjr', '3/12/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 171708, 'tjr', '3/28/2024', 'BASIC', 1, 995, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 173781, 'tjr', '3/20/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 206087, 'tjr', '3/14/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 249209, 'jeb', '3/1/2024', 'L200', 1, 1280, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 280833, 'lel', '3/29/2024', 'BASIC', 1, 995, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 281967, 'lel', '3/29/2024', 'STANDARD', 1, 1795, 'INBOUND', '', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 285861, 'jbl', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 293908, 'jbl', '3/13/2024', 'BBS150', 1, 925, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 296261, 'imm', '3/11/2024', 'BBS300', 1, 1995, 'REINSTATEMENT', '', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 296605, 'tjr', '3/15/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 296616, 'tjr', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 297845, 'imm', '3/5/2024', 'BBS150', 1, 925, 'INTERNAL LEAD', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 333439, 'tjr', '3/6/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 341062, 'imm', '3/11/2024', 'BBS200', 1, 1150, 'REINSTATEMENT', 'OTHER', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 342117, 'lel', '3/15/2024', 'BBSINTL', 1, 599, 'OUTBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 348443, 'tjr', '3/20/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 355183, 'jbl', '3/13/2024', 'BBS300', 1, 1995, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 355849, 'lel', '3/12/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 361439, 'jbl', '3/18/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 365387, 'jbl', '3/21/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 368322, 'lel', '3/4/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 368631, 'jbl', '3/19/2024', 'BBS150', 1, 925, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 377160, 'tjr', '3/7/2024', 'BBS150', 1, 925, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 394652, 'lel', '3/1/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 395210, 'jbl', '3/21/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 395793, 'lel', '3/6/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 396827, 'jbl', '3/28/2024', 'STANDARD', 1, 1795, 'IFPA FRESH PRODUCE & FLORAL SHOW', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 396830, 'jrm', '3/5/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 396847, 'lel', '3/15/2024', 'BBS200', 1, 1150, 'PACA', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 396935, 'tjr', '3/11/2024', 'BBS200', 1, 1150, 'PACA', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397207, 'lel', '3/1/2024', 'BBSINTL', 1, 599, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397473, 'lel', '3/21/2024', 'BBS200', 1, 1150, 'OUTBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397727, 'tjr', '3/5/2024', 'BBS200', 1, 1150, 'PACA', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397730, 'tjr', '3/8/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397757, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'OUTBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397806, 'lel', '3/25/2024', 'BBS150', 1, 925, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397969, 'jbl', '3/11/2024', 'BBS300', 1, 1995, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397970, 'lel', '3/28/2024', 'BBSINTL', 1, 599, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397970, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397975, 'lel', '3/6/2024', 'BBS200', 1, 805, 'PACA', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397980, 'lel', '3/28/2024', 'BBSINTL', 1, 599, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397980, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 397984, 'tjr', '3/4/2024', 'BBS150', 1, 925, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398002, 'lel', '3/11/2024', 'BBSINTL', 1, 599, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398005, 'lel', '3/11/2024', 'BBS200', 1, 1150, 'PACA', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398018, 'lel', '3/13/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398019, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398022, 'jeb', '3/11/2024', 'L200', 1, 1280, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398027, 'tjr', '3/12/2024', 'BBS150', 1, 925, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398031, 'lel', '3/12/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398037, 'jbl', '3/22/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398044, 'tjr', '3/22/2024', 'BBS250', 1, 1450, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398054, 'lel', '3/14/2024', 'BBS300', 1, 1995, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398077, 'tjr', '3/19/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398092, 'tjr', '3/21/2024', 'BBS200', 1, 1150, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398101, 'tjr', '3/22/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398103, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398104, 'lel', '3/25/2024', 'BBS200', 1, 1150, 'ONLINE', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398110, 'tjr', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 398117, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 404261, 'lel', '3/28/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
INSERT INTO PRMembershipReportTable (prmr_TypeCode,prmr_CompanyID,prmr_SoldBy,prmr_InvoiceDate,prmr_ItemCode,prmr_Quantity,prmr_Amount,prmr_Pipeline,prmr_UpDown,prmr_CreatedBy,prmr_CreatedDate) VALUES ('NEW', 404265, 'tjr', '3/29/2024', 'STANDARD', 1, 1795, 'INBOUND', 'NEW', 1, @Start)
Go
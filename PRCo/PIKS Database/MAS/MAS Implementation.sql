USE MAS_PRC
IF EXISTS (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetBillTo]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    DROP FUNCTION [dbo].[ufn_GetBillTo]
GO
CREATE FUNCTION [dbo].[ufn_GetBillTo] ( 
    @BillToCustomerNo varchar (20),
    @CustomerNo varchar(20)
)
RETURNS varchar(20)
AS
BEGIN
	RETURN CASE WHEN @BillToCustomerNo <> '' THEN @BillToCustomerNo ELSE @CustomerNo END
END
GO



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ufn_InvoiceDetailPrimarySortOrder]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	DROP FUNCTION dbo.ufn_InvoiceDetailPrimarySortOrder
GO

CREATE FUNCTION dbo.ufn_InvoiceDetailPrimarySortOrder(@CompanyID varchar(20))  
RETURNS int AS  
BEGIN 

	DECLARE @SortOrder int = 0
	DECLARE @PrimaryCompanyNo varchar(20)

	SELECT @PrimaryCompanyNo = CustomerNo
	  FROM AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
		   INNER JOIN AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
		   INNER JOIN CI_Item ON ihd.ItemCode = CI_Item.ItemCode
	 WHERE Category2 = 'PRIMARY'
	   AND dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo) = @CompanyID
	   

	IF (@PrimaryCompanyNo = @CompanyID)
		SET @SortOrder = 1
	ELSE 
		SET @SortOrder = 99
	
	   
	RETURN @SortOrder 
END  
Go


CREATE OR ALTER VIEW vBBSiMasterInvoices
AS
SELECT JournalNoGLBatchNo,
       ihh.UDF_MASTER_INVOICE
      ,c.CustomerNo As BillToCustomerNo
      ,ihh.InvoiceDate
      ,ihh.InvoiceDueDate       
      ,TermsCodeDesc
      ,ISNULL(RTRIM(Addressee), '') as ContactName
      ,UDF_BILL_NAME As BillToName
      ,ISNULL(RTRIM(ca.Addr_Address1), '') As BillToAddress1
      ,ISNULL(RTRIM(ca.Addr_Address2), '') As BillToAddress2
      ,ISNULL(RTRIM(ca.Addr_Address3), '') As BillToAddress3
      ,ISNULL(RTRIM(ca.prci_City), '') As BillToCity
      ,ISNULL(RTRIM(ca.State), '') As BillToState
      ,ISNULL(RTRIM(PostCode), '') As BillToZipCode
      ,ISNULL(ca.prcn_CountryID, '') As BillToCountryCode  
      ,ISNULL(RTRIM(ca.prcn_Country), '') as CountryName

	  ,CASE WHEN HasAdvertising=1 THEN
			ISNULL(CRM.dbo.ufn_FormatPhone(advBillPhone.Phon_CountryCode, advBillPhone.Phon_AreaCode, advBillPhone.Phon_Number, advBillPhone.phon_PRExtension), ca.Fax) 
		ELSE
			ISNULL(ca.Fax, '')
		END as FaxNo

	  ,CASE WHEN HasAdvertising=1 THEN
			ISNULL(RTRIM(advBillEmail.Emai_EmailAddress), RTRIM(ca.EmailAddress))
	  ELSE
			ISNULL(RTRIM(ca.EmailAddress), '') 
	  END as EmailAddress

      ,SUM(ihh.DiscountAmt) As DiscountAmt
      ,SUM(TaxableSalesAmt) As TaxableSalesAmt
      ,SUM(NonTaxableSalesAmt) As NonTaxableSalesAmt
      ,SUM(ihh.SalesTaxAmt) As SalesTaxAmt
      ,Total = (SUM(TaxableSalesAmt) + SUM(NonTaxableSalesAmt) + SUM(ihh.SalesTaxAmt) - SUM(ihh.DiscountAmt))
      ,Balance = SUM(Balance)
      ,prci2_BillingException
      ,ISNULL(ca.prattn_IncludeWireTransferInstructions, 'N') AS prattn_IncludeWireTransferInstructions
	  ,CASE WHEN ca.prattn_AddressID IS NOT NULL THEN 'Y' ELSE 'N' END HasBillAddress,
	  ISNULL(HasAdvertising, 0) HasAdvertisingItemCode,
	  prci2_StripeCustomerId
 FROM AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
      INNER JOIN AR_Customer c WITH (NOLOCK) ON dbo.ufn_GetBillTo(BillToCustomerNo, ihh.CustomerNo) = c.CustomerNo AND ISNUMERIC(c.CustomerNo) = 1 AND c.ARDivisionNo <> '01'
      INNER JOIN AR_TermsCode tc WITH (NOLOCK) ON  ihh.TermsCode = tc.TermsCode
      INNER JOIN CRM.dbo.vPRCompanyAccounting ca WITH (NOLOCK) ON c.CustomerNo = comp_CompanyID
      LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_Country sysc WITH (NOLOCK) ON c.CountryCode = sysc.CountryCode
      LEFT OUTER JOIN AR_CustomerContact WITH (NOLOCK) ON c.CustomerNo = AR_CustomerContact.CustomerNo
      LEFT OUTER JOIN CRM.dbo.PRCompanyIndicators WITH (NOLOCK) ON c.CustomerNo = prci2_CompanyID
      LEFT OUTER JOIN AR_OpenInvoice ON ihh.InvoiceNo = AR_OpenInvoice.InvoiceNo AND ihh.HeaderSeqNo = AR_OpenInvoice.InvoiceHistoryHeaderSeqNo
	  LEFT OUTER JOIN CRM.dbo.PRAttentionLine advbill WITH(NOLOCK) ON advbill.prattn_CompanyID = comp_CompanyID AND advBill.prattn_ItemCode='ADVBILL'
	  LEFT OUTER JOIN CRM.dbo.Email advBillEmail WITH (NOLOCK) ON advbill.prattn_EmailID = advBillEmail.Emai_EmailId
	  LEFT OUTER JOIN CRM.dbo.Phone advBillPhone WITH (NOLOCK) ON advbill.prattn_PhoneID = advBillPhone.Phon_PhoneId
	  LEFT OUTER JOIN (SELECT DISTINCT UDF_MASTER_INVOICE, 1 HasAdvertising 
	                     FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
                              INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo
	                    WHERE ItemCode IN ('LMBAD','TTAD','BPAD','RGADPREM','IADVB','PRDBAD','PRLAD','LHPAD','SQHPAD''IADVI','RGAD', 'IADBUT', 'IADVI', 'SQHPAD')
						  AND UDF_MASTER_INVOICE IS NOT NULL
						  AND UDF_MASTER_INVOICE <> ''
						  AND SourceJournal = 'SO') AdvItems ON AdvItems.UDF_MASTER_INVOICE = ihh.UDF_MASTER_INVOICE
	
WHERE ihh.UDF_MASTER_INVOICE IS NOT NULL      
  AND ihh.UDF_MASTER_INVOICE <> ''
  AND SourceJournal = 'SO'
GROUP BY JournalNoGLBatchNo, ihh.UDF_MASTER_INVOICE, c.CustomerNo, ihh.InvoiceDate,
      ihh.InvoiceDueDate, TermsCodeDesc, ISNULL(RTRIM(Addressee), ''), 
	  UDF_BILL_NAME, ca.Addr_Address1, ca.Addr_Address2, ca.Addr_Address3, ca.prci_City,
      ca.State, PostCode, ca.prcn_CountryID, ca.prcn_Country, ca.Fax,ca.EmailAddress,
      prci2_BillingException, ca.prattn_IncludeWireTransferInstructions, ca.prattn_AddressID, advbill.prattn_EmailID,
	  Phon_CountryCode, Phon_AreaCode, Phon_Number, phon_PRExtension, Emai_EmailAddress, HasAdvertising, prci2_StripeCustomerId
Go


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AR_InvoiceHistoryHeader]') AND name = N'IDX_UDF_MASTER_INVOICE')
	CREATE NONCLUSTERED INDEX [IDX_UDF_MASTER_INVOICE] ON [dbo].[AR_InvoiceHistoryHeader] 
		([UDF_MASTER_INVOICE] ASC) 
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] 
GO 


IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AR_InvoiceHistoryHeader]') AND name = N'IDX_JournalNoGLBatchNo')
	CREATE NONCLUSTERED INDEX [IDX_JournalNoGLBatchNo] ON [dbo].[AR_InvoiceHistoryHeader] 
		([JournalNoGLBatchNo] ASC) 
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY] 
GO 


IF EXISTS(select * FROM sys.views where name = 'vBBSiMasterInvoiceDetails') BEGIN
	DROP View vBBSiMasterInvoiceDetails
END
Go

CREATE VIEW vBBSiMasterInvoiceDetails 
AS
SELECT DISTINCT mi.JournalNoGLBatchNo,
       mi.UDF_MASTER_INVOICE,
       mi.BillToCustomerNo,
       ihh.ShipToCity, 
       ihh.ShipToState, 
       ihd.DetailSeqNo,
       ihd.ItemCode, 
       ihd.ItemCodeDesc,
       ExplodedKitItem, 
       QuantityOrdered, 
       ExtensionAmt, 
       UnitPrice,
       LineDiscountPercent,
       ISNULL(PrimarySort, 9999) As PrimarySortOrder,
       prci_City as ListingCity,
       ISNULL(prst_Abbreviation, prst_State) as ListingState,
       prcn_Country,
       ihh.CustomerNo
  FROM vBBSiMasterInvoices mi
       INNER JOIN AR_InvoiceHistoryHeader ihh WITH (NOLOCK) ON mi.UDF_MASTER_INVOICE = ihh.UDF_MASTER_INVOICE
       INNER JOIN AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
       INNER JOIN CRM.dbo.Company WITH (NOLOCK) ON Comp_CompanyId = CAST(ihh.CustomerNo As Int)
       INNER JOIN CRM.dbo.vPRLocation ON comp_PRListingCityID = prci_CityID
       LEFT OUTER JOIN (
			SELECT DISTINCT CustomerNo As PrimaryCompanyID, 1 as PrimarySort
			  FROM AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
				   INNER JOIN AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo 
				   INNER JOIN CI_Item ON ihd.ItemCode = CI_Item.ItemCode
			 WHERE Category2 = 'PRIMARY') T1 ON CustomerNo = PrimaryCompanyID;
Go

 

IF EXISTS(select * FROM sys.views where name = 'vBBSiInvoiceDetails') BEGIN
	DROP View vBBSiInvoiceDetails
END
Go

CREATE VIEW vBBSiInvoiceDetails 
AS
SELECT CustomerNo, ihh.InvoiceNo, InvoiceDate, ihd.ItemCode, Category2, ExtensionAmt
  FROM MAS_PRC.dbo.AR_InvoiceHistoryHeader ihh WITH (NOLOCK)
       INNER JOIN MAS_PRC.dbo.AR_InvoiceHistoryDetail ihd WITH (NOLOCK) ON ihh.InvoiceNo = ihd.InvoiceNo AND ihh.HeaderSeqNo = ihd.HeaderSeqNo
	   INNER JOIN MAS_PRC.dbo.CI_Item ON ihd.ItemCode = CI_Item.ItemCode
Go


/*
*
*/
USE CRM
DECLARE @Script varchar(max)
SET @Script = 
'CREATE VIEW dbo.vPRBBOSInternalExport AS
SELECT comp_CompanyID as [Company ID],
       comp_PRCorrTradestyle as [Correspondence Tradestyle],
	   comp_PRLegalName as [Legal Tradestyle],
	   comp_PRBookTradestyle as [Book Tradestyle],
	   prci_SalesTerritory as [Sales Territory],
	   prse_Primary as [Is Member],
	   ItemCodeDesc as [Primary Service],
	   comp_PRReceivePromoEmails as [Receive Promo Emails],
	   comp_PRReceivePromoFaxes as [Receive Promo Faxes],
	   AvailLicenses as [Available Licenses],
	   ActiveLicenses as [Active Licenses],
	   AdvertisingRevenue as [Advertising Revenue],
	   MembershipRevenue as [Membership Revenue],
	   AvailableUnits as [Available Units],
	   UsedUnits as [Used Units]
  FROM Company WITH (NOLOCK)
       INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID
	   LEFT OUTER JOIN PRService on comp_CompanyID = prse_CompanyID AND prse_Primary = ''Y''
	   LEFT OUTER JOIN (SELECT prse_CompanyID, SUM(QuantityOrdered) As AvailLicenses 
	                      FROM PRService
						 WHERE Category2 = ''License''
                      GROUP BY prse_CompanyID) As T1 ON comp_CompanyID = T1.prse_CompanyID  
	   LEFT OUTER JOIN (SELECT prwsat_CompanyID, COUNT(DISTINCT prwsat_WebUserID) As ActiveLicenses 
	                      FROM PRWebAuditTrail WITH (NOLOCK)
                         WHERE prwsat_CreatedDate >= DATEADD(month, -6, GETDATE())
                      GROUP BY prwsat_CompanyID) As T2 ON comp_CompanyID = T2.prwsat_CompanyID  
	   LEFT OUTER JOIN (SELECT CAST(CustomerNo as Int) CompanyID, SUM(ExtensionAmt) As AdvertisingRevenue
	                      FROM MAS_PRC.dbo.vBBSiInvoiceDetails WITH (NOLOCK)
                         WHERE InvoiceDate >= DATEADD(month, -12, GETDATE())
						   AND Category2 = ''Adverts''
                      GROUP BY CustomerNo) As T3 ON comp_CompanyID = T3.CompanyID  
	   LEFT OUTER JOIN (SELECT CAST(CustomerNo as Int) CompanyID, SUM(DiscountAmt + TaxableAmt + NonTaxableAmt+ SalesTaxAmt) As MembershipRevenue
	                      FROM MAS_PRC.dbo.SO_SalesOrderHeader WITH (NOLOCK)
                         WHERE OrderType = ''R''
						    AND CycleCode <> ''99''
                      GROUP BY CustomerNo) As T4 ON comp_CompanyID = T4.CompanyID  
	   LEFT OUTER JOIN (SELECT prun_CompanyID, SUM(prun_UnitsRemaining) As AvailableUnits
	                      FROM PRServiceUnitAllocation WITH (NOLOCK)
                         WHERE GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate
                      GROUP BY prun_CompanyID) As T5 ON comp_CompanyID = T5.prun_CompanyID  	
	   LEFT OUTER JOIN (SELECT prsuu_CompanyID, SUM(prsuu_Units) As UsedUnits
	                      FROM PRServiceUnitUsage WITH (NOLOCK)
                         WHERE prsuu_CreatedDate >= DATEADD(YEAR,DATEDIFF(YEAR,0,GETDATE()),0)
                      GROUP BY prsuu_CompanyID) As T6 ON comp_CompanyID = T6.prsuu_CompanyID'
EXEC usp_TravantCRM_CreateView 'vPRBBOSInternalExport', @Script  
Go


USE MAS_PRC
Go


CREATE OR ALTER TRIGGER [dbo].[trg_BBSi_SalesOrderAuditTrail]
ON [dbo].[SO_SalesOrderDetail]
FOR INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON

    DECLARE @Action as char(1); 
 
    SET @Action = 'I'; -- Set Action to Insert by default. 
    IF EXISTS(SELECT 'x' FROM DELETED) 
    BEGIN 
        SET @Action = 'U'
    END 

	--  After inserting a new Sales Order Detail item MAS then inserts
	--  a detail history item, then circles back to update the original sales
	--  order detail item with the ID of the history item.  We want to ignore
	--  that last update.
	DECLARE @InsertAuditTrail bit = 1;
	
	DECLARE @OldQuantity numeric(24,5), @OldExtensionAmt numeric(24,5)
	
	IF (@Action = 'U') BEGIN
	
		DECLARE @SOHistoryDetlSeqNo varchar(14), @OldSOHistoryDetlSeqNo varchar(14)
		SELECT @SOHistoryDetlSeqNo = SOHistoryDetlSeqNo FROM inserted;
		SELECT @OldSOHistoryDetlSeqNo = SOHistoryDetlSeqNo FROM deleted;
		
		IF @SOHistoryDetlSeqNo <> @OldSOHistoryDetlSeqNo BEGIN
			SET @InsertAuditTrail = 0
		END
	
		SELECT @OldQuantity = QuantityOrdered,
		       @OldExtensionAmt = ExtensionAmt
		  FROM deleted;
	
	END

	IF (@InsertAuditTrail = 1) BEGIN
		INSERT INTO CRM.dbo.PRSalesOrderAuditTrail (prsoat_SalesOrderNo, prsoat_SoldToCompany, prsoat_BillToCompany, prsoat_CycleCode, prsoat_ItemCode, 
													prsoat_Quantity, prsoat_LineDiscountPercent, prsoat_ExtensionAmt, 
													prsoat_QuantityChange, prsoat_ExtensionAmtChange,
													prsoat_Pipeline, prsoat_Up_Down, prsoat_SoldBy,
													prsoat_ActionCode, prsoat_UpdatedBy, prsoat_CreatedBy, prsoat_UserLogon)
		SELECT SO_SalesOrderHeader.SalesOrderNo, CustomerNo, BillToCustomerNo, CycleCode, ItemCode,
			   QuantityOrdered, LineDiscountPercent, ExtensionAmt,
			   CASE @Action WHEN 'I' THEN QuantityOrdered ELSE QuantityOrdered - @OldQuantity END,
			   CASE @Action WHEN 'I' THEN ExtensionAmt ELSE ExtensionAmt - @OldExtensionAmt END,
			   UDF_PIPELINE, UDF_UP_DOWN, SalespersonNo,
			   @Action, SO_SalesOrderHeader.UserUpdatedKey, SO_SalesOrderHeader.UserUpdatedKey, ISNULL(UserLogon, '')
		  FROM inserted	i
			   INNER JOIN SO_SalesOrderHeader ON i.SalesOrderNo = SO_SalesOrderHeader.SalesOrderNo
			   LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User ON SO_SalesOrderHeader.UserUpdatedKey = UserKey
		 WHERE OrderType = 'R'
		   AND CycleCode <> '99'
		   AND SalesAcctKey <> ''
		   AND UnitPrice <> 0;
	END			   

END
Go

CREATE OR ALTER TRIGGER [dbo].[trg_BBSi_SalesOrderDetail_insupd]
	ON [dbo].[SO_SalesOrderDetail]
	FOR INSERT, UPDATE AS
BEGIN
	SET NOCOUNT ON

	DECLARE @CompanyID int, @ItemCount int, @Quantity int, @OldQuantity int
	DECLARE @ItemCode varchar(30),  @OldItemCode  varchar(30), @SalesOrderNo varchar(7)
	DECLARE @Category2 varchar(10), @OrderType varchar(1), @MasterRepeatingOrderNo varchar(7)

	SELECT @CompanyID = CAST(CustomerNo As Int),
	       @SalesOrderNo = SO_SalesOrderHeader.SalesOrderNo,
	       @MasterRepeatingOrderNo = MasterRepeatingOrderNo,
	       @ItemCode = i.ItemCode,
	       @Category2 = Category2,
	       @OrderType = OrderType,
	       @Quantity = QuantityOrdered
	  FROM inserted	i
	       INNER JOIN SO_SalesOrderHeader ON i.SalesOrderNo = SO_SalesOrderHeader.SalesOrderNo
	       INNER JOIN CI_Item ON i.ItemCode = CI_Item.ItemCode
	 WHERE CycleCode <> '99';

	SELECT @OldItemCode = ItemCode,
	       @OldQuantity = QuantityOrdered
	  FROM deleted;

	IF (((@OldItemCode IS NULL) OR
	     (@ItemCode <> @OldItemCode) OR
		 (@Quantity <> @OldQuantity)) AND
		 (@OrderType = 'R')) BEGIN
	    
	    SELECT @ItemCount = SUM(QuantityOrdered)
	      FROM SO_SalesOrderDetail
	     WHERE ItemCode = @ItemCode
	       AND SalesOrderNo = @SalesOrderNo;
	    
		EXEC CRM.dbo.usp_AttentionLineSetDefault @CompanyID, @ItemCode, @ItemCount
	END
	
	IF ((@OldItemCode IS NULL) AND
	    (@Category2 = 'Units')) BEGIN
	
		DECLARE @AllocationType varchar(40) = 'A'
		DECLARE @AddUnits bit = 1
		
		IF @OrderType = 'R' BEGIN
			SET @AllocationType = 'M'
		END

		IF @ItemCode = 'UNITS-RENEWAL' BEGIN
			SET @AllocationType = 'R'

            -- Only one "Renewal" allocation can be active.  Some times
			-- this code fires when MAS line items are re-ordered so
			-- we need to prevent a duplicate allocation.
			IF EXISTS(SELECT 'X'
					  FROM CRM.dbo.PRServiceUnitAllocation
					 WHERE prun_AllocationTypeCode = 'R'
					   AND prun_SourceCode = 'C'
					   AND prun_UnitsAllocated = @Quantity
					   AND prun_CompanyId = @CompanyID
					   AND GETDATE() BETWEEN prun_StartDate AND prun_ExpirationDate) BEGIN
			
				SET @AddUnits = 0	   
			END					  

		END

	
		-- If this is a standard order associated with a repeat 
		-- order, then do not allocate the units.
		IF @OrderType = 'S' AND
		   @MasterRepeatingOrderNo <> ''
		BEGIN
			SET @AddUnits = 0
		END
	
		-- Look to see if this "Additional Unit Purchase"
		-- already exists.
		IF @OrderType = 'S' AND
		   @MasterRepeatingOrderNo = ''
		BEGIN
		
			IF EXISTS(SELECT 'X'
					  FROM CRM.dbo.PRServiceUnitAllocation
					 WHERE prun_AllocationTypeCode = 'A'
					   AND prun_SourceCode = 'O'
					   AND prun_UnitsAllocated = @Quantity
					   AND prun_CompanyId = @CompanyID
					   AND prun_CreatedDate >= DATEADD(day, -4, GETDATE())) BEGIN
			
				SET @AddUnits = 0	   
			END					  
		
		END
		
	
		IF (@AddUnits = 1) BEGIN
			EXEC CRM.dbo.usp_AllocateServiceUnits @CompanyID = @CompanyID,
												  @PersonID = null,
												  @Units = @Quantity,
												  @SourceType = 'C',
												  @AllocationType = @AllocationType;
		END
	END
	
	IF ((@OldItemCode IS NULL) AND
	    (@ItemCode = 'UNITS-CL')) BEGIN
	
		SET @AllocationType = 'A'
		SET @AddUnits = 1
		
		IF @OrderType = 'R' BEGIN
			SET @AllocationType = 'M'

            -- Only one "Membership" allocation can be active.  Some times
			-- this code fires when MAS line items are re-ordered so
			-- we need to prevent a duplicate allocation.
			IF EXISTS(SELECT 'X'
					  FROM CRM.dbo.PRBackgroundCheckAllocation
					 WHERE prbca_AllocationTypeCode = @AllocationType
					   AND prbca_Allocation = @Quantity
					   AND prbca_CompanyId = @CompanyID
					   AND GETDATE() BETWEEN prbca_StartDate AND prbca_ExpirationDate) BEGIN
			
				SET @AddUnits = 0	   
			END					  
		END

		-- If this is a standard order associated with a repeat 
		-- order, then do not allocate the units.
		IF @OrderType = 'S' AND
		   @MasterRepeatingOrderNo <> ''
		BEGIN
			SET @AddUnits = 0
		END

		-- Look to see if this "Additional Unit Purchase"
		-- already exists.
		IF @OrderType = 'S' AND
		   @MasterRepeatingOrderNo = ''
		BEGIN
		
			IF EXISTS(SELECT 'X'
					  FROM CRM.dbo.PRBackgroundCheckAllocation
					 WHERE prbca_AllocationTypeCode = 'A'
					   AND prbca_Allocation = @Quantity
					   AND prbca_CompanyId = @CompanyID
					   AND prbca_StartDate >= DATEADD(day, -4, GETDATE())) BEGIN
			
				SET @AddUnits = 0	   
			END					  
		
		END

		IF (@AddUnits = 1) BEGIN
			EXEC CRM.dbo.usp_AllocateBackgroundChecks @CompanyID = @CompanyID,
												      @Units = @Quantity,
												      @SourceType = 'C',
												      @AllocationType = @AllocationType;
		END
	END
END
Go

CREATE OR ALTER TRIGGER [dbo].[trg_BBSi_SalesOrderHeaderAuditTrail]
	ON [dbo].[SO_SalesOrderHeader]
	FOR DELETE AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO CRM.dbo.PRSalesOrderAuditTrail (prsoat_SalesOrderNo, prsoat_SoldToCompany, prsoat_BillToCompany, prsoat_CycleCode, prsoat_ItemCode, 
	                                            prsoat_Quantity, prsoat_LineDiscountPercent, prsoat_ExtensionAmt, 
	                                            prsoat_QuantityChange, prsoat_ExtensionAmtChange,
												prsoat_Pipeline, prsoat_Up_Down, prsoat_SoldBy,
	                                            prsoat_ActionCode, prsoat_UpdatedBy, prsoat_CreatedBy, prsoat_UserLogon)
	SELECT d_soh.SalesOrderNo, d_soh.CustomerNo, d_soh.BillToCustomerNo, d_soh.CycleCode, i.ItemCode,
		   i.QuantityOrderedRevised, i.LineDiscountPercent, i.LastExtensionAmt, 
		   (0-i.QuantityOrderedRevised), (0-i.LastExtensionAmt), 
		   UDF_PIPELINE, UDF_UP_DOWN, SalespersonNo,
		   'C', d_soh.UserUpdatedKey, d_soh.UserUpdatedKey, ISNULL(UserLogon, '')
	  FROM deleted d_soh 
	       INNER JOIN SO_SalesOrderHistoryDetail i ON d_soh.SalesOrderNo = i.SalesOrderNo
		   LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User ON d_soh.UserUpdatedKey = UserKey
     WHERE d_soh.OrderType = 'R'
	   AND CycleCode <> '99'
       AND i.SalesAcctKey <> ''
       AND i.CancelledLine = 'N'
       AND i.LastUnitPrice <> 0;

END
Go

CREATE OR ALTER TRIGGER [dbo].[trg_BBSi_SalesOrderHistoryAuditTrail]
	ON [dbo].[SO_SalesOrderHistoryDetail]
	FOR UPDATE AS
BEGIN
	SET NOCOUNT ON

	INSERT INTO CRM.dbo.PRSalesOrderAuditTrail (prsoat_SalesOrderNo, prsoat_SoldToCompany, prsoat_BillToCompany, prsoat_CycleCode, prsoat_ItemCode, 
	                                            prsoat_Quantity, prsoat_LineDiscountPercent, prsoat_ExtensionAmt, 
	                                            prsoat_QuantityChange, prsoat_ExtensionAmtChange,
												prsoat_Pipeline, prsoat_Up_Down, prsoat_SoldBy,
	                                            prsoat_ActionCode, prsoat_UpdatedBy, prsoat_CreatedBy, prsoat_UserLogon,
	                                            prsoat_CancelReasonCode)
	SELECT SO_SalesOrderHeader.SalesOrderNo, CustomerNo, BillToCustomerNo, CycleCode, i.ItemCode,
		   i.QuantityOrderedRevised, i.LineDiscountPercent, i.LastExtensionAmt, 
		   (0-i.QuantityOrderedRevised), (0-i.LastExtensionAmt), 
		   i.UDF_PIPELINE, i.UDF_UP_DOWN, SalespersonNo,
		   'C', SO_SalesOrderHeader.UserUpdatedKey, SO_SalesOrderHeader.UserUpdatedKey, ISNULL(UserLogon, ''),
		   i.CancelReasonCode
	  FROM inserted	i
	     INNER JOIN deleted d ON i.SalesOrderNo = d.SalesOrderNo AND i.SequenceNo = d.SequenceNo
		   INNER JOIN SO_SalesOrderHeader ON i.SalesOrderNo = SO_SalesOrderHeader.SalesOrderNo
		   LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User ON SO_SalesOrderHeader.UserUpdatedKey = UserKey
     WHERE OrderType = 'R'
	   AND CycleCode <> '99'
       AND i.CancelledLine = 'Y'
       AND d.CancelledLine = 'N'
       AND i.SalesAcctKey <> ''
       AND i.LastUnitPrice <> 0;
	END
GO

CREATE OR ALTER TRIGGER [dbo].trg_BBSi_SalesOrderHistoryHeaderAuditTrail
ON [dbo].[SO_SalesOrderHistoryHeader]
FOR UPDATE AS
BEGIN
	SET NOCOUNT ON

	UPDATE CRM.dbo.PRSalesOrderAuditTrail
	   SET prsoat_CancelReasonCode = i_sohh.CancelReasonCode,
	       prsoat_UpdatedBy = i_sohh.UserUpdatedKey,
	       prsoat_CreatedBy =  i_sohh.UserUpdatedKey, 
	       prsoat_UserLogon = ISNULL(UserLogon, ''),
		   prsoat_UpdatedDate = GETDATE()
	  FROM inserted i_sohh
	       INNER JOIN deleted d_sohh ON i_sohh.SalesOrderNo = d_sohh.SalesOrderNo
	       LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User ON i_sohh.UserUpdatedKey = UserKey
     WHERE i_sohh.OrderStatus = 'X'
       AND d_sohh.OrderStatus <> 'X'
       AND prsoat_SalesOrderNo = i_sohh.SalesOrderNo
	   AND prsoat_ActionCode = 'C' 
	   AND prsoat_CancelReasonCode IS NULL;
       
	--
	-- This handles line items there were cancelled.  We need to capture
	-- the correct user info.
	UPDATE CRM.dbo.PRSalesOrderAuditTrail
	   SET prsoat_UpdatedBy = i_sohh.UserUpdatedKey,
	       prsoat_CreatedBy =  i_sohh.UserUpdatedKey, 
	       prsoat_UserLogon = ISNULL(UserLogon, ''),
		   prsoat_UpdatedDate = GETDATE()
	  FROM inserted i_sohh
	       LEFT OUTER JOIN MAS_SYSTEM.dbo.SY_User ON i_sohh.UserUpdatedKey = UserKey
     WHERE i_sohh.OrderStatus <> 'X'
       AND prsoat_ActionCode = 'C'
       AND DATEDIFF(minute, prsoat_CreatedDate, GETDATE()) < 5
       AND prsoat_SalesOrderNo = i_sohh.SalesOrderNo;       
    
	SET NOCOUNT OFF   
END
Go





CREATE OR ALTER PROCEDURE dbo.usp_PRGenerateMasterInvoiceNo 
As
BEGIN
	DECLARE @MyTable table (
		BillToCustomerNo varchar(10),
		MasterInvoiceNo varchar(20)
	)

	INSERT INTO @MyTable 
	SELECT dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo),
	       'M' + CAST(CAST(MAX(InvoiceNo) as Int) as Varchar) As MasterInvoiceNo
	  FROM SO_InvoiceHeader
	 WHERE (UDF_MASTER_INVOICE IS NULL OR UDF_MASTER_INVOICE = '')
	GROUP BY dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo);

	UPDATE SO_InvoiceHeader
	   SET UDF_MASTER_INVOICE = MasterInvoiceNo
	  FROM @MyTable mt
	 WHERE (UDF_MASTER_INVOICE IS NULL OR UDF_MASTER_INVOICE = '')
	   AND mt.BillToCustomerNo = dbo.ufn_GetBillTo(SO_InvoiceHeader.BillToCustomerNo, SO_InvoiceHeader.CustomerNo);  


	--
	--  When we create the master invoices, save off the tax information for 
	--  future reporting.
	--
	INSERT INTO CRM.dbo.PRInvoiceTaxRate (pritr_MasterInvoiceNo, pritr_BillToCompanyID, pritr_TaxCode, pritr_InvoiceNo, pritr_TaxClass, pritr_Group, pritr_ProductLine, pritr_InvoiceAmt, pritr_TaxRate, pritr_TaxAmt, pritr_County, pritr_City, pritr_State)
    SELECT hdr.UDF_MASTER_INVOICE,
	       dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo),
		   mtax.TaxCode,
           hdr.InvoiceNo,
	       det.TaxClass,
	       item.Category2,
	       prod.ProductLineDesc,
	       SUM(ExtensionAmt) as InvoiceAmt,
		   mtax.TaxRate,
		   SUM(ExtensionAmt) * (mtax.TaxRate/100) as TaxAmt,
		   tax.prtax_County,
 		   tax.prtax_City,
		   tax.prtax_State
	  FROM MAS_PRC.dbo.SO_InvoiceDetail det WITH (NOLOCK)
		   INNER JOIN MAS_PRC.dbo.CI_Item Item WITH (NOLOCK) ON item.ItemCode = det.ItemCode
		   INNER JOIN MAS_PRC.dbo.SO_InvoiceHeader hdr WITH (NOLOCK) ON hdr.InvoiceNo = det.InvoiceNo
		   INNER JOIN CRM.dbo.PRTaxRate tax WITH (NOLOCK) ON tax.prtax_TaxCode = hdr.TaxSchedule
		   INNER JOIN MAS_SYSTEM.dbo.SY_SalesTaxCodeDetail mtax WITH (NOLOCK) ON mtax.TaxCode = hdr.TaxSchedule
														AND mtax.TaxClass = det.TaxClass
           INNER JOIN MAS_PRC.dbo.IM_ProductLine prod WITH (NOLOCK) ON prod.ProductLine = item.ProductLine
     WHERE UDF_MASTER_INVOICE IN (SELECT MasterInvoiceNo FROM @MyTable)
  GROUP BY hdr.UDF_MASTER_INVOICE,
	       dbo.ufn_GetBillTo(BillToCustomerNo, CustomerNo),
		   mtax.TaxCode,
           hdr.InvoiceNo,
	       det.TaxClass,
		   item.Category2,
		   prod.ProductLineDesc,
		   mtax.TaxRate,
		   tax.prtax_County,
		   tax.prtax_City,
		   tax.prtax_State;
END
Go   

Use CRM
If NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'MAS_User') BEGIN
	CREATE USER MAS_User FOR LOGIN MAS_User;
	EXEC sp_addrolemember 'db_owner', 'MAS_User'
END
Go


CREATE OR ALTER VIEW dbo.PRSubscriptionForecast AS 
SELECT sod.ItemCode,
	   sod.ItemCodeDesc,
	   CAST(Category1 As Int) as Category1,
	   Category2,
       CASE WHEN cii.Category2 = 'Primary' THEN 'Y' ELSE NULL END As IsPrimary,
       CycleCode,        
       CASE 
			WHEN MONTH(GETDATE()) >= CAST(CycleCode as Int) THEN DATEADD(Year, 1, CONVERT(datetime, CycleCode + '/1/' + CAST(YEAR(GETDATE()) As Varchar(4)),101))
			ELSE CONVERT(datetime, CycleCode + '/1/' + CAST(YEAR(GETDATE()) As Varchar(4)),101)
  		    END As CycleDate,
       COUNT(DISTINCT soh.CustomerNo) As CompanyCount,       
       SUM(ExtensionAmt) As Total
  FROM MAS_PRC.dbo.SO_SalesOrderDetail sod
       INNER JOIN MAS_PRC.dbo.SO_SalesOrderHeader soh ON soh.SalesOrderNo = sod.SalesOrderNo
       INNER JOIN MAS_PRC.dbo.CI_Item cii ON sod.ItemCode = cii.ItemCode
 WHERE soh.OrderType = 'R'  
   AND CycleCode <> '99'
   AND sod.SalesAcctKey <> ''
GROUP BY sod.ItemCode,
	     sod.ItemCodeDesc,
	     Category1,
	     Category2,
         CycleCode, 
         CASE WHEN cii.Category2 = 'Primary' THEN 'Y' ELSE NULL END 
Go


Use CRM

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ufn_GetPrimaryServiceDate]') 
        and xtype in (N'FN', N'IF', N'TF')) 
    drop function [dbo].[ufn_GetPrimaryServiceDate]
GO
CREATE FUNCTION [dbo].[ufn_GetPrimaryServiceDate] ( 
    @HQID int
)
RETURNS datetime
AS
BEGIN
   
    DECLARE @Return datetime

     SELECT @Return = prse_NextAnniversaryDate 
       FROM PRService_Backup 
      WHERE prse_HQID = @HQID 
        AND prse_Primary = 'Y'

    RETURN @Return
END
GO


USE MAS_PRC
Go

CREATE OR ALTER TRIGGER [dbo].[trg_BBSi_SO_InvoiceDetail_insupd]
	ON [dbo].[SO_InvoiceDetail]
	FOR INSERT AS
BEGIN

	SET NOCOUNT ON

	INSERT INTO CRM.dbo.PRInvoiceTaxRate (pritr_CreatedDate, pritr_InvoiceNo, pritr_TaxClass, pritr_Group, pritr_ProductLine, pritr_InvoiceAmt, pritr_TaxRate, pritr_TaxAmt, pritr_County, pritr_City, pritr_State)
    SELECT InvoiceDate,
	       hdr.InvoiceNo,
	       det.TaxClass,
	       item.Category2,
	       prod.ProductLineDesc,
	       SUM(ExtensionAmt) as InvoiceAmt,
		   mtax.TaxRate,
		   SUM(ExtensionAmt) * (mtax.TaxRate/100) as TaxAmt,
		   tax.prtax_County,
 		   tax.prtax_City,
		   tax.prtax_State
	  FROM inserted det WITH (NOLOCK)
		   INNER JOIN MAS_PRC.dbo.CI_Item Item WITH (NOLOCK) ON item.ItemCode = det.ItemCode
		   INNER JOIN MAS_PRC.dbo.SO_InvoiceHeader hdr WITH (NOLOCK) ON hdr.InvoiceNo = det.InvoiceNo
		   INNER JOIN CRM.dbo.PRTaxRate tax WITH (NOLOCK) ON tax.prtax_TaxCode = hdr.TaxSchedule
		   INNER JOIN MAS_SYSTEM.dbo.SY_SalesTaxCodeDetail mtax WITH (NOLOCK) ON mtax.TaxCode = hdr.TaxSchedule
														AND mtax.TaxClass = det.TaxClass
           INNER JOIN MAS_PRC.dbo.IM_ProductLine prod WITH (NOLOCK) ON prod.ProductLine = item.ProductLine
     WHERE hdr.InvoiceType = 'CM'
  GROUP BY InvoiceDate,
           hdr.InvoiceNo,
	       det.TaxClass,
		   item.Category2,
		   prod.ProductLineDesc,
		   mtax.TaxRate,
		   tax.prtax_County,
		   tax.prtax_City,
		   tax.prtax_State;

END 
Go
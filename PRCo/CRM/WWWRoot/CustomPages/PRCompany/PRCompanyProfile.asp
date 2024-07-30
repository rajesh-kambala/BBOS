<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<% 
// helper function to perform the save of region values when the form is submitted
function saveCompanyRegionsByType(sFormFieldName, sCompanyRegionType)
{
    var sValue = getFormValue(sFormFieldName);
    if (sValue != null && sValue != "undefined")
    {
        // there are values to process.
        // Determine the deletes first
        var recExisting = eWare.FindRecord("PRCompanyRegion", 
                "prcd_Type='"+sCompanyRegionType+"' and prcd_CompanyId=" + comp_companyid);
        while (!recExisting.eof)
        {
            var sKey = "," + recExisting("prcd_RegionId") + ",";
            if (sValue.indexOf(sKey) == -1)
            {
                // the value existed orignially but was removed
                sSQL = "DELETE FROM PRCompanyRegion WHERE prcd_CompanyRegionId=" + recExisting("prcd_CompanyRegionId");
                qryUpdate = eWare.CreateQueryObj(sSQL);
                qryUpdate.ExecSQL();
            }
            else
            {
                // remove the existing record from the values list, not from the DB
                sValue = sValue.replace(sKey,',');
            }
            recExisting.NextRecord();    
        }
        //Response.Write("<br>Remaining values for insert:" + sValue);
        // split the remaining items and process them  as inserts
        var arrInserts = sValue.substring(1, sValue.length-1).split(",");
        for (i=0; i < arrInserts.length; i++)
        {
            if (arrInserts[i] != "undefined" && arrInserts[i] != "")
            {
                recNew = eWare.CreateRecord("PRCompanyRegion");
                recNew.prcd_CompanyId = comp_companyid;
                recNew.prcd_Type = sCompanyRegionType;
                recNew.prcd_RegionId = arrInserts[i];
                recNew.SaveChanges();
            }                
        }
    }
}        

function doPage()
{
    var sSecurityGroups = "1,2,3,4,5,6,7,10,11";


	var blkIncludes = eWare.GetBlock('content');
    blkIncludes.contents += "\n<link rel=\"stylesheet\" href=\"../../prco.css\" />\n";
    blkIncludes.contents += "<script type=\"text/javascript\" src=\"../jquery.tablescroll.js\"></script>\n";
    blkIncludes.contents += "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n";
    blkIncludes.contents += "<script type=\"text/javascript\" src=\"PRCompanyProfile.js\"></script>\n\n";
    blkContainer.AddBlock(blkIncludes);



    /********************************************************************************* 
     * It is possible that a PRCompanyProfile record will not exist for this entity.
     * If this is the case just show the empty screen.  Otherwise, show it populated.
     * When the user tries to go into edit mode, we'll determine if a record exists and
     * act accordingly.
     *
     ********************************************************************************/

    // create the list of fields for various sections that could be hidden
    var sSourcingFields= ",prcp_SrcBuyBrokersPct,prcp_SrcBuyWholesalePct,prcp_SrcBuyShippersPct,prcp_SrcBuyExportersPct,prcp_SrcTakePhysicalPossessionPct,prcp_SalvageDistressedProduce,";
    var sBrokeringFields= ",prcp_BkrTakeTitlePct,prcp_BkrTakePossessionPct,prcp_BkrCollectRemitForShipper,prcp_BkrTakeFrieght,prcp_BkrConfirmation,prcp_BkrReceive,prcp_BkrGroundInspections,";
    var sTruckBrokeringFields= ",prcp_TrkBkrCollectsFreightPct,prcp_TrkBkrPaymentFreightPct,prcp_TrkBkrCollectsFrom,prcp_TrkBkrResponsibleForPaymentOfClaims,";
    var sSellingFields= ",prcp_SellBrokersPct,prcp_SellWholesalePct,prcp_SellDomesticBuyersPct,prcp_SellExportersPct,prcp_SellBuyOthersPct,prcp_GrowsOwnProducePct,prcp_SellDomesticAccountTypes,prcp_SellShippingSeason,";

    var sTruckingFields= ",prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,prcp_TrkrProducePct,prcp_TrkrOtherColdPct,"
            + "prcp_TrkrOtherWarmPct,prcp_TrkrTeams,prcp_TrkrTrucksOwned,prcp_TrkrTrucksLeased,prcp_TrkrTrailersOwned,prcp_TrkrTrailersLeased,"
            + "prcp_TrkrPowerUnits,prcp_TrkrReefer,prcp_TrkrDryVan,prcp_TrkrFlatbed,prcp_TrkrPiggyback,prcp_TrkrTanker,prcp_TrkrContainer,prcp_TrkrOther,"
            + "prcp_TrkrLiabilityAmount,prcp_TrkrLiabilityCarrier,prcp_TrkrCargoAmount,prcp_TrkrCargoCarrier,";
    var sTranBrokeringFields= ",prcp_TrnBkrArrangesTransportation,prcp_TrnBkrAdvPaymentsToCarrier,prcp_TrnBkrCollectsFrom,";
    var sTranLogisticsFields= ",prcp_TrnLogAdvPaymentsToCarrier,prcp_TrnLogCollectsFrom,prcp_TrnLogResponsibleForPaymentOfClaims,";
    var sFreightFields= ",prcp_FrtLiableForPaymentToCarrier,";
    var sHiddenFields = "";
    var sDividers = "";
    
    // Create the form
	blkEntry1 = eWare.GetBlock("PRCompanyProfile");
	blkEntry1.Title = "Profile";
	
	blkContainer.AddBlock(blkEntry1);
	blkContainer.CheckLocks = false;

    recCompanyProfile = eWare.FindRecord("PRCompanyProfile", "prcp_CompanyId=" + comp_companyid);
    if (recCompanyProfile.eof)
    {
        recCompanyProfile = eWare.CreateRecord("PRCompanyProfile");
        recCompanyProfile.prcp_CompanyId = comp_companyid;
        Entry = blkEntry1.AddEntry("prcp_CompanyId");
        Entry.DefaultValue = comp_companyid;
        Entry.Hidden = true;
    }

    // if we're saving, save and get out
    if (eWare.Mode == Save) 
    {
        blkContainer.Execute(recCompanyProfile);
        DumpFormValues();
        // we have to save the sourcing fields separately because accpac knows nothing about them
        // check for the sourcing Domestic listing
        saveCompanyRegionsByType("HIDDEN_SDR", "SrcD");
        saveCompanyRegionsByType("HIDDEN_SIR", "SrcI");
        saveCompanyRegionsByType("HIDDEN_LDR", "SellD");
        saveCompanyRegionsByType("HIDDEN_LIR", "SellI");

        saveCompanyRegionsByType("HIDDEN_TDR", "TrkD");
        saveCompanyRegionsByType("HIDDEN_TIR", "TrkI");

	    Response.Redirect(eWare.Url("PRCompany/PRCompanyProfile.asp"));
        return;
    }

    
    // determine which sections of the screen should show
    var bShowSourcing = false;
    var bShowSelling = false;
    var bShowBrokering = false;
    var bShowTruckBrokering = false;
    var bShowTrucking = false;
    var bShowTranLogistics = false;
    var bShowTranBrokering = false;  
    var bShowFreight = false;
    var bShowTrkRegions = false;


    var bShowStorage = false;   // Show if  Industry = Produce
    var bShowCertification = false;  // Show if Industry = Produce or T
    var bShowLumber = false;

    if (recCompany.comp_PRIndustryType == "P") {
        bShowStorage = true;
        bShowCertification = true;
    }
    else if (recCompany.comp_PRIndustryType == "T") {
        bShowCertification = true;
    }

    
    var sSQL = "SELECT distinct highest_level = Left(prcl_Path, charindex(',',prcl_Path)-1) " + 
                "FROM PRCompanyClassification WITH (NOLOCK) " + 
                "INNER JOIN PRClassification WITH (NOLOCK) on prc2_ClassificationId = prcl_ClassificationId " +
                "WHERE prc2_CompanyId = " + comp_companyid
    var query = eWare.CreateQueryObj(sSQL);
    query.SelectSQL();
    while (!query.eof)
    {
        sLevel = query("highest_level");
        if (sLevel == 1) bShowSourcing = true;
        else if (sLevel == 2) bShowSelling = true;
        query.NextRecord();
    }
    var sSQL = "SELECT 1 FROM PRCompanyClassification WITH (NOLOCK) " + 
                "WHERE prc2_ClassificationId = 610 and prc2_CompanyId = " + comp_companyid
    var query = eWare.CreateQueryObj(sSQL);
    query.SelectSQL();
    if (query.RecordCount >= 1)
        bShowTrucking = true;
    
    // show the selling panel if "Distributor" is chosen
    if (bShowSelling == false){
        sSQL = "SELECT 1 FROM PRCompanyClassification WITH (NOLOCK) " + 
                    "WHERE prc2_ClassificationId = 180 and prc2_CompanyId = " + comp_companyid
        query = eWare.CreateQueryObj(sSQL);
        query.SelectSQL();
        if (query.RecordCount >= 1)
            bShowSelling = true;
    }


    // show the Transaction Broker panel if "Transportation Broker" is chosen
    sSQL = "SELECT 1 FROM PRCompanyClassification WITH (NOLOCK) " + 
                "WHERE prc2_ClassificationId IN (570, 580, 590, 520, 500, 530, 540, 550, 560) and prc2_CompanyId = " + comp_companyid
    query = eWare.CreateQueryObj(sSQL);
    query.SelectSQL();
    if (query.RecordCount >= 1) {
        bShowTranBrokering = true;
    }


    if (recCompany.comp_PRIndustryType == "T") {
        bShowTrkRegions = true;
    }

    if (recCompany.comp_PRIndustryType == "L") {
        sHiddenFields += ",prcp_MigratedProfileDescription,prcp_SellShippingSeason,prcp_Organic,prcp_FoodSafetyCertified,";
        sHiddenFields += ",prcp_SrcBuyBrokersPct,prcp_SrcBuyShippersPct,prcp_SrcBuyWholesalePct,prcp_SalvageDistressedProduce,";
        bShowSourcing = true;
        
        sHiddenFields += ",prcp_GrowsOwnProducePct,prcp_SellBuyOthersPct,prcp_SellBrokersPct,prcp_SellWholesalePct,prcp_SellShippingSeason,prcp_SellBuyOthers,prcp_SellDomesticBuyersPct,prcp_SellWholesalePct,";
        bShowSelling = true;
        
        sHiddenFields += ",prcp_StorageWarehouses,prcp_ColdStorage,prcp_StorageSF,prcp_RipeningStorage,prcp_StorageCF,prcp_HumidityStorage,prcp_StorageBushel,prcp_AtmosphereStorage,prcp_StorageCarlots,prcp_ColdStorageLeased,";
        
        fldType = blkEntry1.GetEntry("prcp_SellDomesticAccountTypes");
        fldType.LookupFamily = "prcp_SellDomesticAccountTypesL";
        
        fldType = blkEntry1.GetEntry("prcp_Volume");
        fldType.LookupFamily = "prcp_VolumeL";        
    } else {
        sHiddenFields += ",prcp_RailServiceProvider1,prcp_RailServiceProvider2,";
        sHiddenFields += ",prcp_SrcBuyStockingWholesalePct,prcp_SrcBuyOfficeWholesalePct,prcp_SrcBuyMillsPct,prcp_SrcBuyOtherPct,prcp_SrcBuySecManPct,";
        sHiddenFields += ",prcp_SellCoOpPct,prcp_SellStockingWholesalePct,prcp_SellRetailYardPct,prcp_SellOtherPct,prcp_SellHomeCenterPct,prcp_SellOfficeWholesalePct,prcp_SellProDealerPct,prcp_SellSecManPct,";
        sHiddenFields += ",prcp_StorageCoveredSF,prcp_StorageUncoveredSF,";
    }   

    if (!bShowStorage) {
        sHiddenFields += ",prcp_StorageWarehouses,prcp_StorageOwnLease,prcp_StorageSF,";
    }

    if (!bShowCertification) {
        sHiddenFields += ",prcp_Organic,prcp_FoodSafetyCertified,";
    }

    

    if (!bShowSourcing)
        sHiddenFields += sSourcingFields;
    else
    {
        if (recCompany.comp_PRIndustryType ==  "L") {
            sDividers += "\n\t\tInsertDivider('Sourcing', '_Captprcp_srcbuystockingwholesalepct');";
        } else {
            sDividers += "\n\t\tInsertDivider('Sourcing', '_Captprcp_srcbuybrokerspct');";
        }            
    }    
        
    if (!bShowSelling)
        sHiddenFields += sSellingFields;
    else {
        if (recCompany.comp_PRIndustryType ==  "L") {
            sDividers += "\n\t\tInsertDivider('Selling', '_Captprcp_sellcooppct');";
        } else {
            sDividers += "\n\t\tInsertDivider('Selling', '_Captprcp_sellbrokerspct');";
        }            
    }            

    if (!bShowBrokering)
        sHiddenFields += sBrokeringFields;
    else
        sDividers += "\n\t\tInsertDivider('Brokering', '_Captprcp_bkrtaketitlepct');";

    if (!bShowTruckBrokering)
        sHiddenFields += sTruckBrokeringFields;
    else
        sDividers += "\n\t\tInsertDivider('Truck Brokering', '_Captprcp_trkbkrcollectsfreightpct');";

    if (!bShowTrucking)
        sHiddenFields += sTruckingFields;
    else
    {
        // We are hiding this section
        //sDividers += "\n\t\tInsertDivider('Trucking - Arranging Hauls', '_Captprcp_trkrdirecthaulspct');";
        sHiddenFields += ",prcp_TrkrDirectHaulsPct,prcp_TrkrTPHaulsPct,";

        sDividers += "\n\t\tInsertDivider('Trucking - Types of Hauls', '_Captprcp_trkrproducepct');";
        sDividers += "\n\t\tInsertDivider('Trucking - Equipment', '_Captprcp_trkrtrucksowned');";

        // We are hiding this section
        //sDividers += "\n\t\tInsertDivider('Trucking - Insurance Info', '_Captprcp_trkrliabilityamount');";
        sHiddenFields += ",prcp_TrkrLiabilityAmount,prcp_TrkrLiabilityCarrier,prcp_TrkrCargoAmount,prcp_TrkrCargoCarrier,";


    }
    if (!bShowTranBrokering)
        sHiddenFields += sTranBrokeringFields;
    else
        sDividers += "\n\t\tInsertDivider('Truck/Transportation Broker', '_Captprcp_trnbkrarrangestransportation');";

    if (!bShowTranLogistics)
        sHiddenFields += sTranLogisticsFields;
    else
        sDividers += "\n\t\tInsertDivider('Transportation Logistics', '_Captprcp_trnlogcollectsFrom');";

    if (!bShowFreight)
        sHiddenFields += sFreightFields;
    else {
        if (eWare.Mode == Edit)
            sDividers += "\n\t\tInsertDivider('Freight Contractor', 'prcp_frtliableforpaymenttocarrier');";
        else
            sDividers += "\n\t\tInsertDivider('Freight Contractor', '_Captprcp_frtliableforpaymenttocarrier');";
    }

    
    //Response.Write(sHiddenFields);
    removeFieldsInBlock(blkEntry1, sHiddenFields);
    
    if (recCompany.comp_PRIndustryType == "L") {
        // These fields have captions that differ from produce
        var f = blkEntry1.GetEntry("prcp_SrcBuyExportersPct");
        f.Caption = "% Purchased from International Exporters:";
        
        var f = blkEntry1.GetEntry("prcp_SellExportersPct");
        f.Caption = "% Sold to International Importers:";
    }
    
    // include the appropriate sourcing displays
%>    
    <!-- #include file="PRCompanyProfileSourcing.asp" -->
<%
    // based upon the mode determine the buttons and actions
    var sAssignedClassifications = "";
    
    if (eWare.Mode == Edit)
    {
		var nbr_script = "if (this.value != null) { this.value = this.value.replace(/[^0-9\.]/g, ''); }";
		for (var fld_entry in { "prcp_TrkrLiabilityAmount":0, "prcp_TrkrCargoAmount":0 } ) {
			var fld = blkEntry1.GetEntry(fld_entry);
			if (fld != null) {
				fld.OnChangeScript = nbr_script;
			}
		}
		
        sCancelAction = eWare.Url("PRCompany/PRCompanyProfile.asp");
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
        // CompanyTrxInclude.asp should never allow us to be in edit or save without a trx;
        // therefore this check isn't required but it's a nice safety net.
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
    	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"if (validate()) save();\""));
        }
        //set javascript variables for Truck Brokering and Freight Contractor classifications
        var sSQL = "SELECT 1 " + 
                "FROM PRCompanyClassification WITH (NOLOCK) " + 
                "WHERE prc2_ClassificationId = 590 and prc2_CompanyId = " + comp_companyid
        var query = eWare.CreateQueryObj(sSQL);
        query.SelectSQL();
        if (query.RecordCount >= 1)
            sAssignedClassifications += "bTruckBrokerAssigned=true;\n";

        var sSQL = "SELECT 1 " + 
                "FROM PRCompanyClassification WITH (NOLOCK) " + 
                "WHERE prc2_ClassificationId = 510 and prc2_CompanyId = " + comp_companyid
        var query = eWare.CreateQueryObj(sSQL);
        query.SelectSQL();
        if (query.RecordCount >= 1)
            sAssignedClassifications += "bFreightContractorAssigned=true;\n";
            
    }
    
      else 
    {

        if (recCompany.comp_PRLocalSource !=  "Y") {  
            if (iTrxStatus == TRX_STATUS_EDIT)
            {
                if (isUserInGroup(sSecurityGroups))
    	            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));
            }
        }

        tabContext = "&T=Company&Capt=Profile";


		var btnDL = eWare.Button("View&nbsp;D/L","list.gif", eWare.URL("PRCompany/PRCompanyDLView.asp") + tabContext);
		blkContainer.AddButton(btnDL);

            
        if (recCompany.comp_PRIndustryType ==  "P") {
		    var btnCommodities = eWare.Button("Commodities","list.gif", eWare.URL("PRCompany/PRCompanyCommodityListing.asp") + tabContext);
    		blkContainer.AddButton(btnCommodities);
	    }	
		
		
		var btnClassification = eWare.Button("Classifications","list.gif", eWare.URL("PRCompany/PRCompanyClassificationListing.asp") + tabContext);
		blkContainer.AddButton(btnClassification);

        if (recCompany.comp_PRIndustryType ==  "L") {
    		blkContainer.AddButton(eWare.Button("Products Provided","list.gif", eWare.URL("PRCompany/PRProductListing.asp") + tabContext));
	    	blkContainer.AddButton(eWare.Button("Services Provided","list.gif", eWare.URL("PRCompany/PRServiceListing.asp") + tabContext));
		    blkContainer.AddButton(eWare.Button("Species","list.gif", eWare.URL("PRCompany/PRSpecieListing.asp") + tabContext));
        }
        
        if (recCompany.comp_PRIndustryType !=  "L") {
    		var btnLicenses = eWare.Button("Licenses","list.gif", eWare.URL("PRCompany/PRCompanyLicenseListing.asp") + tabContext);
	    	blkContainer.AddButton(btnLicenses);
        }
    
        if (recCompany.comp_PRLocalSource !=  "Y") {        
		    var btnLinkBank = eWare.Button("Banks","list.gif", eWare.URL("PRCompany/PRCompanyBankListing.asp") + tabContext);
		    blkContainer.AddButton(btnLinkBank);


		    var btnLinkExchange = eWare.Button("Exchanges","list.gif", eWare.URL("PRCompany/PRCompanyStockExchangeListing.asp") + tabContext);
		    blkContainer.AddButton(btnLinkExchange);

		    var btnTradeAssociations = eWare.Button("Trade Association Memberships","list.gif", eWare.URL("PRCompany/PRCompanyTradeAssociationListing.asp") + tabContext);
		    blkContainer.AddButton(btnTradeAssociations);

		    //var btnTradeShows = eWare.Button("Trade Shows","list.gif", eWare.URL("PRCompany/PRCompanyTradeShowListing.asp") + tabContext);
		    //blkContainer.AddButton(btnTradeShows);
        }

        if (recCompany.comp_PRIndustryType ==  "P") {
        	var btnLocalSource = eWare.Button("Local Source Data","list.gif", eWare.URL("PRCompany/PRCompanyLocalSource.asp") + tabContext);
	        blkContainer.AddButton(btnLocalSource);
        }

        var btnLocalSource = eWare.Button("Local Source Data","list.gif", eWare.URL("PRCompany/PRCompanyLocalSource.asp") + tabContext);
	    blkContainer.AddButton(btnLocalSource);

        blkContainer.AddButton(eWare.Button("Background Checks","list.gif", eWare.URL("TravantCRM.dll-RunBackgroundCheckListing")));
        blkContainer.AddButton(eWare.Button("Business Valuations","list.gif", eWare.URL("TravantCRM.dll-RunBusinessValuationRequestListing")));
    }


    eWare.AddContent(blkContainer.Execute(recCompanyProfile));
	Response.Write(eWare.GetPage('Company'));

    var sKeypressValidation = "";
    var sSetCompanyID = "";
    if (eWare.Mode == Edit) {
        sKeypressValidation = "setKeypressValidation();\n";        
        //sSetCompanyID = "document.getElementById('prcp_companyid').value='" + comp_companyid + "';"
    }
%>
<script type="text/javascript">
    function initBBSI() 
    {
        initializeScreen();
        InsertDivider("Business Size", "_Captprcp_ftemployees"); 

<%
        if (sDividers != "")
            Response.Write(sDividers );
%>

<%  if (recCompany.comp_PRIndustryType ==  "L") {  %>
        InsertDivider("Storage", "_Captprcp_storagecoveredsf");
<% } else { %>
    <%  if (recCompany.comp_PRIndustryType ==  "P") {  %>
        InsertDivider("Storage", "_Captprcp_storagewarehouses");
    <% } %>
<% } %>
        

<%  if (recCompany.comp_PRIndustryType !=  "L") {  %>
    <%  if (recCompany.comp_PRIndustryType ==  "P" || recCompany.comp_PRIndustryType ==  "T") {  %>
        InsertDivider("Certification", "_Captprcp_organic");
    <% } %>
<% } %>

        <%= sSourcingFormLoadCommands %>
        <%= sSellingFormLoadCommands %>
        <%= sTrkFormLoadCommands %>
        
        <%= sAssignedClassifications %>
        <%= sKeypressValidation %>
        <%= sSetCompanyID %>

<%  if (bShowTrkRegions) {  %>
        
<% } %>

    }
    if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
</script>
<%
}
doPage();
%>
<!-- #include file="CompanyFooters.asp" -->

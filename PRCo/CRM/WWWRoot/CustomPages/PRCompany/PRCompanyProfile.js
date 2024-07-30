var bTruckBrokerAssigned = false;
var bFreightContractorAssigned = false;

function getIntegerValue(sField)
{
    if (sField == null)
        return 0;
    var sValue = parseInt(sField.value);
    if (isNaN(sValue))
        return 0;
    
    return sValue;    
}

function validate()
{
    var validationErrors = "";
    var validateField = null;
    if (document.EntryForm.prcp_srcbuybrokerspct != null)
    {
        
        var totalSourcing = getIntegerValue(document.EntryForm.prcp_srcbuybrokerspct) + 
                            getIntegerValue(document.EntryForm.prcp_srcbuywholesalepct) + 
                            getIntegerValue(document.EntryForm.prcp_srcbuyshipperspct) + 
                            getIntegerValue(document.EntryForm.prcp_srcbuyexporterspct);
        if (totalSourcing > 100)
        {
            validationErrors += "Total for Sourcing percentages cannot exceed 100%.";
            validateField = document.EntryForm.prcp_srcbuybrokerspct;
        }
    }

    if (document.EntryForm.prcp_sellbrokerspct != null)
    {
        var totalSelling = getIntegerValue(document.EntryForm.prcp_sellbrokerspct) + 
                            getIntegerValue(document.EntryForm.prcp_sellwholesalepct) + 
                            getIntegerValue(document.EntryForm.prcp_selldomesticbuyerspct) + 
                            getIntegerValue(document.EntryForm.prcp_sellexporterspct);
        if (totalSelling > 100)
        {
            validationErrors += "\nTotal for Selling percentages cannot exceed 100%.";
            if (validateField == null) 
                validateField = document.EntryForm.prcp_sellbrokerspct;
        }
    }

    if (document.EntryForm.prcp_trkrdirecthaulspct != null)
    {
        var totalTruckingArrange = getIntegerValue(document.EntryForm.prcp_trkrdirecthaulspct) + 
                            getIntegerValue(document.EntryForm.prcp_trkrtphaulspct);
        if (totalTruckingArrange > 100)
        {
            validationErrors += "Total for Trucking - Arranging Hauls percentages cannot exceed 100%.";
            if (validateField == null) 
                validateField = document.EntryForm.prcp_trkrdirecthaulspct;
        }

        var totalTruckingTypes = getIntegerValue(document.EntryForm.prcp_trkrproducepct) + 
                            getIntegerValue(document.EntryForm.prcp_trkrothercoldpct) + 
                            getIntegerValue(document.EntryForm.prcp_trkrotherwarmpct);
        if (totalTruckingTypes > 100)
        {
            validationErrors += "Total for Trucking - Types of Hauls percentages cannot exceed 100%.";
            if (validateField == null) 
                validateField = document.EntryForm.prcp_trkrproducepct;
        }
    }
    
    if (document.EntryForm.prcp_trkbkrcollectsfreightpct != null)
	{

        var prcp_trkbkrcollectsfreightpct = getIntegerValue(document.EntryForm.prcp_trkbkrcollectsfreightpct);
        var prcp_trkbkrpaymentfreightpct = getIntegerValue(document.EntryForm.prcp_trkbkrpaymentfreightpct);
        if (prcp_trkbkrcollectsfreightpct > 100)
        {
            validationErrors += "Broker Collects/Remits Freight Charge % cannot exceed 100%.\n";
            if (validateField == null) 
                validateField = document.EntryForm.prcp_trkbkrcollectsfreightpct;
        }

        if (prcp_trkbkrpaymentfreightpct > 100)
        {
            validationErrors += "Broker Resp. for Payment of Freight % cannot exceed 100%.\n";
            if (validateField == null) 
                validateField = document.EntryForm.prcp_trkbkrpaymentfreightpct;
        }

        if (validationErrors == "") {
            sAlertMessage = "";
            if (!bTruckBrokerAssigned && prcp_trkbkrcollectsfreightpct > 0)
            {
                sAlertMessage += "Truck broker classification should be added since broker collects/remits freight charge % is greater than 0.\n";
            }
            
            if (!bFreightContractorAssigned && prcp_trkbkrpaymentfreightpct > 0)
            {
                sAlertMessage += "Freight contractor classification should be added since broker resp. for payment of freight % is greater than 0.\n";
            }
            if (sAlertMessage != "") {
                alert(sAlertMessage);
            }   
         }
        
	    //document.all.prcp_trnpaymentfreightpct.onkeypress = function(){keypressValidationHandler(keypressNumeric);};
    }

    if (validationErrors != "") {
        alert(validationErrors);
        if (validateField != null)
            validateField.focus();
        return false;
    }

    return true;    
}

function save()
{
    document.EntryForm.submit();
}

function setKeypressValidation()
{
	if (document.EntryForm.prcp_srcbuybrokerspct != null)
	{
	    document.getElementById("prcp_srcbuybrokerspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuywholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyshipperspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyexporterspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	}

	if (document.EntryForm.prcp_srcbuystockingwholesalepct != null) {
	    document.getElementById("prcp_srcbuystockingwholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyofficewholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuymillspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuysecmanpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyexporterspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyexporterspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srctakephysicalpossessionpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_srcbuyotherpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	}

	if (document.EntryForm.prcp_sellcooppct != null) {
	    document.getElementById("prcp_sellcooppct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellstockingwholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellofficewholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellprodealerpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellretailyardpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellhomecenterpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellsecmanpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellotherpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellexporterspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	}
	
    
	if (document.EntryForm.prcp_sellbrokerspct != null)
	{
	    document.getElementById("prcp_sellbrokerspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellwholesalepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_selldomesticbuyerspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_sellexporterspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
    }

	if (document.EntryForm.prcp_bkrtaketitlepct != null)
	{
	    document.getElementById(".prcp_bkrtaketitlepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_bkrtakepossessionpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
    }
    
    if (document.EntryForm.prcp_trkbkrcollectsfreightpct != null)
	{
        document.getElementById("prcp_trkbkrcollectsfreightpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
        document.getElementById("prcp_trkbkrpaymentfreightpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
    }
    
	if (document.EntryForm.prcp_trkrdirecthaulspct != null)
	{
	    document.getElementById("prcp_trkrdirecthaulspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_trkrtphaulspct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};

	    document.getElementById("prcp_trkrproducepct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_trkrothercoldpct").onkeypress = function(){keypressValidationHandler(keypressNumeric);};
	    document.getElementById("prcp_trkrotherwarmpct").onkeypress = function () { keypressValidationHandler(keypressNumeric); };
    }
}

// on click handler for the Selling International Regions Checkbox
function onRegionSelectClick()
{
    var chk = window.event.srcElement;
    var curRow = chk.parentElement;
    //while ((curRow.sourceIndex > 0) && (curRow.tagName != "TR"))
    while ((curRow != null) && (curRow.tagName != "TR"))
    {
        curRow = curRow.parentElement;
    }
    if (curRow == null)
        return;
    
    processRegionChange(chk);    
    processRegionChildren(curRow, chk.checked);
    
}
function processRegionChildren(curRow, bDisable)
{
    var iCurRowLevel = curRow.getAttribute("Level");
    // if this is level 4, exit.  there will be no children
    if (iCurRowLevel == 4)
        return;

    // start down the rows until you hit a level <= curLevel
    var bExit = false;
    var testRow = curRow.nextSibling;
    while (testRow != null && !bExit)
    {
        //var RegionId = testRow.getAttribute("RegionId");
        var iTestRowLevel = testRow.getAttribute("Level");
        if (iTestRowLevel <= iCurRowLevel)
            return;
        else 
        {
            var arrChk = testRow.getElementsByTagName("INPUT");
            if (arrChk.length == 0)
                return;
            arrChk[0].disabled = bDisable;
            if (bDisable && (arrChk[0].checked == true) )
            {
                arrChk[0].checked = false;
                processRegionChange(arrChk[0]);
            }    
        }
        testRow = testRow.nextSibling;
    }    
}
function processRegionChange(chk)
{
    var sChkName = new String(chk.id);
    var ndx = sChkName.indexOf("Select_");
    if (ndx == -1)
        return;
    var sIdValue = sChkName.substring(ndx + "Select_".length);    
    // get our hidden field for value submission
    var sHidden = "HIDDEN" + sChkName.substring(0, ndx);
    var hidden = document.getElementById(sHidden);
    var sHiddenValue = "" + hidden.value;
    if (chk.checked == true)
    {
        if (sHiddenValue == "")
            sHiddenValue = ",";
        sHiddenValue += sIdValue + ",";
    }
    else
    {
        var sSearchValue = "," + sIdValue + ",";
        regexp = new RegExp(sSearchValue, 'gi');
        sHiddenValue = sHiddenValue.replace(regexp, ",");
    }
    hidden.value = sHiddenValue;
        
}
function initializeScreen()
{
    removeBRInTD("_Captprcp_CorporateStructure");
    removeBRInTD("_Captprcp_SrcBuyBrokersPct");
    removeBRInTD("_Captprcp_SrcBuyWholesalePct");
    removeBRInTD("_Captprcp_SrcBuyShippersPct");
    removeBRInTD("_Captprcp_SrcBuyExportersPct");
    removeBRInTD("_Captprcp_SrcTakePhysicalPossessionPct");

    removeBRInTD("_Captprcp_SellBrokersPct");
    removeBRInTD("_Captprcp_SellWholesalePct");
    removeBRInTD("_Captprcp_SellDomesticBuyersPct");
    removeBRInTD("_Captprcp_SellExportersPct");
    removeBRInTD("_Captprcp_SellShippingSeason");

    removeBRInTD("_Captprcp_SellBuyOthersPct");
    removeBRInTD("_Captprcp_GrowsOwnProducePct");

    removeBRInTD("_Captprcp_StorageWarehouses");
    removeBRInTD("_Captprcp_StorageSF");
    removeBRInTD("_Captprcp_StorageOwnLease");

    
    //removeBRInTD("_Captprcp_StorageCF");
    //removeBRInTD("_Captprcp_StorageBushel");
    //removeBRInTD("_Captprcp_StorageCarlots");

    //removeBRInTD("_Captprcp_ColdStorage");
    //removeBRInTD("_Captprcp_RipeningStorage");
    //removeBRInTD("_Captprcp_HumidityStorage");
    //removeBRInTD("_Captprcp_AtmosphereStorage");
    //removeBRInTD("_Captprcp_ColdStorageLeased");

    removeBRInTD("_Captprcp_HAACPCertifiedBy");
    removeBRInTD("_Captprcp_QTVCertifiedBy");
    removeBRInTD("_Captprcp_OrganicCertifiedBy");
    removeBRInTD("_Captprcp_OtherCertification");

    removeBRInTD("_Captprcp_TrnBkrArrangesTransportation");
    removeBRInTD("_Captprcp_TrnBkrCollectsFrom");

    removeBRInTD("_Captprcp_TrnLogCollectsFrom");

    removeBRInTD("_Captprcp_SellCoOpPct");
    removeBRInTD("_Captprcp_SellDistributorsPct");
    removeBRInTD("_Captprcp_SellRetailYardPct");
    removeBRInTD("_Captprcp_SellOtherPct");
    removeBRInTD("_Captprcp_SellHomeCenterPct");
    removeBRInTD("_Captprcp_SellSecManPct");
    
    removeBRInTD("_Captprcp_SrcBuyOfficeWholesalePct");
    removeBRInTD("_Captprcp_SrcBuyStockingWholesalePct");
    removeBRInTD("_Captprcp_SellOfficeWholesalePct");
    removeBRInTD("_Captprcp_SellStockingWholesalePct");
    removeBRInTD("_Captprcp_SellProDealerPct");
    
    removeBRInTD("_Captprcp_SrcBuyMillsPct");
    removeBRInTD("_Captprcp_SrcBuyOtherPct");
    removeBRInTD("_Captprcp_SrcBuySecManPct");

    removeBRInTD("_Captprcp_StorageCoveredSF");
    removeBRInTD("_Captprcp_StorageUncoveredSF");
    
    
}


/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

var txtSelectedNumerals = null;
var spnAssignedRatingNumerals = null;
var bIsBranch = null;
var bBranchWith80 = null;

var bAlwaysDisable_CreditWorth = true;
var bAlwaysDisable_Integrity = true;
var bAlwaysDisable_Pay = true;


function validateRatingRules() {

    // This validation rule was moved to the beginning of the function
    // to acocmodate Lumber companies.
    txtPublishedAnalysis = document.getElementById("prra_publishedanalysis");
    sPublishedAnalysis = txtPublishedAnalysis.value;

    // get the rating numerals
    if (txtSelectedNumerals == null) {
        txtSelectedNumerals = document.getElementById("_txt_SelectedNumerals");
    }
    sRatingNumerals = txtSelectedNumerals.value;


    if (sPublishedAnalysis == "") {
        if (
            (sRatingNumerals.indexOf("(27)") > -1) ||
            (sRatingNumerals.indexOf("(49)") > -1) ||
            (sRatingNumerals.indexOf("(74)") > -1) ||
            (sRatingNumerals.indexOf("(76)") > -1) ||
            (sRatingNumerals.indexOf("(78)") > -1) ||
            (sRatingNumerals.indexOf("(83)") > -1) ||
            (sRatingNumerals.indexOf("(85)") > -1) ||
            (sRatingNumerals.indexOf("(86)") > -1) ||
            (sRatingNumerals.indexOf("(124)") > -1) ||
            (sRatingNumerals.indexOf("(131)") > -1) ||
            (sRatingNumerals.indexOf("(132)") > -1) ||
            (sRatingNumerals.indexOf("(133)") > -1)
           ) {
            alert("Published Analysis comments are required based upon the selected Rating Numeral.");
            txtPublishedAnalysis.focus();
            return false;
        }
    }

    if (comp_PRIndustryType == "L") {
        return true;
    }

	if ( bIsBranch == null)
	{
	    inpHQCWRId = document.getElementById("hq_prra_creditworthid");
	    bIsBranch = (inpHQCWRId != null)
    }

	// run through any validation rules that would prevent a save
    sLowPayOnBranch = "N";
    inpLowPayRating = document.getElementById("branch_lowpayrating");
    if (inpLowPayRating != null)
        sLowPayOnBranch = inpLowPayRating.value;

    sAllow150 = "N";
    inpAllow150 = document.getElementById("allow150");
    if (inpAllow150 != null)
        sAllow150 = inpAllow150.value;
        
    // check the values of the combo boxes    
    cboCWR = document.getElementById("prra_creditworthid");
	cboInt = document.getElementById("prra_integrityid");
	cboPay = document.getElementById("prra_payratingid");
	sInt = cboInt.options[cboInt.selectedIndex].innerText;
	sCWR = cboCWR.options[cboCWR.selectedIndex].innerText;
	sPay = cboPay.options[cboPay.selectedIndex].innerText;

    sAtTheHQ  ="";
	// get the HQ controls (these won't exist if this is the HQ)
    inpHQCWRId = document.getElementById("hq_prra_creditworthid");
	if (inpHQCWRId != null)
	{
	    sAtTheHQ = " at the headquarter location";
	    sHQCWRId = inpHQCWRId.value;
	    inpHQIntId = document.getElementById("hq_prra_integrityid");
	    sHQIntId = inpHQIntId.value;
	    inpHQPayId = document.getElementById("hq_prra_payratingid");
	    sHQPayId = inpHQPayId.value;

	    inpHQCWR = document.getElementById("hq_prcw_name");
	    sHQCWR = inpHQCWR.value;
	    inpHQInt = document.getElementById("hq_prin_name");
	    sHQInt = inpHQInt.value;
	    inpHQPay = document.getElementById("hq_prpy_name");
	    sHQPay = inpHQPay.value;
            
	    inpHQAssignedRatingNumerals = document.getElementById("hq_prra_assignedratingnumerals");
        sHQAssignedRatingNumerals = inpHQAssignedRatingNumerals.value;
    }
    else
    {
        // our HQ values are the same as the dropdown values
	    sHQCWRId = cboCWR.options[cboCWR.selectedIndex].value;
	    sHQIntId = cboInt.options[cboInt.selectedIndex].value;
	    sHQPayId = cboPay.options[cboPay.selectedIndex].value;

	    sHQCWR = sCWR;
	    sHQInt = sInt;
	    sHQPay = sPay;
    }



	// set the 5M index as it is used several times
	ndx5M = 0;
	b5MFound = false;
	while (!b5MFound && ndx5M < cboCWR.options.length )
	{
	    if (!b5MFound && cboCWR.options[ndx5M].innerText == "5M")
	        b5MFound = true;
	    else    
	        ndx5M = ndx5M +1;
    }
    if (!b5MFound)
        ndx5M = -1;
/**** THIS IS THE START OF THE ACTUAL RULE DETERMINATIONS  *******/

	// CWR must be accompanied by an Integrity or a Rating Numeral of 60
	// this will only apply to HQs because Branches cannot select CWR
	if (sCWR != "" ) 
	{
	    if (sInt == "")
	    {
	        if (sRatingNumerals.indexOf("(60)") != -1)
	        {
	            alert("Every Credit Worth Estimate must be accompanied by a Trade Practices rating or a Rating Numeral of (60)."); 
	            return false;
            }
        }
    }        

	if (sCWR == "(62)" ) 
	{
	    if (",XXXX,XXX,".indexOf(","+sHQInt+",") == -1)
	    {
	        alert("Credit Worth Estimate of (62) must be accompanied by a Trade Practices Rating of XXXX or XXX" + sAtTheHQ + ".");
	        return false;
	    }
	    if (sLowPayOnBranch == "Y")
	    {
	        alert("Credit Worth Estimate of (62) cannot be reported if any branch location " +
	                    "reports a Trade Practices Rating of X, XX, XX147, or XXX148.");
	        return false;
	    }
	}

	if ( (sCWR == "(68)") &&
	     (",AA,A,AB,B,C,".indexOf(","+sHQPay+",") > -1) )
	{
	    alert("Credit Worth Estimate of (68) cannot be accompanied by a Pay Description of AA, A, AB, B, or C" + sAtTheHQ + ".");
	    return false;
	}
	     
	if ( (sCWR == "(150)") &&
	     (sAllow150 == "N" ))
	{
	    alert("Credit Worth Estimate of (150) cannot be reported unless the parent company has a Credit Worth Rating " + 
	            "and applies only to those firms listed as a subsidiary or wholly owned subsidiary.");
	    return false;
	}

	if (sInt == "XXXX")
	{
	    if (sHQCWR != "(62)" && sHQCWR != "(150)") 
	    {
	        // we failed the first test; if this is a 5M+ company, it's still ok
	        if (cboCWR.selectedIndex < ndx5M)
	        {
	            alert("Trade Practices rating 'XXXX' must be accompanied by Credit Worth Estimate of (62), (150), within the range of 5M to 50000M" + sAtTheHQ + ".");
	            return false;
	        }
	    }
	    if  (("C,D,E,F,(81)".indexOf(sPay) > -1) ||
	         ("C,D,E,F,(81)".indexOf(sHQPay) > -1))
	    {
	        alert("Trade Practices rating 'XXXX' cannot be accompanied by a Pay Description of C,D,E,F, or (81).");
	        return false;
	    }
	    

	    bInvalid = false;
	    if (bIsBranch)
	    {
	        if (sHQAssignedRatingNumerals.indexOf("(146)") > -1 ||
	            sHQAssignedRatingNumerals.indexOf("(149)") > -1 ||
	            (sRatingNumerals.indexOf("(146)") > -1 ) ||
	            (sRatingNumerals.indexOf("(149)") > -1 ) )
	        {
	            bInvalid = true;
	        }
	    }
	    else
	    {
	        if ((sRatingNumerals.indexOf("(146)") > -1 ) ||
	            (sRatingNumerals.indexOf("(149)") > -1 ))
	        {
	            bInvalid = true;
	        }
	        
	    }
        if (bInvalid)
	    {
	        alert("Trade Practices rating 'XXXX' cannot be accompanied by a Rating Numeral of (146) or (149).");
	        return false;
	    }
        	        
	    
    }
    	     
	if ( (",AA,A,AB,".indexOf(","+sPay+",") > -1) &&
	     (sHQCWR != "(150)") &&
	     (cboCWR.selectedIndex < ndx5M) )
	{
	    alert("Pay rating of AA, A, or AB must be accompanied by a Credit Worth Estimate of (150) or within the range 5M to 50000M" + sAtTheHQ + ".");
	    return false;
	}

    // chk60 should be on HQs only
    if (sRatingNumerals.indexOf("(60)") > -1)
    {
	    if ((cboCWR.selectedIndex == 0) &&
	        ((sRatingNumerals.indexOf("(146)") == -1 ) && (sRatingNumerals.indexOf("(83)") == -1 ) && (sRatingNumerals.indexOf("(63)") == -1)) )
	    {
	        alert("Rating Numeral (60) must be accompanied by a Credit Worth Estimate or a Rating Numeral of (63), (83) or (146)" + sAtTheHQ + ".");
	        return false;
	    }
    }
    
    // Rating numeral 85 can only appear with an empty or (78) CWR
    if (sRatingNumerals.indexOf("(85)") > -1 )
    {
	    if ((cboCWR.selectedIndex != 0) && (sCWR != "(78)")&& (sCWR != "(79)") )
	    {
	        alert("Rating Numeral (85) must be accompanied by a Credit Worth Estimate of '--None--', (78), or (79)" + sAtTheHQ + ".");
	        return false;
	    }
    }

    
    // go through the list of RN checkboxes; if two more than two affiliate types are checked,
    // prevent the save
    tblNumerals = document.getElementById("_NumeralsListing");
    var arrNumeralCheckboxes = tblNumerals.getElementsByTagName("INPUT");
    iCount = 0;
    for (ndx=0; ndx<arrNumeralCheckboxes.length; ndx++)
    {
        if (arrNumeralCheckboxes[ndx].PRType == "A" && arrNumeralCheckboxes[ndx].checked == true)
            iCount = iCount + 1;
            
        if (iCount > 2)
        {
	        alert("Only two Rating Numerals of type 'Affiliate' can be selected.");
	        return false;
	    }
    }


    upgradedowngrade = document.getElementById("prra_upgradedowngrade");
    if (upgradedowngrade.value == "") {
        alert("The Upgrade/Downgrade field cannot be empty.");
        return false;
    }

    return true;
}

function save()
{
    if (validateRatingRules() == true)
    {
        cboCWR = document.getElementById("prra_creditworthid");
        cboInt = document.getElementById("prra_integrityid");
        cboPay = document.getElementById("prra_payratingid");
        hdnCWR = document.getElementById("_HIDDENprra_creditworthid");
        hdnInt = document.getElementById("_HIDDENprra_integrityid");
        hdnPay = document.getElementById("_HIDDENprra_payratingid");
	    hdnCWR.value = cboCWR.options[cboCWR.selectedIndex].value;

	    if (cboInt != null) {
	        hdnInt.value = cboInt.options[cboInt.selectedIndex].value;
	    }

	    if (cboPay != null) {
	        hdnPay.value = cboPay.options[cboPay.selectedIndex].value;
	    }

        // Enable any of the rating checkboxes that are disabled so that
	    // we preserve their values.
        var arrNumeralCheckboxes = tblNumerals.getElementsByTagName("TR");
        for (ndx = 0; ndx < arrNumeralCheckboxes.length; ndx++) {
            if (arrNumeralCheckboxes[ndx].id.indexOf("_tr_prrn_") == 0) {
                arrNumeralCheckboxes[ndx].disabled = false;
            }
        }
  
        document.EntryForm.submit();
    }
}

function onRatingNumeralClick()
{
    if (txtSelectedNumerals == null)
    {
        txtSelectedNumerals = document.getElementById("_txt_SelectedNumerals");
        spnAssignedRatingNumerals = document.getElementById("spn_AssignedRatingNumerals");
    }    
    
    chkRN = window.event.srcElement;
    if (chkRN.checked == true)
        txtSelectedNumerals.value = txtSelectedNumerals.value + chkRN.getAttribute("Numeral");
    else
        txtSelectedNumerals.value = (txtSelectedNumerals.value).replace(chkRN.getAttribute("Numeral"), "");
    
    spnAssignedRatingNumerals.innerText = txtSelectedNumerals.value;
    
    processRatingNumeralRules(chkRN);
}
function processRatingNumeralRules(chkRNClicked)
{         
	if ( bIsBranch == null)
	{
	    inpHQCWRId = document.getElementById("hq_prra_creditworthid");
	    bIsBranch = (inpHQCWRId != null)
    }

    if (txtSelectedNumerals == null)
    {
        txtSelectedNumerals = document.getElementById("_txt_SelectedNumerals");
        spnAssignedRatingNumerals = document.getElementById("spn_AssignedRatingNumerals");
    }    

    sSelectedNumerals = txtSelectedNumerals.value;
    
    // get the CWR, Integrity, And Pay Description fields
    cboCWR = document.getElementById("prra_creditworthid");
    cboInt = document.getElementById("prra_integrityid");
    cboPay = document.getElementById("prra_payratingid");

        
    // Should the CWR be NULL 
    if ( 
         (sSelectedNumerals.indexOf("(76)") != -1) ||
         (sSelectedNumerals.indexOf("(78)") != -1) ||
         (sSelectedNumerals.indexOf("(79)") != -1) ||
         (sSelectedNumerals.indexOf("(84)") != -1) ||
         (sSelectedNumerals.indexOf("(86)") != -1) ||
         (sSelectedNumerals.indexOf("(88)") != -1) ||
         (sSelectedNumerals.indexOf("(108)") != -1) ||
         (sSelectedNumerals.indexOf("(113)") != -1) ||
         (sSelectedNumerals.indexOf("(114)") != -1) ||
         (sSelectedNumerals.indexOf("(124)") != -1) ||
         (sSelectedNumerals.indexOf("(131)") != -1) ||
         (sSelectedNumerals.indexOf("(132)") != -1) 
       )
    {
        cboCWR.selectedIndex = 0;
        disableDropDown(cboCWR, true);
    }
    else
    {
        if (bIsBranch == true)
            cboCWR.selectedIndex = 0;
        disableDropDown(cboCWR, false);
    }

    if (cboInt != null) {
        // Should the Integrity Rating be nulled
        if (
             (sSelectedNumerals.indexOf("(60)") != -1) ||
             (sSelectedNumerals.indexOf("(76)") != -1) ||
             (sSelectedNumerals.indexOf("(82)") != -1) ||
             (sSelectedNumerals.indexOf("(84)") != -1) ||
             (sSelectedNumerals.indexOf("(85)") != -1) ||
             (sSelectedNumerals.indexOf("(86)") != -1) ||
             (sSelectedNumerals.indexOf("(88)") != -1) ||
             (sSelectedNumerals.indexOf("(108)") != -1) ||
             (sSelectedNumerals.indexOf("(113)") != -1) ||
             (sSelectedNumerals.indexOf("(114)") != -1) ||
             (sSelectedNumerals.indexOf("(124)") != -1) ||
             (sSelectedNumerals.indexOf("(131)") != -1) ||
             (sSelectedNumerals.indexOf("(132)") != -1)
           ) {
            cboInt.selectedIndex = 0;
            disableDropDown(cboInt, true);
        }
        else {
            disableDropDown(cboInt, false);
        }
    }

    if (cboPay != null) {
        // Should the Pay Description be nulled
        if (
             (sSelectedNumerals.indexOf("(27)") != -1) ||
             (sSelectedNumerals.indexOf("(60)") != -1) ||
             (sSelectedNumerals.indexOf("(74)") != -1) ||
             (sSelectedNumerals.indexOf("(76)") != -1) ||
             (sSelectedNumerals.indexOf("(82)") != -1) ||
             (sSelectedNumerals.indexOf("(84)") != -1) ||
             (sSelectedNumerals.indexOf("(85)") != -1) ||
             (sSelectedNumerals.indexOf("(88)") != -1) ||
             (sSelectedNumerals.indexOf("(108)") != -1) ||
             (sSelectedNumerals.indexOf("(113)") != -1) ||
             (sSelectedNumerals.indexOf("(114)") != -1) ||
             (sSelectedNumerals.indexOf("(124)") != -1) ||
             (sSelectedNumerals.indexOf("(131)") != -1) ||
             (sSelectedNumerals.indexOf("(132)") != -1)
           ) {
            cboPay.selectedIndex = 0;
            disableDropDown(cboPay, true);
        }
        else {
            disableDropDown(cboPay, false);
        }
    }
    
        
    // Should the Rating Numerals be cleared
/*    if ( 
         (sSelectedNumerals.indexOf("(76)") != -1) ||
         (sSelectedNumerals.indexOf("(85)") != -1) ||
         (sSelectedNumerals.indexOf("(88)") != -1) ||
         (sSelectedNumerals.indexOf("(108)") != -1) ||
         (sSelectedNumerals.indexOf("(113)") != -1) ||
         (sSelectedNumerals.indexOf("(114)") != -1) ||
         (sSelectedNumerals.indexOf("(124)") != -1) ||
         (sSelectedNumerals.indexOf("(131)") != -1) ||
         (sSelectedNumerals.indexOf("(132)") != -1) 
       )
    {
        clearCheckedRatingNumerals("", ",A,");
    }
    else
    {
*/
        enableAllRatingNumerals("");
//    }        
    
    // start checking for special conditions
    
    // if an 84 or 86 are assigned, prompt the user if an 80 exists on any other branch
    // this value is passed in on the caller or defaults to false
    if (chkRNClicked != null && chkRNClicked.checked == true && 
            ("(84)(86)".indexOf(chkRNClicked.Numeral) > -1) )
            
    {
        // find for the first time
        if (bBranchWith80 == null)
        {
            bBranchWith80 = false;
            hdnbBranchWith80 = document.getElementById("branch_with80");
            if (hdnbBranchWith80 != null)
                bBranchWith80 = (hdnbBranchWith80.value == "Y");
        }
        if (bBranchWith80 == true)
        {
            alert("FYI: A branch has a separate rating from this HQ record.");
        } 
    }
    
    
    return true;
}

function disableDropDown(cbo, bValue)
{
	if (cbo != null)
	{
        if (cbo.Id = "prra_creditworthid" && bAlwaysDisable_CreditWorth)
            return;
        if (cbo.Id = "prra_integrityid" && bAlwaysDisable_Integrity)
            return;
        if (cbo.Id = "prra_payratingid" && bAlwaysDisable_Pay)
            return;

        cbo.disabled = bValue;        
    }
}

function clearCheckedRatingNumerals(sExceptions, sStetTypes)
{
    tblNumerals = document.getElementById("_NumeralsListing");
    var arrNumeralCheckboxes = tblNumerals.getElementsByTagName("INPUT");
    for (ndx=0; ndx<arrNumeralCheckboxes.length; ndx++)
    {
        // this function is not allowed to remove these values if they are selected;
        // these value typically trigger this function and need to remained enabled so the user can 
        // unselected them
        if ("(76)(85)(88)(108)(113)(114)(124)(131)(132)".indexOf(arrNumeralCheckboxes[ndx].Numeral) != -1
           // && (arrNumeralCheckboxes[ndx].checked == true)
            )
            continue;
        
        if (sExceptions.indexOf(arrNumeralCheckboxes[ndx].Numeral) == -1)
        {
            // if this is not in our stet types, remove the checkbox and disable; 
            if (sStetTypes.indexOf(","+arrNumeralCheckboxes[ndx].PRType+",") == -1 )
            {
                if (arrNumeralCheckboxes[ndx].checked == true)
                {
                    txtSelectedNumerals.value = (txtSelectedNumerals.value).replace(arrNumeralCheckboxes[ndx].Numeral, "");
                    spnAssignedRatingNumerals.innerText = txtSelectedNumerals.value;
                    arrNumeralCheckboxes[ndx].checked = false;
                }
                arrNumeralCheckboxes[ndx].disabled = true;
            }
            else
            {
                if (arrNumeralCheckboxes[ndx].checked == false)
                    arrNumeralCheckboxes[ndx].disabled = true;
            }
        }
    }
}

function enableAllRatingNumerals(sExceptions)
{
    tblNumerals = document.getElementById("_NumeralsListing");
    var arrNumeralCheckboxes = tblNumerals.getElementsByTagName("INPUT");
    for (ndx=0; ndx<arrNumeralCheckboxes.length; ndx++)
    {
        if (sExceptions.indexOf(arrNumeralCheckboxes[ndx].Numeral) == -1)
            arrNumeralCheckboxes[ndx].disabled = false;
    }
}
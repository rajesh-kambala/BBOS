/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
 File: PRCompanySummary.js
 Description: This file contians the clientside javascript functions to validate 
              the fields of the company summary information

***********************************************************************
***********************************************************************/
var sIndustryTypeCode = "";

var nClassificationCount = 0;
var nCommodityCount = 0;
var nPublishedPhoneCount = 0;
var nPublishedAddressCount = 0;
var nHeadExecCount = 0;

var bOriginalWebActivated = false;
var dtOriginalWebActivatedDate = null;


function getDateAsString(sValue)
{
    if (sValue == null || sValue == "undefined")
        dtValue = new Date();
    else
        dtValue = new Date(sValue);
    sMonth = dtValue.getMonth()+1;
    sDay = dtValue.getDate();
    sReturn = ((sMonth<10?"0"+sMonth:sMonth) + "/" + (sDay<10?"0"+sDay:sDay) +  "/" + dtValue.getFullYear());
    dtValue = null;
    return sReturn;
}

/* **************************************************************************************
 *  function: validate
 *  Description: validation rules for company summary changes 
 *
 ***************************************************************************************/
function validate()
{
    var sSaveErrors = "";
    var oTradestyle1 = document.EntryForm.comp_prtradestyle1;
    if (oTradestyle1 != null)
    {
        var sTradestyle = String(document.EntryForm.comp_prtradestyle1.value);
        if (sTradestyle == "")
        {
            sSaveErrors += " - Tradestyle 1 is required.\n";
        }
    }

    // Look for the hidden ID field to make sure the user clicked
    // the magnifying glass to match the city name to a city ID.
    var oListingCity = document.EntryForm.comp_prlistingcityid;
   
    if (oListingCity != null)
    {
        var sListingCity = String(oListingCity.value);
        if (sListingCity == "")
        {
            sSaveErrors += " - Listing City is required or is not entered properly.\n";
        }
    }

    var oReceiveTES = document.EntryForm.comp_prreceivetes;
    var oOldReceiveTES = document.EntryForm._HIDDENcomp_prreceivetes;

    var oReceiveTESCode = document.EntryForm.comp_prreceivetescode;

    if (oReceiveTESCode != null) {
        if ((oReceiveTES.checked == false) &&
            (oOldReceiveTES.value == "Y")) {

            var sReceiveTESCode = oReceiveTESCode.options[oReceiveTESCode.selectedIndex].value;
            if (sReceiveTESCode == "") {
                sSaveErrors += " - If 'Receive TES' is not checked, please specify a reason.\n";
            }
        }

        if (oReceiveTES.checked == false && oReceiveTESCode.value == "PNR") {
            sSaveErrors += " - If 'Receive TES' is not checked, then Partial Non-Responder cannot be selected.\n";
        }
    }

    var oEmailAddress = document.EntryForm.emai_emailaddress;
    if (oEmailAddress != null) {
        if (oEmailAddress.value.indexOf(",") !== -1)
            sSaveErrors += " - Email Address cannot contain a comma.\n";
    }

    if (sSaveErrors != "")
    {
        alert("Please correct the following errors:\n\n" + sSaveErrors);
        return false;
    }
    

    if (document.getElementById("comp_pronlineonly") != null) {

        var sType = document.getElementById("_HIDDENcomp_prtype").value;

        if (document.getElementById("comp_pronlineonly").checked &&
            document.getElementById("_HIDDENcomp_pronlineonly").value == "") {


            sMsg = "Are you sure you want to list this company online only?";

            if ((sType == "H") &&
                (document.getElementById("hdn_branchCount").value > "0")) {
                sMsg += "  All branch locations will also be flagged as online only";
            }

            bResult = confirm(sMsg);
            if (bResult == false) {
                return false;
            }
        }

        if (!document.getElementById("comp_pronlineonly").checked &&
            document.getElementById("_HIDDENcomp_pronlineonly").value == "Y") {

            sMsg = "Are you sure you want to list this company in print and online?";

            if ((sType == "H") &&
                (document.getElementById("hdn_OnlineOnlybranchCount").value > "0")) {
                sMsg += "  Please review all listed branches that are marked as Online-Only.";
            }


            bResult = confirm(sMsg);
            if (bResult == false) {
                return false;
            }
        }
    }

    var oListingStatus =document.getElementById("comp_prlistingstatus");
    if (oListingStatus != null)
    {

        var sType = document.getElementById("_HIDDENcomp_prtype").value;
        var sListedStatusCode = oListingStatus.options[oListingStatus.selectedIndex].value;
        var sOldListedStatusCode = document.EntryForm._HIDDENcomp_prlistingstatus.value;
        
     
        if ((sOldListedStatusCode == "L" || sOldListedStatusCode == "H") 
                && (sListedStatusCode != "L" && sListedStatusCode != "H") ) {
            var sMsg = "By delisting this ";
            if (sType == "H") 
                sMsg += "headquarter company\n   1) any listed branches will also be delisted,\n   2) "
            else 
                sMsg += "company, ";
            sMsg += "any associated people will be marked No Longer Connected.\n\nDo you want to continue?";      
            bResult = confirm(sMsg);
            if (bResult == false) {
                return false;
            }
        }
        
        // if this company code is listed, certain requirements have to be met.
        var sListingErrors = "";
        if (sListedStatusCode == "L")
        {
            if (nClassificationCount == 0)
                sListingErrors += "\n - A classification must be assigned";
            if (nPublishedPhoneCount == 0)
                sListingErrors += "\n - A published phone number must be entered";
            if (nPublishedAddressCount == 0)
                sListingErrors += "\n - A published address must be entered";
            if (sIndustryTypeCode == "P" && nCommodityCount == 0)
                sListingErrors += "\n - A commodity must be assigned for this Produce company";
             
            if (sListingErrors != "")
            {
                alert("The following issues must be addressed prior to setting the status to \"Listed\":\n" 
                    + sListingErrors + "\n\nCancel this action and correct the necessary issues.");
                return false;
            }
            
            // check if this is a Headquarter
            oBranch = document.EntryForm._HIDDENcomp_prtype;
            // This alert only shows for HQs
            if (oBranch != null && oBranch.value == "H")
            {
                if ( (sIndustryTypeCode == "P" || sIndustryTypeCode == "T") && nHeadExecCount == 0)
                {
                    // Notice that this message does not prevent the save; just gives a message
                    alert("Please assign a person with the role of \"Head Executive\" for this listed business.");
                }

                if ((document.EntryForm.hdn_branchCount.value != "0") &&
                    ((document.getElementById("comp_prtradestyle1").value != document.getElementById("_HIDDENcomp_prtradestyle1").value) ||
                     (document.getElementById("comp_prtradestyle2").value != document.getElementById("_HIDDENcomp_prtradestyle2").value) ||
                     (document.getElementById("comp_prtradestyle3").value != document.getElementById("_HIDDENcomp_prtradestyle3").value) ||
                     (document.getElementById("comp_prtradestyle4").value != document.getElementById("_HIDDENcomp_prtradestyle4").value))) {
                    alert("HQ Tradestyle has changed.  Please check all branch records to see if their Tradestyle should also be changed.");
                }
            }
        }
    }


    var addressMsg = "";

    var addr_address1 = document.getElementById("addr_address1");
    var addr_prcityidTEXT = document.getElementById("addr_prcityidTEXT");
    var addr_postcode = document.getElementById("addr_postcode");

    // If we have one address field, we have them all.
    if (addr_address1 != null) {

        if ((addr_address1.value != "") || 
            (addr_prcityidTEXT.value != "") || 
            (addr_postcode.value != "")) {

            //alert(countryID);
            
            if ((countryID == "1") ||
                (countryID == "2")) {

                if ((addr_address1.value == "") ||
                    (addr_prcityidTEXT.value == "") ||
                    (addr_postcode.value == "")) {

                    addressMsg += "The specified address is incomplete.\n"

                }
            } else {
                if ((addr_address1.value == "") ||
                    (addr_prcityidTEXT.value == "")) {

                    addressMsg += "The specified address is incomplete.\n"

                }
            }


        }
    }


    if (addressMsg != "") {
        alert(addressMsg);
        return false;
    }


    //alert("_HIDDENprtx_status: " + document.getElementById("_HIDDENprtx_status").value);
    //alert("prtx_status: " + document.getElementById("prtx_status").value);
    
	return true;
}

/* **************************************************************************************
 *  function: save
 *  Description: performs the validate and save 
 *
 ***************************************************************************************/
function save()
{
    if (validate()) {

        // if we're prompting the user, don't submit
        // the form yet.  The user prompt events will
        // submit the form for us.
        if (!promptToSendCompanyRequests()) {
            document.EntryForm.submit();
        }
    }
}

function saveNew() {
    if (checkDupCompany(sCheckDupUrl) &&
        validate() &&
        validateTransaction())
        document.EntryForm.submit();
}

/* **************************************************************************************
 *  function: UpdateTradestyles
 *  Description: Updates the string content of the Name & Book and Correspondence 
 *               Tradestyle Memo values by concatenating the tradestyle values
 *
 ***************************************************************************************/
function UpdateTradestyles()
{
  var sTS1 = String("");
  var sTS2 = String("");
  var sTS3 = String("");
  var sTS4 = String("");

  var tsField = document.getElementById("comp_prtradestyle1");
  if (!isEmpty(tsField))
	sTS1 = String(tsField.value);
  tsField = document.getElementById("comp_prtradestyle2");
  if (!isEmpty(tsField))
	sTS2 = String(tsField.value);
  tsField = document.getElementById("comp_prtradestyle3");
  if (!isEmpty(tsField))
	sTS3 = String(tsField.value);
  tsField = document.getElementById("comp_prtradestyle4");
  if (!isEmpty(tsField))
	sTS4 = String(tsField.value);
  
  // first complete the Book Tradestyle (which will also be the name)
  var sBookName = String("");
  if (sTS4.length > 0)
  {
    // if the fourth field is populated, the first field must be "The"
    // tradestyle block gets composed as 3+2+4+1
    sBookName = sTS3;
	if (sBookName.length > 0 && sTS2.length > 0)
		sBookName = sBookName + ", ";
	sBookName = sBookName + sTS2;

	if (sBookName.length > 0 && sTS4.length > 0)
		sBookName = sBookName + ", ";
	sBookName = sBookName + sTS4;

    // This value should be "The", but append it just the same
	if (sBookName.length > 0 && sTS1.length > 0)
		sBookName = sBookName + ", ";
	sBookName = sBookName + sTS1;
  }
  else
  {
    // tradestyle block gets composed as 2+1+3
    sBookName = sTS2;
	if (sBookName.length > 0 && sTS1.length > 0)
		sBookName = sBookName + ", ";
	sBookName = sBookName + sTS1;
	if (sBookName.length > 0 && sTS3.length > 0)
		sBookName = sBookName + ", ";
	sBookName = sBookName + sTS3;
  }

  // Now get the correspondence tradestyle
  var sCorrName = new String("");
  sCorrName = sTS1;
  if (sCorrName.length > 0 && sTS2.length > 0)
	sCorrName = sCorrName + " ";
  sCorrName = sCorrName + sTS2;
  if (sCorrName.length > 0 && sTS3.length > 0)
	sCorrName = sCorrName + " ";
  sCorrName = sCorrName + sTS3;
  if (sCorrName.length > 0 && sTS4.length > 0)
	sCorrName = sCorrName + " ";
  sCorrName = sCorrName + sTS4;
  
  var displayfield = document.getElementById("_Datacomp_prbooktradestyle");
  if (!isEmpty(displayfield))
	displayfield.innerText = sBookName;
  var displayfield = document.getElementById("_Datacomp_name");
  if (!isEmpty(displayfield))
	displayfield.innerText = sBookName;

  // BE sure to also se the hidden fields of you will not be able
  // to save the values.
  var displayfield = document.getElementById("_HIDDENcomp_prbooktradestyle");
  if (!isEmpty(displayfield))
	displayfield.value = sBookName;
  var displayfield = document.getElementById("_HIDDENcomp_name");
  if (!isEmpty(displayfield))
	displayfield.value = sBookName;
	
  var displayfield = document.getElementById("_Datacomp_prcorrtradestyle");
  if (!isEmpty(displayfield))
	displayfield.innerText = sCorrName;
  // BE sure to also se the hidden fields of you will not be able
  // to save the values.
  var displayfield = document.getElementById("_HIDDENcomp_prcorrtradestyle");
  if (!isEmpty(displayfield))
	displayfield.value = sCorrName;

  return ;
}

function handleTradeStyleOnpaste()
{
    event.returnValue = false;
    var clipboardText = event.clipboardData.getData("Text");
    document.execCommand("insertHTML", false, clipboardText);

    UpdateTradestyles();
}

function initialize()
{
    var tsField = document.getElementById("comp_prtradestyle1");
    if (!isEmpty(tsField))
        tsField.onpaste = handleTradeStyleOnpaste;
    tsField = document.getElementById("comp_prtradestyle2");
    if (!isEmpty(tsField))
        tsField.onpaste = handleTradeStyleOnpaste;
    tsField = document.getElementById("comp_prtradestyle3");
    if (!isEmpty(tsField))
        tsField.onpaste = handleTradeStyleOnpaste;
    tsField = document.getElementById("comp_prtradestyle4");
    if (!isEmpty(tsField))
        tsField.onpaste = handleTradeStyleOnpaste;
}

function promptToSendCompanyRequests() {

  var oIndustryType = document.getElementById("comp_prindustrytype");
  if (oIndustryType == null) {
    return;
  }

    var sIndustryType = oIndustryType.options[oIndustryType.selectedIndex].value;

    var sType = document.getElementById("_HIDDENcomp_prtype").value;

    if ((sIndustryType != "L") && (sIndustryType != "S") && (sType == "H")) {

        var oListingStatus = document.getElementById("comp_prlistingstatus");
        if (oListingStatus != null) {
            var sListedStatusCode = oListingStatus.options[oListingStatus.selectedIndex].value;
            var sOldListedStatusCode = document.EntryForm._HIDDENcomp_prlistingstatus.value;


            if ((sOldListedStatusCode != "L" && sOldListedStatusCode != "H")
                && (sListedStatusCode == "L" || sListedStatusCode == "H")) {

                document.getElementById("pnlSendCompanyRequest").style.display = "";
                return true;
            }
        }
    }

    return false;
}


function sendCompanyRequest() {
    document.getElementById("hidSendCompanyRequest").value = "Y";
    closeCompanyRequest();
}

function closeCompanyRequest() {
    document.getElementById("pnlSendCompanyRequest").style.display = "none";
    document.EntryForm.submit();
}

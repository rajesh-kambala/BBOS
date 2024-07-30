/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
 File: PRCompanyRelationship.js
 Description: This file contians the clientside javascript functions to validate 
              the fields of the company relationship information

***********************************************************************
***********************************************************************/

// this is the accpac container block table for the trade Report display
var tblTradeReport = null;
var btnTradeReportTextAnchor = null;


// some change tracking logic stolen from DataChangeInclude.js (don't want the form unload
// functionality just yet; that is one of the only differences)
var bDataChanged = false;

function onChangeHandler()
{
    var src = window.event.srcElement;
    handleDataChanged(src);
}

function handleDataChanged(src)
{
    bDataChanged = true;
}

function save()
{
    bDataChanged=false;
    document.EntryForm.submit();
}

// create functionality for enabling or disabling the view of the trade report
function getTradeReportBlock()
{
    // start at a field we know is on the trade report and work backwards
    var field = document.getElementById("prtr_lastdealtdate");
    if (field != null && field != "undefined")
    {
        while ((field != null) && (field.tagName != "TABLE"))
            field = field.parentElement;
        if (field != null)
            tblTradeReport = field;
    }
}
function toggleTradeReportUse()
{
    if (tblTradeReport == null)
    {
        getTradeReportBlock();
        getTradeReportButtonTextAnchor();
    }
    // now determine the visible state
    if (tblTradeReport != null)
    {
        if (tblTradeReport.style.display == "none") {

            var txtprcr_RightCompanyId = document.getElementById("prcr_rightcompanyid");
            if (txtprcr_RightCompanyId != null && txtprcr_RightCompanyId != "undefined") {
                if (txtprcr_RightCompanyId.value == "") {
                    alert("A related company must be specified before adding a trade report.");
                    return;
                }
            }

            var hdn_RelatedCompanies = document.getElementById("hdn_relatedcompanylist");
            sRelatedCompanies = "," + hdn_RelatedCompanies.value + ",";
            if (sRelatedCompanies.indexOf("," + txtprcr_RightCompanyId.value + ",") > -1) {
                alert("A company cannot submit a trade report on its headquarter, branch, sibling branch, or an affiliated company.");
                return;
            }
         
            setTradeReportBlockDisplay("inline");
        } else
            setTradeReportBlockDisplay("none");
    }
}
function setTradeReportBlockDisplay(sStyle)
{
    var txtUseTradeReport = document.getElementById("_usetradereport");
    if (tblTradeReport == null)
    {
        getTradeReportBlock();
        getTradeReportButtonTextAnchor();
    }
    if (tblTradeReport != null)
        tblTradeReport.style.display = sStyle;
        
    if (sStyle == "none")
    {
        if (btnTradeReportTextAnchor != null)
            btnTradeReportTextAnchor.innerHTML = "Include Trade Report";
        if (txtUseTradeReport != null)
            txtUseTradeReport.value = "false";
    }
    else
    {
        if (btnTradeReportTextAnchor != null)
            btnTradeReportTextAnchor.innerHTML = "Exclude Trade Report";
        if (txtUseTradeReport != null)
            txtUseTradeReport.value = "true";
    }
}
function getTradeReportButtonTextAnchor()
{
    // find the anchor that has the inital text of the Trade Report button
    var arr = document.getElementsByTagName("A");
    for (ndx=0; ndx<arr.length; ndx++)
    {
        if (arr[ndx].innerText == "Include Trade Report")
        {
            btnTradeReportTextAnchor = arr[ndx];
            break;
        }
    }
}



/* **************************************************************************************
 *  function: validate
 *  Description: validation rules 
 *
 ***************************************************************************************/
function validate()
{
    var txtUseTradeReport = document.getElementById("_usetradereport");
    var txtprcr_RightCompanyId = document.getElementById("prcr_rightcompanyid");
	
	if (txtprcr_RightCompanyId != null && txtprcr_RightCompanyId != "undefined" )
    {
        if (txtprcr_RightCompanyId.value == "")
        {
            alert("Related Company is required for a new relationship.");
            return false;
        } else {
    
            // CHW 10/3/06  We keep bombing on this field when editing a relationship
            // The "Toggle" trade report doesn't do anything.  I don't know if we should
            // be hiding the button or fixing the toggle as the code seems to indicate adding
            // trade report data is for new relationships only.
            if (txtUseTradeReport.value == "true") {
                var txtprtr_SubjectId = document.EntryForm.prtr_subjectid;
                txtprtr_SubjectId.value = txtprcr_RightCompanyId.value;            }
        }
    } else  {
        alert("Related Company cannot be determined.");
        return false;
    }

    var sRelationshipType = new String(document.EntryForm.prcr_type.value);
    if ((sRelationshipType == "09") ||
        (sRelationshipType == "10") ||
        (sRelationshipType == "11") ||
        (sRelationshipType == "12") ||
        (sRelationshipType == "13") ||
        (sRelationshipType == "14") ||
        (sRelationshipType == "15")) {

        var hdn_RelatedCompanies = document.getElementById("hdn_relatedcompanylist");
        sRelatedCompanies = "," + hdn_RelatedCompanies.value + ",";
        if (sRelatedCompanies.indexOf("," + txtprcr_RightCompanyId.value + ",") > -1) {
            alert("A company cannot be related to an affiliated company.");
            return false;
        }
    }

    if (txtUseTradeReport.value == "true")
    {
        var txtprtr_Date = document.EntryForm.prtr_date;
    	if (txtprtr_Date != null && txtprtr_Date != "undefined" )
        {
            if (txtprtr_Date.value == "")
            {
                alert("Trade Report Date is required for a new trade report.");
                return false;
            }
        }
    
    }

    if (document.EntryForm.prcr_leftcompanyid.value == document.EntryForm.prcr_rightcompanyid.value) {
        alert("A company cannot have a relationship to itself.");
        return false;
    }

    if (document.EntryForm.prcr_lastreporteddate.value != "") {
        if (!isValidDate(document.EntryForm.prcr_lastreporteddate.value)) {
            alert("The Last Reported Date field has an invalid value.");
            return false;
        }
    }
    

    if (document.EntryForm.prcr_source.value == "") {
        alert("The Source field is required.");
        return false;
    }


    if (bNew) {
        // Determine if we need to remind the user to set the affiliation
        // ratings
        var sRelationshipType = new String(document.EntryForm.prcr_type.value);
        var sOldRelationshipType = new String(document.EntryForm._HIDDENprcr_type.value);

        if (sRelationshipType != sOldRelationshipType) {
            if ((sRelationshipType == "27") ||
                (sRelationshipType == "28") ||
                (sRelationshipType == "29")) {

                return confirm("After saving this relationship, please be sure to add the appropriate affiliation rating numerals to all involved companies.");
            }
        }
    } else {

        var newActive = document.getElementById("_IDprcr_active").checked;
        var oldActive = false;
        if (document.EntryForm._HIDDENprcr_active.value == "Y") {
            var oldActive = true;
        }


        // If this releationship is no longer active and 
        // it is the last CL type, we need to clear out
        // the CL date.
        if ((!newActive) &&
            (oldActive) &&
            (clCount == 1)) {

            var sRelationshipType = new String(document.EntryForm._HIDDENprcr_type.value);
            if ((sRelationshipType == "09") ||
                (sRelationshipType == "10") ||
                (sRelationshipType == "11") ||
                (sRelationshipType == "12") ||
                (sRelationshipType == "13") ||
                (sRelationshipType == "15")) {

                document.getElementById("comp_prconnectionlistdate").value = "";
            }
        }
    }

	return true;
}

/* **************************************************************************************
 *  function: save
 *  Description: performs the validate and save 
 *
 ***************************************************************************************/
function save()
{
	if (validate())	
		document.EntryForm.submit();
}

var xmlHttpBranchOwnershipRequest = null;

function checkForBranchOwnership()
{            
    var sRelationshipType = new String($("#prcr_type").val());

    sReturn = true;
    if ((sRelationshipType == "27") || (sRelationshipType == "28")) {
        var sLeftCompanyID = new String(document.EntryForm.prcr_leftcompanyid.value);
        var sRightCompanyID = new String(document.EntryForm.prcr_rightcompanyid.value);

        xmlHttpBranchOwnershipRequest = new XMLHttpRequest();
        xmlHttpBranchOwnershipRequest.onreadystatechange = HandleBranchOwnership;
        xmlHttpBranchOwnershipRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetBranchOwnership?leftCompanyId=" + sLeftCompanyID + "&rightCompanyId=" + sRightCompanyID, true);
        xmlHttpBranchOwnershipRequest.send();

        return false;
    }

    return sReturn;
}

function HandleBranchOwnership() {
    if (xmlHttpBranchOwnershipRequest.readyState == 4) {
        if (xmlHttpBranchOwnershipRequest.responseXML != null) {
            var result = $(xmlHttpBranchOwnershipRequest.responseText)[2].innerText;

            var obj = jQuery.parseJSON(result);
            if (obj.comp_CompanyId_l == obj.comp_CompanyId_r) {
                alert(obj.CompanyName_l + " (" + obj.comp_CompanyId_l + ") is a branch of " + obj.CompanyName_r + " (" + obj.comp_CompanyId_r + ") and thus cannot have an ownership relationship.");
                return false;
            }
            else {
                save();
                return true;
            }
        }
    }
}


function onTypeChange() {


}

function deactivateAll(sURL) {

    if (confirm("Are you sure you want to deactivate all of the relationships between these two companies?")) {
        location.href = sURL;
    }
}

var xmlHttp = null;

function SetCompanyListener() {
  GetLastRelType(document.getElementById("prcr_rightcompanyid").value);
  
}

function GetLastRelType(companyID) {
    //xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = SetLastRelType;
    xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetLastRelationshipType?companyID=" + companyID, true);
    xmlHttp.send(null);
}

function SetLastRelType() {
  if (xmlHttp.readyState == 4) {
    
    //var sResponse = xmlHttp.responseXML.getElementsByTagName("string")[0].childNodes[0].nodeValue;
    var sResponse = xmlHttp.responseXML.text;
    var prcr_Type = document.getElementById("prcr_type");
    for (var i = 0; i < prcr_Type.options.length; i++) {
      if (prcr_Type.options[i].value == sResponse) {
        prcr_Type.options[i].selected = true;
        return;
      }
    }
  }
}

var xmlHttpCompanyOwnershipRequest = null;
function GetCompanyOwnership(eCompanyIDControl) {
    var l = eCompanyIDControl.length;
    var sCompanyID;
    $("input[name*='" + eCompanyIDControl + "' i]").each(function (x) {
        if ((this).id.toLowerCase() == eCompanyIDControl.toLowerCase())
            sCompanyID = (this).value;
    });

    xmlHttpCompanyOwnershipRequest = new XMLHttpRequest();
    xmlHttpCompanyOwnershipRequest.onreadystatechange = SetCompanyOwnership;
    xmlHttpCompanyOwnershipRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetCompanyOwnership?companyId=" + sCompanyID, true);
    xmlHttpCompanyOwnershipRequest.send();
}

function SetCompanyOwnership() {
    if (xmlHttpCompanyOwnershipRequest.readyState == 4) {
        if (xmlHttpCompanyOwnershipRequest.responseXML != null) {
            var result = $(xmlHttpCompanyOwnershipRequest.responseText)[2].innerText;

            var obj = jQuery.parseJSON(result);
            var fld = $("#hdn_CompanyOwnershipPercent");
            if (fld) {
                fld.value = obj.CurrentPercentage;
                if (obj.CurrentPercentage > 100) {
                    alert("Warning: The total ownership of " + obj.CompanyName + " is " + obj.CurrentPercentage + "% which exceeds 100%.");
                }
            }
        }
    }
}


/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
 File: PRCompanySummary.js
 Description: This file contians the clientside javascript functions to validate 
              the fields of the company summary information

***********************************************************************
***********************************************************************/
var xmlHttp = null;
var xmlHttpHasAvailable = null;
var sCompanyId = null;
var sBRChecksUrl = null;

function onRequestingPersonChange()
{
    var txtRequestingPersonTEXT = document.getElementById("prbr_requestingpersonidTEXT");
    var txtRequestorInfo = document.getElementById("prbr_requestorinfo");
    txtRequestorInfo.value = txtRequestingPersonTEXT.value;
    
    checkCanUseUnits();
}

function onDoNotChargeUnitsChange()
{
    if (document.getElementById("_IDprbr_donotchargeunits").checked == true) {
        setHeaderMessage("header_canuseunits", "");
        setHeaderMessage("header_hasavailableunits", "");
    } else {
        checkCanUseUnits();
        checkHasAvailableUnits();        
    }    
}

function onMethodSentChange()
{
    if (document.getElementById("_IDprbr_donotchargeunits").checked == true){
        setHeaderMessage("header_canuseunits", "");
        setHeaderMessage("header_hasavailableunits", "");
    } else {
        checkCanUseUnits();
        checkHasAvailableUnits();        
    }    
}

function checkCanUseUnits()
{
    // check if the selected user can use units
    if (document.getElementById("_IDprbr_donotchargeunits").checked == false){
        var sPersonId = null;
        if (sCompanyId == null)
            sCompanyId = document.getElementById("prbr_requestingcompanyid").value;

        sPersonId = document.getElementById("prbr_requestingpersonid").value;
        if (sCompanyId && sPersonId){
            // use ajax to check if this use is allowed to use service units
            xmlHttp = GetXmlHttpObject();
            xmlHttp.onreadystatechange=handleUseServiceUnitsResponse;
            xmlHttp.open("GET",sBRChecksUrl + "&check=useserviceunits" + "&CompanyId=" + sCompanyId + "&PersonId=" + sPersonId,true);
            xmlHttp.send(null);		
        }    
    }
}

function handleUseServiceUnitsResponse() {
    // readyState of 4 = Complete
    if(xmlHttp.readyState==4) {
        // if "OK"
        if (xmlHttp.status==200){
            sMsg = "";
            if (xmlHttp.responseText == "N")
                sMsg = "This user does not have permission to use service units for this company.";
            setHeaderMessage("header_canuseunits", sMsg);
            
        } else {
            // if there is an error, redirect so we can see and fix it
            var sPersonId = null;
            if (sCompanyId == null)
                sCompanyId = document.getElementById("prbr_requestingcompanyid").value;
            sPersonId = document.getElementById("prbr_requestingpersonid").value;
            location.href = sBRChecksUrl + "&act=useserviceunits" + "&CompanyId=" + sCompanyId + "&PersonId=" + sPersonId;
        }
    }
}

function checkHasAvailableUnits()
{
    var sPricingListId;

    // check if the selected user can use units
    if (document.getElementById("_IDprbr_donotchargeunits").checked == false)
    {
        if (sCompanyId == null)
            sCompanyId = document.getElementById("prbr_requestingcompanyid").value;
            
        var sHQId = document.getElementById("hdn_hqid").value;
        var sMethodSent = document.getElementById("prbr_methodsent").value.toUpperCase();
        var lkPricingList = { "EBR":16013, "FBR":16011, "OBR":16010, "VBR":16012 };  // Lookup table to translate the method sent to the pricing list.
        if ((sPricingListId = lkPricingList[sMethodSent]) == null) {
            sPricingListId = 16002;  // set to default
        }
        var sProductId = document.getElementById("prbr_productid").value;
 
        if (sCompanyId && sMethodSent){
            // use ajax to check if this use is allowed to use service units
            xmlHttpHasAvailable = GetXmlHttpObject();
            xmlHttpHasAvailable.onreadystatechange=handleHasAvailableUnitsResponse;
            xmlHttpHasAvailable.open("GET",sBRChecksUrl + "&check=hasavailableunits" + "&HQID=" + sHQId + "&ProductId=" + sProductId + "&PricingListID=" + sPricingListId,true);
            xmlHttpHasAvailable.send(null);		
        }    
    }
}

function handleHasAvailableUnitsResponse() {
    // readyState of 4 = Complete
    if(xmlHttpHasAvailable.readyState==4) {
        // if "OK"
        if (xmlHttpHasAvailable.status==200){
            sMsg = "";
            if (xmlHttpHasAvailable.responseText == "N")
                sMsg = "This company does not have sufficient units to purchase the requested report.";
            setHeaderMessage("header_hasavailableunits", sMsg);
            
        } else {
            // if there is an error, redirect so we can see and fix it
            var sMethodSent = null;
            if (sCompanyId == null)
                sCompanyId = document.getElementById("prbr_requestingcompanyid").value;
            sMethodSent = document.getElementById("prbr_methodsent").value;
            location.href = sBRChecksUrl + "&check=hasavailableunits" + "&CompanyId=" + sCompanyId + "&UsageType=" + sMethodSent;
        }
    }
}


function setHeaderMessage(spanName, Msg){
    var obj = document.all[spanName];
    obj.innerHTML = Msg;   

    if (document.getElementById("header_canuseunits").innerHTML != "" || document.getElementById("header_hasavailableunits").innerHTML != "")
        document.getElementById("header_banner").style.display = "inline";
    else
        document.getElementById("header_banner").style.display = "none";

}



function validate(sRequestingCompanyId)
{
    var sErrors = "";
    
    // if an error message is displayed, repeat it and return
    if (document.all["header_canuseunits"].innerHTML != "" || document.all["header_hasavailableunits"].innerHTML != "" )
    {
        alert(document.all["header_canuseunits"].innerHTML + "\n" + document.all["header_hasavailableunits"].innerHTML);
        return false;
    }

    var prbr_RequestingPersonId = document.EntryForm.prbr_requestingpersonid.value;
    if (prbr_RequestingPersonId == "")
    {
        if (sErrors != "") sErrors += "\n";
        sErrors += "Requesting Person must be entered";
    }         

    var prbr_RequestedCompanyId = document.EntryForm.prbr_requestedcompanyid.value;
    if (prbr_RequestedCompanyId == "")
    {
        if (sErrors != "") sErrors += "\n";
        sErrors += "Business Report On Company must be entered";
    }
    
    var prbr_ProductId = document.getElementById("prbr_productid").value;
    if (prbr_ProductId == "") {
        if (sErrors != "") sErrors += "\n";
        sErrors += "Product must be entered";
    }
    
    var prbr_Fax = document.EntryForm.prbr_fax.value;
    var prbr_EmailAddress = document.EntryForm.prbr_emailaddress.value;
    var prbr_MethodSent = document.EntryForm.prbr_methodsent.value;
    if (prbr_MethodSent == "EBR" && prbr_EmailAddress == "" )
    {
        if (sErrors != "") sErrors += "\n";
        sErrors += "Emailed reports require a Email Address to be entered";
    }         
    else if (prbr_MethodSent == "FBR" && prbr_Fax == "" )
    {
        if (sErrors != "") sErrors += "\n";
        sErrors += "Faxed reports require a Fax Number to be entered";
    }
    
    if (sErrors != "")
    {
        alert(sErrors);
        return false;
    }
    
    
    return true;    
}

function save(sRequestingCompanyId)
{
    if (validate(sRequestingCompanyId))
        document.EntryForm.submit();
}
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
function onClickAddrPRPublish()
{
    var oPublish = document.getElementById("addr_prpublish");
    if (oPublish == undefined) return;
    
    var oType = document.getElementById("adli_Type");
    if (oType == undefined) return;
    
    if ((oPublish.checked == true) && (oType.value == "M"))
    {
        if (! confirm("Only one published mailing address is allowed.  Do you want to publish this address?"))
            oPublish.checked = false;
    }
}

function validate()
{
    var sValidationErrors = "";
    var oFocus = null;

    var oCityId = document.getElementById("addr_prcityid");
    var oCityStateCountry = document.getElementById("addr_prcityidTEXT");
    if (oCityId == null || oCityId.value == "")
    {
        sValidationErrors += " - City is missing or not properly entered.\n";
        oFocus = oCityStateCountry;
    }
    
    var oAddress1 = document.getElementById("addr_address1");
    if (oAddress1 == null || oAddress1.value == "")
    {
        sValidationErrors += " - Address Line 1 is required.\n";
        if (oFocus == null) oFocus = oAddress1;
    }



    var oCounty = document.getElementById("addr_prcounty");
    
    var sCountryValue = new String(oCityStateCountry.value);
    var bCountryUSA = (sCountryValue.indexOf(", USA") >= 0);
    if (bCountryUSA && oCounty.value == "")
    {
        sValidationErrors += " - County is required for cities when the country is 'USA'.\n";
        if (oFocus == null) oFocus = oCounty;
    }

    if (bCountryUSA) {
        var oaddr_postcode = document.getElementById("addr_postcode");
        if (oaddr_postcode == null || oaddr_postcode.value == "") {
            sValidationErrors += " - Zip Code is required.\n";
            if (oFocus == null) oFocus = oaddr_postcode;
        }
    }


    var oType = document.getElementById("adli_type");
    if (oType == null || oType.value == "")
    {
        sValidationErrors += " - Type is required.\n";
        if (oFocus == null) oFocus = oType;
    }

    if (sValidationErrors != "")
    {
        alert("The following issues must be addressed prior to saving this address:\n\n" 
            + sValidationErrors + "\n\nCorrect the necessary issues before continuing.");
        if (oFocus != null)
            oFocus.focus();
        return false;
    }
    return true;

}

var bSaveFlag = false;
function save() {

    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;
    
    if (validate() == false) {
        bSaveFlag = false;
    } else {
        enableAllDefaults();
        //document.getElementById
        document.EntryForm.submit();
    } 
    
}

//$('form').keypress(function (event) {

//    var keycode = (event.keyCode ? event.keyCode : event.which);
//    if (keycode == '13') {
//        save();
//        event.preventDefault();
//        event.cancelBubble = true;
//        event.returnValue = false;
//        return false;
//    }

//});


function enableAllDefaults() {
    if (document.forms[0].adli_prdefaultmailing)
        document.forms[0].adli_prdefaultmailing.disabled = false;

    if (document.forms[0].adli_prdefaulttax)
        document.forms[0].adli_prdefaulttax.disabled = false;
}

function selectAllDefaults() {
    if (document.forms[0].adli_prdefaultmailing)
        document.forms[0].adli_prdefaultmailing.checked = true;

    if (document.forms[0].adli_prdefaulttax)
        document.forms[0].adli_prdefaulttax.checked = true;
}


function selectAddressType() {
    if ((document.forms[0].adli_type.value == 'PS') ||
        (document.forms[0].adli_type.value == 'PM')) {
        document.forms[0].addr_prpublish.checked = false;
        document.forms[0].addr_prpublish.disabled = true;
    } else {
        document.forms[0].addr_prpublish.disabled = false;    
    }
}
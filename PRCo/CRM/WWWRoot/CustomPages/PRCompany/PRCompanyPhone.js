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

function validate()
{
    var focusControl= null;
    var sAlertMsg = "";

    var txtPhoneAC = document.EntryForm.phon_areacode;
    if (txtPhoneAC.value == "")
    {
        sAlertMsg += "Phone Area/City Code is a required field.\n";
        focusControl = txtPhoneAC;
    } 
    
           
    var txtPhone = document.EntryForm.phon_number;
    if (txtPhone.value == "")
    {
        sAlertMsg += "Phone Number is a required field.\n";
        if (focusControl != null)
            focusControl = txtPhoneAC;
    } 

    
    if (sAlertMsg != "")
    {
        alert ("The following changes are required to save the Phone record:\n\n" + sAlertMsg);
        if (focusControl != null)
            focusControl.focus();
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
        document.EntryForm.submit();
    }
}

function togglePreferredPublished() {

    if (!document.getElementById("_IDphon_prpublish").checked) {
        document.getElementById("_IDphon_prpreferredpublished").checked = false;
    }
}

function togglePublished() {

    if (document.getElementById("_IDphon_prpreferredpublished").checked) {
        document.getElementById("_IDphon_prpublish").checked = true;
    }
}
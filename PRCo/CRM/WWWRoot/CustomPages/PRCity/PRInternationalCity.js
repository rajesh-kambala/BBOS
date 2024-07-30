///***********************************************************************
// ***********************************************************************
//  Copyright Blue Book Services, Inc. 2013
//
//  The use, disclosure, reproduction, modification, transfer, or  
//  transmittal of  this work for any purpose in any form or by any 
//  means without the written permission of Blue Book Services, Inc. is 
//  strictly prohibited.
//
//  Confidential, Unpublished Property of Blue Book Services, Inc.
//  Use and distribution limited solely to authorized personnel.
// 
//  All Rights Reserved.
// 
//  Notice:  This file was created by Travant Solutions, Inc.  Contact
//  by e-mail at info@travant.com.
// 
// 
//***********************************************************************
//***********************************************************************/
function validate() {
    var focusControl = null;
    var sAlertMsg = "";

    var txtCity = document.EntryForm.prci_city;
    var txtCountry = document.EntryForm.prcn_countryid;

    // From previous phone file.
    if (txtCity.value == "") {
        sAlertMsg += " - City is a required field.\n";
        focusControl = txtCity;
    }

    // From previous phone file.
    if (txtCountry.value == "") {
        sAlertMsg += " - Country is a required field.\n";
        focusControl = txtCity;
    }

    if ((txtCountry.value == "2") ||
        (txtCountry.value == "3")) {
        sAlertMsg += " - Cities in Canada and Mexico must be entered in the normal City screen.\n";
        if (focusControl != null)
            focusControl = txtState;
    }

    if (sAlertMsg != "") {
        alert("The following changes are required to save the City record:\n\n" + sAlertMsg);
        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    return true;
}

function save() {
    if (validate() == true) {
        document.EntryForm.submit();
    }
}
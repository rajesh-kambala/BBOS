///***********************************************************************
// ***********************************************************************
//  Copyright Produce Report Company 2019
//
//  The use, disclosure, reproduction, modification, transfer, or  
//  transmittal of  this work for any purpose in any form or by any 
//  means without the written permission of Produce Report Company is 
//  strictly prohibited.
// 
//  Confidential, Unpublished Property of Produce Report Company.
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

// From accpac
var View = 0, Edit = 1, Save = 2, PreDelete = 3, PostDelete = 4, Clear = 6;
var Find = 2;

function validate() {
    var focusControl = null;
    var sAlertMsg = "";

    //var txtName = document.EntryForm.pradch_name;
    //var txtTypeCode = document.EntryForm.pradch_typecode;

    var bNumericErrors = false;
    var total = 0;
    $('*[class^="TermsAmt"]').each(function (index) {
        var num = $(this).val().replace(/,/g, "").replace(/[$]/g, "");
        var valid = !isNaN(num);
        if (!valid || num < 0) {
            bNumericErrors = true;
        }
        else
            total += Number(num);
    });

    total = total.toFixed(2);

    var costAmount = Number(document.getElementById("_HIDDENpradc_cost").value.replace(/,/g, '').replace(/[$]/g, '')).toFixed(2);
    var discountAmount = Number(document.getElementById("_HIDDENpradc_discount").value.replace(/,/g, '').replace(/[$]/g, '')).toFixed(2);
    var netAmount = (costAmount - discountAmount).toFixed(2);
    if (total !== netAmount) {
        sAlertMsg += " - Amounts entered must equal Cost-Discount = $" + netAmount + "\n";
    }

    if (bNumericErrors) {
        sAlertMsg += " - Amounts must be non-negative numeric.\n";
    }

    var bDateErrors = false;
    $('*[class^="BillingDate"]').each(function (index) {
        var valid = isValidDate($(this).val());
        if ($(this).val() != "" && !valid) {
            bDateErrors = true;
        }
    });

    if (bDateErrors) {
        sAlertMsg += " - One or more Billing Dates are invalid.\n";
    }

    if (sAlertMsg != "") {
        alert("Please correct the following issues before continuing.\n\n" + sAlertMsg);
        
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

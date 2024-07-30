///***********************************************************************
// ***********************************************************************
//  Copyright Produce Report Company 2019-2019
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

    var txtName = document.EntryForm.pradch_name;
    var txtTypeCode = document.EntryForm.pradch_typecode;

    // From previous phone file.
    if (txtName.value == "") {
        sAlertMsg += " - Name is a required field.\n";
        focusControl = txtName;
    }

    if (txtTypeCode.value == "") {
        sAlertMsg += " - Ad Campaign Type is a required field.\n";
        if (focusControl != null)
            focusControl = txtTypeCode;
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

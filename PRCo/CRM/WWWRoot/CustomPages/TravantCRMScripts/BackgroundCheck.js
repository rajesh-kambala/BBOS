/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, LLC 2024

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, LLC is
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, LLC.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

function validate() {
    var focusControl = null;
    var sAlertMsg = "";

 

    if (sAlertMsg != "") {
        alert("Please correct the following issues before continuing.\n\n" + sAlertMsg);

        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    return true;
}

function change_button() {
    document.EntryForm.HiddenMode.value = 'Change';
    document.getElementById("EntryForm").submit();
}


function save_button() {
    if (validate() == true) {
        document.EntryForm.HiddenMode.value = 'Save';
        document.getElementById("EntryForm").submit();
    }
}

function cancel_button() {
    document.EntryForm.HiddenMode.value = 'View';
    document.getElementById("EntryForm").submit();
}

function setResponsePanelWidths() {
    var tbl = document.getElementById("tblResponses");
    tbl.children[0].children[0].children[0].style.width = "50%";
}

function sendBusinessReport() {
    var rbBackgroundCheckID = document.querySelector('input[name="rbBackgroundCheck"]:checked');
    if (rbBackgroundCheckID == null) {
        alert("Please select a background check to include in the report.")
        return false;
    }

    document.EntryForm.HiddenMode.value = 'SendBackgroundCheck';
    document.getElementById("EntryForm").submit();

}
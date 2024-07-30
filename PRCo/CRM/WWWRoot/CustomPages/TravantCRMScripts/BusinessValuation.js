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

function delete_button() {
    document.EntryForm.HiddenMode.value = 'Delete';
    document.getElementById("EntryForm").submit();
}

function imageDragDropped(filename) {
    if (filename != "") {
        $("#_HIDDENprbv_filename").val(filename);
        $("#_Dataprbv_filename").text(filename);
        $("#HiddenIsNewFile").val(filename);
    }
}
function businessValuationConfirmDelete() {
    if (confirm("Are you sure you want to delete this Business Valuation?")) {
        delete_button();
    }
    return false;
}

function sendValuationToRequestor() {
    document.EntryForm.HiddenMode.value = 'SendValuationToRequestor';
    document.getElementById("EntryForm").submit();
}

function sendValuationToEmail() {
    var email = prompt('Please enter the email address where you would like to send the Business Valuation');
    if (email != null) {
        document.EntryForm.HiddenMode.value = 'SendValuationToEmail';
        $("#HiddenValuationEmailAddress").val(email);
        document.getElementById("EntryForm").submit();
    }
    else {
        $("#HiddenValuationEmailAddress").val("");
    }
}
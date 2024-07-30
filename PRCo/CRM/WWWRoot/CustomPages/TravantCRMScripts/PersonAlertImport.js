/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2020

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

function validate() {
    var focusControl = null;
    var sAlertMsg = "";

    var hidAlertImportFileName = $("#hidAlertImportFileName");
    if (hidAlertImportFileName.val() == "") {
        sAlertMsg += " - Alert Import File is a required field (drag/drop one).\n";
    }

    var ddlLocationCode = $("#ddlBBID");   //document.EntryForm.ddlBBID;
    if (ddlLocationCode.val() == "") {
        sAlertMsg += " - Person's Company is a required field.\n";
        focusControl = ddlLocationCode;
    }

    if (sAlertMsg != "") {
        alert("Please correct the following issues before continuing.\n\n" + sAlertMsg);

        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    return true;
}

function importAlerts() {
    if (validate() == true) {
        document.EntryForm.HiddenMode.value = 'Import';
        pop();
        document.getElementById("EntryForm").submit();
    }

    return false;
}

function pop() {
    var ddlBBID = $("#ddlBBID");
    $("#hidBBID").val(ddlBBID.val());

    var cbReplaceExisting = $("#cbReplaceExisting");
    $("#hidReplaceExisting").val(cbReplaceExisting.is(':checked'));
}

function imageDragDropped(filename) {
    if (filename != "") {
        $("#txtAlertImportFileName").text(filename);
        $("#hidAlertImportFileName").val(filename);
    }
}
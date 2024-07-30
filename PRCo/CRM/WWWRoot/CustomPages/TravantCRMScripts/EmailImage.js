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

    var txtStartDate = document.EntryForm.prei_startdate;
    if (txtStartDate.value == "") {
        sAlertMsg += " - Start Date is a required field.\n";
        focusControl = txtStartDate;
    }

    var txtEndDate = document.EntryForm.prei_enddate;
    if (txtEndDate.value == "") {
        sAlertMsg += " - End Date is a required field.\n";
        focusControl = txtEndDate;
    }

    var ddlEmailTypeCode = document.EntryForm.prei_emailtypecode;
    if (ddlEmailTypeCode.value == "") {
        sAlertMsg += " - Email Type Code is a required field.\n";
        focusControl = ddlEmailTypeCode;
    }

    var EmailImageFileName = document.getElementById("_HIDDENprei_emailimgfilename");
    if (EmailImageFileName.value == "") {
        sAlertMsg += " - Email Image is a required field (drag/drop one).\n";
    }
    else {
        if (!EmailImageFileName.value.match(/.(jpg|jpeg|png|gif)$/i))
            sAlertMsg += " - Email Image must be a jpg, jpeg, png, or gif.\n";
    }

    var ddlLocationCode = document.EntryForm.prei_locationcode;
    if (ddlLocationCode.value == "") {
        sAlertMsg += " - Location Code is a required field.\n";
        focusControl = ddlLocationCode;
    }

    var ddlIndustry = document.EntryForm.prei_industry;
    if (ddlIndustry.value == "") {
        sAlertMsg += " - Industry is a required field.\n";
        focusControl = ddlIndustry;
    }

    var txtHyperlink = document.EntryForm.prei_hyperlink;
    if (txtHyperlink != undefined && txtHyperlink.value != "") {
        if (!validateUrl(txtHyperlink.value) && !txtHyperlink.value.toLowerCase().startsWith("mailto:"))
        {
            sAlertMsg += " - Email Image Hyperlink is not a valid url.\n";
            focusControl = txtHyperlink;
        }
    }

    if (sAlertMsg != "") {
        alert("Please correct the following issues before continuing.\n\n" + sAlertMsg);

        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    return true;
}

function validateUrl(value) {
    return /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(value);
}

function save_button() {
    if (validate() == true) {
        document.EntryForm.HiddenMode.value = 'Save';
        document.getElementById("EntryForm").submit();
    }
}

function change_button() {
    document.EntryForm.HiddenMode.value = 'Change';
    document.getElementById("EntryForm").submit();
}

function delete_button() {
    document.EntryForm.HiddenMode.value = 'Delete';
    document.getElementById("EntryForm").submit();
}

function cancel_button() {
    document.EntryForm.HiddenMode.value = 'View';
    document.getElementById("EntryForm").submit();
}

function imageDragDropped(filename) {
    if (filename != "") {
        $("#_HIDDENprei_emailimgfilename").val(filename);
        $("#_Dataprei_emailimgfilename").text(filename);
        $("#HiddenIsNewFile").val(filename);
    }
}
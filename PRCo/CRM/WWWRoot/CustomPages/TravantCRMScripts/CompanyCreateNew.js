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
    var sAlertMsg = "";

    var radioRecordType = $("input[name=optRecordType]");
    var radioRecordTypeCheckedValue = radioRecordType.filter(":checked").val();

    if (radioRecordTypeCheckedValue == null) {
        sAlertMsg += " - Either HQ or Branch must be selected.\n";
    }
    else {
        if ($("#sourceId").val() == "")
            sAlertMsg += " - Missing Source ID.\n";
        else {
            var six_digits = new RegExp('^[0-9]{6}$');
            if (!six_digits.test($("#sourceId").val())) {
                sAlertMsg += " - Invalid Source ID.\n";
            }
        }
    }

    if (sAlertMsg != "") {
        alert("Please correct the following issues before continuing.\n\n" + sAlertMsg);
        return false;
    }

    return true;
}

function save() {
    if (validate() == true) {
        document.EntryForm.HiddenMode.value = 'Save';
        document.getElementById("EntryForm").submit();
    }
}

function onOptRecordTypeClick() {
    var radioRecordType = $("input[name=optRecordType]");
    var radioRecordTypeCheckedValue = radioRecordType.filter(":checked").val();
    var hidCompanyId;

    if (radioRecordTypeCheckedValue == null) {
        $("tr.trSource").hide();
    }
    else if (radioRecordTypeCheckedValue == '1') {
        $("tr.trSource").hide();
        hidCompanyId = $("#hidCompanyId").val();
        $("#sourceId").val(hidCompanyId);
    }
    else {
        $("tr.trSource").show();
        if ($("#sourceId").val() == "") {
            hidCompanyId = $("#hidCompanyId").val();
            $("#sourceId").val(hidCompanyId);
        }
    }
}
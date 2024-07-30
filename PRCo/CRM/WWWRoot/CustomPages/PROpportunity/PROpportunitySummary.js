function initializeKeypressFunctions() {
    fld = document.EntryForm.oppo_forecast;
    if (fld != null) {
        fld.onkeypress = function () { keypressValidationHandler(keypressDecimal); };
    }
    fld = document.EntryForm.oppo_certainty;
    if (fld != null) {
        fld.onkeypress = function () { keypressValidationHandler(keypressDecimal); };
    }
    fld = document.EntryForm.oppo_signedauthreceiveddate;
    if (fld != null) {
        fld.onkeypress = function () { keypressValidationHandler(keypressDecimal); };
    }
}


function validateBasicFields() {

    var fld = null;
    var sAlertString = "";

    if (!isWebUserOppo) {
        fld = document.EntryForm.oppo_primarycompanyid;
        if (fld.value == "") {
            sAlertString += " - Company is required.\n";
        }
    }

    var type = document.EntryForm._HIDDENoppo_type.value;

    if (type == "BP") {
        fld = document.EntryForm.oppo_pradsize;
        if (fld && (fld[fld.selectedIndex].value == "")) {
            sAlertString += " - Ad Size is a required field.\n";
        }

        fld = document.EntryForm.oppo_prplacement;
        if (fld && (fld[fld.selectedIndex].value == "")) {
            sAlertString += " - Ad Placement is a required field.\n";
        }

        fld = document.EntryForm.oppo_prcertainty;
        if (fld && (fld[fld.selectedIndex].value == "")) {
            sAlertString += " - Certainty is a required field.\n";
        }

        fld = document.EntryForm.oppo_forecast;
        if (fld && (fld.value == "")) {
            sAlertString += " - Forecast Amount is a required field.\n";
        }

        fld = document.EntryForm.oppo_prtargetstartyear;
        if (fld && (fld[fld.selectedIndex].value == "")) {
            sAlertString += " - Target Start Year is a required field.\n";
        }

        fld = document.EntryForm.oppo_prtargetstartmonth;
        if (fld && (fld[fld.selectedIndex].value == "")) {
            sAlertString += " - Target Start Month is a required field.\n";
        }
    }


    fld = document.EntryForm.oppo_prpipeline;
    if (fld && (fld[fld.selectedIndex].value == "")) {
        sAlertString += " - Pipeline is a required field.\n";
    }

    fld = document.EntryForm.oppo_prtrigger;
    if (fld && (!fld.disabled)) {
        if (fld[fld.selectedIndex].value == "") {
            sAlertString += " - Trigger is a required field.\n";
        }
    }

    fld = document.EntryForm.oppo_source;
    if (fld && (fld[fld.selectedIndex].value == "")) {
        sAlertString += " - Source is a required field.\n";
    }


    if ((type == "NEWM") ||
        (type == "UPG")) {
        //fld = document.EntryForm.oppo_prtype;
        //if (fld && (fld[fld.selectedIndex].value == "")) {
        //    sAlertString += " - BBS Level is a required field.\n";
        //}

        //fld = document.EntryForm.oppo_forecast;
        //if (fld && (fld.value == "")) {
        //    sAlertString += " - Forecast Amount is a required field.\n";
        //}

        //fld = document.EntryForm.oppo_prcertainty;
        //if (fld && (fld[fld.selectedIndex].value == "")) {
        //    sAlertString += " - Certainty is a required field.\n";
        //}
    }





    fld = document.EntryForm.oppo_note;
    if (fld && (fld.value == "")) {
        sAlertString += " - Note/Details is required.\n";
    }

    return sAlertString;
}

function validateDealLost() {
    var sAlertString = "";

    fld = document.EntryForm.oppo_prlostreason;
    if (fld.value == "") {
        sAlertString += " - Close Reason is required if the opportunity is not sold.\n";
    }

    return sAlertString;
}



function validateSold() {
    var sAlertString = "";

    fld = document.EntryForm.oppo_signedauthreceiveddate;
    if (fld != null) {
        if (fld.value == "") {
            sAlertString += " - Signed Auth Received Date is required.\n";
        }
        else if (!isValidDate(fld.value)) {
            sAlertString += " - Signed Auth Received Date must be a valid date.\n";
        }
    }
    return sAlertString;
}

function save() {
    var sAlertString = validateBasicFields();

    var fld = document.getElementById("oppo_status");
    stageValue = fld[fld.selectedIndex].value;

    if (stageValue == "NotSold") {
        sAlertString += validateDealLost();
    }

    if (stageValue == "Sold") {
        sAlertString += validateSold();
    }

    if (sAlertString != "") {
        alert("The following fields are required:\n\n" + sAlertString);
        return;
    }    
    document.EntryForm.submit();
}


function toggleTrigger() {
    document.getElementById("oppo_prtrigger").disabled = document.getElementById("_IDoppo_pradrenewal").checked
}

function ToggleStatus() {
    fld = document.getElementById("oppo_status");

    if (fld[fld.selectedIndex].value == "NotSold") {
        document.getElementById("oppo_prlostreason").disabled = false;
    } else {
        document.getElementById("oppo_prlostreason").disabled = true;
    }

    if (document.getElementById("oppo_signedauthreceiveddate") != null) {
        if (fld[fld.selectedIndex].value == "Sold") {
            document.getElementById("oppo_signedauthreceiveddate").disabled = false;
            document.getElementById("_Caloppo_signedauthreceiveddate").disabled = false;
        } else {
            document.getElementById("oppo_signedauthreceiveddate").disabled = true;
            document.getElementById("_Caloppo_signedauthreceiveddate").disabled = true;
        }
    }
}

function initializePage() {
    sContents = "<span>";
    sContents += "<img class=ButtonItem align=left border=0 src=\"../../img/Buttons/new.gif\" " +
        " onclick=\"javascript:timestampRecordOfActivity();\">";
    sContents += "<span class=ButtonItem onclick=\"javascript:timestampRecordOfActivity();\">";
    sContents += "Add Timestamp</span>";
    sContents += "</span>";
    AppendCell("_Captoppo_prlostreason", sContents);


    var type = document.EntryForm._HIDDENoppo_type.value;
    if (type == "BP" || type=="DA")
    {
        document.EntryForm.oppo_note.cols = 160;
        document.EntryForm.oppo_note.rows = 7;
    }
    else
    {
        document.EntryForm.oppo_note.cols = 120;
        document.EntryForm.oppo_note.rows = 7;
    }
}

function timestampRecordOfActivity() {
    var obj = document.EntryForm.oppo_note;
    sValue = "";
    if (obj) {

        sValue = new String(getDatetimeAsString() + ': ');
        obj.value = sValue + "\n" + obj.value;
    }
}
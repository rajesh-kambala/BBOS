
function validatePhonePreferredInternal(eCheckBox) {

    if (eCheckBox.checked) {
        var cbOtherPhonePreferredInternal = null;
        var PersonID = eCheckBox.name.substr(21);

        // Which one is this?
        if (eCheckBox.name.indexOf("cbPPreferredInternal_") == 0) {
            cbOtherPhonePreferredInternal = document.getElementById("cbCPreferredInternal_" + PersonID);
        } else {
            cbOtherPhonePreferredInternal = document.getElementById("cbPPreferredInternal_" + PersonID);
        }

        cbOtherPhonePreferredInternal.checked = false;
    }
}


function validatePhonePreferredPublished(eCheckBox) {

    if (eCheckBox.checked) {
    
        var PersonID = eCheckBox.name.substr(22);

        var cbThisPhonePublish = null;
        var cbOtherPhonePreferredPublish = null;


        // Which one is this?
        if (eCheckBox.name.indexOf("cbPPreferredPublished_") == 0) {
            cbThisPhonePublish = document.getElementById("cbPPublish_" + PersonID);
            cbOtherPhonePreferredPublish = document.getElementById("cbCPreferredPublished_" + PersonID);
        } else {
            cbThisPhonePublish = document.getElementById("cbCPublish_" + PersonID);
            cbOtherPhonePreferredPublish = document.getElementById("cbPPreferredPublished_" + PersonID);
        }

        cbThisPhonePublish.checked = true;
        cbOtherPhonePreferredPublish.checked = false;
    }
}


function save() {

    if (validate()) {
        document.forms[0].submit();
    }
}

function validate() {

    var szErrors = "";
    var bEmailAllFieldsErr = false;
    var bEmailValidErr = false;
    var bPhoneErr = false;
    var bPhonePreferredInternalTurnedOff = false;
    
    var oPersonIDs = document.getElementsByName("txtPersonID");
    for (var i = 0; i < oPersonIDs.length; i++) {

        var sPersonID = oPersonIDs[i].value;

        // Validate the Email controls
        var txtEmailID = document.getElementById("txtEmailID_" + sPersonID);
        var txtEmail = document.getElementById("txtEmail_" + sPersonID);
        var cbEmailPublish = document.getElementById("cbEmailPublish_" + sPersonID);

        if (!bEmailAllFieldsErr) {
            if ((cbEmailPublish.checked) && (txtEmail.value == "")) {
                szErrors += "\n - One or more email addresses have the publish flag checked, but do not have an email address specified.";
                bEmailAllFieldsErr = true;
            }
        }

        if (!bEmailValidErr) {
            if (!isValidEMail(txtEmail.value)) {
                szErrors += "\n - One or more email addresses are not in a valid Internet format.";
                bEmailValidErr = true;
            }

            if (txtEmail.value.indexOf(",") !== -1) {
                szErrors += "\n - One or more email addresses contains a comma which is invalid.";
                bEmailValidErr = true;
            }
        }

        if (!bPhoneErr) {
            sPhoneErr = validatePhoneFields("P", sPersonID);
            if (sPhoneErr.length == 0) {
                sPhoneErr = validatePhoneFields("C", sPersonID);
            }

            if (sPhoneErr.length > 0) {
                szErrors += "\n - " + sPhoneErr;
                bPhoneErr = true;
            }
        }

        if (!bPhonePreferredInternalTurnedOff) {
            var txtWorkOldValue = document.getElementById("txtPPreferredInternal_" + sPersonID);
            var cbWorkPreferredInternal = document.getElementById("cbPPreferredInternal_" + sPersonID);

            var txtCellOldValue = document.getElementById("txtCPreferredInternal_" + sPersonID);
            var cbCellPreferredInternal = document.getElementById("cbCPreferredInternal_" + sPersonID);

            // If both PreferredInternal checkboxes are off, but when the page was loaded one
            // of them was on, warn the user.
            if ((cbWorkPreferredInternal.checked == false) &&
                (cbCellPreferredInternal.checked == false) &&
                ((txtWorkOldValue.value == "checked") || (txtCellOldValue.value == "checked"))) {
                bPhonePreferredInternalTurnedOff = true;
            }
        }        

        
        
    }

    if (szErrors.length > 0) {
        alert("Please correct the following errors:\n" + szErrors);
        return false;
    }

    if (bPhonePreferredInternalTurnedOff) {
        return confirm("The phone numbers for one or more persons have had their 'Preferred Internal' flag turned off.  To continue saving, click 'OK' and be sure to review the person's phone numbers to set one as the 'Preferred Internal'.  Otherwise click 'Cancel' to remain on this page.");
    }

    return true;
}


function validatePhoneFields(sType, sPersonID) {

    var txtCountryCode = document.getElementById("txt" + sType + "CountryCode_" + sPersonID);
    var txtAreaPhone = document.getElementById("txt" + sType + "AreaCode_" + sPersonID);
    var txtNumber = document.getElementById("txt" + sType + "Phone_" + sPersonID);
    var txtExtention = document.getElementById("txt" + sType + "Ext_" + sPersonID);
    var cbPublish = document.getElementById("cb" + sType + "Publish_" + sPersonID);
    var cbPreferredPublished = document.getElementById("cb" + sType + "PreferredPublished_" + sPersonID);
    var cbPreferredInternal = document.getElementById("cb" + sType + "PreferredInternal_" + sPersonID);

    // If any of these values are set, then make sure our
    // minimums are met.
    if ((txtCountryCode.value.length > 0) ||
            (txtAreaPhone.value.length > 0) ||
            (txtNumber.value.length > 0) ||
            (cbPublish.checked) ||
            (cbPreferredPublished.checked) ||
            (cbPreferredInternal.checked)) {

        if ((txtCountryCode.value.length == 0) ||
            (txtAreaPhone.value.length == 0) ||
            (txtNumber.value.length == 0)) {
            return "One or more phone numbers is missing the country code, area code, and/or the phone number.";
        }

    }

    return "";
}


//
// Determines if the value is a
// valid Internet e-mail address.
//
function isValidEMail(szEmail) {

    if (szEmail.length == 0) {
        return true;
    }

    var iAtSignCount = 0;
    var iPosofAtSign = 0;
    var iPosofRightMostDot = 0;
    var bSpaceFound = false;

    for (iIndex = 0; iIndex <= szEmail.length - 1; iIndex++) {
        if (szEmail.charAt(iIndex) == '@') {
            iAtSignCount = iAtSignCount + 1;
            iPosofAtSign = iIndex;
        }

        if (szEmail.charAt(iIndex) == '.') {
            iPosofRightMostDot = iIndex;
        }

        if (szEmail.charAt(iIndex) == ' ') {
            bSpaceFound = true;
        }
    } // End For

    // If we don''t have a single '@' character or if
    // the "." is not to the right of the '@' then this is
    // not a valid SMTP e-mail address.
    if ((iAtSignCount != 1) ||
	    (iPosofAtSign > iPosofRightMostDot) ||
		(bSpaceFound)) {
        return false;
    }

    return true;
}

function Sort(sSortField) {

    if (sSortField == document.getElementById("hidCurrentOrderBy").value) {
        return;
    }

    if (confirm("Resorting the grid will cause all data entered into the form to be lost.  Do you want to continue?")) {
        document.location = document.getElementById("hidSortURL").value + sSortField;
        //alert(document.all.hidSortURL.value + sSortField);
    }

}
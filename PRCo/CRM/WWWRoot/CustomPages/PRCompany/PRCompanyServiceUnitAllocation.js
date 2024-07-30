var isNew = false;

function validate() {

    var sValidationErrors = "";
    var oFocus = null;

    var eStartDate = document.getElementById("prun_startdate");
    var eExpirationDate = document.getElementById("prun_expirationdate");

    if (!isValidDate(eStartDate.value)) {
        sValidationErrors += " - A valid Start Date is required.\n";
        if (oFocus != null)
            oFocus = eStartDate;
    }

    if (!isValidDate(eExpirationDate.value)) {
        sValidationErrors += " - A valid Expiration Date is required.\n";
        if (oFocus != null)
            oFocus = eExpirationDate;
    }

    // If we made it this far without a validation error, then both dates are
    // valid.
    if (sValidationErrors == "") {
        var startDate = new Date(eStartDate.value);
        var expirationDate = new Date(eExpirationDate.value);

        if (startDate.getTime() >= expirationDate.getTime()) {
            sValidationErrors += " - The Start Date must come before the Expiration Date.\n";
        }
    }


    var eUnitsAllocated = document.getElementById("prun_unitsallocated");
    if (eUnitsAllocated.value == "") {
        sValidationErrors += " - A valid Units Allocated is required.\n";
        if (oFocus != null)
            oFocus = eUnitsAllocated;
    } else {
        var unitsAllocated = new Number(eUnitsAllocated.value);
        if (isNaN(unitsAllocated)) {
            sValidationErrors += " - A valid Units Allocated is required.\n";
            if (oFocus != null)
                oFocus = eUnitsAllocated;
        } else {
            if (unitsAllocated % 1 != 0) {
                sValidationErrors += " - A valid Units Allocated is required.\n";
                if (oFocus != null)
                    oFocus = eUnitsAllocated;
            }
        }
    }

    if (sValidationErrors != "") {
        alert("Please correct the following errors::\n\n"
              + sValidationErrors);

        if (oFocus != null)
            oFocus.focus();
        return false;
    }

    return true;
}

var bSaveFlag = false;
function save() {

    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;

    if (validate() == false) {
        bSaveFlag = false;
    } else {
        document.EntryForm.submit();
    }
}


function onAllocationTypeChange() {

    if (!isNew) {
        return;
    }


    var eAllocationType = document.getElementById("prun_allocationtypecode");
    var eStartDate = document.getElementById("prun_startdate");
    var eExpirationDate = document.getElementById("prun_expirationdate");

    var startDate = new Date(eStartDate.value);
    var expirationDate = null;

    if (eAllocationType.options[eAllocationType.selectedIndex].value == "A") {
        expirationDate = new Date();
        expirationDate.setMonth(startDate.getMonth() + 13);
        expirationDate.setDate(1);
    }

    if (eAllocationType.options[eAllocationType.selectedIndex].value == "M") {
        expirationDate = new Date(startDate.getFullYear() + 1,
                                  0,
                                  1);
    }

    if (expirationDate != null) {
        eExpirationDate.value = (expirationDate.getMonth() + 1).zp(2) + "/" + expirationDate.getDate().zp(2) + "/" + expirationDate.getFullYear();
    }
}
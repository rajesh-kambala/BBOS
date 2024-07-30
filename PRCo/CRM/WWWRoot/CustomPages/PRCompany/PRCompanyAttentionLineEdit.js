/***********************************************************************
***********************************************************************
Copyright Produce Report Company 2010

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
function pageLoad(sender, args) {
    var eCCFax = $find("ccFax");
    eCCFax.add_populated(onPopulated);

    var eCCEmail = $find("ccEmail");
    eCCEmail.add_populated(onPopulated);
}


function onPopulated() {
    toggleDelivery();
} 


function toggleAddressee() {
    if (document.getElementById('rbAddresseePerson').checked) {
        document.getElementById('ddlPerson').disabled = false;
        document.getElementById('txtCustomLine').disabled = true;

        document.getElementById('hidAddressee').value = "Person";

    } else {
        document.getElementById('ddlPerson').disabled = true;
        document.getElementById('txtCustomLine').disabled = false;

        document.getElementById('ddlPerson').selectedIndex = 0;

        document.getElementById('hidAddressee').value = "Custom";
    }

    // Now trigger the cascading drop downs to update
    var eCCFax = $find("ccFax");
    if (eCCFax != null) {
        eCCFax._onParentChange(null, null);
    }

    var eCCEmail = $find("ccEmail");
    if (eCCEmail != null) {
        eCCEmail._onParentChange(null, null);
    }
}

function toggleDelivery() {
    if (document.getElementById('rbDeliveryAddress').checked) {
        document.getElementById('ddlAddress').disabled = false;
        document.getElementById('ddlFax').disabled = true;
        document.getElementById('ddlEmail').disabled = true;

        document.getElementById('hidDelivery').value = "Address";
    }
    if (document.getElementById('rbDeliveryFax').checked) {
        document.getElementById('ddlAddress').disabled = true;
        document.getElementById('ddlFax').disabled = false;
        document.getElementById('ddlEmail').disabled = true;

        document.getElementById('hidDelivery').value = "Fax";
    }
    if (document.getElementById('rbDeliveryEmail').checked) {
        document.getElementById('ddlAddress').disabled = true;
        document.getElementById('ddlFax').disabled = true;
        document.getElementById('ddlEmail').disabled = false;

        document.getElementById('hidDelivery').value = "Email";
    }

    if (document.getElementById('rbDeliveryBBOS').checked) {
        document.getElementById('ddlAddress').disabled = true;
        document.getElementById('ddlFax').disabled = true;
        document.getElementById('ddlEmail').disabled = true;

        document.getElementById('hidDelivery').value = "BBOS";
    }

    setDeliveryOptions();
}

function initControls() {
    if (document.getElementById('hidAddressee').value == "Person") {
        document.getElementById('rbAddresseePerson').checked = true;
    } else {
        document.getElementById('rbAddresseeCustom').checked = true;
    }

    if (document.getElementById('hidDelivery').value == "Address") {
        document.getElementById('rbDeliveryAddress').checked = true;
    }
    if (document.getElementById('hidDelivery').value == "Fax") {
        document.getElementById('rbDeliveryFax').checked = true;
    }
    if (document.getElementById('hidDelivery').value == "Email") {
        document.getElementById('rbDeliveryEmail').checked = true;
    }
    if (document.getElementById('hidDelivery').value == "BBOS") {
        document.getElementById('rbDeliveryBBOS').checked = true;
    }


    setDeliveryOptions();

    if (document.getElementById('hidSkipAddresseeInit').value == "false") {
        toggleAddressee();
    }
    toggleDelivery();
}


function setDeliveryOptions() {
    if (document.getElementById('hidAddressEnabled').value == "false") {
        document.getElementById('rbDeliveryAddress').checked = false;
        document.getElementById('rbDeliveryAddress').disabled = true;
    }

    if (document.getElementById('hidFaxEnabled').value == "false") {
        document.getElementById('rbDeliveryFax').checked = false;
        document.getElementById('rbDeliveryFax').disabled = true;
    }

    if (document.getElementById('hidEmailEnabled').value == "false") {
        document.getElementById('rbDeliveryEmail').checked = false;
        document.getElementById('rbDeliveryEmail').disabled = true;
    }

    if (document.getElementById('hidBBOSEnabled').value == "false") {
        document.getElementById('rbDeliveryBBOS').checked = false;
        document.getElementById('rbDeliveryBBOS').disabled = true;
    }    
}

function onSave() {

    // If this item is being disabled, then there is nothing
    // to validate.
    if (document.getElementById('cbDisabled').checked) {
        return true;
    }

    if ((document.getElementById('rbDeliveryAddress').checked == false) &&
        (document.getElementById('rbDeliveryFax').checked == false) &&
        (document.getElementById('rbDeliveryEmail').checked == false) &&
        (document.getElementById('rbDeliveryBBOS').checked == false)) {
        alert("A delivery option must be selected.");
        return false;
    }

    var szMsg = "";
    var bChange = false;
    var dllControl;
    var eHidden;

    if (document.getElementById('rbAddresseeCustom').checked) {
        eHidden = document.getElementById("hidCustom");

        if (document.getElementById('hidOldAddressee').value != "Custom") {
            bChange = true;
        } else {
            if (eHidden.value != "") {
                if (document.getElementById('txtCustomLine').value != eHidden.value) {
                    bChange = true;
                }
            }
        }
    }

    if (document.getElementById('rbAddresseePerson').checked) {
        dllControl = document.getElementById('ddlPerson');
        eHidden = document.getElementById("hidPersonID");

        if (dllControl.options[dllControl.selectedIndex].value == "0") {
            alert("A valid person must be selected when the Addressee is set to 'Person'.");
            return false;
        }

        if (document.getElementById('hidOldAddressee').value != "Person") {
            bChange = true;
        } else {
            if (eHidden.value != "0") {
                if (dllControl.options[dllControl.selectedIndex].value != eHidden.value) {
                    bChange = true;
                }
            }
        }
    }

    if (document.getElementById('rbDeliveryAddress').checked) {

        dllControl = document.getElementById('ddlAddress');
        eHidden = document.getElementById("hidAddressID");

        if (dllControl.options[dllControl.selectedIndex].value == "0") {
            alert("A valid address must be selected when the Delivery is set to 'Address'.");
            return false;
        }

        if (document.getElementById('hidOldDelivery').value != "Address") {
            bChange = true;
        } else {
            if (eHidden.value != "0") {
                if (dllControl.options[dllControl.selectedIndex].value != eHidden.value) {
                    bChange = true;
                }
            }
        }
    }

    if (document.getElementById('rbDeliveryFax').checked) {
        dllControl = document.getElementById('ddlFax');
        eHidden = document.getElementById("hidPhoneID");

        if (dllControl.options[dllControl.selectedIndex].value == "0") {
            alert("A valid FAX number must be selected when the Delivery is set to 'Fax'.");
            return false;
        }

        if (document.getElementById('hidOldDelivery').value != "Fax") {
            bChange = true;
        } else {
            if (eHidden.value != "0") {
                if (dllControl.options[dllControl.selectedIndex].value != eHidden.value) {
                    bChange = true;
                }
            }
        }
    }

    if (document.getElementById('rbDeliveryEmail').checked) {
        dllControl = document.getElementById('ddlEmail');
        eHidden = document.getElementById("hidEmailID");

        if (dllControl.options[dllControl.selectedIndex].value == "0") {
            alert("A valid email address must be selected when the Delivery is set to 'Email'.");
            return false;
        }


        if (document.getElementById('hidOldDelivery').value != "Email") {
            bChange = true;
        } else {
            if (eHidden.value != "0") {
                if (dllControl.options[dllControl.selectedIndex].value != eHidden.value) {
                    bChange = true;
                }
            }
        }
    }

    if ((bChange) &&
        (document.getElementById('rbDeliveryBBOS').checked == false)) {
        if (confirm("All items with this attention line and delivery method will be updated.\n\n - Click OK to update all items.\n - Click Cancel to update only this single item.")) {
            document.getElementById("hidUpdateOthers").value = "true";
        }
    }


    return true;
}


function onDelete() {
    return confirm("Are you sure you want to delete this attenion line item?  This is different form disabling it.  Once the attention line item is deleted, it cannot be restored.");
}
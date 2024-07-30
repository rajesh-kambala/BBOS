function handleEnterKey() {
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if ((keycode == '13') &&
        (eent.srcElement.type != 'textarea')) {
        save();
        event.cancelBubble = true;
        event.returnValue = false;
        return false;
    }
}


function validateTransaction()
{
    var szErrors = "";
    
    // this requires an authorized by user id or authorization information
    if (document.getElementById("prtx_authorizedbyid").value == '' && document.getElementById("prtx_authorizedinfo").value  == '')
    {
        szErrors += " - Either an Authorized By User or Authorization Information must be entered.\n";
    }
    
    if (document.getElementById("prtx_explanation").value == '')
    {
        szErrors += " - An Explanation must be entered.\n";
    }

    if (document.getElementById("prtx_notificationtype").value == '') {
        szErrors += " - A Notification Type must be entered.\n";
    }


    if (document.getElementById("prtx_notificationstimulus").value == '') {
        szErrors += " - A Notification Stimulus must be entered.\n";
    }


    if (ValidatePersons() == false) {
        szErrors += " - Each selected person must have at least one explanation checkbox checked.\n";
    }        
    
    if (szErrors.length > 0) {
        alert("Please correct the following errors:\n\n" + szErrors);
        return false;
    }
    
    // Enable our field so that it gets saved.
    if (document.getElementById("_HIDDENprtx_status").value == 'C') {
        document.getElementById("prtx_explanation").disabled = false;
    }
        
    return true;
}

var bSaveFlag = false;
function save() {

    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;

    if (validateTransaction() == false) {
        bSaveFlag = false;
    } else {
        document.EntryForm.submit();
    }
}



function openCloseTranWindow(szURL) {
    window.open(szURL,
                "winViewListing",
                "location=no,menubar=no,status=no,toolbar=no,scrollbars=no,resizable=yes,width=600,height=600", true);
} 


// copies the values from a company transaction row to the transction screen fields
function copyTrx(rowId){
    // lookup the row in the transaction table
    var tbl = document.getElementById("tbl_OpenTrxs");
    row = tbl.rows(rowId);
    if (row.cells(1).AuthId != "undefined"){
        NavUrlprtx_authorizedbyid(row.cells(1).AuthId)
    }
    else
    {
        Clearprtx_authorizedbyid(true);
        document.EntryForm.prtx_authorizedbyidTEXT.value = "";
    }
    document.getElementById("prtx_authorizedinfo").value = row.cells(2).innerText;
    document.getElementById("prtx_explanation").value = row.cells(3).innerText;
}

function TogglePersons() {
    var bChecked = document.all.cbAll.checked;

    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
	        (oCheckboxes[i].id.indexOf("cbPersonID_") == 0)) {
            
            if (oCheckboxes[i].disabled == false) {
                oCheckboxes[i].checked = bChecked;
            }
        }
    }
}


// Ensures at least one explanation checkbox is selected
// for each selected person.
function ValidatePersons() {

    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
	        (oCheckboxes[i].id.indexOf("cbPersonID_") == 0)) {

            if ((oCheckboxes[i].disabled == false) &&
                (oCheckboxes[i].checked)) {

                var szPersonID = oCheckboxes[i].id.substring(11);

                if ((!document.getElementById("cbCI_" + szPersonID).checked) &&
                    (!document.getElementById("cbNLC_" + szPersonID).checked) &&
                    (!document.getElementById("cbTC_" + szPersonID).checked) &&
                    (!document.getElementById("cbCopy_" + szPersonID).checked)) {

                    if (document.getElementById("cbOther_" + szPersonID).checked) {
                        if (document.getElementById("txtOther_" + szPersonID).value.length == 0) {
                            return false;
                        }
                    } else {
                        return false;
                    }
                }
            }
        }
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
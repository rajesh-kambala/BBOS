/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

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
var bIsNew = false;
var dupChecking = false;
var sPeliId = "";

var txtSelectedRoles = null;

// these get set to prevent the associated fields from getting overwritten if already populated
var sOrigDLTitle = null;
var sOrigPublishedTitle = null;
var bContactInfoExists = false;
var bWebUserExists = false;
var bAttentionLineExists = false;
var bActiveOnOtherCompanies = false;
var companyTypeCode = "";

var sCompanyLookupsURL = "";
var sAssignedCompanyHeadOfRoles = "";

var chkRoleSelect_E = null;//Executive
var chkRoleSelect_O = null;//operations
var chkRoleSelect_F = null;//Finance
var chkRoleSelect_S = null;//Sales
var chkRoleSelect_B = null;//Buying/Purchasing
var chkRoleSelect_M = null;//Manager
var chkRoleSelect_T = null;//Transportation/Dispatch
var chkRoleSelect_K = null;//Marketing
var chkRoleSelect_C = null; //Credit
var chkRoleSelect_A = null; //IT
var chkRoleSelect_I = null; //Administration

// these are the commonly set Role Assignments
function initializeRoleCheckboxes() {
    chkRoleSelect_E = document.getElementById("_chkRoleSelect_E");//Executive
    chkRoleSelect_O = document.getElementById("_chkRoleSelect_O");//operations
    chkRoleSelect_F = document.getElementById("_chkRoleSelect_F");//Finance
    chkRoleSelect_S = document.getElementById("_chkRoleSelect_S");//Sales
    chkRoleSelect_B = document.getElementById("_chkRoleSelect_B");//Buying/Purchasing
    chkRoleSelect_M = document.getElementById("_chkRoleSelect_M");//Manager
    chkRoleSelect_T = document.getElementById("_chkRoleSelect_T");//Transportation/Dispatch
    chkRoleSelect_K = document.getElementById("_chkRoleSelect_K");//Marketing
    chkRoleSelect_C = document.getElementById("_chkRoleSelect_C"); //Credit
    chkRoleSelect_A = document.getElementById("_chkRoleSelect_A"); //Administration
    chkRoleSelect_I = document.getElementById("_chkRoleSelect_I"); //IT
}

function validate() {
    var focusControl = null;
    var sAlertMsg = "";
    var cboPRTitleCode = document.EntryForm.peli_prtitlecode;
    var sSelectedTitleCode = cboPRTitleCode[cboPRTitleCode.selectedIndex].value;

    var txtCompanyId = document.EntryForm.peli_companyid;
    if (txtCompanyId.value == "") {
        sAlertMsg += "Company is a required field.\n";
        var focusableCompanyId = document.EntryForm.peli_companyidTEXT;
        focusControl = focusableCompanyId;
    }
    if (sSelectedTitleCode == "") {
        sAlertMsg += "Generic Title is a required field.\n";
        if (focusControl == null)
            focusControl = cboPRTitleCode;
    }

    // For certain generic titles, a responsibly connected role is required.
    cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
    sSelectedTitleDesc = cboPRTitleCode[cboPRTitleCode.selectedIndex].innerText;
    sSelectedOwnershipCode = cboPROwnershipRole[cboPROwnershipRole.selectedIndex].value;



    var companyName = document.EntryForm.peli_companyidTEXT.value;

    if (companyName.indexOf(" (B),") > -1) {
        companyTypeCode = "B";
    }

    if (companyName.indexOf(" (H),") > -1) {
        companyTypeCode = "H";
    }


    if (companyTypeCode == "B") {

        if (sSelectedOwnershipCode != 'RCR') {
            sAlertMsg += "An Ownership Role is not allowed on branch locations.\n";
            if (focusControl == null)
                focusControl = cboPROwnershipRole;

        }


    } else {


        if (',MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,TRE,'.indexOf(',' + sSelectedTitleCode + ',') > -1) {
            if (sSelectedOwnershipCode == 'RCR') {

                sAlertMsg += "When a Generic Title of '" + sSelectedTitleDesc + "' is selected, an Ownership Role is required.\n";
                if (focusControl == null)
                    focusControl = cboPROwnershipRole;
            }
        }
    }

    var nPct = 0;
    peli_prpctowned = document.EntryForm.peli_prpctowned;
    if (peli_prpctowned)
        nPct = parseFloat(peli_prpctowned.value);
    if (!isNaN(nPct) && nPct > 100) {
        sAlertMsg += "Pct Owned cannot exceed 100%.\n";
        if (focusControl == null)
            focusControl = peli_prpctowned;
    }

    if (sAlertMsg != "") {
        alert("The following changes are required to save the Person History record:\n\n" + sAlertMsg);
        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    // check the company ownership percentage
    // this will warn the user if > 100% but will not prevent the save
    // 3.3 Release: Will prevent the save
    var nTotalPct = 0;
    var nOrigPct = 0;
    var hdnCOP = document.getElementById("hdn_CompanyOwnershipPercent");
    if (hdnCOP) {
        nTotalPct = parseFloat(hdnCOP.value);
    }

    var peli_HIDDENprpctowned = document.getElementById("_HIDDENpeli_prpctowned");
    if (peli_HIDDENprpctowned)
        nOrigPct = parseFloat(peli_HIDDENprpctowned.value);

    var nNewTotal = nTotalPct - nOrigPct + nPct;
    if (!isNaN(nNewTotal) && nNewTotal > 100) {
        alert("Total Ownership Percentage for all company personnel equals " + nNewTotal + "%. This value should not exceed 100%.");
    }

    return true;
}

function save() {
    if (validate() == true) {
        // if this selection is disabled, we need to update accpac's hidden field to get
        // the correct value saved.
        cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
        if (cboPROwnershipRole.disabled) {
            hdnPROwnershipRole = document.EntryForm._HIDDENpeli_prownershiprole;
            hdnPROwnershipRole.value = cboPROwnershipRole.value;
        }

        //document.all("_HIDDENpeli_prrole").value = document.all("peli_prrole");
        document.EntryForm.submit();
    }
    dupChecking = false;
}

function autoTitleChange() {


    if (!confirm("This process will automatically create a new person history record for the new title.  Are you sure you want to continue?")) {
        return;
    }

    var hidAutoTitleChange = document.createElement("input");
    hidAutoTitleChange.type = "hidden";
    hidAutoTitleChange.name = "hidAutoTitleChange";
    hidAutoTitleChange.value = "Y";
    document.EntryForm.appendChild(hidAutoTitleChange);

    document.EntryForm.submit();
}

function onRoleCheckboxClick() {
    chkRole = window.event.srcElement;
    handleRoleCheckboxClick(chkRole.getAttribute("RoleCode"), chkRole.checked);
}

function handleRoleCheckboxClick(sRoleCode, bChecked) {
    if (txtSelectedRoles == null)
        txtSelectedRoles = document.all("_txt_SelectedRoles");

    sSelectedRoles = txtSelectedRoles.value;
    if (bChecked) {
        if (sSelectedRoles.indexOf("," + sRoleCode + ",") == -1) {
            if (sSelectedRoles == "")
                sSelectedRoles = ",";
            sSelectedRoles = sSelectedRoles + sRoleCode + ",";
        }
    }
    else {
        sSelectedRoles = sSelectedRoles.replace("," + sRoleCode + ",", ",");
    }
    txtSelectedRoles.value = sSelectedRoles;

}

function handleCompanyChange() {
    sRoles = "";
    var oPRCompanyId = document.EntryForm.peli_companyid;
    //var oPRCompanyId = document.EntryForm._HIDDENpeli_companyid;
    var sCompanyId = oPRCompanyId.value;

    if (sCompanyId == "") {
        hdnCOP = document.all["hdn_CompanyOwnershipPercent"];
        hdnCOP.value = "0";
        var tbl_PctWarning = document.getElementById("tbl_PctWarning");
        if (tbl_PctWarning)
            tbl_PctWarning.style.display = "none";
        return;
    }

    retrieveAssignedCompanyRolesById(sCompanyId);

    // this will recheck th etotal company percentage 
    checkCompanyOwnership(sCompanyId);
}

function handleStatusChange() {
    var cboStatus = window.event.srcElement;
    // get the value
    var nSelectedStatus = cboStatus.options[cboStatus.selectedIndex].value;

    handleStatusChange2(nSelectedStatus);
}

function handleStatusChange2(nSelectedStatus) {

    // No Longer Connected
    if (nSelectedStatus == 1)
        document.getElementById('Button_Save').style.display = "inline-block";

    var sAlertMsg = "";

    if (nSelectedStatus == 2 ||
        nSelectedStatus == 3 ||
        nSelectedStatus == 4) {
        if (bAttentionLineExists) {
            sAlertMsg += " - This person is associated with an attention line.  That attention line must be reassigned before this person can be updated to ";
            if (nSelectedStatus == 2)
                sAlertMsg += "Inactive.";
            else if (nSelectedStatus == 3)
                sAlertMsg += "No Longer Connected.";
            else if (nSelectedStatus == 4)
                sAlertMsg += "Removed by Company.";

            document.getElementById('Button_Save').style.display = "none";

            sAlertMsg += "\n\n";
        }
    }

    if ((nSelectedStatus == 3) ||
        (nSelectedStatus == 4)) {
        // clear the checked Roles for the Genreal Roles
        clearCheckedRoles();
        enableAllRoles(false);
        sAlertMsg += "All Company Roles have been cleared.\n\n";

        if (bContactInfoExists) {
            sAlertMsg += " - Contact Info (Address, Phone, Email) exists for this person.  This information should be reviewed.\n\n";
        }

        if (nSelectedStatus == 3) {
            if (bHasLSSLicense)
                sAlertMsg += " - This person has a LSS License.  It should be reassigned.\n\n";
            else if (bHasBBOSLicense)
                sAlertMsg += " - This person has a BBOS License.  It should be reassigned.\n\n";
            else if (bHasLSSLicense && bHasBBOSLicense)
                sAlertMsg += " - This person has both a LSS and BBOS License.  They should be reassigned.\n\n";
        }
    }
    else {
        enableAllRoles(true);
    }

    if (sAlertMsg != "")
        alert(sAlertMsg);
}

function handleExitReasonChange() {

    var cboExitReason = document.getElementById("peli_prexitreason");
    var nSelectedExitReason = cboExitReason.options[cboExitReason.selectedIndex].value;

    if (nSelectedExitReason == "D") {

        var cboStatus = document.getElementById("peli_prstatus");
        var nSelectedStatus = cboStatus.options[cboStatus.selectedIndex].value;

        if ((nSelectedStatus != "3") &&
            (nSelectedStatus != "4")) {

            SelectDropdownItemByValue("peli_prstatus", "3");
            handleStatusChange2("3");

            var sAlertMsg = "";
            if (bActiveOnOtherCompanies) {
                sAlertMsg += "Since this person is deceased, their status has been changed to 'No Longer Connected'.  This person is also associated with other companies so please update those person history records as well.";
            }

            if (sAlertMsg != "")
                alert(sAlertMsg);
        }
    }
}

function handleSReceiveMethodChange() {
    var cbo = window.event.srcElement;
    // get the value
    nSelectedValue = cbo.options[cbo.selectedIndex].value;
    var sAlertMsg = "";

    // Fax
    if (nSelectedValue == 1)
        sAlertMsg = "After saving, verify that the person has a valid fax number.\n";
    else if (nSelectedValue == 2)
        sAlertMsg = "After saving, verify that the person has a valid email address.\n";

    if (sAlertMsg != "")
        alert(sAlertMsg);

}

function onTitleCodeChange() {
    var cboTitle = window.event.srcElement;
    handleTitleCodeChange(cboTitle);
}

function onTitleCodeChange(cboTitle) {
    if (cboTitle == null)
        cboTitle = document.EntryForm.peli_prtitlecode;

    // set this for the handleRoleCheckboxClick functionality
    if (txtSelectedRoles == null) {
        txtSelectedRoles = document.all("_txt_SelectedRoles");
    }
    if (chkRoleSelect_E == "undefined" || chkRoleSelect_E == null)
        initializeRoleCheckboxes();

    var sTitleCode = cboTitle.options[cboTitle.selectedIndex].value;
    var sTitleText = cboTitle.options[cboTitle.selectedIndex].innerText;
    // default handling of Default in BR
    if (bIsNew) {
        cboPRBRPublish = document.EntryForm.peli_prbrpublish;
        if (',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,CTO,SVP,VP,SEC,TRE,SHR,MEM,MDIR,DIR,TRU,OWN,'.indexOf(',' + sTitleCode + ',') > -1)
            cboPRBRPublish.checked = true;
        else
            cboPRBRPublish.checked = false;
    }

    // determine default role assignment 
    // the following values set the executive role and prevents it from changing (potentially)
    var bChecked = false;
    var bDisabled = false;
    if (',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,CTO,SVP,VP,SEC,TRE,SHR,MDIR,DIR,OWN,MEM,TRU,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',MEM,TRU,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_E.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_E.checked = bChecked;
    chkRoleSelect_E.disabled = bDisabled;

    // the following values set the Operations role 
    bChecked = false;
    bDisabled = false;
    if (',COO,OMGR,CS,DIRO,OPER,QC,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',OMGR,CS,QC,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_O.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_O.checked = bChecked;
    chkRoleSelect_O.disabled = bDisabled;

    // the following values set the Finance role 
    bChecked = false;
    bDisabled = false;
    if (',CFO,TRE,CRTL,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',OMGR,CS,QC,CTRL,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_F.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_F.checked = bChecked;
    chkRoleSelect_F.disabled = bDisabled;

    // the following values set the Manager role 
    bChecked = false;
    bDisabled = false;
    if (',GM,MGR,OMGR,SMGR,DIRO,CRED,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',OMGR,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_M.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_M.checked = bChecked;
    chkRoleSelect_M.disabled = bDisabled;

    // the following values set the Sales role 
    bChecked = false;
    bDisabled = false;
    if (',SMGR,SALE,BUY,BRK,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',BRK,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_S.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_S.checked = bChecked;
    chkRoleSelect_S.disabled = bDisabled;

    // the following values set the Buying/Purchasing role 
    bChecked = false;
    bDisabled = false;
    if (',BUY,BRK,BUYR,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',BRK,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_B.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_B.checked = bChecked;
    chkRoleSelect_B.disabled = bDisabled;

    // the following values set the Transportation/Dispatch role 
    bChecked = false;
    bDisabled = false;
    if (',TRN,DISP,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_T.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_T.checked = bChecked;
    chkRoleSelect_T.disabled = bDisabled;

    // the following values set the Marketing role 
    bChecked = false;
    bDisabled = false;
    if (',MRK,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_K.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_K.checked = bChecked;
    chkRoleSelect_K.disabled = bDisabled;

    // the following values set the Credit role 
    bChecked = false;
    bDisabled = false;
    if (',CRED,ACC,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        if (',ACC,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_C.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_C.checked = bChecked;
    chkRoleSelect_C.disabled = bDisabled;


    // the following values set the Adminstration role 
    bChecked = false;
    bDisabled = false;
    if (',ADMIN,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_A.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_A.checked = bChecked;
    chkRoleSelect_A.disabled = bDisabled;


    // the following values set the IT role 
    bChecked = false;
    bDisabled = false;
    if (',IT,CTO,'.indexOf(',' + sTitleCode + ',') > -1) {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_I.getAttribute("RoleCode"), bChecked);
    chkRoleSelect_I.checked = bChecked;
    chkRoleSelect_I.disabled = bDisabled;


    // now handle the Responsible Connected listing
    cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
    var sValue = 'RCR';
    if (',PROP,OWN,SHR,'.indexOf(',' + sTitleCode + ',') > -1) {
        sValue = 'RCO';
        SelectDropdownItemByValue('peli_prownershiprole', sValue);
    }
    cboPROwnershipRole.disabled = (sValue == 'RCO');

    // set the "Published Title"  to the Title Code value 
    var txtTitle = document.all("peli_prtitle");
    if (sOrigPublishedTitle == null)
        txtTitle.value = sTitleText;
    // set the "DL Title"  to the Title Code value 
    var txtDLTitle = document.getElementById("peli_prdltitle");
    if (sOrigDLTitle == null)
        txtDLTitle.value = sTitleText;

}

function ToggleRoles() {

    initializeRoleCheckboxes();

    cboTitle = document.EntryForm.peli_prtitlecode;
    var sTitleCode = cboTitle.options[cboTitle.selectedIndex].value;

    // determine default role assignment 
    // the following values set the executive role and prevents it from changing (potentially)
    var bDisabled = false;
    if (',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,VP,SEC,TRE,SHR,MDIR,DIR,OWN,MEM,TRU,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',MEM,TRU,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_E.disabled = bDisabled;

    // the following values set the Operations role 
    bDisabled = false;
    if (',COO,OMGR,CS,DIRO,OPER,QC,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',OMGR,CS,QC,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_O.disabled = bDisabled;

    // the following values set the Finance role 
    bDisabled = false;
    if (',CFO,TRE,CRTL,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',OMGR,CS,QC,CTRL,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_F.disabled = bDisabled;

    // the following values set the Manager role 
    bDisabled = false;
    if (',GM,MGR,OMGR,SMGR,DIRO,CRED,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',OMGR,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_M.disabled = bDisabled;

    // the following values set the Sales role 
    bDisabled = false;
    if (',SMGR,SALE,BUY,BRK,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',BRK,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_S.disabled = bDisabled;

    // the following values set the Buying/Purchasing role 
    bDisabled = false;
    if (',BUY,BRK,BUYR,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',BRK,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_B.disabled = bDisabled;

    // the following values set the Transportation/Dispatch role 
    bDisabled = false;
    if (',TRN,DISP,'.indexOf(',' + sTitleCode + ',') > -1) {
        bDisabled = true;
    }
    chkRoleSelect_T.disabled = bDisabled;

    // the following values set the Marketing role 
    bDisabled = false;
    if (',MRK,'.indexOf(',' + sTitleCode + ',') > -1) {
        bDisabled = true;
    }
    chkRoleSelect_K.disabled = bDisabled;

    // the following values set the Credit role 
    bDisabled = false;
    if (',CRED,ACC,'.indexOf(',' + sTitleCode + ',') > -1) {
        if (',ACC,'.indexOf(',' + sTitleCode + ',') == -1)
            bDisabled = true;
    }
    chkRoleSelect_C.disabled = bDisabled;


    // the following values set the Adminstration role 
    bDisabled = false;
    if (',ADMIN,'.indexOf(',' + sTitleCode + ',') > -1) {
        bDisabled = true;
    }
    chkRoleSelect_A.disabled = bDisabled;


    // the following values set the IT role 
    bDisabled = false;
    if (',IT,'.indexOf(',' + sTitleCode + ',') > -1) {
        bDisabled = true;
    }
    chkRoleSelect_I.disabled = bDisabled;
}

function clearCheckedRoles() {
    tblCheckboxes = document.getElementById("_RolesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    for (ndx = 0; ndx < arrCheckboxes.length; ndx++) {
        if (arrCheckboxes[ndx].checked == true) {
            arrCheckboxes[ndx].checked = false;
        }
    }
    if (txtSelectedRoles == null)
        txtSelectedRoles = document.getElementById("_txt_SelectedRoles");
    txtSelectedRoles.value = "";
}

function enableAllRoles(bEnable) {
    tblCheckboxes = document.getElementById("_RolesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    for (ndx = 0; ndx < arrCheckboxes.length; ndx++) {
        if (bEnable) {
            // we cannot enable checkboxes for Head roles that are already assigned.
            if (sAssignedCompanyHeadOfRoles.indexOf("," + arrCheckboxes[ndx].getAttribute("RoleCode") + ",") > -1)
                continue;
        }
        arrCheckboxes[ndx].disabled = !bEnable;
    }
}

var xmlHttpRoleRequest = null;
function retrieveAssignedCompanyRolesById(sCompanyId) {

    var excludeClause = "&excludePersonLinkID=0";
    if (sPeliId != "") {
        excludeClause = "&excludePersonLinkID=" + sPeliId;
    }


    xmlHttpRoleRequest = new XMLHttpRequest();
    xmlHttpRoleRequest.onreadystatechange = HandleRoles;
    xmlHttpRoleRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetPersonRoles?companyID=" + sCompanyId + excludeClause, true);
    xmlHttpRoleRequest.send();
}

function HandleRoles() {
    if (xmlHttpRoleRequest.readyState == 4) {

        var sRoles = getStringValue(xmlHttpRoleRequest);

        // now disable any "Head of..." roles that are already assigned.  They can
        // only be assigned once.
        tblCheckboxes = document.getElementById("_RolesListing");
        var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
        var bDisabled = false;
        sAssignedCompanyHeadOfRoles = ",";
        for (ndx = 0; ndx < arrCheckboxes.length; ndx++) {
            bDisabled = false;
            if (",HE,HM,HS,HB,HC,HT,HO,HF,HI,".indexOf("," + arrCheckboxes[ndx].getAttribute("RoleCode") + ",") > -1) {
                if (sRoles.indexOf("," + arrCheckboxes[ndx].getAttribute("RoleCode") + ",") > -1) {
                    sAssignedCompanyHeadOfRoles += arrCheckboxes[ndx].getAttribute("RoleCode") + ",";
                    handleRoleCheckboxClick(arrCheckboxes[ndx].getAttribute("RoleCode"), false);
                    arrCheckboxes[ndx].checked = false;
                    arrCheckboxes[ndx].disabled = true;
                    bDisabled = true;
                }
            }
            if (!bDisabled)
                arrCheckboxes[ndx].disabled = false;

        }
        if (sAssignedCompanyHeadOfRoles != ",")
            sAssignedCompanyHeadOfRoles += ",";

    }
}

var xmlHttpCompanyOwnershipRequest = null;
function checkCompanyOwnership(sCompanyId) {
    xmlHttpCompanyOwnershipRequest = new XMLHttpRequest();
    xmlHttpCompanyOwnershipRequest.onreadystatechange = HandleOwnership;
    xmlHttpCompanyOwnershipRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetOwnershipPct?companyID=" + sCompanyId, true);
    xmlHttpCompanyOwnershipRequest.send();
}

function HandleOwnership() {
    if (xmlHttpCompanyOwnershipRequest.readyState == 4) {

        var ownership = getStringValue(xmlHttpCompanyOwnershipRequest);

        var tbl_PctWarning = document.getElementById("tbl_PctWarning");
        nTotalPct = parseFloat(ownership);
        if (!isNaN(nTotalPct) && nTotalPct > 100) {
            var spnTotalPct = document.getElementById("spnTotalPct");
            spnTotalPct.innerText = nTotalPct;
            tbl_PctWarning.style.display = "inline";
        } else {
            tbl_PctWarning.style.display = "none";
        }
    }
}

var xmlHttpDupPersonLinkRequest = null;
function checkDupHistory(sPersonID, sPersonLinkID) {
    var sCompanyId = document.EntryForm.peli_companyid.value;

    if (sCompanyId == "") {
        alert("Please select a company.");
        return;
    }

    if (dupChecking == true)
        return;

    dupChecking = true;

    xmlHttpDupPersonLinkRequest = new XMLHttpRequest();
    xmlHttpDupPersonLinkRequest.onreadystatechange = HandleDupeHistory;
    xmlHttpDupPersonLinkRequest.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/CheckForDupPersonLink?CompanyID=" + sCompanyId + "&PersonID=" + sPersonID + "&PersonLinkID=" + sPersonLinkID, true);
    xmlHttpDupPersonLinkRequest.send();
}

function HandleDupeHistory() {
    if (xmlHttpDupPersonLinkRequest.readyState == 4) {

        var isDuplicate = getStringValue(xmlHttpDupPersonLinkRequest);
        if (isDuplicate == "true") {
            if (confirm("An active history record already exists for this person and company.  Do you want to save this record anyway?")) {
                save();
            } else {
                dupChecking = false;
            }
        } else {
            save();
        }
    }
}

function getStringValue(xmlHttpRequest) {
    var value = xmlHttpRequest.responseXML.documentElement.innerHTML;
    if (value == undefined) {
        value = xmlHttpRequest.responseXML.documentElement.childNodes[0].nodeValue;
    }

    return value;
}
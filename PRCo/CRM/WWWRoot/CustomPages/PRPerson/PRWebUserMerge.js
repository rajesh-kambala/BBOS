/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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
function ModifySageReadOnly(fieldName){
    oElement = document.all(fieldName);
    if (oElement){
        inner = oElement.innerHTML;
        ndx = inner.indexOf("<");
        if (ndx > 0)
            inner = inner.substring(0, ndx);
        oElement.innerHTML = inner;
        oElement.className="viewbox";
    }
}
function IndentSageCaption(fieldName){
    oElement = document.all(fieldName);
    if (oElement){
        inner = oElement.innerHTML;
        oElement.innerHTML = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + inner;
    }
}

function onOptPersonClick()
{
    var e = window.event.srcElement
    if (e){
        if (e.value == 1){
            Clearprwu_mergedpersonid();
        }
    }
}
function onOptCompanyClick()
{
    var e = window.event.srcElement
    alert(e.name);
    if (e){
        alert(e.value == 1);
        if (e.value == 1){
            Clearprwu_mergedcompanyid();
        }
    }
}

function initEditScreen(){
    // In edit mode, we need to place the Compnay search and person search in Option elements
    
    // find the person control's caption
    oPerson = document.all("_Captprwu_mergedpersonid");
    if (oPerson){
          oParent = oPerson.parentElement;
          oParent.innerHTML = "<INPUT align=left type=radio name=\"optPerson\" value=\"0\" CHECKED><span valign=top class=viewboxcaption>Associate to selected Person:</span><BR/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+ oParent.innerHTML;
    }
    oLastName = document.all("_Captprwu_lastname");
    if (oLastName){
          oParent = oLastName.parentElement;
          oParent.innerHTML = "<INPUT type=radio name=\"optPerson\" onclick=\"onOptPersonClick()\" value=\"1\" ><span valign=top class=viewboxcaption>Create Person using info below:</span><BR/>" + oParent.innerHTML ; 
    }
    // find the company control's caption
    oCompany = document.all("_Captprwu_mergedcompanyid");
    if (oCompany){
          oParent = oCompany.parentElement;
          oParent.innerHTML = "<INPUT align=left type=radio name=\"optCompany\" value=\"0\" CHECKED><span valign=top class=viewboxcaption>Associate to selected Company:</span><BR/>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"+ oParent.innerHTML;
    }
    oCompanyName = document.all("_Captprwu_companyname");
    if (oCompanyName){
          oParent = oCompanyName.parentElement;
          oParent.innerHTML = "<INPUT type=radio name=\"optCompany\" onclick=\"onOptCompanyClick()\" value=\"1\"><span valign=top class=viewboxcaption>Create Company using info below:</span><BR/>" + oParent.innerHTML ; 
    }

    // since we are displaying CRM field in edit mode, the requiered * will display.  We hide that with ModifySageReadOnly
    // We also have to indent the fields (albeit with &nbsp; tags) to space it under the option box.  Use IndentSageCaption.
    ModifySageReadOnly("_Dataprwu_lastname"); 
    IndentSageCaption("_Captprwu_lastname"); 
    ModifySageReadOnly("_Dataprwu_firstname"); 
    IndentSageCaption("_Captprwu_firstname"); 
    ModifySageReadOnly("_Dataprwu_email"); 
    IndentSageCaption("_Captprwu_email"); 
    // same for company fields
    ModifySageReadOnly("_Dataprwu_companyname"); 
    IndentSageCaption("_Captprwu_companyname"); 
    ModifySageReadOnly("_Dataprwu_titlecode"); 
    IndentSageCaption("_Captprwu_titlecode"); 

}

function validate()
{
    
    var focusControl= null;
    var sAlertMsg = "";

    if (document.EntryForm.optPerson[0].checked){
        if (document.EntryForm.prwu_mergedpersonid.value == ""){
            sAlertMsg += "\nA person must be selected to associate to this Web User.";
            var focusablePersonId = document.EntryForm.prwu_mergedpersonidTEXT;
            focusControl = focusablePersonId;
        }
    }
    if (document.EntryForm.optCompany[0].checked){
        if (document.EntryForm.prwu_mergedcompanyid.value == ""){
            sAlertMsg += "\nA company must be selected to associate to this Web User.";
            if (focusControl == null){
                var focusableCompanyId = document.EntryForm.prwu_mergedcompanyidTEXT;
                focusControl = focusableCompanyId;
            }
        }
    }
    if (sAlertMsg != "")
    {
        alert ("The following changes are required to perform the Merge action:\n" + sAlertMsg);
        if (focusControl != null)
            focusControl.focus();
        return false;
    }

    return true;
}

function save()
{
    if (validate() == true)
    {
        document.EntryForm.submit();
    }
}


function onRoleCheckboxClick()
{
    chkRole = window.event.srcElement;
    handleRoleCheckboxClick(chkRole.RoleCode, chkRole.checked);
}

function handleRoleCheckboxClick(sRoleCode, bChecked)
{
    if (txtSelectedRoles == null)
        txtSelectedRoles = document.all("_txt_SelectedRoles");

    sSelectedRoles = txtSelectedRoles.value;
    if (bChecked)
    {
        if (sSelectedRoles.indexOf(","+sRoleCode+",") == -1)
        {
            if (sSelectedRoles == "")
                sSelectedRoles = ",";
            sSelectedRoles = sSelectedRoles + sRoleCode + ",";
        }
    }
    else
    {
        sSelectedRoles = sSelectedRoles.replace("," + sRoleCode + ",", ",");
    }
    txtSelectedRoles.value = sSelectedRoles;

}

function onRecipientRoleCheckboxClick()
{
    chkRole = window.event.srcElement;
    handleRecipientRoleCheckboxClick(chkRole.RoleCode, chkRole.checked);
}

function handleRecipientRoleCheckboxClick(sRoleCode, bChecked)
{
    if (txtSelectedRecipientRoles == null)
    {
        txtSelectedRecipientRoles = document.all("_txt_SelectedRecipientRoles");
    }
    var sSelectedRoles = txtSelectedRecipientRoles.value;
    if (bChecked)
    {
        if (sSelectedRoles.indexOf(","+sRoleCode+",") == -1)
        {
            if (sSelectedRoles == "")
                sSelectedRoles = ",";
            sSelectedRoles = sSelectedRoles + sRoleCode + ",";
        }
    }
    else
    {
        sSelectedRoles = sSelectedRoles.replace("," + sRoleCode + ",", ",");
    }
    txtSelectedRecipientRoles.value = sSelectedRoles;

}

function handleCompanyChange()
{   
    sRoles = "";
    var oPRCompanyId = document.EntryForm.peli_companyid;
    //var oPRCompanyId = document.EntryForm._HIDDENpeli_companyid;
    var sCompanyId = oPRCompanyId.value;
    
    if (sCompanyId == "")
    {
        hdnCOP = document.all["hdn_CompanyOwnershipPercent"];
        hdnCOP.value = "0";    
        var tbl_PctWarning = document.all["tbl_PctWarning"];
        if (tbl_PctWarning)
            tbl_PctWarning.style.display = "none";
        return;
    }
        
    sRoles = retrieveAssignedCompanyRoles(sCompanyLookupsURL, sCompanyId);
    // now disable any "Head of..." roles that are already assigned.  They can
    // only be assigned once.
    tblCheckboxes = document.all("_RolesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    var bDisabled = false;
    sAssignedCompanyHeadOfRoles = ",";
    for (ndx=0; ndx<arrCheckboxes.length; ndx++)
    {
        bDisabled = false;
        if (",HE,HM,HS,HB,HC,HT,HO,HF,HI,".indexOf("," + arrCheckboxes[ndx].RoleCode + ",") > -1)
        {
            if (sRoles.indexOf("," + arrCheckboxes[ndx].RoleCode + ",") > -1)
            {
                sAssignedCompanyHeadOfRoles += arrCheckboxes[ndx].RoleCode + ",";
                handleRoleCheckboxClick(arrCheckboxes[ndx].RoleCode, false);
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

    var sRecipientRoles = retrieveAssignedRecipientRoles(sCompanyLookupsURL, sCompanyId);
    // now disable any recipient roles that are already assigned.  They can
    // only be assigned once.
    tblCheckboxes = document.all("_RecipientRoleListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    var bDisabled = false;
    sAssignedRecipientRoles = ",";
    for (ndx=0; ndx<arrCheckboxes.length; ndx++)
    {
        bDisabled = false;
        if (sRecipientRoles.indexOf("," + arrCheckboxes[ndx].RoleCode + ",") > -1)
        {
            sAssignedRecipientRoles += arrCheckboxes[ndx].RoleCode + ",";
            handleRecipientRoleCheckboxClick(arrCheckboxes[ndx].RoleCode, false);
            arrCheckboxes[ndx].checked = false;
            arrCheckboxes[ndx].disabled = true;
            bDisabled = true;
        }
        if (!bDisabled)
            arrCheckboxes[ndx].disabled = false;

    }
    if (sAssignedRecipientRoles != ",")
        sAssignedRecipientRoles += ",";

    // this will recheck th etotal company percentage 
    checkCompanyOwnership(sCompanyOwnershipURL, 'peli_companyid');
    hdnCOP = document.all["hdn_CompanyOwnershipPercent"];
    var tbl_PctWarning = document.all["tbl_PctWarning"];
    if (hdnCOP){
        nTotalPct = parseFloat(hdnCOP.value);
        if (!isNaN(nTotalPct) && nTotalPct > 100){
            var spnTotalPct = document.all["spnTotalPct"];
            spnTotalPct.innerText = nTotalPct;
            tbl_PctWarning.style.display = "inline";
        } else {
            tbl_PctWarning.style.display = "none";
        }
    }
        
}

function handleStatusChange()
{
    var cboStatus = window.event.srcElement;
    // get the value
    nSelectedValue = cboStatus.options[cboStatus.selectedIndex].value;
    // No Longer Connected
    if (nSelectedValue == 3)
    {
        var sAlertMsg = "";
        // clear the checked Roles for the Genreal Roles
        clearCheckedRoles();
        enableAllRoles(false);
        sAlertMsg = "All Company Roles have been cleared.\n\n";
        
        if (bContactInfoExists)
        {
            sAlertMsg += "Contact Info (Address, Phone, Email) exists for this person.  This \ninformation should be reviewed.\n\n";
        }
        
        var sMsg = "";
        if (bPersonIdIsDefaultMailingAddress)
            sMsg = "\n - A Company Address Attention Line";
            
        // this is the field that will hold the recipient roles
        if (txtSelectedRecipientRoles == null)
        {
            txtSelectedRecipientRoles = document.all("_txt_SelectedRecipientRoles");
        }
        sRoles = txtSelectedRecipientRoles.value;
        if (sRoles.indexOf("RCVTES") > -1)
        {
            if (sMsg != "") sMsg += ",";
            sMsg += "\n - Recipient Role for Receives TES Forms";
        }    
        if (sRoles.indexOf("RCVJEP") > -1)
        {
            if (sMsg != "") sMsg += ",";
            sMsg += "\n - Recipient Role for Receives Jeopardy Letters";
        }    
        if (sRoles.indexOf("RCVBILL") > -1)
        {
            if (sMsg != "") sMsg += ",";
            sMsg += "\n - Recipient Role for Billing Attention Line";
        }    
        if (sRoles.indexOf("RCVLIST") > -1)
        {
            if (sMsg != "") sMsg += ",";
            sMsg += "\n - Recipient Role for Listing Attention Line";
        }   
        if (sMsg != "")
        {
            sAlertMsg += "The following values that are currently assigned to this" +
                    "\nuser should be reassigned to an 'Active' person:" + 
                    sMsg;
        }
        if (sAlertMsg != "")
            alert (sAlertMsg);           
    }
    else
    {
        enableAllRoles(true);
    }
}

function handleAUSReceiveMethodChange()
{
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
        alert (sAlertMsg);           

}

function onTitleCodeChange()
{
    var cboTitle = window.event.srcElement;
    handleTitleCodeChange(cboTitle);
}
function onTitleCodeChange(cboTitle)
{
    if (cboTitle == null)
        cboTitle = document.EntryForm.peli_prtitlecode;
        
    // set this for the handleRoleCheckboxClick functionality
    if (txtSelectedRoles == null)
    {
        txtSelectedRoles = document.all("_txt_SelectedRoles");
    }
    if (chkRoleSelect_E == "undefined" || chkRoleSelect_E == null)
        initializeRoleCheckboxes();
    
    var sTitleCode = cboTitle.options[cboTitle.selectedIndex].value;
    var sTitleText = cboTitle.options[cboTitle.selectedIndex].innerText;
    // default handling of Default in BR
    if (bIsNew)
    {
        cboPRBRPublish = document.EntryForm.peli_prbrpublish;
        if ( ',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,VP,SEC,TRE,SHR,MEM,MDIR,DIR,TRU,OWN,'.indexOf(','+sTitleCode+',') >-1 )
            cboPRBRPublish.checked = true;    
        else
            cboPRBRPublish.checked = false;    
    }
    
    // determine default role assignment 
    // the following values set the executive role and prevents it from changing (potentially)
    var bChecked = false;
    var bDisabled = false;
    if (',PROP,MM,CHR,CEO,PRES,PAR,COO,CFO,SVP,VP,SEC,TRE,SHR,MDIR,DIR,OWN,MEM,TRU,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',MEM,TRU,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }    
    handleRoleCheckboxClick(chkRoleSelect_E.RoleCode, bChecked);
    chkRoleSelect_E.checked = bChecked;
    chkRoleSelect_E.disabled = bDisabled;

    // the following values set the Operations role 
    bChecked = false;
    bDisabled = false;
    if (',COO,OMGR,CS,DIRO,OPER,QC,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',OMGR,CS,QC,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_O.RoleCode, bChecked);
    chkRoleSelect_O.checked = bChecked;
    chkRoleSelect_O.disabled = bDisabled;
    
    // the following values set the Finance role 
    bChecked = false;
    bDisabled = false;
    if (',CFO,TRE,CRTL,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',OMGR,CS,QC,CTRL,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_F.RoleCode, bChecked);
    chkRoleSelect_F.checked = bChecked;
    chkRoleSelect_F.disabled = bDisabled;
    
    // the following values set the Manager role 
    bChecked = false;
    bDisabled = false;
    if (',GM,MGR,OMGR,SMGR,DIRO,CRED,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',OMGR,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_M.RoleCode, bChecked);
    chkRoleSelect_M.checked = bChecked;
    chkRoleSelect_M.disabled = bDisabled;

    // the following values set the Sales role 
    bChecked = false;
    bDisabled = false;
    if (',SMGR,SALE,BUY,BRK,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',BRK,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_S.RoleCode, bChecked);
    chkRoleSelect_S.checked = bChecked;
    chkRoleSelect_S.disabled = bDisabled;

    // the following values set the Buying/Purchasing role 
    bChecked = false;
    bDisabled = false;
    if (',BUY,BRK,BUYR,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',BRK,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_B.RoleCode, bChecked);
    chkRoleSelect_B.checked = bChecked;
    chkRoleSelect_B.disabled = bDisabled;

    // the following values set the Transportation/Dispatch role 
    bChecked = false;
    bDisabled = false;
    if (',TRN,DISP,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_T.RoleCode, bChecked);
    chkRoleSelect_T.checked = bChecked;
    chkRoleSelect_T.disabled = bDisabled;

    // the following values set the Marketing role 
    bChecked = false;
    bDisabled = false;
    if (',MRK,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_M.RoleCode, bChecked);
    chkRoleSelect_M.checked = bChecked;
    chkRoleSelect_M.disabled = bDisabled;

    // the following values set the Credit role 
    bChecked = false;
    bDisabled = false;
    if (',CRED,ACC,'.indexOf(','+sTitleCode+',') >-1 )
    {
        bChecked = true;
        if (',ACC,'.indexOf(','+sTitleCode+',') == -1 )
            bDisabled = true;
    }
    handleRoleCheckboxClick(chkRoleSelect_C.RoleCode, bChecked);
    chkRoleSelect_C.checked = bChecked;
    chkRoleSelect_C.disabled = bDisabled;
    
    // now handle the Responsible Connected listing
    cboPROwnershipRole = document.EntryForm.peli_prownershiprole;
    var sValue = 'RCR';
    if (',PROP,OWN,SHR,'.indexOf(','+sTitleCode+',') >-1 )
    {   
        sValue = 'RCO';
        SelectDropdownItemByValue('peli_prownershiprole', sValue);
    }
    cboPROwnershipRole.disabled = (sValue == 'RCO');            
    
    // set the "Published Title"  to the Title Code value 
    var txtTitle = document.all("peli_prtitle");
    if (sOrigPublishedTitle == null)
        txtTitle.value = sTitleText;
    // set the "DL Title"  to the Title Code value 
    var txtDLTitle = document.all("peli_prdltitle");
    if (sOrigDLTitle == null)
        txtDLTitle.value = sTitleText;

}

function clearCheckedRoles()
{
    tblCheckboxes = document.all("_RolesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    for (ndx=0; ndx<arrCheckboxes.length; ndx++)
    {
        if (arrCheckboxes[ndx].checked == true)
        {
            arrCheckboxes[ndx].checked = false;
        }
    }
    if (txtSelectedRoles == null)
        txtSelectedRoles = document.all("_txt_SelectedRoles");
    txtSelectedRoles.value = "";
}

function enableAllRoles(bEnable)
{
    tblCheckboxes = document.all("_RolesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    for (ndx=0; ndx<arrCheckboxes.length; ndx++)
    {
        if (bEnable)
        {
            // we cannot enable checkboxes for Head roles that are already assigned.
            if (sAssignedCompanyHeadOfRoles.indexOf("," + arrCheckboxes[ndx].RoleCode + ",")>-1)
                continue;
        }
        arrCheckboxes[ndx].disabled = !bEnable;
    }
}

function generatePassword() {

    if (!confirm("Are you sure you want to generate a new web password?")) {
        return;
    }

 	var aVowel = new Array(6);
	var aConsonant = new Array(19);
	var aNumber = new Array(11);
	var szPassword;
	
	aVowel[0] = 'a';
	aVowel[1] = 'e';
	aVowel[2] = 'i';
	aVowel[3] = 'o';
	aVowel[4] = 'u';

    aConsonant[0] = 'b';
    aConsonant[1] = 'c';
    aConsonant[2] = 'd';
    aConsonant[3] = 'f';
    aConsonant[4] = 'g';
    aConsonant[5] = 'h';
    aConsonant[6] = 'j';
    aConsonant[7] = 'k';
    aConsonant[8] = 'l';
    aConsonant[9] = 'm';
    aConsonant[10] = 'n';
    aConsonant[11] = 'p';
    aConsonant[12] = 'r';
    aConsonant[13] = 's';
    aConsonant[14] = 't';
    aConsonant[15] = 'v';
    aConsonant[16] = 'w';
    aConsonant[17] = 'z';

	aNumber[0] = '0';
	aNumber[1] = '1';
	aNumber[2] = '2';
	aNumber[3] = '3';
	aNumber[4] = '4';
	aNumber[5] = '5';
	aNumber[6] = '6';
	aNumber[7] = '7';
	aNumber[8] = '8';
	aNumber[9] = '9';

    // Build a 10 character length string with
    // vowel consonant pairs.
    szPassword = "";    
    for(var i=0; i<5; i++) {
        szPassword = szPassword + aVowel[generateRandom(4)];
        szPassword = szPassword + aConsonant[generateRandom(17)];
        //szPassword = szPassword + aNumber[generateRandom(9)];
    }
    
    // randomize the starting point 
    var iStart = Math.round(generateRandom(4));

    // randomize the length, though the minimum length is 5
    var iLength = Math.round(generateRandom(2)) + 5;
    
    //extract the password 
    document.forms[0].peli_webpassword.value = szPassword.substr(iStart, iLength);
}

function generateRandom(iMax) {
    var iRandom = Math.round(Math.random() * (iMax + 1));
    
    if (iRandom > iMax) {
        iRandom = iMax;
    }
    
    return iRandom
    
}

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
  
  NOTE: This JS file is used by multiple ASP scripts.

***********************************************************************
***********************************************************************/
function validate() {
    var txtCmli_CompanyId = document.getElementById("cmli_comm_companyid");
    var txtCmli_CompanyIdTEXT = document.getElementById("cmli_comm_companyidTEXT");
    var sCompanyId = txtCmli_CompanyId.value;
    var sCompanyIdText = txtCmli_CompanyIdTEXT.value;

    var txtCmli_PersonId = document.getElementById("cmli_comm_personid");
    var cmli_PersonId = txtCmli_PersonId.value;

    var txtComm_EmailFax = document.getElementById("comm_emailfax");
    var comm_EmailFax = txtComm_EmailFax.value;

    if ((document.EntryForm.comm_action.value == 'FaxOut') ||
        (document.EntryForm.comm_action.value == 'EmailOut')) {

        if (document.getElementById("comm_emailfax").value.length == 0) {
            alert("Please specify an email/fax value.");
            return false;
        }
    }

    if (comm_EmailFax.indexOf(",") != -1) {
        alert("Email/Fax cannot contain a comma.");
        return false;
    }

    if (sCompanyId == "" || sCompanyIdText == "") {
        alert("Receiving Company must be linked to an existing company.");
        txtCmli_CompanyIdTEXT.focus();
        return false;
    }
    return true;
}

function save() {
    document.EntryForm.submit();
}

function refresh() {
    document.EntryForm.em.value = 0;
    document.EntryForm.submit();
}

function closeWindow() {

    close();
}

function setDefaultOutAddress() {
    if (document.EntryForm.comm_action.value == 'FaxOut') {
        document.getElementById("comm_emailfax").value = sDefaultFax;
    }

    if (document.EntryForm.comm_action.value == 'EmailOut') {
        document.getElementById("comm_emailfax").value = sDefaultEmail;
    }
}

var xmlHttp = null;
var oldPersonID = 0;

function SetPersonListener() {
    //if (document.getElementById("cmli_comm_personid").value != oldPersonID) {
    oldPersonID = document.getElementById("cmli_comm_personid").value;
    GetPersonOutAddress(document.getElementById("cmli_comm_companyid").value, oldPersonID);
    //}
}

function GetPersonOutAddress(companyID, personID) {
    //xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = SetPersonOutAddress;
    xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetPersonEmail?companyID=" + companyID + "&personID=" + personID, true);
    xmlHttp.send(null);
}

function SetPersonOutAddress() {
    if (xmlHttp.readyState == 4) {
        if (xmlHttp.responseXML != null) {
            var result = $(xmlHttp.responseText)[2].innerText;
            document.getElementById("comm_emailfax").value = $.trim(result);
        }
    }
} 
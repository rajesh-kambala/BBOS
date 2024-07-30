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
function validate() {

    var sMsg = "";

    if (document.getElementById('prvi_investigationname').value == "") {
        sMsg += "- Please specify an Investigation Name.\n";
    }

    if (document.getElementById('prvi_targetnumberofpayreports').value == "") {
        sMsg += "- Please specify a Target # Of Pay Reports.  Use zero if none are required.\n";
    }

    if (document.getElementById('prvi_targetnumberofintegrityreports').value == "") {
        sMsg += "- Please specify a Target # Of Trade Practice Reports.  Use zero if none are required.\n";
    }

    if ((document.getElementById('prvi_maxnumberofattempts').value == "") ||
        (document.getElementById('prvi_maxnumberofattempts').value == "0")) {
        sMsg += "- Please specify a Max # Of Attempts Per Responder.\n";
    }

    if (document.getElementById('prvi_targetcompletiondate').value == "") {
        sMsg += "- Please specify a Target Completion Date.\n";
    }


    if ((document.getElementById('prvi_targetnumberofpayreports').value == "0") && 
        (document.getElementById('prvi_targetnumberofintegrityreports').value == "0")) {
        sMsg += "- Please specify a value for Target # Of Trade Practice Reports or Target # Of Pay Reports.\n";
    }

    if (sMsg != "") {
        alert("Please fix the following errors:\n\n" + sMsg);
        return false;
    }

    return true;
}



function save() {

    if (validate()) {
        document.EntryForm.submit();
    }
}
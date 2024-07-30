/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2015

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
function validate()
{
    // If we're dealing with a list of TESRequest records,
    // then don't worry about validating the subject company
    if (document.getElementById("hidTESIDList").value == "N") {
        var sc = document.getElementById('prtesr_subjectcompanyid').value;
        sc = ((sc != undefined && sc.length > 0) ? sc : -1);

        if (sc <= 0) {
            alert('Please specifiy a subject company');
            return false;
        }
    }

    var ph = document.getElementById('prtesr_overrideaddress').value;
    ph = (ph != undefined) ? ph : '';
    ph = ph.replace(/^\s*/, '');   // ltrim
    ph = ph.replace(/\s*$/, '');   // rtrim
    if (ph.length == 0) {
        alert("Please specify an email value.");
        return false;
    }
    
    var oEmailAddress = document.EntryForm.prtesr_overrideaddress;
    if (oEmailAddress != null) {
        if (oEmailAddress.value.indexOf(",") !== -1) {
            alert("Override Address cannot contain a comma.");
            return false;
        }
    }

    return true;
}

function save()
{
    document.EntryForm.submit();
}

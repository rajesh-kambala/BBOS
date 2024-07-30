/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

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
function setDeceased() {
    var rbDeceased = document.getElementsByName("_deceasedsearch")

    for (var i = 0; i < rbDeceased.length; i++) {

        if (rbDeceased[i].checked) {
            document.getElementById("_HIDDEN_deceasedsearch").value = rbDeceased[i].value;
            break;
        }
    }
}

function initPersonAdvancedSearch()
{
    // This variable is defined in the page
    // by the ASP script.
    if (szDeceased == "") {
        szDeceased = "NotChecked";
    }


    document.getElementById("_HIDDEN_deceasedsearch").value = szDeceased;

    var rbDeceased = document.getElementsByName("_deceasedsearch")

    for (var i = 0; i < rbDeceased.length; i++) {

        rbDeceased[i].setAttribute('onclick', 'setDeceased()')

        rbDeceased[i].checked = false;
        if (rbDeceased[i].value == szDeceased) {
            rbDeceased[i].checked = true;
        }
    }

    document.getElementById("pers_lastname").focus();
    document.getElementById("pers_lastname").select();
}


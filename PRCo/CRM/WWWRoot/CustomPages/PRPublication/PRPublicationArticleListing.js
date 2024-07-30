/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2009

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
function PublicationArticleListingFormUpdates(sEditionDropDown)
{
    var spanEdition = document.getElementById("_DATAprpbed_name");
    spanEdition.innerHTML += sEditionDropDown;
    
    // Hide the edition name field, we will use the dropdown
    var fldEdition = document.getElementById("prpbed_name");
    fldEdition.style.display = "none";

    // Set the dropdown's selected index to the edition name returned from the postback.
    var sEdition = fldEdition.value.toString();
    var fldEditionDD = document.getElementById("_prbed_edition");

    fldEditionDD.selectedIndex = 0;
    for (var i = 0; i < fldEditionDD.length; i++) {
        if (fldEditionDD[i].value.toString() == sEdition) {
            fldEditionDD.selectedIndex = i;
            break;
        }
    }
}


function clear() {

    document.getElementById('prpbed_publishdate_start').value = "";
    document.getElementById('prpbed_publishdate_end').value = "";
    document.EntryForm.em.value = '6';
    document.EntryForm.submit();

}
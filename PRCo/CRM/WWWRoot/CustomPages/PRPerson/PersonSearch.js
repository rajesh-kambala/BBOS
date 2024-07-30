/***********************************************************************
***********************************************************************
Copyright Blue Book Services, Inc. 2013-2015

The use, disclosure, reproduction, modification, transfer, or  
transmittal of  this work for any purpose in any form or by any 
means without the written permission of Blue Book Services, Inc. is 
strictly prohibited.
 
Confidential, Unpublished Property of Blue Book Services, Inc.
Use and distribution limited solely to authorized personnel.
 
All Rights Reserved.
 
Notice:  This file was created by Travant Solutions, Inc.  Contact
by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

function stripPersonName() {
    var fldName = document.getElementById("pers_firstnamealphaonly");
    var sName = String(fldName.value);
    var objRegExp = new RegExp("[^a-z0-9%]", "gi");
    var sTemp = sName.replace(objRegExp, '');
    fldName.value = sTemp;

    fldName = document.getElementById("pers_lastnamealphaonly");
    sName = String(fldName.value);
    objRegExp = new RegExp("[^a-z0-9%]", "gi");
    //objRegExp = new RegExp("[^A-Za-z0-9 _]", "gi");
    sTemp = sName.replace(objRegExp, '');
    fldName.value = sTemp;
   
}

function search() {
    stripPersonName();
    document.EntryForm.submit();
}

function initializeSearch() {

    if (window.addEventListener) {
        window.addEventListener("submit", search, false);
        $(document).keypress(function (e) {
            if (e.which == 13) {
                search();
            }
        });
    } else {
        window.attachEvent("onsubmit", search);
    }

    // now find the Search anchor and modify its href to go to our search function
    var arrAnchors = document.getElementsByTagName("A");
    for (var ndx = 0; ndx < arrAnchors.length; ndx++) {
        if (arrAnchors[ndx].href == "javascript:document.EntryForm.submit();") {
            arrAnchors[ndx].href = "javascript:search()";
        }

        if (arrAnchors[ndx].id == "Button_Search") {
            arrAnchors[ndx].addEventListener("click", search, false);
        }
    }

    document.getElementById("pers_personid").focus();
    document.getElementById("pers_personid").select();
}

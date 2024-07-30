/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
var tdEmail = null;
var tdWeb = null;

var bSaveFlag = false;
function save() {

    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;
    
    
    bValidationError = false;
    
    sTypeCode = selType.options[selType.selectedIndex].value;
    if (sTypeCode == "E") {

        var txtEmail = document.getElementById("emai_emailaddress");
        var sValue = new String (txtEmail.value);
        if (sValue.length > 0) {
            txtEmail.value = sValue.toLowerCase(); 
            if (txtEmail.value.indexOf(",") != -1) {
                bValidationError = true;
                alert("Email Address cannot contain a comma.");
            }
        } else {
            bValidationError = true;
            alert("An email address is required.");
        }
        
    } else if (sTypeCode == "W") {
    
        var txtWeb = document.all("emai_prwebaddress");
        var sValue = new String (txtWeb.value);
        if (sValue.length == 0) {
            bValidationError = true;
            alert("A web address is required.");
        }
    
    }

    if (bValidationError == true) {
        bSaveFlag = false;
    } else {
        document.EntryForm.submit();
    }        
}

function onTypeChange()
{
    handleOnTypeChange(window.event.srcElement, false);
}
function handleOnTypeChange(selType, bInit)
{
    var lblEmailCaption = document.getElementById("_Captemai_emailaddress");
    var lblWebCaption = document.getElementById("_Captemai_prwebaddress");
    if (tdEmail == null)
    {
        // find the td for the eamil and web fields
        var parent = lblEmailCaption.parentElement;
        while ((parent != null) && (parent.tagName != "TD"))
            parent = parent.parentElement;
        tdEmail = parent;
        parent = lblWebCaption.parentElement;
        while ((parent != null) && (parent.tagName != "TD"))
            parent = parent.parentElement;
        tdWeb = parent;
    }        
    if (selType != null && tdEmail != null)
    {
        if (selType.options[selType.selectedIndex].value == "E")
        {
            tdEmail.style.display = "";
            tdWeb.style.display = "none";
            tdWeb.disabled = true;
            tdEmail.disabled = false;
            document.getElementById("_IDemai_prpreferredinternal").disabled = false;
        }
        else if (selType.options[selType.selectedIndex].value == "W")
        {
            tdEmail.style.display = "none";
            tdWeb.style.display = "";
            tdWeb.disabled = false;
            tdEmail.disabled = true;
            document.getElementById("_IDemai_prpreferredinternal").checked = false;
            document.getElementById("_IDemai_prpreferredinternal").disabled = true;
        }
    }


    txtDescription = document.getElementById("emai_prdescription");
    if ((selType != null) && (bInit == false))
    {
        if (selType.selectedIndex < 0)
            txtDescription.value = "";
        else 
        {
            sTypeCode = selType.options[selType.selectedIndex].value;
            sType = selType.options[selType.selectedIndex].innerText;
            txtDescription.value = sType;
        }
    }
}


function togglePreferredPublished() {

    if (!document.getElementById("_IDemai_prpublish").checked) {
        document.getElementById("_IDemai_prpreferredpublished").checked = false;
    }
}

function togglePublished() {

    if (document.getElementById("_IDemai_prpreferredpublished").checked) {
        document.getElementById("_IDemai_prpublish").checked = true;
    }
}
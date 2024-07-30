/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
 File: PRCompanySummary.js
 Description: This file contians the clientside javascript functions to validate 
              the fields of the company summary information

***********************************************************************
***********************************************************************/
function onChangeType(cbo)
{
    var tr=document.getElementById("tr_requestcount");
    var rc = document.getElementById("_requestcount");

    if (cbo.selectedIndex == 2 || cbo.selectedIndex == 3)
    {
        tr.style.visibility="visible"; 
        rc.disabled=false;
    }
    else
    {
        rc.disabled=true; 
        tr.style.visibility="hidden";
    }
}
function save()
{
    var sList = "";
    // this is the table that contains the listing; this table only exists for "custom selection"
    tblCheckboxes = document.getElementById("_tbl_TESCustomSelection");
    if (tblCheckboxes != null)
    {
        // get the text field for the company ids
        var hdnCompanyIds = document.getElementById("_HIDDENcompanyids");
        // check each id to see if it is selected
        var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
        for (ndx=0; ndx<arrCheckboxes.length; ndx++)
        {
            if (arrCheckboxes[ndx].checked == true)
            {
                if (sList != "")
                    sList += ",";
                // the name begins "_chk_"    
                sList += arrCheckboxes[ndx].name.substr(5);
            }
        }
        hdnCompanyIds.value = sList;
        
        if (sList.length == 0) {
            alert("Please select companies to receive surveys.");
            return;
        }            
    }

    var cbo = document.getElementById("prte_customtesrequest");
    if (cbo != null) {
        if (cbo.selectedIndex == 0) {
            alert("Please select Custom TES Request method.");
            return;
        }
    }
    
    document.EntryForm.submit();
}

function setDropdownValue(fieldname, value)
{
    cbo = document.getElementById(fieldname);
    for (ndx=0; ndx<cbo.options.length; ndx++)
    {
        if (cbo.options[ndx].value == value)
        {
            cbo.selectedIndex = ndx;
            break;
        }
    }
}
function removeInvalidDropdowns() {

    RemoveDropdownItemByName("prcr_type", "--None--")
    RemoveDropdownItemByValue("prcr_type", "27")
    RemoveDropdownItemByValue("prcr_type", "28")
    RemoveDropdownItemByValue("prcr_type", "29")
    RemoveDropdownItemByValue("prcr_type", "30")
    RemoveDropdownItemByValue("prcr_type", "31")
    RemoveDropdownItemByValue("prcr_type", "32")

    RemoveDropdownItemByName("comp_prlistingstatus", "--None--")

    if (document.getElementById("_requestage")) {
        RemoveDropdownItemByName("_requestage", "--None--")
    }

/*
    cboType = document.getElementById("prcr_type");
    ndx=0;
    while ( ndx < cboType.options.length)
    {
        if (cboType.options[ndx].innerText == "--None--" )
        {
            cboType.options[ndx].removeNode(true);
        }
        else if (",27,28,29,30,31,32,".indexOf(","+cboType.options[ndx].value+",") > -1)
        {
            //alert("Removing: " + ",27,28,29,30,31,32,".indexOf(cboType.options[ndx].value) + " -- " + cboType.options[ndx].innerText);
            cboType.options[ndx].removeNode(true);
        }
        else
            ndx++;
    }

    cboStatus = document.getElementById("comp_prlistingstatus");
    ndx=0;
    while ( ndx < cboStatus.options.length)
    {
        if (cboStatus.options[ndx].innerText == "--None--")
        {
            cboStatus.options[ndx].removeNode(true);
        }
        else
            ndx++;
    }
*/
}

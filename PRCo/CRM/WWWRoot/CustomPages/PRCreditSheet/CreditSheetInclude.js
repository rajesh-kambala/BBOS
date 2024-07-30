/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
var oLastTextControl = null;
var bSaveFlag = false;

var saveSelection = null;


function validate(sNewStatus) {

    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;
    
    // if this is a new record and there has been data changed; set the status to modified
    var hdnStatus = document.getElementById("_HIDDENprcs_status");
    var prcs_status = document.getElementById("prcs_status");
     


    if (hdnStatus != null)
    {

        if (sNewStatus == "K") {

            if (!confirm("Are you sure you want to Kill this Credit Sheet Item?")) {
                bSaveFlag = false;
                return false;
            }

            var txtListingSpecialistNotes = document.EntryForm.prcs_listingspecialistnotes;
            if (txtListingSpecialistNotes != null)
            {
                if (txtListingSpecialistNotes.value == "")
                {
                    alert("Listing Specialist Notes must be entered to Kill a Credit Sheet Item.");
                    bSaveFlag = false;
                    return false;
                }
            }
        }

        if (sNewStatus == null) {
            if (hdnStatus.value == "N" && bDataChanged) {
                hdnStatus.value = "M";
                prcs_status.value = "M";
            }
        }
        else {
            hdnStatus.value = sNewStatus;
            prcs_status.value = sNewStatus;
        }

        if (sNewStatus == "A")
        {
            var hdnApprover = document.EntryForm._HIDDENprcs_approverid;
            hdnApprover.value = user_userid;
        }
    }

    prepareChangeValue();
    
    return true;
}

// this is a special placement function to put the CompanySelect dropdown in front of the Key checkbox
function placeCompanySelect(sFieldName, sContentId)
{
    // starting at this fieldname work back until you find a table
    var findField = document.all(sFieldName);
    if (findField == null)
    {
        alert("Cannot properly display the table because '" + sFieldName + "' does not exist on the document.");
        return;
    }
    
    while (findField.tagName != "TABLE")
    {
        findField = findField.parentElement;
        if (findField != null)
            break;
    }
    // now name id
    findField.id = "table_chkKeyFlag";
    // use appendCell to place the CompanySelect before the checkbox's table
    AppendCell(findField.id, sContentId, true);
}

function setCaretTextRange()
{
    if (window.event != null) {
        oLastTextControl = window.event.srcElement;
        if (oLastTextControl.createTextRange)
        {
            oLastTextControl.caretPosTR = document.getSelection();
        }    
    }
}

function insertTextAtCursor(sSourceName) 
{
    //if (!document.all) return; // IE only
    var oSource = document.getElementById(sSourceName);
    var sText = "";
    if (oSource.tagName == "SELECT")
    {
        sText=oSource.options[oSource.selectedIndex].text;
    }

    insertAtCursor2(oLastTextControl, sText);
    
}



function insertAtCursor2(myField, myValue) {
    //IE support
    if (document.selection) {
        myField.focus();
        sel = document.selection.createRange();
        sel.text = myValue;
    }
        //MOZILLA and others
    else if (myField.selectionStart || myField.selectionStart == '0') {
        var startPos = myField.selectionStart;
        var endPos = myField.selectionEnd;
        myField.value = myField.value.substring(0, startPos)
            + myValue
            + myField.value.substring(endPos, myField.value.length);
    } else {
        myField.value += myValue;
    }
}



function RegisterCSPhraseHandlers()
{
    // create a list of fields that we want to accept pasted input
    var sFields = ",prcs_authornotes,prcs_listingspecialistnotes,prcs_tradestyle,prcs_numeral,prcs_parenthetical,prcs_change,prcs_ratingchangeverbiage,prcs_ratingvalue,prcs_previousratingvalue,prcs_notes";
    for(i = 0; i < document.all.length; i++)
    {
        var sName = new String(document.all(i).id);
        
        if (sName == "undefined" || sName == "")
            sName = new String(document.all(i).name);
        if (sName != "" && sName != "undefined")
        {
            if (sFields.indexOf(","+sName+",") > -1 )
            {
                document.all(i).onclick=setCaretTextRange;
                document.all(i).onkeyup=setCaretTextRange;
            }
        }
    }
}

String.prototype.trim = function() {
    return this.replace(/^\s*|\s*$/, "");
}

function prepareChangeValue() {

    if (document.getElementById("prcs_change") == null) {
        return;
    }

    var changeText = document.getElementById("prcs_change").value;
    var newText = "";
    
    var ndx = 0;
    //var lineBreak = "\r";
    var lineBreak = "\n";
    var lengthRemaining = changeText.length;
    var lineStartPos = 0;

    while (ndx < changeText.length) {
        nextHardReturn = changeText.indexOf(lineBreak, ndx);

        if (nextHardReturn > -1) {
            changeLine = changeText.substring(ndx, nextHardReturn) + "\n";
            ndx = nextHardReturn + 1;
        } else {
            changeLine = changeText.substring(ndx);
            ndx = changeText.length + 1;
        }
        newText += changeLine.trim();
    }

    document.getElementById("prcs_change").value = newText;
}

function lock() {
    document.getElementById("_IDprcs_locked").checked = true;
    save();
}

function unlock() {
    document.getElementById("_IDprcs_locked").checked = false;
    save();
}
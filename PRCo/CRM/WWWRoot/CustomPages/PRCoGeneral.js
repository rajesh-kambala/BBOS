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

// allow these values to be set by any js
var user_userid = null;

function getInstallName(sPath) {
	//Parse the install name out of the path
	var Path = new String(sPath);
	var InstallName = '';
	var iEndChar=0;iStartChar=0;

	Path = Path.toLowerCase();
	iEndChar = Path.indexOf('/custompages');
	if (iEndChar != -1) {
		//find the first '/' before this
		iStartChar = Path.substr(0,iEndChar).lastIndexOf('/');
		iStartChar++
		InstallName = Path.substring(iStartChar,iEndChar); 
	} else {
	    iEndChar = Path.indexOf('/eware.dll');
	    if (iEndChar != -1) {
		    //find the first '/' before this
		    iStartChar = Path.substr(0,iEndChar).lastIndexOf('/');
		    iStartChar++
		    InstallName = Path.substring(iStartChar,iEndChar); 
		}
	}
	
	return InstallName;

}

// General String and Numeric functions to extend the base classes
String.prototype.times = function(n)
{
 var s = '';
 for (var i = 0; i < n; i++)
  s += this;

 return s;
}
//Zero-Padding
String.prototype.zp = function(n) 
    { return '0'.times(n - this.length) + this; }
// Zero-Trailing
String.prototype.zt = function(n) 
    { return this + '0'.times(n - this.length); } 
Number.prototype.truncate = function(n)
    {return Math.round(this * Math.pow(10, n)) / Math.pow(10, n); } 
// string functions that we want to apply directly to numbers...
Number.prototype.zp = function(n) { return this.toString().zp(n); }
// fractional part of a number
Number.prototype.fractional = 
  function() { return parseFloat(this) - parseInt(this); } 

// format a number with n decimal digits
Number.prototype.format = function(n)
{
    // round the fractional part to n digits, skip the '0.' and zero trail
    var f = this.fractional().truncate(n).toString().substr(2).zt(n);

    // integer part + dot + fractional part, skipping the '0.'
    return parseInt(this) + '.' + f;
}



// accpac has difficulty setting fields on the page if the page is not loading
// a new record; use this helper function to set specific values as necessary
function setFieldValue(sFieldName, sValue)
{
    // make sure the field exists
    var fld = document.getElementById(sFieldName);
    if (fld != null && fld != "undefined")
    {
        // we'll have to determine the type of field this is in order to set the value
        if (fld.tagName == "INPUT" )
        {
            if (fld.type == "text" || fld.type == "hidden")
            {
                fld.value = sValue;
            }
        } else if (fld.tagName == "SELECT"){
            for ( ndx=0; ndx < fld.options.length; ndx++)
            {
                if (fld.options[ndx].value == sValue)
                {
                    fld.options[ndx].selected = true;
                    break;
                }
            }
            
        } else if (fld.tagName == "SPAN")
        {
            fld.innerHTML = sValue;
        }
    
    }


}

// Standard cursor manipulation functions
function cursorWait()
{
    document.body.style.cursor = "wait";
}
function cursorPointer()
{
    document.body.style.cursor = "pointer";
}
function cursorDefault()
{
    document.body.style.cursor = "default";
}

// stopElement is a string to indcate what element should be set display:none
// if the button's table is found; this is usually a TR, but can be a td
function hideButton(sButtonImg, stopElement) {

    if (stopElement == null)
        stopElement = "TR"
    var arrImgs = document.getElementsByTagName("IMG");
    var img = null;
    for (var ndx=0; ndx < arrImgs.length; ndx++)
    {
        if (arrImgs[ndx].src.indexOf(sButtonImg)> -1)
        {
            img = arrImgs[ndx];
            break;
        }  
    }
    if (img == null) {
        return;        
    }
        
    //look for the parent table
    var parent = img.parentElement;


    if (stopElement == "TABLE") {
        while (parent != null)
            parent = parent.parentElement;
    } else {
        while (parent != null && parent.tagName != "TABLE")
            parent = parent.parentElement;
    }

    if (parent != null)
    {
        if (stopElement != "")
        {
            // move up the parent chain again until the next stopElement is found
            while (parent != null && parent.tagName != stopElement )
                parent = parent.parentElement;
        }
    }    
    if (parent != null)
    {
        parent.style.display = "none";
    }
}


// stopElement is a string to indcate what element should be set display:none
// if the button's table is found; this is usually a TR, but can be a td
function toggleButton(sButtonImg, stopElement, display) {

    if (stopElement == null)
        stopElement = "TR"
    var arrImgs = document.getElementsByTagName("IMG");
    var img = null;
    for (var ndx = 0; ndx < arrImgs.length; ndx++) {
        if (arrImgs[ndx].src.indexOf(sButtonImg) > -1) {
            img = arrImgs[ndx];
            break;
        }
    }
    if (img == null) {
        return;
    }

    //look for the parent table
    var parent = img.parentElement;


    if (stopElement == "TABLE") {
        while (parent != null)
            parent = parent.parentElement;
    } else {
        while (parent != null && parent.tagName != "TABLE")
            parent = parent.parentElement;
    }

    if (parent != null) {
        if (stopElement != "") {
            // move up the parent chain again until the next stopElement is found
            while (parent != null && parent.tagName != stopElement)
                parent = parent.parentElement;
        }
    }
    if (parent != null) {
        parent.style.display = display;
    }
}

function isValidEmail(sValue)
{
    var bValid = false;
    try 
    {
	    var regexp = new RegExp('^[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$','gi');
	    bValid = regexp.test(sValue);
	    regexp = null;
    }
    catch (exception)
    {
        return false;
    }
    return bValid;
}
function transformAllDocumentCRMEmailLinks()
{
    var arrAnchors = document.getElementsByTagName("A");
    for (var ndx=0; ndx < arrAnchors.length; ndx++)
    {
        if (arrAnchors[ndx].className == "EMAILLINK")
        {
            sInner = arrAnchors[ndx].innerText;
            // replace the native accpac onclick event for emails
            arrAnchors[ndx].onclick = null;
            // reset the href action
            arrAnchors[ndx].href = "mailto:" + sInner;
            // href changes will change the innerText; set it back
            arrAnchors[ndx].innerText = sInner;
        }  
    }

}

function isValidDate(Value)
{
    // try to get this as a valid 4 digit year date
    var dt = getValidDate(Value);
    if (dt == null)
        return false;
    return true;
}
// returns a valid 4 digit-year date or null if on could not be created
// from the passed string.    
function getValidDate(Value)
{
    var reg1 = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{2}$/
    var reg2 = /^\d{1,2}(\-|\/|\.)\d{1,2}\1\d{4}$/

    // simplest test
    if ( (reg1.test(Value) == false) && (reg2.test(Value) == false) ) 
        { return null; }
    // split the date
    var dateparts = Value.split(RegExp.$1); // based on the divider
    
    var mm = dateparts[0];
    var dd = dateparts[1];
    var yy = dateparts[2];

    // check the century
    if (parseFloat(yy) <= 50) 
        yy = (parseFloat(yy) + 2000).toString(); 
    if (parseFloat(yy) <= 99) 
        yy = (parseFloat(yy) + 1900).toString(); 
   
    var dt = new Date(parseFloat(yy), parseFloat(mm)-1, parseFloat(dd), 0, 0, 0, 0);
    if (parseFloat(dd) != dt.getDate()) 
        return null; 
    if (parseFloat(mm)-1 != dt.getMonth()) 
        return null; 
    return dt;

}

// function to return the current date (or passed date) as a string in mm/dd/yyyy format
function getDateAsString(sValue)
{
    if (sValue == null || sValue == "undefined")
        dtValue = new Date();
    else
        dtValue = new Date(sValue);
    sMonth = dtValue.getMonth()+1;
    sDay = dtValue.getDate();
    sReturn = sMonth.zp(2) + "/" + sDay.zp(2)+  "/" + dtValue.getFullYear();
    dtValue = null;
    return sReturn;
}
function getDatetimeAsString(sValue)
{
    if (sValue == null || sValue == "undefined")
        dtValue = new Date();
    else
        dtValue = new Date(sValue);
    sMonth = dtValue.getMonth()+1;
    sDay = dtValue.getDate();
    sAMPM = "AM";
    sHours = dtValue.getHours();
    if (sHours == 0)
        sHours = 12;
    else if (sHours == 12)
    {
        sAMPM = "PM";
    }
    else if (sHours >= 12)
    {
        sAMPM = "PM";
        sHours = sHours- 12;
    }
    sReturn = sMonth.zp(2) + "/" + sDay.zp(2)+  "/" + dtValue.getFullYear() + 
                " " + sHours.zp(2) + ":" + (dtValue.getMinutes()).zp(2) + ":" + (dtValue.getSeconds()).zp(2) + " " + sAMPM;
    dtValue = null;
    return sReturn;
}

// Functions for manipulating dropdown display
function AddDropdownItem(sDropdownName, sOptionText, sOptionValue, nOptionIndex)
{
    var cbo = document.getElementById(sDropdownName);
    if (cbo == null)
        return;
    var oOption = document.createElement("OPTION");
    oOption.text=sOptionText;
    oOption.value=sOptionValue;
    if (nOptionIndex == null || nOptionIndex < 0)
        cbo.add(oOption);
    else 
        cbo.add(oOption, nOptionIndex);

}
function RemoveDropdownItemByName(sDropdownName, sItemName)
{
    cbo = document.getElementById(sDropdownName);
    if (cbo == null)
        return;

    ndx = 0;
    removeIndex = -1;
    while ( ndx < cbo.options.length)
    {
        if (cbo.options[ndx].innerText == sItemName)
        {
            removeIndex = ndx;
            break;
        }

        ndx++;
    }

    if (removeIndex > -1)
        cbo.remove(ndx);
}
function RemoveDropdownItemByValue(sDropdownName, sItemValue)
{
    cbo = document.getElementById(sDropdownName);
    if (cbo == null)
        return;

    if (cbo.options == null) {
        return;
    }

    ndx = 0;
    removeIndex = -1;
    while ( ndx < cbo.options.length)
    {
        
        if (cbo.options[ndx].value == sItemValue) {
            removeIndex = ndx;
            break;
        }

        ndx++;
    }

    if (removeIndex > -1)
        cbo.remove(ndx);
}


function SelectDropdownItemByValue(sDropdownName, sItemValue)
{
    cbo = document.getElementById(sDropdownName);
    if (cbo == null)
        return;
    ndx=0;
    while ( ndx < cbo.options.length)
    {
        if (cbo.options[ndx].value == sItemValue)
        {
            cbo.selectedIndex = ndx;
            break;
        }
        else
            ndx++;
    }
}

// Use this function to set the colSpan property of an Accpac cell
// this is currently not a native attribute for each field especially
// if you use the .CaptionPos property to manipulate the layout of fields 
// on a screen
function setColSpanProperty(sFieldName, nCols)
{
    var field = document.getElementById(sFieldName);
    if (field != null && field != "undefined")
    {
        while ((field != null) && (field.tagName != "TD"))
            field = field.parentElement;
        if (field != null)
            field.colSpan = nCols;
    }
}

function removeBRInTD(sFieldName)
{
    var field = document.getElementById(sFieldName);
    if (field != null && field != "undefined")
    {
        while ((field != null) && (field.tagName != "TD") )
            field = field.parentElement;

        if (field != null)
        {
            var regexp = new RegExp('<br>','gi');
            var sValue = String(field.innerHTML);
            field.innerHTML = sValue.replace(regexp, '&nbsp;');
            regexp = null;
        }
    }
}

// To use this function, sContentId must be the name of an ID field 
// already added to the form (i.e. using a getBlock("content") structure
// in accpac or manually with html)
function InsertAfterTable(sFieldName, sContentId)
{
    // starting at this fieldname work back until you find a table
    var findField = document.getElementById(sFieldName);
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
    // findField should now be a table or sourceIndex == 0 
    if (findField == null)
        return;

    // get the parent of this table
    var tablesParent = findField.parentElement;
    newDiv = document.getElementById(sContentId);
    if (tablesParent.children.length <= 1)
    {
        // if there is currently only one child append the contents
        tablesParent.appendChild(newDiv);
    }
    else
    {
        var ndx = 0;
        while (tablesParent.children[ndx] != findField && ndx < tablesParent.children.length)
        {
            ndx++;
        }
        if (ndx >= tablesParent.children.length -1 )
            tablesParent.appendChild(newDiv);
        else
            tablesParent.insertBefore(newDiv, tablesParent.children[ndx+1]);
    }
    
}

/*
    This function inserts a blue divider line in an accpac block
    The function looks for a table called "tblNonVisible".  If present,
    we add the row to this table; if not we create the table first but
    do not delete it incase there are more sections to be added later.
    After we have a named row, we use insert row to move it to the appropriate
    place in the accpac block
*/
function InsertDivider(sDividerCaption, sInsertBefore)
{
    //var tblNonVisible = document.getElementById("tblNonVisible");
    var tblNonVisible = document.getElementById("tblNonVisible");
    if (tblNonVisible == null)
    {
        divNonVisible = document.createElement("DIV");
        divNonVisible.innerHTML = ("<TABLE style={display:none;} ID=tblNonVisible >" +
                    "<TR class=InfoContent ID=\"tr_" + sDividerCaption + "\">"+
                    "<TD COLSPAN=10 ALIGN=LEFT >" + sDividerCaption + "</TD></TR>" + 
                    "</TABLE>");
        document.body.appendChild(divNonVisible);
    }
    else
    {
        newTR = document.createElement("TR");
        newTR.className = "InfoContent";
        newTR.id = "tr_" + sDividerCaption;
        var newTD = document.createElement("TD");
        newTD.colSpan = 10;
        newTD.align = "LEFT";
        newTD.innerHTML = sDividerCaption;
        newTR.insertBefore(newTD, null)
        tblNonVisible.insertBefore(newTR, null);
    }
    InsertRow(sInsertBefore, "tr_"+sDividerCaption);

}

// To use this function, sContentId must be the name of an ID field 
// already added to the form (i.e. using a getBlock("content") structure
// in accpac or manually with html)
function InsertRow(sFieldName, sContentId)
{
    //var findField = document.getElementById(sFieldName);
    var findField = document.getElementById(sFieldName);
    if (findField == null)
    {
        alert("Cannot properly display this page because '" + sFieldName + "' does not exist on the document.");
        return;
    }
    //alert (findField.tagName + " -- " + findField.type );
    if (findField.tagName == "INPUT" && findField.type == "checkbox")
    {    
        chkParent = findField.parentElement;
        while ((chkParent != null) && (chkParent.tagName != "TABLE"))
        {
            chkParent = chkParent.parentElement;
        }
        findField = chkParent;
    }
    
    contentRow = document.getElementById(sContentId);
    if (contentRow == null)
    {
        alert("Cannot properly display this page because '" + sContentId + "' does not exist on the document.");
        return;
    }

    // determine if content is a tr; if not wrap it in a tr/td
    if (contentRow.tagName != "TR")
    {
        var newTR = null;
        if (contentRow.tagName != "TD")
        {
            newTR = document.createElement("TR");
            var newTD = document.createElement("TD");
            newTD.insertBefore(contentRow, null);
            newTR.insertBefore(newTD, null);
            contentRow = newTR;
        }
        else 
        {
            newTR = document.createElement("TR");
            newTR.insertBefore(contentRow, null)
            contentRow = newTR;
        }
    }
    // starting at this fieldname work back until you find a table
    var parent = findField.parentElement;
    while ((parent != null) && (parent.tagName != "TR"))
    {
        parent = parent.parentElement;
    }

    

    if (parent != null)
    {

            
        iRowIndex = parent.rowIndex;
        tbody = parent.parentElement;
        tbl = tbody.parentElement;

        if (tbody.rows.length == 0)
            tbody.appendChild(contentRow);
        else
            tbody.insertBefore(contentRow, parent);
    }
}

// To use this function, sContentId CAN be the name of an ID field 
// but if it isn't, the content will be created as a cell of the row.
function AppendRow(sFieldName, sContentId, bInsertBeforeFlag)
{
    var findField = document.getElementById(sFieldName);
    if (findField == null)
    {
        alert("Cannot properly display this page because '" + sFieldName + "' does not exist on the document.");
        return;
    }
    // starting at this fieldname work back until you find a tr
    var parent = findField.parentElement;
    //while ((parent.sourceIndex > 0) && (parent.tagName != "TR"))
    while ((parent != null) && (parent.tagName != "TR"))
    {
        parent = parent.parentElement;
    }


    //if (parent.sourceIndex > 0)
    if (parent != null)
    {
        iRowIndex = parent.rowIndex;
        tbody = parent.parentElement;
        tbl = tbody.parentElement;

        var newTR = null;
        if (sContentId.tagName != undefined)
        {
            if (sContentId.tagName == "TR")
                contentRow = sContentId;
        } else
        {
            contentRow = document.getElementById(sContentId);
            if (contentRow == null)
            {
                // create a row based upon the passed value
                newTR = document.createElement("TR");
                var newTD = document.createElement("TD");
                newTD.innerHTML = String(sContentId);
                newTR.insertBefore(newTD, null)
                contentRow = newTR;
            } 
            else if (contentRow.tagName != "TR")
            {
                // determine if content is a tr; if not wrap it in a tr/td
                if (contentRow.tagName != "TD")
                {
                    newTR = document.createElement("TR");
                    var newTD = document.createElement("TD");
                    newTD.insertBefore(contentRow, null);
                    newTR.insertBefore(newTD, null)
                    contentRow = newTR;
                }
                else 
                {
                    newTR = document.createElement("TR");
                    newTR.insertBefore(contentRow, null);
                    contentRow = newTR;
                }
            }
        }
        

        if (iRowIndex == tbody.rows.length-1)
        {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                tbody.insertBefore(contentRow, parent);
            else
                tbody.insertBefore(contentRow, null);
        }
        else
        {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                tbody.insertBefore(contentRow, parent);
            else
                tbody.insertBefore(contentRow, parent.nextSibling);
        }
    }
}

// To use this function, sContentId CAN be the name of an ID field 
// but if it isn't, the content will be created as the innerHTML of the cell.
function AppendCell(sFieldName, sContentId, bInsertBeforeFlag)
{
    var findField = document.getElementById(sFieldName);
    if (findField == null)
    {
        alert("Cannot properly display this page because '" + sFieldName + "' does not exist on the document.");
        return;
    }
    content = document.getElementById(sContentId);
    if (content == null)
    {
        var node = document.createElement("TD");
        node.vAlign = "top";
        node.innerHTML = sContentId;
        content = node;        
        //alert("Cannot properly display this page because '" + sContentId + "' does not exist on the document.");
        //return;
    } 
    else if (content.tagName != "TD")
    {
        // determine if content is a td; if not wrap it in a td
        var node = document.createElement("TD");
        node.vAlign = "top";
        node.insertBefore(content, null);
        content = node;
    }

    // starting at this fieldname work back until you find a TD
    var parent = findField.parentElement;
    while ((parent != null) && (parent.tagName != "TD"))
    {
        parent = parent.parentElement;
    }

    if (parent != null)
    {
        iCellIndex = parent.cellIndex;
        row = parent.parentElement;
        tbody = row.parentElement;
        tbl = tbody.parentElement;

        if (iCellIndex == row.cells.length-1)
        {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                row.insertBefore(content, parent);
            else
                row.insertBefore(content, null);
        }
        else
        {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                row.insertBefore(content, parent);
            else
                row.insertBefore(content, parent.nextSibling);
        }
    }
}


// To use this function, sContentId CAN be the name of an ID field 
// but if it isn't, the content will be created as the innerHTML of the cell.
function AppendCell2Checkbox(sFieldName, sContentId, bInsertBeforeFlag) {
    var findField = document.getElementById(sFieldName);
    if (findField == null) {
        alert("Cannot properly display this page because '" + sFieldName + "' does not exist on the document.");
        return;
    }
    content = document.getElementById(sContentId);
    if (content == null) {
        var node = document.createElement("TD");
        node.vAlign = "top";
        node.innerHTML = sContentId;
        content = node;
        //alert("Cannot properly display this page because '" + sContentId + "' does not exist on the document.");
        //return;
    }
    else if (content.tagName != "TD") {
        // determine if content is a td; if not wrap it in a td
        var node = document.createElement("TD");
        node.vAlign = "top";
        node.insertBefore(content, null);
        content = node;
    }

    // starting at this fieldname work back until you find a TD
    var parent = findField.parentElement;
    //while ((parent.sourceIndex > 0) && (parent.tagName != "TD")) {
    //    parent = parent.parentElement;
    //}

    // Now go up one more table
    parent = parent.parentElement;
    while ((parent != null) && (parent.tagName != "TD")) {
        parent = parent.parentElement;
    }


    if (parent != null) {
        iCellIndex = parent.cellIndex;
        row = parent.parentElement;
        tbody = row.parentElement;
        tbl = tbody.parentElement;

        if (iCellIndex == row.cells.length - 1) {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                row.insertBefore(content, parent);
            else
                row.insertBefore(content, null);
        }
        else {
            if (bInsertBeforeFlag != null && bInsertBeforeFlag == true)
                row.insertBefore(content, parent);
            else
                row.insertBefore(content, parent.nextSibling);
        }
    }
}

function forceTableCellsToLeftAlign(sFieldInTable, percentage)
{
    var findField = document.getElementById(sFieldInTable);
    if (findField == null)
    {
        alert("Cannot properly display this page because '" + sFieldInTable + "' does not exist on the document.");
        return;
    }
    var parent = findField.parentElement;
    while ((parent != null) && (parent.tagName != "TD"))
    {
        parent = parent.parentElement;
    }

    if (parent != null)
    {
        iCellIndex = parent.cellIndex;
        row = parent.parentElement;
        tbody = row.parentElement;
        tbl = tbody.parentElement;

        var newCell = row.insertCell();
        if (percentage == null || percentage == "undefined")
            percentage = "100%";
        newCell.width=percentage;
    }

}

// hook this function to a form's onkeypress action to make a form submit when the 
// enter key is pressed
function SubmitFormOnEnterKeyPress() 
{ 
    var i = event.keyCode; 
    if (i == 13) { 
        document.EntryForm.submit(); 
        event.cancelBubble=true; 
    } 
} 

// keypress validation routines
var keypressNumeric      = new keypressValidate('01234567890');
var keypressAlpha        = new keypressValidate('abcdefghijklmnopqurstuvwxy');
var keypressAlphaNumeric = new keypressValidate('abcdefghijklmnopqurstuvwxy01234567890');
var keypressDecimal      = new keypressValidate('01234567890.');
var keypressDate         = new keypressValidate('01234567890/');

function keypressValidate(sValidChars) {
	var regexp = new RegExp('[a-z]','gi');

	if(regexp.test(sValidChars))
		this.validChars = sValidChars.toLowerCase() + sValidChars.toUpperCase();// test upper and lower
	else
		this.validChars = sValidChars;

	this.getValidChars = this.validChars.toString();
	regexp = null;
	
}

function keypressValidationHandler(oKeypressValidator)
{
	// get the valid charaters
	sValid = oKeypressValidator.validChars;
	blnValidChar = false;					

	for(i=0;i < sValid.length;i++)
	{
		if(window.event.keyCode == sValid.charCodeAt(i)) 
		{
			blnValidChar = true;
			break;
		}
    }
	if (!blnValidChar) {
	    window.event.returnValue = false;
	    window.event.preventDefault();
	}
}

function CopyStringToClipboard(str) {
    var input = document.createElement('textarea');
    document.body.appendChild(input);
    input.value = str.replaceAll('_NEWLINE_', '\r\n');
    input.focus();
    input.select();
    document.execCommand('Copy');
    input.remove();
}

function ViewReport(ReportURL)
{
    window.open(ReportURL, null, "scrollbars=yes,menubar=no,toolbar=no,resizable=yes,height=600,width=1024");
}

var TRange = null
function findString(str) {

    if (parseInt(navigator.appVersion) < 4) return;

    var strFound;

    // NAVIGATOR-SPECIFIC CODE	
    if (navigator.appName == "Netscape") {
        window.find();
        return;
    }

    // EXPLORER-SPECIFIC CODE
    if (navigator.appName.indexOf("Microsoft") != -1) {

        if (TRange != null) {

            TRange.collapse(false)

            strFound = TRange.findText(str)
            if (strFound) {
                TRange.select()
            }
        }

        if (TRange == null || strFound == 0) {

            TRange = document.body.createTextRange()
            strFound = TRange.findText(str)

            if (strFound) {
                TRange.select()
            }
        }
    }

    if (!strFound) alert("String '" + str + "' not found!")
}

/*
Writes out a table for a button row.  Note: This must be executed inline with the HTML prior to the 
completing the page load.  Otherwise, such as executing this in a body.onload() event, the document.write
REPLACES the document contents.
*/
function WriteButtonTable(sButtonRowID, sImageName, sText, sAction) {
    var sButton = "<table><tr id=" + sButtonRowID + "><td class=\"Button\"><TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><td><A id=a1" + sButtonRowID + " CLASS=\"er_buttonItemImg\" HREF=\"" + sAction + "\" ><IMG SRC=\"/crm/img/Buttons/" + sImageName + "\" BORDER=0 ALIGN=MIDDLE></A></TD><TD>&nbsp;</TD><TD><A id=a2" + sButtonRowID + " class=\"er_buttonItem\" href=\"" + sAction + "\" >" + sText + "</A></TD></TR></TABLE></TD></TR></TABLE>";
    document.write(sButton);  
}

/*
Assumes the ButtonRow control exists (usually via the WriteButtonTable function).  Inserts the specified
row into the button table immediately before the specified button image.
*/
function AddButton(sButtonRowID, sBeforeButtonImg) {


    var stopElement = "TR";

    var arrImgs = document.getElementsByTagName("IMG");
    var img = null;
    for (var ndx = 0; ndx < arrImgs.length; ndx++) {
        if (arrImgs[ndx].src.indexOf(sBeforeButtonImg) > -1) {
            img = arrImgs[ndx];
            break;
        }
    }
    if (img == null)
        return


    //look for the parent table
    var parent = img.parentElement;
    while (parent != null && parent.tagName != "TABLE")
        parent = parent.parentElement;

    if (parent != null) {
        // move up the parent chain again until the next stopElement is found
        while (parent != null && parent.tagName != stopElement)
            parent = parent.parentElement;
    }

    if (parent != null) {
        iRowIndex = parent.rowIndex;
        tbody = parent.parentElement;
        tbl = tbody.parentElement;

        contentRow = document.getElementById(sButtonRowID);
        if (contentRow != null) {
            tbody.insertBefore(contentRow, parent);
        }
    }
}


function CheckAll(szPrefix, bChecked) {
    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {
            if (oCheckboxes[i].disabled == false) {
                oCheckboxes[i].checked = bChecked;
            }
        }
    }
}

function CheckAll2(sGridName, szPrefix, bChecked) {
    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {
        if ((oCheckboxes[i].type == "checkbox") &&
		    (oCheckboxes[i].name.indexOf(szPrefix) == 0) &&
		    (oCheckboxes[i].getAttribute("grid") == sGridName)) {
            if (oCheckboxes[i].disabled == false) {
                oCheckboxes[i].checked = bChecked;
            }
        }
    }
} 

// Determines if an item in the specified
// list control is selected.
function IsItemSelected(szName) {
    oListControl = document.getElementsByName(szName);
    for (var i = 0; i < oListControl.length; i++) {
        if (oListControl[i].checked) {
            return true;
        }
    }

    return false;
}

function changeKey(sQString, sKey, value) {
    var sReturn = String(sQString);
    ndx = sQString.indexOf("&" + sKey + "=");

    if (ndx == -1) {
        ndx = sQString.indexOf("?" + sKey + "=");
    }

    if (ndx == -1) {
        if (sQString.indexOf(sKey + "=") == 0) {
            ndx = 0;
        }
    }

    if (ndx >= 0) {
        ndxNext = sQString.indexOf("&", ndx + 2 + sKey.length);
        if (ndxNext == -1)
            ndxNext = sQString.length;
        sReturn = sQString.substring(0, ndx + 2 + sKey.length) + value + sQString.substring(ndxNext, sQString.length);
    }
    else {
        ndx = sQString.indexOf("?");
        if (ndx == -1)
            sReturn = sQString + "?" + sKey + "=" + value;
        else
            sReturn = sQString + "&" + sKey + "=" + value;
    }
    return sReturn;
}

function removeKey(sQString, sKey) {
    var sReturn = String(sQString);
    ndx = sQString.indexOf("&" + sKey + "=");
    if (ndx >= 0) {
        ndxNext = sQString.indexOf("&", ndx + 2 + sKey.length);
        if (ndxNext == -1)
            ndxNext = sQString.length;
        sReturn = sQString.substring(0, ndx) + sQString.substring(ndxNext, sQString.length);
    }
    return sReturn;
}

function getKey(sQString, sKey) {
    var sReturn = null;
    ndx = sQString.indexOf("&" + sKey + "=");
    if (ndx == -1)
        ndx = sQString.indexOf("?" + sKey + "=");
    if (ndx >= 0) {
        ndxNext = sQString.indexOf("&", ndx + 2 + sKey.length);
        if (ndxNext == -1)
            ndxNext = sQString.length;
        sReturn = sQString.substring(ndx + 2 + sKey.length, ndxNext);
    }
    return sReturn;
}	

function hideMyCRM() {
    var userSelect = document.getElementById("_HIDDENSELECTUser");
    if (userSelect == null)
        return;
    //var parentTable = userSelect.parentElement.style.display = "none";
    var target = userSelect.parentElement.children[1];
    target.style.display = "none";
    //var grandparentCell = userSelect.parentElement.parentElement.style.display = "none";
}

function replaceSpecialCharacters_textarea(ctlid) {
    if ($("#" + ctlid).length == 0)
        return;

    var d = $('#' + ctlid).html();

    if (d.indexOf(cat3(226, 8364, 166)) >= 0) { d = d.replaceAll(cat3(226, 8364, 166), "..."); }
    if (d.indexOf(cat3(226, 8364, 339)) >= 0) { d = d.replaceAll(cat3(226, 8364, 339), "\""); }
    if (d.indexOf(cat3(226, 8364, 157)) >= 0) { d = d.replaceAll(cat3(226, 8364, 157), "\""); }
    if (d.indexOf(cat3(226, 8364, 8220)) >= 0) { d = d.replaceAll(cat3(226, 8364, 8220), "-"); }
    if (d.indexOf(cat3(226, 8364, 8482)) >= 0) { d = d.replaceAll(cat3(226, 8364, 8482), "&apos;"); }

    if (d.indexOf(cat(195, 8364)) >= 0) { d = d.replaceAll(cat(195, 8364), "À"); }
    if (d.indexOf(cat(195, 710)) >= 0) { d = d.replaceAll(cat(195, 710), "È"); }
    if (d.indexOf(cat(195, 338)) >= 0) { d = d.replaceAll(cat(195, 338), "Ì"); }
    if (d.indexOf(cat(195, 8217)) >= 0) { d = d.replaceAll(cat(195, 8217), "Ò"); }
    if (d.indexOf(cat(195, 8482)) >= 0) { d = d.replaceAll(cat(195, 8482), "Ù"); }

    if (d.indexOf(String.fromCharCode(195) + "&nbsp;") >= 0) { d = d.replaceAll(String.fromCharCode(195) + "&nbsp;", "à"); } 
    if (d.indexOf(cat(195, 168)) >= 0) { d = d.replaceAll(cat(195, 168), "è"); }
    if (d.indexOf(cat(195, 172)) >= 0) { d = d.replaceAll(cat(195, 172), "ì"); }
    if (d.indexOf(cat(195, 178)) >= 0) { d = d.replaceAll(cat(195, 178), "ò"); }
    if (d.indexOf(cat(195, 185)) >= 0) { d = d.replaceAll(cat(195, 185), "ù"); }

    if (d.indexOf(cat(195, 129)) >= 0) { d = d.replaceAll(cat(195, 129), "Á"); }
    if (d.indexOf(cat(195, 8240)) >= 0) { d = d.replaceAll(cat(195, 8240), "É"); }
    if (d.indexOf(cat(195, 141)) >= 0) { d = d.replaceAll(cat(195, 141), "Í"); }
    if (d.indexOf(cat(195, 34)) >= 0) { d = d.replaceAll(cat(195, 34), "Ó"); }
    if (d.indexOf(cat(195, 353)) >= 0) { d = d.replaceAll(cat(195, 353), "Ú"); }
    if (d.indexOf(cat(195, 157)) >= 0) { d = d.replaceAll(cat(195, 157), "Ý"); }

    if (d.indexOf(cat(195, 161)) >= 0) { d = d.replaceAll(cat(195, 161), "á"); }
    if (d.indexOf(cat(195, 169)) >= 0) { d = d.replaceAll(cat(195, 169), "é"); }
    if (d.indexOf(cat(195, 173)) >= 0) { d = d.replaceAll(cat(195, 173), "í"); }
    if (d.indexOf(cat(195, 179)) >= 0) { d = d.replaceAll(cat(195, 179), "ó"); }
    if (d.indexOf(cat(195, 186)) >= 0) { d = d.replaceAll(cat(195, 186), "ú"); }
    if (d.indexOf(cat(195, 189)) >= 0) { d = d.replaceAll(cat(195, 189), "ý"); }

    if (d.indexOf(cat(195, 8218)) >= 0) { d = d.replaceAll(cat(195, 8218), "A"); } 
    if (d.indexOf(cat(195, 352)) >= 0) { d = d.replaceAll(cat(195, 352), "Ê"); }
    if (d.indexOf(cat(195, 381)) >= 0) { d = d.replaceAll(cat(195, 381), "Î"); }
    if (d.indexOf(cat(195, 34)) >= 0) { d = d.replaceAll(cat(195, 34), "Ô"); }
    if (d.indexOf(cat(195, 8250)) >= 0) { d = d.replaceAll(cat(195, 8250), "Û"); }

    if (d.indexOf(cat(195, 162)) >= 0) { d = d.replaceAll(cat(195, 162), "â"); }
    if (d.indexOf(cat(195, 170)) >= 0) { d = d.replaceAll(cat(195, 170), "ê"); }
    if (d.indexOf(cat(195, 174)) >= 0) { d = d.replaceAll(cat(195, 174), "î"); }
    if (d.indexOf(cat(195, 180)) >= 0) { d = d.replaceAll(cat(195, 180), "ô"); }
    if (d.indexOf(cat(195, 187)) >= 0) { d = d.replaceAll(cat(195, 187), "û"); }

    if (d.indexOf(cat(195, 402)) >= 0) { d = d.replaceAll(cat(195, 402), "Ã"); }
    if (d.indexOf(cat(195, 8216)) >= 0) { d = d.replaceAll(cat(195, 8216), "Ñ"); }
    if (d.indexOf(cat(195, 8226)) >= 0) { d = d.replaceAll(cat(195, 8226), "Õ"); }

    if (d.indexOf(cat(195, 163)) >= 0) { d = d.replaceAll(cat(195, 163), "ã"); }
    if (d.indexOf(cat(195, 177)) >= 0) { d = d.replaceAll(cat(195, 177), "ñ"); }
    if (d.indexOf(cat(195, 181)) >= 0) { d = d.replaceAll(cat(195, 181), "õ"); }

    if (d.indexOf(cat(195, 8222)) >= 0) { d = d.replaceAll(cat(195, 8222), "Ä"); }
    if (d.indexOf(cat(195, 8249)) >= 0) { d = d.replaceAll(cat(195, 8249), "Ë"); }
    if (d.indexOf(cat(195, 143)) >= 0) { d = d.replaceAll(cat(195, 143), "Ï"); }
    if (d.indexOf(cat(195, 45)) >= 0) { d = d.replaceAll(cat(195, 45), "Ö"); }
    if (d.indexOf(cat(195, 339)) >= 0) { d = d.replaceAll(cat(195, 339), "Ü"); }
    if (d.indexOf(cat(197, 184)) >= 0) { d = d.replaceAll(cat(197, 184), "Ÿ"); }

    if (d.indexOf(cat(195, 164)) >= 0) { d = d.replaceAll(cat(195, 164), "ä"); }
    if (d.indexOf(cat(195, 171)) >= 0) { d = d.replaceAll(cat(195, 171), "ë"); }
    if (d.indexOf(cat(195, 175)) >= 0) { d = d.replaceAll(cat(195, 175), "ï"); }
    if (d.indexOf(cat(195, 182)) >= 0) { d = d.replaceAll(cat(195, 182), "ö"); }
    if (d.indexOf(cat(195, 188)) >= 0) { d = d.replaceAll(cat(195, 188), "ü"); }
    if (d.indexOf(cat(195, 191)) >= 0) { d = d.replaceAll(cat(195, 191), "ÿ"); }

    d = d.replaceAll(String.fromCharCode(194), " ");

    $('#' + ctlid).html(d);
}

function replaceSpecialCharacters_text(ctlid) {
    if ($("#" + ctlid).length == 0)
        return;

    var d = $('#' + ctlid).val();

    if (d.indexOf(cat3(226, 8364, 166)) >= 0) { d = d.replaceAll(cat3(226, 8364, 166), "..."); }
    if (d.indexOf(cat3(226, 8364, 339)) >= 0) { d = d.replaceAll(cat3(226, 8364, 339), "\""); }
    if (d.indexOf(cat3(226, 8364, 157)) >= 0) { d = d.replaceAll(cat3(226, 8364, 157), "\""); }
    if (d.indexOf(cat3(226, 8364, 8220)) >= 0) { d = d.replaceAll(cat3(226, 8364, 8220), "-"); }
    if (d.indexOf(cat3(226, 8364, 8482)) >= 0) { d = d.replaceAll(cat3(226, 8364, 8482), "'"); }

    if (d.indexOf(cat(195, 8364)) >= 0) { d = d.replaceAll(cat(195, 8364), "A"); }
    if (d.indexOf(cat(195, 710)) >= 0) { d = d.replaceAll(cat(195, 710), "E"); }
    if (d.indexOf(cat(195, 338)) >= 0) { d = d.replaceAll(cat(195, 338), "I"); }
    if (d.indexOf(cat(195, 8217)) >= 0) { d = d.replaceAll(cat(195, 8217), "O"); }
    if (d.indexOf(cat(195, 8482)) >= 0) { d = d.replaceAll(cat(195, 8482), "U"); }

    if (d.indexOf(String.fromCharCode(195) + "&nbsp;") >= 0) { d = d.replaceAll(String.fromCharCode(195) + "&nbsp;", "a"); }
    if (d.indexOf(cat(195, 168)) >= 0) { d = d.replaceAll(cat(195, 168), "e"); }
    if (d.indexOf(cat(195, 172)) >= 0) { d = d.replaceAll(cat(195, 172), "i"); }
    if (d.indexOf(cat(195, 178)) >= 0) { d = d.replaceAll(cat(195, 178), "o"); }
    if (d.indexOf(cat(195, 185)) >= 0) { d = d.replaceAll(cat(195, 185), "u"); }

    if (d.indexOf(cat(195, 129)) >= 0) { d = d.replaceAll(cat(195, 129), "A"); }
    if (d.indexOf(cat(195, 8240)) >= 0) { d = d.replaceAll(cat(195, 8240), "E"); }
    if (d.indexOf(cat(195, 141)) >= 0) { d = d.replaceAll(cat(195, 141), "I"); }
    if (d.indexOf(cat(195, 34)) >= 0) { d = d.replaceAll(cat(195, 34), "O"); }
    if (d.indexOf(cat(195, 353)) >= 0) { d = d.replaceAll(cat(195, 353), "U"); }
    if (d.indexOf(cat(195, 157)) >= 0) { d = d.replaceAll(cat(195, 157), "Y"); }

    if (d.indexOf(cat(195, 161)) >= 0) { d = d.replaceAll(cat(195, 161), "a"); }
    if (d.indexOf(cat(195, 169)) >= 0) { d = d.replaceAll(cat(195, 169), "e"); }
    if (d.indexOf(cat(195, 173)) >= 0) { d = d.replaceAll(cat(195, 173), "i"); }
    if (d.indexOf(cat(195, 179)) >= 0) { d = d.replaceAll(cat(195, 179), "o"); }
    if (d.indexOf(cat(195, 186)) >= 0) { d = d.replaceAll(cat(195, 186), "u"); }
    if (d.indexOf(cat(195, 189)) >= 0) { d = d.replaceAll(cat(195, 189), "y"); }

    if (d.indexOf(cat(195, 8218)) >= 0) { d = d.replaceAll(cat(195, 8218), "A"); }
    if (d.indexOf(cat(195, 352)) >= 0) { d = d.replaceAll(cat(195, 352), "E"); }
    if (d.indexOf(cat(195, 381)) >= 0) { d = d.replaceAll(cat(195, 381), "I"); }
    if (d.indexOf(cat(195, 34)) >= 0) { d = d.replaceAll(cat(195, 34), "O"); }
    if (d.indexOf(cat(195, 8250)) >= 0) { d = d.replaceAll(cat(195, 8250), "U"); }

    if (d.indexOf(cat(195, 162)) >= 0) { d = d.replaceAll(cat(195, 162), "a"); }
    if (d.indexOf(cat(195, 170)) >= 0) { d = d.replaceAll(cat(195, 170), "e"); }
    if (d.indexOf(cat(195, 174)) >= 0) { d = d.replaceAll(cat(195, 174), "i"); }
    if (d.indexOf(cat(195, 180)) >= 0) { d = d.replaceAll(cat(195, 180), "o"); }
    if (d.indexOf(cat(195, 187)) >= 0) { d = d.replaceAll(cat(195, 187), "u"); }

    if (d.indexOf(cat(195, 402)) >= 0) { d = d.replaceAll(cat(195, 402), "A"); }
    if (d.indexOf(cat(195, 8216)) >= 0) { d = d.replaceAll(cat(195, 8216), "N"); }
    if (d.indexOf(cat(195, 8226)) >= 0) { d = d.replaceAll(cat(195, 8226), "O"); }

    if (d.indexOf(cat(195, 163)) >= 0) { d = d.replaceAll(cat(195, 163), "a"); }
    if (d.indexOf(cat(195, 177)) >= 0) { d = d.replaceAll(cat(195, 177), "n"); }
    if (d.indexOf(cat(195, 181)) >= 0) { d = d.replaceAll(cat(195, 181), "o"); }

    if (d.indexOf(cat(195, 8222)) >= 0) { d = d.replaceAll(cat(195, 8222), "A"); }
    if (d.indexOf(cat(195, 8249)) >= 0) { d = d.replaceAll(cat(195, 8249), "E"); }
    if (d.indexOf(cat(195, 143)) >= 0) { d = d.replaceAll(cat(195, 143), "I"); }
    if (d.indexOf(cat(195, 45)) >= 0) { d = d.replaceAll(cat(195, 45), "O"); }
    if (d.indexOf(cat(195, 339)) >= 0) { d = d.replaceAll(cat(195, 339), "U"); }
    if (d.indexOf(cat(197, 184)) >= 0) { d = d.replaceAll(cat(197, 184), "Y"); }

    if (d.indexOf(cat(195, 164)) >= 0) { d = d.replaceAll(cat(195, 164), "a"); }
    if (d.indexOf(cat(195, 171)) >= 0) { d = d.replaceAll(cat(195, 171), "e"); }
    if (d.indexOf(cat(195, 175)) >= 0) { d = d.replaceAll(cat(195, 175), "i"); }
    if (d.indexOf(cat(195, 182)) >= 0) { d = d.replaceAll(cat(195, 182), "o"); }
    if (d.indexOf(cat(195, 188)) >= 0) { d = d.replaceAll(cat(195, 188), "u"); }
    if (d.indexOf(cat(195, 191)) >= 0) { d = d.replaceAll(cat(195, 191), "y"); }

    d = d.replaceAll(String.fromCharCode(194), " ");

    $('#' + ctlid).val(d);
}

function cat(s1, s2) {
    return String.fromCharCode(s1) + String.fromCharCode(s2);
}
function cat3(s1, s2, s3) {
    return String.fromCharCode(s1) + String.fromCharCode(s2) + String.fromCharCode(s3);
}

function trimString(textbox) {
    textbox.value = textbox.value.trim();
}
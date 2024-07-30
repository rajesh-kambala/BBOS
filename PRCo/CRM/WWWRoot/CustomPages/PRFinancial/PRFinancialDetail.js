/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
var tblDetailValues = null;

function apply()
{
    // sNewEntryUrl is defined in PRFinancialDetail.asp on page setup
    document.EntryForm.action = sSaveUrl;
    document.EntryForm.submit();    
           
}
// The newEntry action verifies that a value is entered for the description and 
// amount then submits the form with an action of 96.
function newEntry()
{
    if (tblDetailValues == null)
        tblDetailValues = document.all("_tblValues");
    rows = tblDetailValues.rows;
    nLastRow = rows.length-3;//remove one row for the "To remove..." and one for the total
    txtDescription = document.all("_txtDescription_"+nLastRow);    
    txtAmount = document.all("_txtAmount_"+nLastRow);
    if (txtDescription.value == "" )
    {
        alert("The last detail entry must be completed before a new entry can be added.");
        txtDescription.focus();
        return;
    }    
    if (txtAmount.value == "")
    {
        alert("The last detail entry must be completed before a new entry can be added.");
        txtAmount.focus();
        return;
    }
    // sNewEntryUrl is defined in PRFinancialDetail.asp on page setup
    document.EntryForm.action = sNewEntryUrl;
    document.EntryForm.submit();    
           
}
function onAmountKeyPress()
{
    var key = window.event.keyCode;
    if((key < 48 || key > 57) 
        && key != 45 // -
        && key != 46 // .
        )
    {
        return false;
    }
    sText = window.event.srcElement.value;
    if (key == 45) 
    {
        if (sText.charAt(0) == "-") 
            return false;
        else if (sText.length > 0)
        {
            window.event.srcElement.value = "-" + sText;
            return false;
        }
    }
    return true;
}
function onAmountChange()
{
    recalculateTotal();
}
function recalculateTotal()
{
    nTotal = 0;
    if (tblDetailValues == null)
        tblDetailValues = document.all("_tblValues");
    rows = tblDetailValues.rows;
    // skip the "To delete..." and the total rows
    for (ndx=1; ndx < rows.length-1; ndx++)
    {
        //txtDescription = rows.cells[1].getElementByTagName("input");
        var txtAmount = rows(ndx).cells(3).getElementsByTagName("input");
        nAmount = parseInt(txtAmount[0].value);
        if (!isNaN(nAmount))
            nTotal += nAmount;
    }
    spnTotal = tblDetailValues.all("_spnTotal");    
    txtTotal = tblDetailValues.all("_txtTotal");    
    if (spnTotal != null && txtTotal != null)
    {
        txtTotal.value = nTotal;
        spnTotal.innerText = nTotal;
    }
}
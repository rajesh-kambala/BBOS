/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
var bDataChanged = false;

function onChangeHandler()
{
    if (window.event != null) {
        var src = window.event.srcElement;
        handleDataChanged(src);
    }
}

function handleDataChanged(src)
{
    bDataChanged = true;
}

function save()
{
    bDataChanged=false;
    document.EntryForm.submit();
}

window.onbeforeunload = confirmExit;
function confirmExit()
{
    if (bDataChanged)
        return "Data has changed. Leaving this page will cause changes to be lost.  Are you sure you want to leave this page?";
    return;
}

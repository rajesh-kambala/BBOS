/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2013

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
/* **************************************************************************************
 *  function: save
 *  Description: performs the validate and save 
 *
 ***************************************************************************************/
function save() {

    sAlertMsg = "";

    var txtEditionName = document.EntryForm.prpbed_name;
    if (txtEditionName.value == "") {
        sAlertMsg += " - Edition Name is a required field.\n";
        focusControl = txtEditionName;
    }

    var txtPublicationDate = document.EntryForm.prpbed_publishdate;
    if (txtPublicationDate.value == "") {
        sAlertMsg += " - Publish Date is a required field.\n";
        if (focusControl != null)
            focusControl = txtPublicationDate;
    }

    if (sAlertMsg != "") {
        alert("The following changes are required to save the Edition record:\n\n" + sAlertMsg);
        if (focusControl != null)
            focusControl.focus();
        return;
    }

    // Note that the upload document will submit this form.
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];
    
    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function Form_OnSubmit()
{
    // Get a pointer to the form in the iFrame.
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];
    
    // Cover Art
    var sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName1'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbed_coverartfilename'].value = sCurrFilePath;
    }

    // Cover Art Thumbnail
    sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName2'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbed_coverartthumbfilename'].value = sCurrFilePath;
    }

    document.getElementById('prpbed_publicationcode').disabled = false;
}

function PublicationEditionFormUpdates()
{
    AppendRow('_Captprpbed_coverartfilename', '_tr_publication_upload', false);

    document.getElementById('prpbed_coverartfilename').style.display = 'none';
    document.getElementById('_Captprpbed_coverartfilename').style.display = 'none';
    document.getElementById('prpbed_coverartthumbfilename').style.display = 'none';
    document.getElementById('_Captprpbed_coverartthumbfilename').style.display = 'none';

    document.getElementById('prpbed_publicationcode').disabled = true;
}

function PublicationEditionViewUpdates() {

    var img = document.getElementById('imgCoverArt');
    if (img) {
        AppendCell('_Captprpbed_publicationcode', 'tdCoverArt', false);
    }
}


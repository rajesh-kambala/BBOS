/***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2121

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
var Edit = 1;
var View = 0;


function formLoad(Mode) {

    if (Mode == Edit) {

        AppendRow('_Captprpbar_filename', '_tr_publication_upload', false);
        document.getElementById('prpbar_filename').style.display = 'none';
        document.getElementById('_Captprpbar_filename').style.display = 'none';
        document.getElementById('prpbar_coverartfilename').style.display = 'none';
        document.getElementById('_Captprpbar_coverartfilename').style.display = 'none';

        mediaTypeCode = document.getElementById('prpbar_mediatypecode');
        mediaTypeCode.onchange = toggleMediaType;

        setTimeout(toggleMediaType, 500);

    }
}


function toggleMediaType() {


    var mediaTypeCode = document.getElementById('prpbar_mediatypecode');
    var sSelectedMediaTypeCode = mediaTypeCode[mediaTypeCode.selectedIndex].value;

    var uploadFrame = document.getElementById('_frmPublication_Upload');
    var oUploadDoc = uploadFrame.contentDocument ? uploadFrame.contentDocument : uploadFrame.contentWindow.document;
    var oUploadForm = oUploadDoc.getElementById('form1');

    if (sSelectedMediaTypeCode == "Doc") {
        document.getElementById('prpbar_filename').style.display = 'none';
        document.getElementById('_Captprpbar_filename').style.display = 'none';
        oUploadDoc.getElementById('trFile1').style.display = '';

        //document.getElementById('captprpbar_Length').disabled = true;
        document.getElementById('prpbar_length').disabled = true;
    } else {
        document.getElementById('prpbar_filename').style.display = '';
        document.getElementById('_Captprpbar_filename').style.display = '';
        oUploadDoc.getElementById('trFile1').style.display = 'none';

        //document.getElementById('captprpbar_Length').disabled = false;
        document.getElementById('prpbar_length').disabled = false;
    }
}

function save() {
	// Submit the publishing file.
    var ifr = document.getElementById("_frmPublication_Upload");
    var ifrDoc = ifr.contentDocument || ifr.contentWindow.document;
    var theForm = ifrDoc.getElementById("form1");

    if (theForm.onsubmit) {
        theForm.onsubmit();
    }
    theForm.submit();
}

function confirmDelete() {
    return confirm("Are you sure you want to delete this training article?");
}

function Form_OnSubmit()
{
    // for now, ignore the status in the upload form and just save.
    var ifr = document.getElementById("_frmPublication_Upload");
    var ifrDoc = ifr.contentDocument || ifr.contentWindow.document;
    var theForm = ifrDoc.forms[0];

    var sCurrFilePath = String(theForm.elements['hidUploadedFileName1'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_filename'].value = sCurrFilePath;
    }

    sCurrFilePath = String(theForm.elements['hidUploadedFileName2'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_coverartfilename'].value = sCurrFilePath;
    }
}

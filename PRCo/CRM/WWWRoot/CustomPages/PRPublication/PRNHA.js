/***********************************************************************
  Copyright Blue Book Services, Inc. 2012

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

        document.getElementById('prpbar_coverartfilename').style.display = 'none';
        document.getElementById('_Captprpbar_coverartfilename').style.display = 'none';
        
        document.getElementById('_Captprpbar_coverartthumbfilename').style.display = 'none';
        document.getElementById('prpbar_coverartthumbfilename').style.display = 'none';
        
        document.getElementById('prpbar_coverartfilename').style.display = 'none';
        document.getElementById('_Captprpbar_coverartfilename').style.display = 'none';
   }
}

function confirmDelete() {
    return confirm("Are you sure you want to delete this New Hire Academy article?");
}

function save() {

	// Submit the publishing file.
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];
	if (oUploadForm.onsubmit) {
		oUploadForm.onsubmit();
	}
	oUploadForm.submit();
}

function Form_OnSubmit()
{
    // 
    // Go get the file names that were uploaded by the ASPX component and
    // set the Accpac fields so they save properly.  We are using the FileName
    // field for the videoURL (which is not set by the ASPX component), the
    // CoverArtFileName for the PDF file, and the thumbnail for, well, the
    // thumbnail image.
    //
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];

    var sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName1'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_coverartfilename'].value = sCurrFilePath;
    }

    sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName2'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_coverartthumbfilename'].value = sCurrFilePath;
    }
}

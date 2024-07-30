/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2019

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
var Edit = 1;
var View = 0;
var bFilenameHasChanged = false;
var bIsNew = false;

function prpbar_publicationcode_OnChange(evt)
{
    // normalize event objects between w3c & ie.
    evt = (evt) ? evt : ((event) ? event : null);
    var elem = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);

    SetHeiarchyFieldStatus(elem);
    SetIndustryCode(elem);

    var cboPubCode = document.EntryForm.prpbar_publicationcode;
    var sSelectedPubCode = cboPubCode[cboPubCode.selectedIndex].value;

    // BPO articles have a publish date, regardless if they are set
    // as a news item or not.
    if ((sSelectedPubCode == "BPO") || (sSelectedPubCode == "KYCGFB") || (sSelectedPubCode == "TTGFB")) {
        var fldPublishDate = document.getElementById('prpbar_publishdate');
        var fldPublishDateCal = document.getElementById('_Calprpbar_publishdate');

        fldPublishDate.disabled = false;
        fldPublishDateCal.style.display = 'inline';
    } else {
        SetPublishExpireFieldStatus(document.getElementById("_IDprpbar_news"))
    }

    toggleFileUpload();

}

function prpbar_filename_OnChange(evt) {
    bFilenameHasChanged = true;
}

function prpbar_publishdate_OnChange(evt) {
    prpbar_publicationcode_OnChange(evt);
}



var _flipBookPath = "";

function toggleFileUpload() {

    var cboPubCode = document.EntryForm.prpbar_publicationcode;
    var sSelectedPubCode = cboPubCode[cboPubCode.selectedIndex].value;
                                                   
    var uploadFrame = document.getElementById('_frmPublication_Upload');
    var oUploadDoc = uploadFrame.contentDocument ? uploadFrame.contentDocument : uploadFrame.contentWindow.document;
    var oUploadForm = oUploadDoc.getElementById('form1');
    
    oUploadDoc.getElementById('upFile1').disabled = false;
    oUploadDoc.getElementById('upFile2').disabled = false;
    oUploadDoc.getElementById('upFile3').disabled = true;

    document.getElementById('prpbar_filename').style.display = 'none';
    document.getElementById('_Captprpbar_filename').style.display = 'none';

    oUploadDoc.getElementById('trFile2').style.display = '';
    if (sSelectedPubCode == "KYC") {
        oUploadDoc.getElementById('trFile2').style.display = 'none';
        oUploadForm.getElementById('upFile3').disabled = false;
    } 

    if (sSelectedPubCode == "KYCG") {
        oUploadDoc.getElementById('trFile1').style.display = 'none';
        oUploadDoc.getElementById('trFile2').style.display = 'none';
        oUploadDoc.getElementById('trFile3').style.display = 'none';
    } 

    if ((sSelectedPubCode == "KYCGFB") || (sSelectedPubCode == "TTGFB")) {
        oUploadDoc.getElementById('trFile3').style.display = 'none';
        oUploadDoc.getElementById('upFile1').disabled = true;
        document.getElementById('prpbar_filename').style.display = '';
        document.getElementById('_Captprpbar_filename').style.display = '';

        if (document.getElementById('prpbar_filename').value == "" || (bIsNew && !bFilenameHasChanged)) {
            if (document.getElementById('prpbar_publishdate').value != "") {
                var year = document.getElementById('prpbar_publishdate').value.substr(document.getElementById('prpbar_publishdate').value.length - 4);
                if (sSelectedPubCode == "KYCGFB") {
                    _flipBookPath = "KYC/kyc_ebook/" + year + "/index.html";
                }
                else if (sSelectedPubCode == "TTGFB") {
                    _flipBookPath = "TTGuide/" + year + "/index.html";
                }

                document.getElementById('prpbar_filename').value = _flipBookPath;
            }
        } else {
            _flipBookPath = document.getElementById('prpbar_filename').value;
        }
    } 

    if ((sSelectedPubCode == "BP") ||
        (sSelectedPubCode == "BPS")) {
        oUploadDoc.getElementById('upFile2').disabled = true;
    }

    if ((sSelectedPubCode == "BPFB") ||
        (sSelectedPubCode == "BPFBS")) {
        oUploadDoc.getElementById('upFile1').disabled = true;

        document.getElementById('prpbar_filename').style.display = '';
        document.getElementById('_Captprpbar_filename').style.display = '';

        if (document.getElementById('prpbar_filename').value == "" || (bIsNew && !bFilenameHasChanged)) {
            var editionName = document.getElementById('prpbar_publicationeditionidTEXT').value;

            if (sSelectedPubCode == "BPFB") {
                _flipBookPath = "BP/" + editionName + "/eBook/index.html";
            } else {
                var supplementCount = new Number(document.getElementById("FPFBSCount").value);
                supplementCount++;
    
                _flipBookPath = "BP/" + editionName + "/eBookSupplement" + supplementCount.toString() + "/index.html";
            }

            document.getElementById('prpbar_filename').value = _flipBookPath;
        }
        else {
            _flipBookPath = document.getElementById('prpbar_filename').value;
        }
    }
}


function SetHeiarchyFieldStatus(elem) {
    //alert("The current article type is " + elem.value + ".");
    var fldLevel = document.getElementById('prpbar_level');
    if (fldLevel != null) {
        fldLevel.disabled = (elem.value.search(/^BB(R|S)$/i) < 0);
    }
}

function SetIndustryCode(elem) {
    bDisable = (elem.value.search(/^BBS$/i) < 0);
    var trIndustryCode = document.getElementById('IndustryCode');
    var trIndustryCode2 = document.getElementById('IndustryCode2');

    var languageLabel = document.getElementById('_Captprpbar_communicationlanguage');
    var language = document.getElementById('_Dataprpbar_communicationlanguage');

    //var categoryCodeLabel = document.getElementById('_Captprpbar_categorycode');
    //var categoryCode = document.getElementById('_Dataprpbar_categorycode');

    if (bDisable) {
        trIndustryCode.style.display = "none";
        trIndustryCode2.style.display = "none";
        languageLabel.style.display = "none";
        language.style.display = "none";
        //categoryCodeLabel.style.display = "none";
        //categoryCode.style.display = "none";
    } else {
        trIndustryCode.style.display = "inline";
        trIndustryCode2.style.display = "inline";
        languageLabel.style.display = "inline";
        language.style.display = "inline";
        //categoryCodeLabel.style.display = "inline";
        //categoryCode.style.display = "inline";
    }
}

function prpbar_News_OnClick(evt)
{
    // normalize event objects between w3c & ie.
    evt = (evt) ? evt : ((event) ? event : null);
    var elem = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);

    SetPublishExpireFieldStatus(elem);
}

function SetPublishExpireFieldStatus(elem)
{
  
    var fldExpireDate = document.getElementById('prpbar_expirationdate');
    var fldExpireDateData = document.getElementById('_Dataprpbar_expirationdate');
    var fldExpireDateCal = document.getElementById('_Calprpbar_expirationdate');

    var bDisable = ! elem.checked;
    var sDisplay = bDisable ? 'none' : 'inline';
    
    fldExpireDate.disabled = bDisable;
    fldExpireDateCal.style.display = sDisplay;


    var fldPublishDate = document.getElementById('prpbar_publishdate');
    var fldPublishDateData = document.getElementById('_Dataprpbar_publishdate');
    var fldPublishDateCal = document.getElementById('_Calprpbar_publishdate');

    if (fldPublishDate == null) {
        return;
    }

    var cboPubCode = document.EntryForm.prpbar_publicationcode;
    var sSelectedPubCode = cboPubCode[cboPubCode.selectedIndex].value;

    // BPO articles have a publish date, regardless if they are set
    // as a news item or not.
    if ((sSelectedPubCode != "BPO") && (sSelectedPubCode != "KYCGFB") && (sSelectedPubCode != "TTGFB")) {
        fldPublishDate.disabled = bDisable;
        fldPublishDateCal.style.display = sDisplay;
    }
    
}

/* **************************************************************************************
 *  function: TopicList_OnClick()
 *  Description: Disables/Enables the checkboxes that comprise a topic list tree.
 *
 ***************************************************************************************/
function TopicList_OnClick(evt)
{
    // normalize event objects between w3c & ie.
	evt = (evt) ? evt : ((event) ? event : null);
	var elem = (evt.target) ? evt.target : ((evt.srcElement) ? evt.srcElement : null);
	if (! elem) return;
	
	var m, m2, level, id;
	// id is _PTSelect_id_level
	var re_id = 1, re_level = 2;
	var re = /_PTSelect_(\d+)_(\d+)/;
	if (m = elem.id.match(re)) {
		/*
			1. climb to the table level element
			2. get the array of input elements
			3. scan through these until you hit the source id
			4. scan through elements disabling those with a higher level than the source
			5. end the scan when you return to the source id's level
		*/

		id = m[re_id];
		level = m[re_level];
		var bDisable = elem.checked;

		while (elem = elem.parentElement) {
			if (elem.tagName.toLowerCase() == "table")
				break;
		}
		if (! elem) return;
		
		var input_elems = elem.getElementsByTagName("input");
		var i, start;
		var bFound = false;
		for (i = 0; i < input_elems.length; i++) {
			if (! (m2 = input_elems[i].id.match(re))) {
				throw ("Unexpected id found in Topic List table: " + input_elems[i].id);
			}

			if (m2[re_id] == id) {
				bFound = true;
			} else if (bFound) {
				if (m2[re_level] > level) {
					input_elems[i].disabled = bDisable;
					if (bDisable) {
						input_elems[i].checked = false;
					}
				} else if (m2[re_level] == level) {
					break;
				}
			}
		}
	}
}

// This function concats all of the checked topic id's into a single comma-delimited list stored in a field called HIDDEN_PUBTOPICS
function SaveTopicList()
{
	var hdn = document.getElementById('HIDDEN_PUBTOPICS');
	var lst = document.getElementById('_PublicationTopicListing');
	var chk_elems = lst.getElementsByTagName('INPUT');
	var topic_ids = [ ];
	var re = /_PTSelect_(\d+)_(\d+)/;
	var i;
	for (i = 0; i < chk_elems.length; i++) {
		if (chk_elems[i].id.search(re) >= 0 && chk_elems[i].checked) {	// paranoia check
			topic_ids.push(chk_elems[i].value);
		}
	}
	if (topic_ids.length > 0) {
		hdn.value = topic_ids.join(",");
	} else {
		hdn.value = "";
	}
}

function PublicationArticleFormUpdates(Mode) {

    if (document.getElementById("IndustryCode") != null) {
        AppendRow('_Captprpbar_abstract', 'IndustryCode', true);
        AppendRow('_Captprpbar_abstract', 'IndustryCode2', true);
    }

    AppendCell('_Captprpbar_publicationcode', '_td_PublicationTopics', false);
    AppendCell('_Captprpbar_publicationcode', '_td_Spacer', false);

    if (Mode == Edit) {

        AppendRow('_Captprpbar_filename', '_tr_publication_upload', false);
        document.getElementById('prpbar_filename').style.display = 'none';
        document.getElementById('_Captprpbar_filename').style.display = 'none';
        document.getElementById('prpbar_coverartfilename').style.display = 'none';
        document.getElementById('_Captprpbar_coverartfilename').style.display = 'none';
        document.getElementById('prpbar_coverartthumbfilename').style.display = 'none';
        document.getElementById('_Captprpbar_coverartthumbfilename').style.display = 'none';
        
        fld = document.getElementById('_IDprpbar_news');
        fld.onclick = prpbar_News_OnClick;
        SetPublishExpireFieldStatus(fld);

        fld = document.getElementById('prpbar_publicationcode');
        if (fld != null) {
            fld.onchange = prpbar_publicationcode_OnChange;
            SetHeiarchyFieldStatus(fld);
            SetIndustryCode(fld);
            setTimeout(toggleFileUpload, 500);
            //toggleFileUpload();
        }

        fld = document.getElementById('prpbar_filename');
        if (fld != null) {
            fld.onchange = prpbar_filename_OnChange;
        }

        fld = document.getElementById('prpbar_publishdate');
        if (fld != null) {
            fld.onchange = prpbar_publishdate_OnChange;
        }
        
//        fld = document.getElementById('prpbar_CategoryCode');
//        while (fld && fld.tagName.toUpperCase() != "TR") {
//            fld = fld.parentNode;
//        }
//        fld.style.display = "none";

        if (document.getElementById("prpbar_mediatypecode") != null) {
            mediaTypeCode = document.getElementById('prpbar_mediatypecode');
            mediaTypeCode.onchange = toggleMediaType;

            setTimeout(toggleMediaType, 500);
        }
    }
}

function save() {

    var cboPubCode = document.EntryForm.prpbar_publicationcode;
    var sSelectedPubCode = cboPubCode[cboPubCode.selectedIndex].value;

    var cboCatCode = document.EntryForm.prpbar_categorycode;
    for (var i = 0; i < cboCatCode.options.length; i++) {
        if (cboCatCode.options[i].value == sSelectedPubCode) {
            cboCatCode.options[i].selected = true;
            break;
        } 
    }
    
    if ((sSelectedPubCode == "BPFB") ||
        (sSelectedPubCode == "BPFBS")) {
        alert("For Flipbook articles, we will link to the file indicated.  Please ensure all supporting files are copied to the Learning Center location on the BBOS server in  the subfolder '" + _flipBookPath + "'.");
    }
    
	// Submit the publishing file.
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];
	if (oUploadForm.onsubmit) {
		oUploadForm.onsubmit();
	}
    
    oUploadForm.submit();
}

function Form_OnSubmit()
{
	// Save the topic list  into an easily parsed field.
	//SaveTopicList();

    // Save the publication code in the category code and enable the field
	var fldPubCode = document.getElementById('prpbar_publicationcode');
	if (fldPubCode.value != "BBS") {
	    var fldCatCode = document.getElementById('prpbar_categorycode');
	    fldPubCode.disabled = false;
	    fldCatCode.value = fldPubCode.value;
	}
    
    // enable the level field
    var fldLevel = document.getElementById('prpbar_Level');
    if (fldLevel != null) {
        fldLevel.disabled = false;
    }
    
    // for now, ignore the status in the upload form and just save.
    var oUploadForm = window.frames['_frmPublication_Upload'].contentDocument.forms[0];

    var sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName1'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_filename'].value = sCurrFilePath;
    }

    sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName2'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_coverartfilename'].value = sCurrFilePath;
    }

    sCurrFilePath = String(oUploadForm.elements['hidUploadedFileName3'].value);
    if (sCurrFilePath.length > 0) {
        document.forms['EntryForm'].elements['prpbar_coverartthumbfilename'].value = sCurrFilePath;
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
    } else {
        document.getElementById('prpbar_filename').style.display = '';
        document.getElementById('_Captprpbar_filename').style.display = '';
        oUploadDoc.getElementById('trFile1').style.display = 'none';
    }
}
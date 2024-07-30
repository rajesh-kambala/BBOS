///***********************************************************************
// ***********************************************************************
//  Copyright Produce Report Company 2007-2024
//
//  The use, disclosure, reproduction, modification, transfer, or  
//  transmittal of  this work for any purpose in any form or by any 
//  means without the written permission of Produce Report Company is 
//  strictly prohibited.
// 
//  Confidential, Unpublished Property of Produce Report Company.
//  Use and distribution limited solely to authorized personnel.
// 
//  All Rights Reserved.
// 
//  Notice:  This file was created by Travant Solutions, Inc.  Contact
//  by e-mail at info@travant.com.
// 
// 
//***********************************************************************
//***********************************************************************/

var xmlHttp = null;
var sDataUrl = "";
var eWareMode;
var pradc_adcampaignid;

// From accpac
var View = 0, Edit = 1, Save = 2, PreDelete = 3, PostDelete = 4, Clear = 6;
var Find = 2;


function Form_OnSubmit() {
    handleFileUpload("_frame_uploadadimagefile", "_HIDDENpracf_filename");
    handleFileUpload("_frame_uploadadimagefile2", "_HIDDENpracf_filename2");
    handleFileUpload("_frame_uploadadimagefile3", "_HIDDENpracf_filename3");
    handleFileUpload("_frame_uploadadimagefile4", "_HIDDENpracf_filename4");

    //var msg = "Uploaded images:\n";
    //msg += "_HIDDENpracf_filename=" + document.getElementById("_HIDDENpracf_filename").value + "\n";
    //msg += "_HIDDENpracf_filename2=" + document.getElementById("_HIDDENpracf_filename2").value + "\n";
    //msg += "_HIDDENpracf_filename3=" + document.getElementById("_HIDDENpracf_filename3").value + "\n";
    //msg += "_HIDDENpracf_filename4=" + document.getElementById("_HIDDENpracf_filename4").value + "\n";
    //alert(msg);

    return false;
}

function handleFileUpload(frameControl, hiddenFileName) {
    if (document.getElementById(frameControl)) {
        var oUploadDoc = document.getElementById(frameControl).contentWindow.document;
        var sUploadedFile = oUploadDoc.getElementById("hidUploadedFileName1").value;
        var pracf_filename = document.getElementById(hiddenFileName);

        if (sUploadedFile.replace(/\s*/, "").length > 0) {
            pracf_filename.value = sUploadedFile;
        }
    }
}

function PRCompanyAdvertisementFormUpdates(AdCampaignID, eWareModeParam, sDataUrlParam) {
    sDataUrl = sDataUrlParam;
    eWareMode = eWareModeParam;
    pradc_adcampaignid = AdCampaignID;

    if (eWareMode !== Edit) {
        // move the image to the campaign  block
        //var img = document.getElementById('img_AdImage');
        if (document.getElementById('img_AdImage')) {
            switch (document.all._HIDDENpradch_typecode.value) {
                case "TT":
                case "D":
                    AppendCell('_Captpradc_adfileupdatedby', 'tdAdImage', false);
                    break;
                case "KYC":
                    AppendCell('_Captpradc_creativestatus', 'tdAdImage', false);
                    
                    break;
                default:
                    AppendCell('_Captpradc_startdate', 'tdAdImage', false);
            }
        }

        if (document.getElementById('img_AdImage2')) {
            switch (document.all._HIDDENpradch_typecode.value) {
                case "BP":
                    AppendCell('_Captpradc_adfileupdatedby', 'tdAdImage2', false);
                    break;
                case "KYC":
                    AppendCell('_Datapradc_creativestatusprint', 'tdAdImage2', false);
                    break;
                case "D": 
                    AppendCell('img_AdImage', 'tdAdImage2', false);
            }
        }

        if (document.getElementById('img_AdImage3')) {
            AppendCell('img_AdImage', 'tdAdImage3', false);
        }

        if (document.getElementById('img_AdImage4')) {
            AppendCell('img_AdImage3', 'tdAdImage4', false);
        }
    }
}

function saveBP() {
    var sMsg = "";

    if (document.getElementById("pradc_blueprintsedition").value === "") {
        sMsg += " - Blueprints Edition is a required field.\n";
    }

    if (document.getElementById("pradc_name").value === "") {
        sMsg += " - Name is a required field.\n";
    }

    if (sMsg !== "") {
        alert("Please correct the following issues before continuing.\n\n" + sMsg);
        return;
    }

    CostAlert();

    // Note that the upload document will submit this form.
    var oUploadForm = document.getElementById("_frame_uploadadimagefile").contentWindow.document.forms[0];
    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function saveDigital() {
    var sMsg = "";

    if (document.getElementById("pradc_name").value === "") {
        sMsg += " - Name is a required field.\n";
    }

    if (document.getElementById("pradc_adcampaigntypedigital").value === "") {
        sMsg += " - Digital Type is a required field.\n";
    }
    else if (document.getElementById("pradc_adcampaigntypedigital").value === "BBOSSlider" ||
             document.getElementById("pradc_adcampaigntypedigital").value === "BBOSSliderITA")
        {
            if (document.getElementById("pradc_sequence").value === "") {
                sMsg += " - Sequence is a required field for BBOS Slider ads.\n";
        }
        else {
            var sequence = $(document.getElementById("pradc_sequence")).val().replace(/,/g, "").replace(/[$]/g, "");
            var valid = !isNaN(sequence);
            if (!valid || sequence < 0) {
                sMsg += " - Sequence must be a non-negative numeric.\n";
            }
        }
    }

    var startDate;
    var hasStartDate = false;
    var hasEndDate = false;
    if (document.getElementById("pradc_startdate")) {
        if (document.getElementById("pradc_startdate").value === "") {
            sMsg += " - Start Date is a required field.\n";
        } else {
            hasStartDate = true;
            startDate = getValidDate(document.getElementById("pradc_startdate").value);
        }
    }

    if (document.getElementById("pradc_enddate")) {
        if (document.getElementById("pradc_enddate").value === "") {
            sMsg += " - End Date is a required field.\n";
        } else {
            hasEndDate = true;
            if (hasStartDate) {
                var endDate = getValidDate(document.getElementById("pradc_enddate").value);
                endDate.setDate(endDate.getDate() + 1);

                if (startDate >= endDate) {
                    sMsg += " - Start Date must come before the End Date.\n";
                }
            }
        }
    }

    //Update end date to midnight
    if (hasEndDate && sMsg == "") {
        var midnightEndDate = document.getElementById("pradc_enddate").value.substring(0, 10) + " 11:59:59pm";
        document.getElementById("_HIDDENpradc_enddate").value = midnightEndDate;
        document.getElementById("pradc_enddate").value = midnightEndDate;
    }

    if (sMsg !== "") {
        alert("Please correct the following issues before continuing.\n\n" + sMsg);
        return;
    }

    CostAlert();

    //Update the pradc_Name field
    document.getElementById("_HIDDENpradc_name").value = document.getElementById("pradc_adcampaigntypedigital").value;

    // Note that the upload document will submit this form.
    var oUploadForm = document.getElementById("_frame_uploadadimagefile").contentWindow.document.forms[0];
    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function saveTT() {
    var sMsg = "";

    if (document.getElementById("pradc_ttedition").value === "") {
        sMsg += " - Edition is a required field.\n";
    }

    var startDate;
    var hasStartDate = false;
    if (document.getElementById("pradc_startdate")) {
        if (document.getElementById("pradc_startdate").value === "") {
            sMsg += " - Start Date is a required field.\n";
        } else {
            hasStartDate = true;
            startDate = getValidDate(document.getElementById("pradc_startdate").value);
        }
    }

    if (document.getElementById("pradc_enddate")) {
        if (document.getElementById("pradc_enddate").value === "") {
            sMsg += " - End Date is a required field.\n";
        } else {

            if (hasStartDate) {
                var endDate = getValidDate(document.getElementById("pradc_enddate").value);
                if (startDate > endDate) {
                    sMsg += " - Start Date must come before the End Date.\n";
                }
            }
        }
    }

    if (sMsg !== "") {
        alert("Please correct the following issues before continuing.\n\n" + sMsg);
        return;
    }

    CostAlert();

    //Update the pradc_Name field
    document.getElementById("_HIDDENpradc_name").value = document.getElementById("pradc_ttedition").value;

    // Note that the upload document will submit this form.
    var oUploadForm = document.getElementById("_frame_uploadadimagefile").contentWindow.document.forms[0];
    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function saveKYC() {
    var sMsg = "";

    if (document.getElementById("pradc_kycedition").value === "") {
        sMsg += " - Edition is a required field.\n";
    }

    if (!document.getElementById("_IDpradc_premium").checked) {
        if (document.getElementById("pradc_kyccommodityid").value === "") {
            sMsg += " - KYC Commodity Article is a required field.\n";
        }
    }

    if (sMsg !== "") {
        alert("Please correct the following issues before continuing.\n\n" + sMsg);
        return; 
    }

    CostAlert();

    //Update fields
    document.getElementById("_HIDDENpradc_name").value = document.getElementById("pradc_kycedition").value;
    document.getElementById("_HIDDENpradc_kyccommodityid").value = document.getElementById("pradc_kyccommodityid").value;

    // Note that the upload document will submit this form.
    var oUploadForm = document.getElementById("_frame_uploadadimagefile").contentWindow.document.forms[0];

    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function CostAlert() {
    var cost = document.getElementById("pradc_cost").value;
    if (cost=== "" || cost==="0.00")
        alert("Please enter the cost amount.");
}

function submitNextFileUpload(ifn) {
    // Note that the upload document will submit this form.
    var oUploadForm = document.getElementById("_frame_uploadadimagefile" + ifn).contentWindow.document.forms[0];

    if (oUploadForm.onsubmit)
        oUploadForm.onsubmit();
    oUploadForm.submit();
}

function onPlacementChangeBP() {

    var fld = document.getElementById('pradc_placement');
    if (fld === null) {
        return;
    }

    if ((fld.value === "IFC") ||
        (fld.value === "Page1") ||
        (fld.value === "Page3") ||
        (fld.value === "5thP") ||
        (fld.value === "LHS") ||
        (fld.value === "RHS") ||
        (fld.value === "HSL") ||
        (fld.value === "HSR") ||
        (fld.value === "IBC") ||
        (fld.value === "OBC") ||
        (fld.value === "PamelaPick") ||
        (fld.value === "FoodForThought") ||
        (fld.value === "BTN")) {
        document.getElementById('_IDpradc_premium').checked = true;
    } else {
        document.getElementById('_IDpradc_premium').checked = false;
    }
}

function onPlacementChangeKYC() {

    var fld = document.getElementById('pradc_placement');
    if (fld === null) {
        return;
    }

    if ((fld.value === "IFC") ||
        (fld.value === "Page1") ||
        (fld.value === "Page3") ||
        (fld.value === "5thP") ||
        (fld.value === "CSL1") ||
        (fld.value === "CSL2") ||
        (fld.value === "CSL3") ||
        (fld.value === "IF") ||
        (fld.value === "IB") ||
        (fld.value === "IBC") ||
        (fld.value === "OBC") ||
        (fld.value === "INTRO") ||
        (fld.value === "TP") ||
        (fld.value === "O"))
    {
        document.getElementById('_IDpradc_premium').checked = true;
    } else {
        document.getElementById('_IDpradc_premium').checked = false;
    }
}

function onPlacementChangeTT() {

    var fld = document.getElementById('pradc_placement');
    if (fld === null) {
        return;
    }

    if ((fld.value === "IFC") ||
        (fld.value === "Page1") ||
        (fld.value === "Page3") ||
        (fld.value === "TRADG") ||
        (fld.value === "TRANSG") ||
        (fld.value === "SELR") ||
        (fld.value === "IBC") ||
        (fld.value === "OBC"))
    {
        document.getElementById('_IDpradc_premium').checked = true;
    } else {
        document.getElementById('_IDpradc_premium').checked = false;
    }
}

function stripDollarComma(textbox) {
    textbox.value = textbox.value.replace(/,/g, "").replace(/[$]/g, "");
}

function normalizeDate(textbox) {
    var valid = isValidDate(textbox.value);
    if (valid) {
        var d = new Date(getValidDate(textbox.value));
        textbox.value = d.getMonth() + 1 + '/' + d.getDate() + '/' + d.getFullYear();
    }
}

function pradc_adcampaigntypedigital_SetStatus() {
    var f = document.getElementById('pradc_adcampaigntypedigital');
    var g = document.getElementById('_Datapradc_adcampaigntypedigital');

    if (f != null) {
        if (f.value != 'BBOSSlider' && f.value != 'BBOSSliderITA') {
            document.getElementById('_Captpradc_sequence').hidden = 'hidden';
            document.getElementById('pradc_sequence').hidden = 'hidden';
        }
        else {
            document.getElementById('_Captpradc_sequence').removeAttribute('hidden');
            document.getElementById('pradc_sequence').removeAttribute('hidden');
        }

        if (f.value == "CSEU") {
            document.getElementById('fileRegion2').hidden = 'hidden';
            document.getElementById('fileRegion3').removeAttribute('hidden');
            document.getElementById('fileRegion4').removeAttribute('hidden');
        } else {
            document.getElementById('fileRegion2').removeAttribute('hidden');
            document.getElementById('fileRegion3').hidden = 'hidden';
            document.getElementById('fileRegion4').hidden = 'hidden';
        }
    }

    else
        if (g != null) {
            if (!g.innerText.startsWith("BBOS Slider")) {
                document.getElementById('_Captpradc_sequence').hidden = 'hidden';
                document.getElementById('_Datapradc_sequence').hidden = 'hidden';
            }
            else {
                document.getElementById('_Captpradc_sequence').removeAttribute('hidden');
                document.getElementById('_Datapradc_sequence').removeAttribute('hidden');
            }
        }
}
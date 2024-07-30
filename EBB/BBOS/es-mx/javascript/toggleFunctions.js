//***********************************************************************
//***********************************************************************
// Copyright Travant Solutions, Inc. 2000-2018
//
// The use, disclosure, reproduction, modification, transfer, or  
// transmittal of  this work for any purpose in any form or by any 
// means without the written  permission of Travant Solutions is 
// strictly prohibited.
//
// Confidential, Unpublished Property of Travant Solutions, Inc.
// Use and distribution limited solely to authorized personnel.
//
// All Rights Reserved.
//
// Notice:  This file was created by Travant Solutions, Inc.  Contact
// by e-mail at info@travant.com
//
// Filename:		toggleFunctions.js (en-mx version)
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>
function Toggle(szSpanID) {
    var oSpan = document.getElementById(szSpanID);
    var oImg = document.getElementById('img' + szSpanID);

    if (oSpan == null)
        return;
		
	if (oSpan.style.display == "") {
		oSpan.style.display = "none";

        $("#img" + szSpanID).removeClass("glyphicon-minus");
        $("#img" + szSpanID).addClass("glyphicon-plus");

        oImg.src = imgPlus;

	} else {
		oSpan.style.display = "";
        $("#img" + szSpanID).addClass("glyphicon-minus");
        $("#img" + szSpanID).removeClass("glyphicon-plus");

        oImg.src = imgMinus;
	}
}

function bsToggle(szSpanID) {
    var isExpanded = $("#" + szSpanID).attr("aria-expanded");
    if (typeof isExpanded == "undefined")
        isExpanded = false;

    $("#" + szSpanID).collapse(isExpanded ? "hide" : "show");
}
function bsCollapse(szSpanID) {
    $("#" + szSpanID).collapse("hide");
}
function bsExpand(szSpanID) {
    $("#" + szSpanID).collapse("show");
}

function ToggleAll(bExpand){

	// Retrieve the SPAN tags
	var colSPAN = document.body.getElementsByTagName("SPAN");

	// Iterate through
	for (i=0; i < colSPAN.length; i++) {
		var oSPAN = colSPAN.item(i);

		// If it is marked as "Toggleable" (sp?)
		// then toggle it.
		if (oSPAN.name == "tsiToggle") {

			var oImg =  document.getElementById('img' + oSPAN.id);
			
			if (bExpand == true) {
				oSPAN.style.display = "";		
				oImg.src = imgMinus;
			} else {
				oSPAN.style.display = "none";	
				oImg.src = imgPlus;
			}
		}
	}
}

function Toggle_Hid(szSpanID, oHid, szImg) {
    var oSpan = document.getElementById(szSpanID);

    if (oSpan == null)
        return;

    //toggle state
    if (oHid.value == null || oHid.value == "" || oHid.value == "false")
        oHid.value = "true";
    else
        oHid.value = "false"

    Set_Hid_Display(szSpanID, oHid, szImg);
}

function Set_Hid_Display(szSpanID, oHid, szImg) {
    var oSpan = document.getElementById(szSpanID);
    var oImg = document.getElementById(szImg);

    if (oSpan == null)
        return;

    if (oHid.value == "false") {
        oSpan.style.display = "none";

        $("#" + szImg).removeClass("glyphicon-minus");
        $("#" + szImg).addClass("glyphicon-plus");

        oImg.src = imgPlus;
    }
    else {
        oSpan.style.display = "";
        $("#" + szImg).addClass("glyphicon-minus");
        $("#" + szImg).removeClass("glyphicon-plus");

        oImg.src = imgMinus;
    }
}

function Set_Expand(szSpanID, bExpanded) {
        var oSpan = document.getElementById(szSpanID);
        var oImg = document.getElementById('img' + szSpanID);

        if (oSpan == null)
            return;

        if (bExpanded == false) {
            oSpan.style.display = "none";

            $("#img" + szSpanID).removeClass("glyphicon-minus");
            $("#img" + szSpanID).addClass("glyphicon-plus");

            oImg.src = imgPlus;
        }
        else {
            oSpan.style.display = "";
            $("#img" + szSpanID).addClass("glyphicon-minus");
            $("#img" + szSpanID).removeClass("glyphicon-plus");

            oImg.src = imgMinus;
        }
    }
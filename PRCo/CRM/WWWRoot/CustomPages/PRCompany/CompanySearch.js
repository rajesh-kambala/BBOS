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

function stripCompanyName()
{
	var fldName = document.EntryForm.prcse_namealphaonly;
	var sName = String(fldName.value);
    var objRegExp  = new RegExp("[^a-z0-9%]", "gi");
	var sTemp = sName.replace(objRegExp,'');
	fldName.value = sTemp;
}

function search()
{
	stripCompanyName();
	document.EntryForm.submit();
}
// now find the Search anchor and modify its href to go to our search function

function initializeSearch()
{
	var oTables = document.getElementsByTagName('table');  
	for (n=0; n<oTables.length; n++)  
	{  
		if (oTables[n].className == 'workflow')  
		{ 
			oTables[n].style.display = 'none'; break; 
		}  
	}  
	RemoveDropdownItemByName('comp_prtype', '--None--');  
	RemoveDropdownItemByName('comp_prlistingstatus', '--None--');  
	RemoveDropdownItemByName('comp_prindustrytype', '--None--');  

	if (window.addEventListener) {
		window.addEventListener("submit", search, false);
		$(document).keypress(function (e) {
			if (e.which == 13) {
				search();
			}
		});
	} else {
	    window.attachEvent("onsubmit", search);
	}

    // now find the Search anchor and modify its href to go to our search function
    var arrAnchors = document.getElementsByTagName("A");
    for (var ndx=0; ndx < arrAnchors.length; ndx++)
    {
        if (arrAnchors[ndx].href == "javascript:document.EntryForm.submit();")
        {
            arrAnchors[ndx].href = "javascript:search()";
        }

        if (arrAnchors[ndx].id == "Button_Search") {
            arrAnchors[ndx].addEventListener("click", search, false);
        }
    }

    document.getElementById("comp_companyid").focus();
	document.getElementById("comp_companyid").select();

	var ddlIndustryType = document.getElementById("comp_prindustrytype");
	if (ddlIndustryType != null) {
		ddlIndustryType.onchange = function () { changeIndustry(); };
		changeIndustry();
	}
}

function changeIndustry() {
	var ddlIndustryType = $("#comp_prindustrytype");
	var ddlServiceCode = $("#prse_servicecode");
	if (ddlIndustryType.val() == "P" || ddlIndustryType.val() == "S" || ddlIndustryType.val() == "T") {
		SetPST();
	}
	else if (ddlIndustryType.val() == "L") {
		SetL();
	}
	else {
		SetAll();
    }
}

function SetPST() {
	SetAll();
	$("#prse_servicecode option[value=L100]").hide();
	$("#prse_servicecode option[value=L150]").hide();
	$("#prse_servicecode option[value=L200]").hide();
	$("#prse_servicecode option[value=L201]").hide();
	$("#prse_servicecode option[value=L300]").hide();
	$("#prse_servicecode option[value=L301]").hide();
	$("#prse_servicecode option[value=L99]").hide();
}

function SetL() {
	SetAll();
	$("#prse_servicecode option[value=BBS100]").hide();
	$("#prse_servicecode option[value=BBS100-E]").hide();
	$("#prse_servicecode option[value=BBS150]").hide();
	$("#prse_servicecode option[value=BBS200]").hide();
	$("#prse_servicecode option[value=BBS250]").hide();
	$("#prse_servicecode option[value=BBS300]").hide();
	$("#prse_servicecode option[value=BBS350]").hide();
	$("#prse_servicecode option[value=BBS355]").hide();
	$("#prse_servicecode option[value=BBS75-APR]").hide();
	$("#prse_servicecode option[value=BBSINTL]").hide();
}

function SetAll() {
	$("#prse_servicecode option[value=BBS100]").show();
	$("#prse_servicecode option[value=BBS100-E]").show();
	$("#prse_servicecode option[value=BBS150]").show();
	$("#prse_servicecode option[value=BBS200]").show();
	$("#prse_servicecode option[value=BBS250]").show();
	$("#prse_servicecode option[value=BBS300]").show();
	$("#prse_servicecode option[value=BBS350]").show();
	$("#prse_servicecode option[value=BBS355]").show();
	$("#prse_servicecode option[value=BBS75-APR]").show();
	$("#prse_servicecode option[value=BBSINTL]").show();
	$("#prse_servicecode option[value=L100]").show();
	$("#prse_servicecode option[value=L150]").show();
	$("#prse_servicecode option[value=L200]").show();
	$("#prse_servicecode option[value=L201]").show();
	$("#prse_servicecode option[value=L300]").show();
	$("#prse_servicecode option[value=L301]").show();
	$("#prse_servicecode option[value=L99]").show();
}
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
var userlogon = null;

function InitializeListing()
{
    //alert(document.referrer);
    //SelectDropdownItemByValue("comm_status", "sagecrm_code_all");


	var sUrl=new String( location.href );
	
	iQMark = sUrl.indexOf("?");
	var sQuery = new String (sUrl.slice(iQMark, sUrl.length));
		
	// step 1 - Remove the New Appointment and Email buttons
	hideButton("/Buttons/newappointment.png");
	hideButton("/Buttons/newemail.png");
    // calendar too
    hideButton("/Buttons/Calendar.gif");

    AddArchiveReportButton();
}

function Initialize() {
	var sUrl=new String( location.href );
	iQMark = sUrl.indexOf("?");
    //alert(sUrl);
	var sHREF = new String (sUrl.substring(0, iQMark));
	var sQuery = new String (sUrl.slice(iQMark, sUrl.length));

	// step 1 - Remove the New Company and Person buttons
    hideButton("/Buttons/NewIndividual.gif", "TD");	
    
    // Step 2 - Hide the New Appointment and Delete buttons
    hideButton("/Buttons/newappointment.png");
    hideButton("/Buttons/Delete.gif"); 

    // step 3 - Remove the Regarding advanced search select and replace it with the 
    //          opportunity, case, or special service file.
    var sKey0 = "";
    sKey0 = getKey(GetKeys(), "Key0");
    spn = document.all("_Datacomm_opportunityid");
    if (spn != null)
    {
        var parent = spn.parentElement;
        while (parent != null && parent.tagName != "TD")
            parent = parent.parentElement;
            
        if (spn != null )
        {
            if (sKey0 == "7")
                spn.innerHTML = "Opportunity Workflow";
            else if (sKey0 == "8")
                spn.innerHTML = "Customer Care Workflow";
            else
            {
                if (parent != null)
                    parent.style.display = "none";
            }
        }    
    }

    // Step 4 - Remove invalid dropdwon values
    RemoveDropdownItemByValue("comm_action", "M"); 
    RemoveDropdownItemByValue("comm_action", "P"); 
    RemoveDropdownItemByValue("comm_action", "E"); 
    RemoveDropdownItemByValue("comm_action", "F"); 
    RemoveDropdownItemByValue("comm_action", "T"); 
    RemoveDropdownItemByValue("comm_action", "S"); 
    RemoveDropdownItemByValue("comm_action", "L"); 
    RemoveDropdownItemByValue("comm_action", "R"); 
    RemoveDropdownItemByValue("comm_action", "O"); 
    
    // changing the cancel links because the value of 430 generates a 
    // cannot browse directory error
    var arrAnchors = document.getElementsByTagName("A");
    for (var ndx=0; ndx < arrAnchors.length; ndx++)
    {
        sContent = String (arrAnchors[ndx].href);
        //alert (sContent );
        var regexp = new RegExp('Act=430&', 'gi');
        if (regexp.test(sContent)==true)
        {
            //alert("Changing");
            sContent = sContent.replace(regexp, 'Act=183&');
            arrAnchors[ndx].href= sContent;
        }  
    }
    
    //return;

    AddCompanySummaryButton();

    if (document.getElementById("_HIDDENcomm_createddate").value == "") {
        RemoveDropdownItemByValue("comm_prsubcategory", "ARSub");
    }
}

function initializePage() {
    sContents = "<span>";
    sContents += "<img class=ButtonItem align=left border=0 src=\"../../img/Buttons/new.gif\" " +
        " onclick=\"javascript:timestampRecordOfActivity();\">";
    sContents += "<span class=ButtonItem onclick=\"javascript:timestampRecordOfActivity();\">";
    sContents += "Add Timestamp</span>";
    sContents += "</span>";
    AppendCell("_Captcomm_note", sContents);
}

function timestampRecordOfActivity() {
    var obj = document.EntryForm.comm_note;
    sValue = "";
    if (obj)
    {
        sValue = new String(getDatetimeAsString() + ' ' + String(userlogon).toUpperCase() + ': ');
        obj.value = sValue + "\n" + obj.value;
    }
}

function AddArchiveReportButton() {

    var sImgName = "help.gif";
    var arrImgs = document.getElementsByTagName("IMG");
    var img = null;
    for (var ndx = 0; ndx < arrImgs.length; ndx++) {
        if (arrImgs[ndx].src.indexOf(sImgName) > -1) {
            img = arrImgs[ndx];
            break;
        }
    }

    if (img == null)
        sImgName = "newtask.gif";

    AddButton("trArchiveReport", sImgName);
}

var xmlHttp = null;
var sCompanyID;
var sPersonID;

function WriteArchiveReportButtonTable() {

    var sAction = document.forms[0].action;
    var sKey0 = getKey(sAction, "Key0");
    sCompanyID = getKey(sAction, "Key1");
    sPersonID = getKey(sAction, "Key2");

    // Write this out now before the page finishes loading.  It has to be done
    // here instead of the within the onload event handler.   
    WriteButtonTable("trArchiveReport", "componentpreview.gif", "Archived Interactions Report", "");

    // Query for our SSRS URL, and invoke a method that finally sets the report links.
    //xmlHttp = new ActiveXObject("Microsoft.XMLHTTP");
    xmlHttp = new XMLHttpRequest();
    xmlHttp.onreadystatechange = SetArchiveReportURL;
    xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/GetCustomCaptionValue?szFamily=SSRS&szCode=URL", true);
    xmlHttp.send(null);
}

function SetArchiveReportURL() {
    if (xmlHttp.readyState == 4) {

        var sResponse = xmlHttp.responseXML.getElementsByTagName("string")[0].childNodes[0].nodeValue;

        var sReportURL = sResponse + "/CRMArchive/InteractionsSummary";
        if (sCompanyID != null) {
            sReportURL = sReportURL + "&CompanyID=" + sCompanyID;
        }
        if (sPersonID != null) {
            sReportURL = sReportURL + "&PersonID=" + sPersonID;
        }
        sReportURL += "&rc:Parameters=false";
        document.getElementById("a1trArchiveReport").href = "javascript:ViewReport('" + sReportURL + "');";
        document.getElementById("a2trArchiveReport").href = "javascript:ViewReport('" + sReportURL + "');";
    }
}


function WriteCompanySummaryButtonTable() {

    var sAction = document.forms[0].action;
    if (sAction == "") {
        sAction = window.location.href;
    }
    
    var sCompanyID = getKey(sAction, "Key1");
    var sSID = getKey(sAction, "SID");

    if (sCompanyID == null) {
        var eCompanyID = document.getElementById("cmli_comm_companyid");
        if (eCompanyID != null) {
            sCompanyID = eCompanyID.value;
        }
    }


    //if (sCompanyID == null) {
    //    return;
    //}

    // Write this out now before the page finishes loading.  It has to be done
    // here instead of the within the onload event handler.
    WriteButtonTable("trCompanySummaryButton", "newcompany.gif", "Company Summary", "/CRM/CustomPages/PRCompany/PRCompanySummary.asp?Key0=1&SID=" + sSID + "&comp_companyid=" + sCompanyID + "&Key1=" + sCompanyID);
}

//
//  This function is called from different onLoad functions on different pages.
//  Sometimes it is the initialize() function above, sometimes it is an onload
//  generated by the ASP script.
//
function AddCompanySummaryButton() {

    var sBeforeButtonImg = "help.gif";
    
    var arrImgs = document.getElementsByTagName("IMG");
    var img = null;
    for (var ndx = 0; ndx < arrImgs.length; ndx++) {
        if (arrImgs[ndx].src.indexOf(sBeforeButtonImg) > -1) {
            img = arrImgs[ndx];
            break;
        }
    }
    if (img == null) {
        sBeforeButtonImg = "componentpreview.gif";
    }

    var sCompanyID = document.getElementById("cmli_comm_companyid").value;

    var anchor = document.getElementById("a2trCompanySummaryButton");
    anchor.href = anchor.href.replace("comp_companyid=null", "comp_companyid=" + sCompanyID);
    anchor.href = anchor.href.replace("key0=null", "key0=1");
    AddButton("trCompanySummaryButton", sBeforeButtonImg);
}


function RedirectInteraction() {
    var sUrl = String(location.href);

    iEWare = sUrl.indexOf("eware.dll");
    var sApp = String(sUrl.substring(0, iEWare));

    iQMark = sUrl.indexOf("?");
    var sQuery = String(sUrl.slice(iQMark, sUrl.length));

    var sAction = String("");
    ndx = sQuery.indexOf("&Act=");
    if (ndx == -1) {
        ndx = sQuery.indexOf("?Act=");
    }

    if (ndx >= 0) {
        ndxNext = sQuery.indexOf("&", ndx + 5);

        sAction = sQuery.substring(ndx + 5, ndxNext);
        //if ((sAction == "363") ||
        //    (sAction == "364")) {

        if (sAction == "363") {
            var comp_CompanyID = getKey(sQuery, "Key1")

            sQuery = removeKey(sQuery, "Act");
            sQuery = removeKey(sQuery, "T");

            //if (sAction == "364") {
            //    sQuery += "&NewStatus=Complete";
            //}

            location.href = sApp + "CustomPages/PRGeneral/PRInteraction.asp" + sQuery + "&J=PRGeneral/PRInteraction.asp&comp_CompanyID=" + comp_CompanyID;
            //location.href = sApp + sQuery + "&dotnetdll=TravantCRM&dotnet-func=RunCompanyInteractionListing&J=PRGeneral/PRInteraction.asp&comp_CompanyID=" + comp_CompanyID;
            
        }
        if (sAction == "361" || sAction == "363") {
            //override Cancel button to go to custom Interaction list page instead eware version
            if (window.addEventListener) { window.addEventListener("load", newInteractionCancelHref); } else { window.attachEvent("onload", newInteractionCancelHref); }
            if (window.addEventListener) { window.addEventListener("load", removeButtons); } else { window.attachEvent("onload", removeButtons); }
        }
    }
    else {
        var ndxKey0_6 = sQuery.indexOf("&Key0=6");
        var ndxJ = sQuery.indexOf("&J=PRGeneral/PRInteraction.asp");
        if (ndxKey0_6 >= 0 && ndxJ >= 0) {
            //override Cancel button to go to custom Interaction list page instead eware version
            if (window.addEventListener) { window.addEventListener("load", postEWareCancelHref); } else { window.attachEvent("onload", postEWareCancelHref); }
        }
    }

    return;
}

function initOnLoad() {

        
    window.addEventListener('load', function () {
        InitializeListing();
        setDefaultStatus();
    });
}

function newInteractionCancelHref() {
    //override Cancel button to go to custom Interaction list page instead eware version
    var SID = getKey(location.href, "SID");
    var Key1 = getKey(location.href, "Key1");
    var F = getKey(location.href, "F");

    if (F !=null && F != "") {
        var h = document.getElementById("Button_Cancel").href;
        if (h == null)
            return;

        //Inject custom url on Cancel Button
        var eWarePos = location.href.indexOf("eware.dll/Do");
        h = h.substring(0, eWarePos);
        //h = h + "CustomPages/PRInteraction/PRCompanyInteractions.asp?SID=" + SID + "&Key0=1&Key1=" + Key1 + "&J=PRInteraction/PRCompanyInteractions.asp&F=PRInteraction/PRCompanyInteractions.asp&T=Company";
        h = h + "?SID=" + SID + "&dotnetdll=TravantCRM&dotnet-func=RunCompanyInteractionListing&Key0=1&Key1=" + Key1 + "&J=PRInteraction/PRCompanyInteractions.asp&F=PRInteraction/PRCompanyInteractions.asp&T=Company";

        document.getElementById("Button_Cancel").href = h;
    }
}

function postEWareCancelHref() {
    //override Cancel button after coming back from eware page (such as Add Attachment)
    var SID = getKey(location.href, "SID");
    var Key1 = getKey(location.href, "Key1");
    var Key4 = getKey(location.href, "Key4");

    var h = document.getElementById("Button_Cancel").href;
    if (h == null)
        return;

    //Inject custom url on Cancel Button
    var PRIntPos = location.href.indexOf("CustomPages/PRGeneral/PRInteraction.asp");
    if (PRIntPos >= 0) {
        h = h.substring(0, PRIntPos);
        
        if (Key4 != null && Key4 == "7") {
            //MYCRM
            h = h + "eware.dll/Do?Act=183&SID=" + SID + "&ErgTheme=0&Key0=4&Key4=7&T=User&ErgTheme=0";
            document.getElementById("Button_Cancel").href = h;
        }
        else {
            //h = h + "CustomPages/PRInteraction/PRCompanyInteractions.asp?SID=" + SID + "&Key0=1&Key1=" + Key1;
            h = h + "?SID=" + SID + "&dotnetdll=TravantCRM&dotnet-func=RunCompanyInteractionListing&Key0=1&Key1=" + Key1;
            
            document.getElementById("Button_Cancel").href = h;
        }
    }
}

function removeButtons() {
    //defect 5767 - remove Show Campaigns and Add Attachment buttons
    var buttons = document.getElementsByClassName("er_buttonItem");
    for (var i = 0; i < buttons.length; i++) {
        if (buttons.item(i).id == 'Button_ShowCampaigns' || 
            buttons.item(i).id == 'Button_AddAttachment')
        buttons.item(i).classList.add('DisplayNone');
    }
}

function setDefaultStatus() {
    var key0 = getKey(GetKeys(), "Key0");

    //alert(key0);


    // If we're in a company context, reset
    // the status
    if ((key0 != null) &&
        ((key0 == "1") ||
         (key0 == "2") ||
         (key0 == "58ccc"))) {
        var status = document.getElementById('_HIDDENcomm_status');
        if (status.value !== 'sage_code_all') {
            status.value = 'sage_code_all';
            document.getElementById('comm_status').value = 'sage_code_all';

            if (document.EntryForm.HIDDEN_FilterMode) {
                document.EntryForm.HIDDEN_FilterMode.value = 't';
            }
            
            try {
                checkSubmit(document.EntryForm);
            } catch (e) {
                document.EntryForm.submit();
            }
        }
    }
}

function hideDropdownValues() {

    window.addEventListener('load', function () {
        hideDropdownValues2();
    });
}

function hideDropdownValues2() {
    // Step 4 - Remove invalid dropdwon values
    RemoveDropdownItemByValue("comm_action", "M");
    RemoveDropdownItemByValue("comm_action", "P");
    RemoveDropdownItemByValue("comm_action", "E");
    RemoveDropdownItemByValue("comm_action", "F");
    RemoveDropdownItemByValue("comm_action", "T");
    RemoveDropdownItemByValue("comm_action", "S");
    RemoveDropdownItemByValue("comm_action", "L");
    RemoveDropdownItemByValue("comm_action", "R");
    RemoveDropdownItemByValue("comm_action", "O");

    if (document.getElementById("_HIDDENcomm_createddate").value == "") {
        RemoveDropdownItemByValue("comm_prsubcategory", "ARSub");
    }
}

function processNSChange() {
    //New Status
    var keyNS = getUrlParameter('NS');
    if (keyNS == null)
        keyNS = "";
    if (keyNS != "") {
        $("#comm_status").val(keyNS);
    }
}

function processOrganizer() {
    if ($("#comm_organizer option:selected").val() == "-1000") {
        $('#comm_organizer').val('');
    }
}

var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
        sURLVariables = sPageURL.split('&'),
        sParameterName,
        i;

    for (i = 0; i < sURLVariables.length; i++) {
        sParameterName = sURLVariables[i].split('=');

        if (sParameterName[0] === sParam) {
            return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
        }
    }
};

function save() {

    var szErrors = "";

    if (document.getElementById("comm_action").value == '') {
        szErrors += " - An Action must be entered.\n";
    }

    if (document.getElementById("comm_subject").value == '') {
        szErrors += " - A Subject must be entered.\n";
    }

    if (document.getElementById("comm_note").value == '') {
        szErrors += " - Details must be entered.\n";
    }


    if (szErrors.length > 0) {
        alert("Please correct the following errors:\n\n" + szErrors);
        return false;
    }

    document.EntryForm.submit();
}
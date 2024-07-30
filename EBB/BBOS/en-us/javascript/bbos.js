//***********************************************************************
//***********************************************************************
// Copyright Produce Reporter Co. 2007-2024
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
// Filename: bbos.js
// Description:	
//
// Notes:		
//
//***********************************************************************
//***********************************************************************%>

function displayReadOnlyMsg(e) {

    if (document.getElementById('pnlReadOnlyPopup') != null) {
        document.getElementById('pnlReadOnlyPopup').style.position = "fixed";
        document.getElementById('pnlReadOnlyPopup').style.top = "50%";
        document.getElementById('pnlReadOnlyPopup').style.left = "50%";
        document.getElementById('pnlReadOnlyPopup').style.display = 'block';

        document.body.className = "modalBackground";
    }

    return false;
}

function hideReadOnlyMsg() {

    document.body.className = "";
    if (document.getElementById('pnlReadOnlyPopup') != null) {
        document.getElementById('pnlReadOnlyPopup').style.display = 'none';
        document.body.className = "";
    }
}

function openListing(szURL) {

    openBBOSWindow(szURL, "width=600,height=600");

    if (document.getElementById('pnlListing') != null) {
        document.getElementById('pnlListing').style.display = 'none';
    }
}

function openContact(szURL) {
    openBBOSWindow(szURL, "width=600,height=300");
}

function openBBOSWindow(szFileName, szParms) {
    window.open(szFileName,
        "bbos",
        "location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes," + szParms, true);
}

//
// Looks at the next sibling Rows of the selected 
// row and "toggles" any rows with a higher level 
// ID until a row is found with the same or lower
// level ID.  
function ToggleChildNodes(e) {
    var chk = e;
    var curRow

    // Used for cross-browser compatiblity.
    if (chk.parentNode) {
        curRow = chk.parentNode;
    } else if (chk.parentElement) {
        curRow = chk.parentElement;
    }

    // Though we have our checkboxes parent element,
    // iterate through the parents to make sure we have
    // the parent TR node.
    while (curRow.tagName != "TR") {

        // Used for cross-browser compatiblity.
        if (curRow.parentNode) {
            curRow = curRow.parentNode;
        } else if (curRow.parentElement) {
            curRow = curRow.parentElement;
        }
    }

    if (curRow.rowIndex < 0)
        return;

    ProcessChildNodes(curRow, chk.checked);
}

//
// Looks for any rows immediately following the
// current row who's <TR> tag has a Level attribute
// greater than our specified row.  If found,
// toggles the checkbox appropriately.
function ProcessChildNodes(curRow, bDisable) {

    //var iCurRowLevel = curRow.Level;
    var iCurRowLevel = curRow.getAttribute('Level');
    var oRow = GetNextRow(curRow.nextSibling);

    while (oRow != null) {
        var iRowLevel = oRow.getAttribute('Level');
        if (iRowLevel <= iCurRowLevel) {
            return;
        } else {

            var arrChk = oRow.getElementsByTagName("INPUT");
            if (arrChk.length == 0)
                return;

            arrChk[0].disabled = bDisable;
            if (bDisable && (arrChk[0].checked == true)) {
                arrChk[0].checked = false;
            }

        }
        oRow = GetNextRow(oRow.nextSibling);
    }
}

//
// IE returns the next sibling of the same type
// while other browers return the next child, regardless
// of position in the hierarchy.
function GetNextRow(curElement) {
    var parentRow = curElement;

    while ((parentRow != null) &&
        (parentRow.tagName != "TR")) {
        parentRow = parentRow.nextSibling;
    }

    return parentRow;
}


//
// Used to iterate through a table's rows
// and invokes ProcessChildNodes on any
// node that is already selected.
function ProcessPresetNodes(eTable) {

    var oRow = eTable.rows[0];

    while (oRow != null) {
        var arrChk = oRow.getElementsByTagName("INPUT");
        if (arrChk.length >= 0) {

            if (arrChk[0].checked) {
                ProcessChildNodes(oRow, true);
            }
        }

        oRow = oRow.nextSibling
    }
}

var szClass = "";
function highlightRow(obj, newClass) {
    if (obj.className != "colHeader") {
        szClass = obj.className;
        obj.className = newClass;
    }
}

function restoreRow(obj) {
    if (obj.className != "colHeader") {
        obj.className = szClass;
    }
}

function EnableRowHighlight(objTable) {

    if (objTable == undefined) {
        return;
    }

    var rows = objTable.getElementsByTagName('tr');
    for (iRowIndex = 0; iRowIndex < rows.length; iRowIndex++) {

        rows[iRowIndex].onmouseover = function () {
            highlightRow(this, 'highlightrow');
        }

        rows[iRowIndex].onmouseout = function () {
            restoreRow(this, '');
        }
    }
}

function newConfirm(title, mess, icon, defbut, mods) {
    if (document.all) {
        icon = (icon == 0) ? 0 : 2;
        defbut = (defbut == 0) ? 0 : 1;
        retVal = makeMsgBox(title, mess, icon, 4, defbut, mods);
        retVal = (retVal == 6);
    }
    else {
        retVal = confirm(mess);
    }
    return retVal;
}


function openRatingWindow() {
    winRatingHandle = window.open("RatingDefinition.html",
        "ebbRating",
        "height=400,width=625,location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes", true);
}


function SelectPartialList2(szControlGroupName, bGreaterThan, iMaxControlIndex) {
    var iSequence = -1;

    for (i = 0; i <= iMaxControlIndex; i++) {
        var szControlID = szControlGroupName + i;

        var e = document.getElementById(szControlID);
        if (e != null) {
            if (e.checked) {
                iSequence = i;
                if (bGreaterThan) {
                    break;
                }
            }
        }
    }

    if (iSequence > -1) {
        SelectPartialList(iSequence, szControlGroupName, bGreaterThan, iMaxControlIndex);
    }
}

function SelectPartialList(iSequence, szControlGroupName, bGreaterThan, iMaxControlIndex) {

    iCurrentSequence = new Number(iSequence);

    if (bGreaterThan) {
        // Select all controls less than or equal to the current control
        for (i = iCurrentSequence; i <= iMaxControlIndex; i++) {
            var szControlID = szControlGroupName + i;
            var e = document.getElementById(szControlID);
            if (e != null) {
                e.checked = true;
            }
        }
    }
    else {
        // Select all controls less than or equal to the current control
        for (i = 0; i <= iCurrentSequence; i++) {
            var szControlID = szControlGroupName + i;
            var e = document.getElementById(szControlID);
            if (e != null) {
                e.checked = true;
            }
        }
    }
}

var TRange = null;

function findString(str) {
    if (parseInt(navigator.appVersion) < 4) return;
    var strFound;

    if (window.find) {
        // CODE FOR BROWSERS THAT SUPPORT window.find
        strFound = self.find(str);
        if (strFound) {
            if (!window.getSelection().anchorNode || !window.getSelection().anchorNode.innerHTML.indexOf('findString') >= 0)
                strFound = self.find(str); //fix Chrome and Firefox issue
        }
        else {
            strFound = self.find(str, 0, 1);
            while (self.find(str, 0, 1)) continue;
        }
    }
    else if (navigator.appName.indexOf("Microsoft") != -1 || navigator.appName.toString().toUpperCase() == "NETSCAPE") {
        // EXPLORER-SPECIFIC CODE
        if (TRange != null) {
            TRange.collapse(false);
            strFound = TRange.findText(str);
            if (strFound) TRange.select();
        }
        if (TRange == null || strFound == 0) {
            TRange = self.document.body.createTextRange();
            strFound = TRange.findText(str);
            if (strFound) TRange.select();
        }
    }
    else if (navigator.appName == "Opera") {
        bbAlert("Opera browsers not supported, sorry...")
        return;
    }
    if (!strFound) bbAlert("String '" + str + "' not found!")
    return;
}

function ToggleMustHave(eCheckbox, szControlGroup) {

    if (eCheckbox == null) {
        return;
    }

    var disabled = eCheckbox.checked;

    switch (szControlGroup) {
        case "Fax":
            lblFax.disabled = disabled;
            txtFaxAreaCode.disabled = disabled;
            txtFaxNumber.disabled = disabled;
            break;

        case "Email":
            lblEmail.disabled = disabled;
            txtEmail.disabled = disabled;
            break;

        case "TMFM":
            //document.getElementById('contentMain_ddlMembershipYearSearchType').disabled = disabled;
            //document.getElementById('contentMain_ddlMembershipYear').disabled = disabled;
            //document.getElementById('contentMain_lblMembershipYear').disabled = disabled;

            break;
    }
}

function ToggleNewListing(eCheckbox) {
    if (eCheckbox.checked == true) {
        document.getElementById("NewListingRange").disabled = false;
    } else {
        document.getElementById("NewListingRange").disabled = true;
    }
}

function ToggleRadius(eTermMktTable, ePostal, bEnable) {

    var bEnableRadius = false;

    if (bEnable) {
        bEnableRadius = true;
    }

    // If a value is entered in the Postal code, enable the radius search
    if (ePostal != null) {
        if (ePostal.value.length > 0) {
            bEnableRadius = true;
        }
    }

    // If the terminal market table is displayed, and one of it's items is 
    // selected, enable the radius search	
    if (eTermMktTable != null) {


        var rowCount = eTermMktTable.rows.length;
        for (j = 0; j < rowCount; j++) {
            var oRow = eTermMktTable.rows[j];
            var arrChk = oRow.getElementsByTagName("INPUT");
            if (arrChk.length >= 0) {
                for (i = 0; i < arrChk.length; i++) {
                    if (arrChk[i].checked) {
                        bEnableRadius = true;
                    }
                }
            }

        }
    }

    if (bEnableRadius) {
        document.getElementById("trRadius").disabled = false;
    } else {
        document.getElementById("trRadius").disabled = true;
    }
}

function ToggleStatementMonths(eStatementType) {
    if (eStatementType.value == "I") {
        document.getElementById("StatementMonths").disabled = false;
        ddlMonths.disabled = false;
    } else {
        document.getElementById("StatementMonths").disabled = true;
        ddlMonths.disabled = true;
    }
}

function SetClassificationRank(eCheckbox, szName) {
    bFound = false;
    for (i = 0; i < lbRank.options.length; i++) {
        if (lbRank.options[i].value == eCheckbox.value) {
            bFound = true;
            if (eCheckbox.checked == false) {
                lbRank.options[i] = null;
            }
        }
    }

    if (bFound == false) {
        lbRank.options[lbRank.options.length] = new Option(szName, eCheckbox.value);
    }

    if (lbRank.options.length > 8) {
        lbRank.size = lbRank.options.length;
    }
}

function GetMemberHomePageImage() {
    iArray = new Array("index_mimageswap.gif",
        "mimageswap2.gif",
        "mimageswap3.gif",
        "mimageswap4.gif");
    ri = Math.floor(iArray.length * Math.random());
    return '<img src="' + iArray[ri] + '" border=0>';
}


function AutoCompleteSelected(source, eventArgs) {

    if (eventArgs.get_value() != null) {
        document.getElementById('QuickFind_txtQuickFind').value = "";
        document.location.href = "Company.aspx?CompanyID=" + eventArgs.get_value();
    }
}

function acePopulated(sender, e) {

    var target = sender.get_completionList();
    target.className = "AutoCompleteFlyout";

    var children = target.childNodes;
    var searchText = sender.get_element().value;

    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        var arrValue = child.innerHTML.split("|");

        var legalName = "";
        if (arrValue[1] != "") {
            legalName = "(" + arrValue[1] + ")<br/>";
        }


        var NodeText = "<span style=\"font-weight:bold;\">" + arrValue[0] + "</span> (" + arrValue[2] + ")<br/>" + legalName + arrValue[3];


        if (i % 2 == 0) {
            child.className = "AutoCompleteFlyoutItem";
        } else {
            child.className = "AutoCompleteFlyoutShadeItem";
        }

        child.innerHTML = NodeText;

        if (child.childNodes[0].tagName == "SPAN") {
            child.childNodes[0]._value = child._value;
        }
    }
}

var szDownloadListingURL = null;
function showListing(e, szCompanyID) {
    document.getElementById('hlListingDownloadListing').style.display = 'none';
    document.getElementById('hlListingDownloadListing').disabled = true;
    PRCo.BBOS.UI.Web.AJAXHelper.GetListing(szCompanyID, setListingFromResponse);

    var eParent = e.offsetParent;
    var iParentOffsetTop = 0;
    var iParentOffsetLeft = 0;
    while (eParent != null) {
        iParentOffsetTop = iParentOffsetTop + eParent.offsetTop;
        iParentOffsetLeft = iParentOffsetLeft + eParent.offsetLeft;
        eParent = eParent.offsetParent;
    }

    document.getElementById('pnlListing').style.left = (iParentOffsetLeft + 26) + 'px';
    document.getElementById('pnlListing').style.top = (iParentOffsetTop + 15) + 'px';

    document.getElementById('hidListingCompanyID').value = szCompanyID;

    if (bListingButtonsEnabled) {
        if (szDownloadListingURL == null) {
            szDownloadListingURL = document.getElementById('hlListingDownloadListing').href;
        }

        document.getElementById('hlListingDownloadListing').href = szDownloadListingURL + szCompanyID;

        if (szCompanyID != '') {
            document.getElementById('hlListingDownloadListing').disabled = false;
            document.getElementById('hlListingDownloadListing').style.display = '';
        }
    } else {
        document.getElementById('hlListingDownloadListing').disabled = true;
        document.getElementById('hlListingDownloadListing').style.display = 'none';
    }
}

function setListingFromResponse(arg) {
    document.getElementById('ltListing').innerHTML = arg;
    document.getElementById('pnlListing').style.display = "block";
}

function hideListing() {
    document.getElementById('pnlListing').style.display = "none";
}


function SetShadeRow(objTable) {

    if (objTable == undefined) {
        return;
    }

    var rows = objTable.getElementsByTagName('tr');
    for (iRowIndex = 0; iRowIndex < rows.length; iRowIndex++) {

        if ((iRowIndex % 2) == 0) {
            rows[iRowIndex].className = "shaderow";
        }
    }
}


var szRegion2 = ",Alaska,Idaho,Montana,Oregon,Washington,Wyoming,,";
var szRegion3 = ",Arizona,California,Colorado,Hawaii,Nevada,New Mexico,Utah,";
var szRegion4 = ",Illinois,Indiana,Iowa,Kansas,Kentucky,Michigan,Minnesota,Missouri,Nebraska,North Dakota,Ohio,South Dakota,Wisconsin,";
var szRegion5 = ",Arkansas,Louisiana,Mississippi,Oklahoma,Texas,";
var szRegion6 = ",Alabama,Florida,Georgia,North Carolina,South Carolina,Tennessee,";
var szRegion7 = ",Connecticut,Delaware,District of Columbia,Maine,Maryland,Massachusetts,New Hampshire,New Jersey,New York,Pennsylvania,Rhode Island,Vermont,Virginia,West Virginia,";
function toggleRegion(RegionID, bChecked) {

    var szPrefix = "ctl00$contentMain$cblStatesFor_1$";

    var szRegion = "";
    switch (RegionID) {
        case "2":
            szRegion = szRegion2;
            break;
        case "3":
            szRegion = szRegion3;
            break;
        case "4":
            szRegion = szRegion4;
            break;
        case "5":
            szRegion = szRegion5;
            break;
        case "6":
            szRegion = szRegion6;
            break;
        case "7":
            szRegion = szRegion7;
            break;
    }

    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    for (var i = 0; i < oCheckboxes.length; i++) {

        if ((oCheckboxes[i].type == "checkbox") &&
            (oCheckboxes[i].name.indexOf(szPrefix) == 0)) {

            parentTD = oCheckboxes[i].parentNode;
            if (parentTD.textContent) {
                stateID = parentTD.textContent;
            } else {
                stateID = parentTD.innerText;
            }

            if (szRegion.indexOf("," + stateID + ",") > -1) {
                oCheckboxes[i].checked = bChecked;
            }
        }
    }


    refreshCriteria();
}


function toggleRead(e) {
    var sLinkID = new String(e.id);
    var sImgID = sLinkID.replace("lnkArticleName1", "imgRead").replace("lnkArticleName2", "imgRead");

    var eImg = document.getElementById(sImgID);
    var sSrc = new String(eImg.src);
    if (sSrc.endsWith("unread.png")) {
        eImg.src = imgRead;
    }
}


function showRatingDef(e, szRatingID) {

    if (szRatingID == "") {
        document.getElementById('ltRatingDef').innerHTML = document.getElementById('litNonMemberRatingDef').innerHTML;
        document.getElementById('pnlRatingDef').style.display = "block";
    } else {
        PRCo.BBOS.UI.Web.AJAXHelper.GetRatingDefinition_NoButton(szRatingID, setRatingDefResponse);
    }

    var eParent = e.offsetParent;
    var iParentOffsetTop = 0;
    var iParentOffsetLeft = 0;
    while (eParent != null) {
        iParentOffsetTop = iParentOffsetTop + eParent.offsetTop;
        iParentOffsetLeft = iParentOffsetLeft + eParent.offsetLeft;
        eParent = eParent.offsetParent;
    }

    document.getElementById('pnlRatingDef').style.left = (iParentOffsetLeft - 340) + 'px';
    document.getElementById('pnlRatingDef').style.top = (iParentOffsetTop + 25) + 'px';
}

function setRatingDefResponse(arg) {
    document.getElementById('ltRatingDef').innerHTML = arg;
    document.getElementById('pnlRatingDef').style.display = "block";
}

function hideRatingDef() {
    document.getElementById('pnlRatingDef').style.display = "none";
}



function ToggleInitialState() {
    ToggleRadius(null, null, true);
}

function getSelectedCountry() {
    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    var countryID = "";
    var parentTD = null;
    for (var i = 0; i < oCheckboxes.length; i++) {

        if ((oCheckboxes[i].type == "checkbox") &&
            (oCheckboxes[i].name.indexOf("ctl00$contentMain$cblCountry") == 0)) {
            if (oCheckboxes[i].checked) {

                // We only allow one country to be checked for
                // the listing city ACE to fire off.  If we
                // find more than one, set our context to
                // 0 so nothing will be found.
                if (countryID != "") {
                    countryID = "";
                    break;
                }

                countryID = oCheckboxes[i].value;
            }
        }
    }

    if (countryID != "1" && countryID != "2" && countryID != "3")
        return "1";
    else
        return countryID;
}

function getSelectedCountry2() {
    var countryID = $("input[name='ctl00$contentMain$select-country']:checked").val();

    if (countryID != "1" && countryID != "2" && countryID != "3")
        return "1";
    else
        return countryID;
}

function getSelectedState() {
    var oCheckboxes = document.body.getElementsByTagName("INPUT");
    var stateID = "";
    var parentTD = null;
    for (var i = 0; i < oCheckboxes.length; i++) {

        if ((oCheckboxes[i].type == "checkbox") &&
            (oCheckboxes[i].name.indexOf("ctl00$contentMain$cblStates") == 0)) {
            if (oCheckboxes[i].checked) {

                // We only allow one state to be checked for
                // the listing city ACE to fire off.  If we
                // find more than one, set our context to
                // 0 so nothing will be found.
                if (stateID != "") {
                    stateID = "";
                    break;
                }

                parentTD = oCheckboxes[i].parentNode;
                if (parentTD.textContent) {
                    stateID = parentTD.textContent;
                } else {
                    stateID = parentTD.innerText;
                }
            }
        }
    }

    return stateID;
}

function getSelectedState2() {
    var stateID = $("#contentMain_hidSelectedStates").val();
    // We only allow one state to be checked for
    // the listing city ACE to fire off.  If we
    // find more than one, set our context to
    // 0 so nothing will be found.
    if (stateID.indexOf(',') > -1) {
        stateID = "";
    }

    return stateID;
}

function aceCityPopulating(sender, e) {
    var stateID = getSelectedState();
    var countryID = getSelectedCountry();
    var autoComplete = $find('aceListingCity');
    autoComplete.set_contextKey(stateID + "|" + countryID);
}

function aceCityPopulating2(sender, e) {
    var stateID = getSelectedState2();
    var countryID = getSelectedCountry2();
    var autoComplete = $find('aceListingCity');
    autoComplete.set_contextKey(stateID + "|" + countryID);
}


function aceCityPopulated(sender, e) {
    var target = sender.get_completionList();
    target.className = "AutoCompleteFlyout";

    var children = target.childNodes;
    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        if (i % 2 == 0) {
            child.className = "AutoCompleteFlyoutItem";
        } else {
            child.className = "AutoCompleteFlyoutShadeItem";
        }
    }
}

function aceCitySelected(source, eventArgs) {
    if (eventArgs.get_value() != null) {

        var aceCity = "";
        var aceState = "";
        var aceValue = new String(eventArgs.get_value());
        iComma = aceValue.indexOf(',', 0);

        aceCity = aceValue.substr(0, iComma);
        aceState = aceValue.substring(iComma + 2, aceValue.length);

        txtListingCity.value = aceCity;

        var oCheckboxes = document.body.getElementsByTagName("INPUT");
        var parentTD = null;
        for (var i = 0; i < oCheckboxes.length; i++) {

            if ((oCheckboxes[i].type == "checkbox") &&
                (oCheckboxes[i].name.indexOf("ctl00$contentMain$cblStates") == 0)) {

                parentTD = oCheckboxes[i].parentNode;
                if (parentTD.textContent) {
                    stateID = parentTD.textContent;
                } else {
                    stateID = parentTD.innerText;
                }

                if (stateID == aceState) {
                    oCheckboxes[i].checked = true;
                    break;
                }
            }
        }
    }
}

function aceCitySelected2(source, eventArgs) {
    if (eventArgs.get_value() != null) {

        var aceCity = "";
        var aceState = "";
        var aceValue = new String(eventArgs.get_value());
        iComma = aceValue.indexOf(',', 0);

        aceCity = aceValue.substr(0, iComma);
        aceState = aceValue.substring(iComma + 2, aceValue.length);

        txtListingCity.value = aceCity;

        if (mulSel_selectSingleStateByName) {
            mulSel_selectSingleStateByName(aceState);
        }
    }
}

function openTrainingVideoWindow(articleID, publicationCode) {
    window.open(_videoURL + "?PublicationArticleID=" + articleID + "&PublicationCode=" + publicationCode, "VideoPlayer", "width=1000px, height=650px");
}


function setSelectedCountInternal(checkboxName, labelControlID, suffix) {
    suffix = suffix || " selected";

    var i, count = 0

    if (typeof document.forms[0][checkboxName] != 'undefined') {
        dLen = document.forms[0][checkboxName].length;

        // if the length property is undefined there is only one checkbox
        if (typeof dLen == "undefined") {
            if (document.forms[0][checkboxName].checked) {
                count++;
            }
        }
        else {
            for (i = 0; i < dLen; i++) {
                if (document.forms[0][checkboxName][i].checked) {
                    count++;
                }
            }
        }
    }

    document.getElementById(labelControlID).innerHTML = count.toString() + suffix;
}

function getSelectedCountInternal(checkboxName) {
    var i, count = 0;

    if (typeof document.forms[0][checkboxName] != 'undefined') {
        dLen = document.forms[0][checkboxName].length;

        // if the length property is undefined there is only one checkbox
        if (typeof dLen == "undefined") {
            if (document.forms[0][checkboxName].checked) {
                count++;
            }
        }
        else {
            for (i = 0; i < dLen; i++) {
                if (document.forms[0][checkboxName][i].checked) {
                    count++;
                }
            }
        }
    }

    return count;
}

function displayMap() {

    var companyIDList = "";
    var checkedCount = 0;
    oListControl = document.getElementsByName("cbCompanyID");
    for (var i = 0; i < oListControl.length; i++) {
        if (oListControl[i].checked) {
            if (companyIDList.length > 0) {
                companyIDList += ",";
            }
            checkedCount++;
            companyIDList += oListControl[i].value;
        }
    }


    if (checkedCount = 0) {
        bbAlert("Please select companies to display on the map.");
        return;
    }

    if (checkedCount > 50) {
        bbAlert("Only 50 companies can be displayed on the map at one time.");
        return;
    }

    window.open("Map.aspx?CompanyIDList=" + companyIDList,
        "bbosMap",
        "width=1000,height=800",
        true);

    //"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=1000,height=800", true);
}



function displayUserListMap() {

    var userListIDList = "";
    var checkedCount = 0;
    oListControl = document.getElementsByName("rbUserListID");
    for (var i = 0; i < oListControl.length; i++) {
        if (oListControl[i].checked) {
            if (userListIDList.length > 0) {
                userListIDList += ",";
            }
            checkedCount++;
            userListIDList += oListControl[i].value;
        }
    }

    if (checkedCount = 0) {
        bbAlert("Please select Watchdog Categories to display on the map.");
        return;
    }

    window.open("Map.aspx?UserListIDList=" + userListIDList,
        "bbosMap",
        "width=1000,height=800",
        true);
}

function replaceNonDigits(v) {
    v.value = v.value.replace(/[^0-9]/g, '');
}

function ValidateExportsCount2(hidExportsMax, hidExportsUsed, hidSelectedCount, hidExportsPeriod) {
    var iExportsMax = Number($('#' + hidExportsMax).val());
    var iExportsUsed = Number($('#' + hidExportsUsed).val());
    var iSelectedCount = Number($('#' + hidSelectedCount).val());
    var iExportsPeriod = $('#' +       hidExportsPeriod).val();
    var Period = "day";
    if (iExportsPeriod == "M") {
        Period = "month"
    }

    if (iExportsMax == 0) {
        bbAlert("Your membership does not allow any exports.", "Membership Export Count Exceeded");
        return false;
    }
    else if ((iExportsUsed + iSelectedCount) > iExportsMax) {
        var msg = "Your membership only allows maximum of " + iExportsMax + " exports per " + Period;
        if (iExportsUsed > 0)
            msg += ", and you have already exported " + iExportsUsed + ".";
        else
            msg += ".";

        msg += "  Please select fewer items for this export.";

        bbAlert(msg, "Membership Export Count Exceeded");
        return false;
    }

    return true;
}
function ValidateExportsCount() {
    return ValidateExportsCount2(
        'contentMain_hidExportsMax',
        'contentMain_hidExportsUsed',
        'contentMain_hidSelectedCount',
        'contentMain_hidExportsPeriod'
    );
}


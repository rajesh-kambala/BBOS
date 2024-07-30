// create gloabal references to things we'll lookup often
var gtblCommodity = null;
var gtblSelectedCommodities = null;
var gtblPublishedCommodities = null;
var gtblAttributeListing = null;
var gtblGrowingMethodSection = null;
var gtblAvailableAttributesSection = null;

var gdivSubmitValues = null;
var gNextDisplaySequence = 5000;

var gSelectedRow = null;
var gSelectedGMRow = null;
var gSelectedCommodityCodeTD = null;
var gSelectedPublishedListing = null;

var garrSearchMatchRows = new Array();
var gsPrevSearchValue = new String("");
var giCurrentMatchRow = 0;


function GetElementInsideContainer(container, childID) {
    var elm = {};
    var elms = container.getElementsByTagName("*");
    for (var i = 0; i < elms.length; i++) {
        if (elms[i].id === childID) {
            elm = elms[i];
            break;
        }
    }
    return elm;
}

function save() {
    document.getElementById("hdn_Action").value = "save";
    document.EntryForm.submit();
}

/*******************************************
  SERACHING FUNCTIONALITY
 *******************************************/

function clearSearch() {
    // otherwise clear the current highlights and research
    for (var k = 0; k < garrSearchMatchRows.length; k++) {
        spanReset = garrSearchMatchRows[k].all("_CommDisplay_" + garrSearchMatchRows[k].getAttribute("CommodityId"));
        spanReset.innerHTML = garrSearchMatchRows[k].getAttribute("SearchText");
    }
    txtSearch = document.getElementById("txtSearch");
    txtSearch.value = "";
    gsPrevSearchValue = "";

}
function searchForValue() {
    try {
        var rowToSelect = null;

        if (gSelectedRow == null)
            gSelectedRow = gtblCommodity.rows[1];

        var txtSearch = document.getElementById("txtSearch");
        var sSearchValue = txtSearch.value.toLowerCase();
        if (sSearchValue.split(" ") == "") {
            clearSearch();
            return;
        }
        // is the text the same as the previous search
        if (gsPrevSearchValue == sSearchValue) {
            // if so go to the next row in the array
            if (giCurrentMatchRow == garrSearchMatchRows.length - 1)
                giCurrentMatchRow = 0;
            else
                giCurrentMatchRow++;
            rowToSelect = garrSearchMatchRows[giCurrentMatchRow];
            bringRowIntoView(rowToSelect);
            return;
        }

        // otherwise clear the current highlights and research
        for (var k = 0; k < garrSearchMatchRows.length; k++) {
            //spanReset = garrSearchMatchRows[k].getElementById("_CommDisplay_" + garrSearchMatchRows[k].getAttribute("CommodityId"));
            spanReset = garrSearchMatchRows[k].cells[2].childNodes[3];
            spanReset.innerHTML = garrSearchMatchRows[k].getAttribute("SearchText");
        }

        // this is a new search; find matches and create the array
        garrSearchMatchRows = new Array();
        var iMatchCount = 0;
        var iRowIndex = 0;

        var iRowCount = gtblCommodity.rows.length;
        var testRow = gtblCommodity.tBodies[0].rows[iRowIndex];
        var regexp = new RegExp(sSearchValue, "gi");
        while (testRow != null && testRow.rowIndex < iRowCount) {
            // determine the row id
            sTestRowId = testRow.id;
            prcm_CommodityId = testRow.getAttribute("CommodityId");
            // get the contents of the display text span
            var arrMatch = testRow.getAttribute("SearchText").match(regexp);
            //var ndxMatch = testRow.getAttribute("SearchText").toLowerCase().indexOf(sSearchValue);
            if (arrMatch != null) {
                garrSearchMatchRows[iMatchCount] = testRow;
                iMatchCount++;
                // replace any matches with a highlight span
                sHighlighted = testRow.getAttribute("SearchText").replace(regexp,
                    "<SPAN ID=\"_SearchMatch\" CLASS=\"SearchMatch\">$&</SPAN>");
                //sHighlighted = testRow.getAttribute("SearchText").replace(sSearchValue, 
                //                "<SPAN ID=\"_SearchMatch\" CLASS=\"SearchMatch\">" + sSearchValue + "</SPAN>");
                document.getElementById("_CommDisplay_" + prcm_CommodityId).innerHTML = sHighlighted;
                // finally, make sure the row is visible
                makeRowVisible(testRow);
            }

            iRowIndex++;
            testRow = gtblCommodity.tBodies[0].rows[iRowIndex];
        }
        if (iMatchCount > 0) {
            // set the position to the first row after the currently selected row
            giCurrentMatchRow = 0; // first item
            if (gSelectedRow != null) {
                for (var j = 0; j < garrSearchMatchRows.length; j++) {
                    if (garrSearchMatchRows[j].rowIndex >= gSelectedRow.rowIndex) {
                        giCurrentMatchRow = j;
                        break;
                    }
                }
            }
            else {
                garrSearchMatchRows[0].rowIndex;
                giCurrentMatchRow = 0;
            }
            rowToSelect = garrSearchMatchRows[giCurrentMatchRow];
            bringRowIntoView(rowToSelect);
        }
        else {
            alert("Search Value was not found.");
            sSearchValue = "";
        }
        gsPrevSearchValue = sSearchValue;

    }
    finally {
        cursorDefault();
    }
}

var rowOffset = 8

function bringRowIntoView(rowToSelect) {
    if (rowToSelect != null) {
        if (rowToSelect.rowIndex + rowOffset >= gtblCommodity.rows.length)
            rowToFocus = gtblCommodity.rows[gtblCommodity.rows.length - 1];
        else if (rowToSelect.rowIndex - 12 <= 0)
            rowToFocus = gtblCommodity.rows[1];
        else {
            if (gSelectedRow == null || gSelectedRow.rowIndex < rowToSelect.rowIndex)
                rowToFocus = gtblCommodity.rows[rowToSelect.rowIndex + rowOffset];
            else
                rowToFocus = gtblCommodity.rows[rowToSelect.rowIndex - rowOffset];
        }

        var index = rowToFocus.rowIndex;

        // go up to the next visible row
        while (rowToFocus.style.display == "none") {
            index++;
            rowToFocus = gtblCommodity.rows[index];
            //rowToFocus = rowToFocus.previousSibling;

        }

        cell = rowToFocus.getElementsByTagName("TD");
        selectRow(rowToSelect);
        cell[0].focus();//scrollIntoView();
        cell[0].scrollIntoView();
    }
    cursorDefault();
}


function makeRowVisible(testRow) {
    // if this row is visible already, just leave
    if (testRow.style.display != "none")
        return;
    testRow.style.display != ""
    // Make sure that the row is visible by 
    // making sure the parent(s) are expanded
    if (testRow.getAttribute("CommLevel") == 1)// level 1 is always visible
        return;
    parentRow = testRow.previousSibling;
    var ndxCommLevel = testRow.getAttribute("CommLevel");
    while (parentRow.rowIndex > 0 && parentRow.getAttribute("CommLevel") > 0) {
        //once the first row (of the tbody which is 1 of the table) is hit or 
        // the commlevel decreases, jump out 
        while (parentRow.rowIndex > 1 && parentRow.getAttribute("CommLevel") >= ndxCommLevel) {
            parentRow = parentRow.previousSibling;
        }

        if (parentRow.getAttribute("RowState") == "collapsed")
            expandRow(parentRow);

        // if this row is already visible, everything above it is visible
        if (parentRow.style.display != "none")
            return;

        ndxCommLevel = parentRow.getAttribute("CommLevel") - 1;
        parentRow = parentRow.previousSibling;

    }
}

/*****************************************************
 EXPAND/COLLAPSE TREEVIEW FUNCTIONALITY
 ****************************************************/
function expandAll() {
    var iRowCount = gtblCommodity.rows.length;
    var iRowIndex = 0;
    var curRow = gtblCommodity.tBodies[0].rows[iRowIndex];
    while (curRow != null && curRow.rowIndex < iRowCount) {
        curRow.setAttribute("RowState", "expanded");
        rowImg = document.getElementById("_prcm_expcol_" + curRow.getAttribute("CommodityId"));
        rowImg.src = "/CRM/Img/prco/collapse.gif";
        if (curRow.getAttribute("CommLevel") > 1)
            curRow.style.display = "";

        iRowIndex++;
        curRow = gtblCommodity.tBodies[0].rows[iRowIndex];
    }
}

function collapseAll() {
    var iRowCount = gtblCommodity.rows.length;
    var iRowIndex = 0;
    var curRow = gtblCommodity.tBodies[0].rows[iRowIndex];
    while (curRow != null && curRow.rowIndex < iRowCount) {
        curRow.setAttribute("RowState", "collapsed");
        rowImg = document.getElementById("_prcm_expcol_" + curRow.getAttribute("CommodityId"));
        rowImg.src = "/CRM/Img/prco/expand.gif";
        if (curRow.getAttribute("CommLevel") > 1)
            curRow.style.display = "none";

        iRowIndex++;
        curRow = gtblCommodity.tBodies[0].rows[iRowIndex];
    }
}

function toggleExpand(item) {
    //find the current row 
    var curRow = null;
    curRow = item.parentElement;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    if (curRow != null) {
        if (curRow.getAttribute("RowState") == "collapsed")
            expandRow(curRow);
        else
            collapseRow(curRow);
    }
    cursorDefault();
}

function expandRow(curRow) {
    iCurRowLevel = curRow.getAttribute("CommLevel");
    // start down the rows until you hit a level <= curLevel
    // but only show children if the row is expanded; if collapsed, skip
    // all of that parent's children
    bExit = false;
    iIgnoreLevel = 7; // this value means don't ignore any levels (we only have 6)

    var rowIndex = curRow.rowIndex;
    rowIndex++;
    testRow = curRow.parentNode.rows[rowIndex];

    while (!bExit) {
        prcm_CommodityId = testRow.getAttribute("CommodityId");
        iTestRowLevel = testRow.getAttribute("CommLevel");
        if (iTestRowLevel <= iCurRowLevel)
            bExit = true;
        else {
            if (iTestRowLevel < iIgnoreLevel) {
                // is this row collapsed? 
                // if so, set ignore level to ignore it's children
                if (testRow.getAttribute("RowState") == "collapsed")
                    iIgnoreLevel = iTestRowLevel + 1;
                else
                    iIgnoreLevel = 7; //set to any value over the level max
                testRow.style.display = '';
            }
            rowIndex++;

            if (rowIndex >= curRow.parentNode.rows.length) {
                bExit = true;
            }

            testRow = curRow.parentNode.rows[rowIndex];
        }
    }
    rowImg = document.getElementById("_prcm_expcol_" + curRow.getAttribute("CommodityId"));
    rowImg.src = "/CRM/Img/prco/collapse.gif";
    curRow.setAttribute("RowState", "expanded");
}

function collapseRow(curRow) {
    //iCurRowIndex = curRow.rowIndex-gtblCommodity.tHead.rows.length;// this is the row index for tbody
    iCurRowLevel = curRow.getAttribute("CommLevel");
    // start down the rows until you hit a level <= curLevel
    bExit = false;

    var rowIndex = curRow.rowIndex;
    rowIndex++;
    testRow = curRow.parentNode.rows[rowIndex];

    while (!bExit) {
        iTestRowLevel = testRow.getAttribute("CommLevel");
        if (iTestRowLevel <= iCurRowLevel)
            bExit = true;
        else
            testRow.style.display = 'none';

        rowIndex++;
        if (rowIndex >= curRow.parentNode.rows.length) {
            bExit = true;
        }

        testRow = curRow.parentNode.rows[rowIndex];
    }



    rowImg = document.getElementById("_prcm_expcol_" + curRow.getAttribute("CommodityId"));
    rowImg.src = "/CRM/Img/prco/expand.gif";
    curRow.setAttribute("RowState", "collapsed");
}

function toggleAttrExpand(item) {
    //find the current row 
    var curRow = null;
    curRow = item.parentElement;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    if (curRow != null) {
        if (curRow.getAttribute("RowState") == "collapsed")
            expandAttrRow(curRow);
        else
            collapseAttrRow(curRow);
    }
    cursorDefault();
}
function expandAttrRow(curRow) {
    // start down the rows until you hit another group
    testRow = curRow.nextElementSibling;
    while (testRow.getAttribute("attrId").charAt(0) != "G") {
        testRow.style.display = '';
        if (testRow.rowIndex < gtblAttributeListing.rows.length - 1)
            testRow = testRow.nextElementSibling;
        else
            break;
    }
    rowImg = document.getElementById("_prat_expcol_" + curRow.getAttribute("attrId"));
    rowImg.src = "/CRM/Img/prco/collapse.gif";
    curRow.setAttribute("RowState", "expanded");
}

function collapseAttrRow(curRow) {
    // start down the rows until you hit another group
    testRow = curRow.nextElementSibling;

    while (testRow.getAttribute("attrId").charAt(0) != "G") {
        testRow.style.display = 'none';
        if (testRow.rowIndex < gtblAttributeListing.rows.length - 1)
            testRow = testRow.nextElementSibling;
        else
            break;
    }
    rowImg = document.getElementById("_prat_expcol_" + curRow.getAttribute("attrId"));
    rowImg.src = "/CRM/Img/prco/expand.gif";
    curRow.setAttribute("RowState", "collapsed");
}



/****************************************************
 SELECTED COMMODITY CODE MAINTENANCE (top left of screen)
 ****************************************************/

function clearSelectedCommodityCode() {
    if (gSelectedCommodityCodeTD != null)
        gSelectedCommodityCodeTD.className = 'CommodityUnselected';
    gSelectedCommodityCodeTD = null;
    unselectGrowingMethods();
    refreshSelectedGrowingMethods();
}
function selectCommodityCodeById(nId) {
    var rowSelected = document.getElementById("_rowSelectedCommodities");
    var arrTDs = rowSelected.getElementsByTagName("SPAN");
    for (var i = 0; i < arrTDs.length; i++) {
        if (arrTDs[i].id == "td_selectcomm_" + nId) {
            if (arrTDs[i] != gSelectedCommodityCodeTD)
                selectCommodityCode(arrTDs[i]);
            break;
        }
    }
}

function selectCommodityCode(item) {
    if (gSelectedCommodityCodeTD != item) {
        clearSelectedCommodityCode();
        gSelectedCommodityCodeTD = item;
        item.className = 'CommoditySelected';
        lId = item.id.substring("td_selectcomm_".length);

        rowCommodity = document.getElementById("_PRCMRow_" + lId);
        makeRowVisible(rowCommodity);
        bringRowIntoView(rowCommodity);

        unselectGrowingMethods();
        refreshSelectedGrowingMethods();
        refreshSelectedAttributes();
    }
}

/****************************************************
 SELECTED PUBLISHED LISTING MAINTENANCE (top right of screen)
 ****************************************************/
function unselectPublishedListing() {
    if (gSelectedPublishedListing != null)
        gSelectedPublishedListing.className = 'CommodityUnselected';
    gSelectedPublishedListing = null;
}

function selectPublishedListing() {
    var item = window.event.srcElement;
    if (gSelectedPublishedListing != item) {
        unselectPublishedListing();
        gSelectedPublishedListing = item;
        item.className = 'CommoditySelected';
        // determine the commodity Id
        // this may be a string with a CommId, GMId, and AttrId
        var sName = item.id.substring("_PubCommodity".length);
        var nCommId = -1;
        var nAttrId = -1;
        var nGMId = -1;
        var bPGM = false;
        var ndxAttr = sName.indexOf("_Attr_");
        var ndxGM = sName.indexOf("_GM_");
        if (ndxAttr > -1) {
            //if this is an attribute, determine if this record is for PublishWithGM
            var sAttr = sName.substring(ndxAttr + "_Attr_".length);
            var ndxPGM = sAttr.indexOf("_PGM"); // publish with GM tag
            if (ndxPGM > -1) {
                nAttrId = sAttr.substring(0, ndxPGM);
                bPGM = true;
            }
            else
                nAttrId = sAttr;
            sName = sName.substring(0, ndxAttr);
        }
        if (ndxGM > -1) {
            nGMId = sName.substring(ndxGM + "_GM_".length);
            sName = sName.substring(0, ndxGM);
        }
        nCommId = sName.substring(sName.lastIndexOf("_") + 1);
        // leverage the selectCommodityCode function via the helper function
        selectCommodityCodeById(nCommId);
        // if there is a growing method; select the GM row
        unselectGrowingMethods();
        if (nGMId > -1) {
            var tBody = gtblGrowingMethodSection.tBodies[0];
            var trGM = document.getElementById("_GMRow_" + nGMId);
            gSelectedGMRow = trGM;
        }

        // refresh the GM table
        refreshSelectedGrowingMethods();
        refreshSelectedAttributes();
    }
}

function movePublishedListingLeft() {
    if (gSelectedPublishedListing == null)
        return;
    var sName = gSelectedPublishedListing.id.substring("_PubCommodity_".length);
    var oLeftPublishedListing = gSelectedPublishedListing.previousSibling;

    // if this is already the leftmost, exit
    if (oLeftPublishedListing == null)
        return;
    var sLeftName = oLeftPublishedListing.id.substring("_PubCommodity_".length);

    // find the two entries in the gDivSubmitValues
    var oSVNode = document.getElementById("spn_" + sName);
    var oSVLeft = document.getElementById("spn_" + sLeftName);

    if (oSVNode == null || oSVLeft == null)
        return;
    // now, simply move the PublishedListing Node
    gSelectedPublishedListing.swapNode(oLeftPublishedListing);

    // and the matching move for the gdivSubmitValues
    oSVNode.swapNode(oSVLeft);
}

function movePublishedListingRight() {
    if (gSelectedPublishedListing == null)
        return;
    var sName = gSelectedPublishedListing.id.substring("_PubCommodity_".length);
    var oRightPublishedListing = gSelectedPublishedListing.nextSibling;
    // if this is already the rightmost, exit
    if (oRightPublishedListing == null)
        return;
    var sRightName = oRightPublishedListing.id.substring("_PubCommodity_".length);

    // find the two entries in the gDivSubmitValues
    var oSVNode = document.getElementById("spn_" + sName);
    var oSVRight = document.getElementById("spn_" + sRightName);
    if (oSVNode == null || oSVRight == null)
        return;

    // now, simply move the PublishedListing Node
    gSelectedPublishedListing.swapNode(oRightPublishedListing);

    // and the matching move for the gdivSubmitValues
    oSVNode.swapNode(oSVRight);
}

/*************************************************
 gdivSubmitValues MAINTENANCE (values submitted back to the caller for processing)
 **************************************************/
function createSubmitValue(nCommId, nGMId, nAttrId, bPublished, bAttributeWithGM) {
    // the last submitted value that is not published will be at 
    // gtblPublishedCommodities.rows[0].cells[0].children.length
    var nPublishedCount = 0;
    if (gtblPublishedCommodities.rows[0].cells[0].children != null)
        nPublishedCount = gtblPublishedCommodities.rows[0].cells[0].children.length;

    var sChecked = "-1";
    if (bPublished == true) {
        sChecked = gNextDisplaySequence;
        gNextDisplaySequence++;
    }
    var sHdnName = "hdnComm_" + nCommId;
    if (nGMId != null)
        sHdnName += "_GM_" + nGMId;
    if (nAttrId != null)
        sHdnName += "_Attr_" + nAttrId;
    if (bAttributeWithGM == true)
        sHdnName += "_PGM";

    // before adding this, we have to make sure it doesn't exist
    // for instance, if we are just publishing, the selected record may exist
    var oEntry = document.getElementById("spn_" + sHdnName);
    if (oEntry == null) {
        var oNew = document.createElement("span");
        oNew.id = "spn_" + sHdnName;
        oNew.innerText = sHdnName + ":&nbsp";
        oNew.innerHTML = sHdnName + ":&nbsp" +
            "<input TYPE=TEXT class=viewbox id=" + sHdnName + " name=" + sHdnName + " value=\"" + sChecked + "\" >" +
            "<input TYPE=TEXT class=viewbox id=" + sHdnName + "_Listing name=" + sHdnName + "_Listing value=\"\" ><br>";

        gdivSubmitValues.insertBefore(oNew); // append to the end
    }
    else {
        // update the publish value
        oInput = document.getElementById(sHdnName);
        if (oInput != null)
            oInput.value = sChecked;
        if (bPublished) {
            // remove this node and readd it to the end
            var oRemoved = oEntry.removeNode(true);
            gdivSubmitValues.insertBefore(oRemoved); // append to the end
        }
    }
}
function removeSubmitValue(nCommId, nGMId, nAttrId, bAttributeWithGM) {
    var sHdnName = "hdnComm_" + nCommId;
    if (nGMId != null)
        sHdnName += "_GM_" + nGMId;
    if (nAttrId != null)
        sHdnName += "_Attr_" + nAttrId;
    if (bAttributeWithGM == true)
        sHdnName += "_PGM";
    // cycle through (backwards) each of the gdivSubmitValues and remove any 
    // that begin "spn_" + sHdnName
    var sSearch = "spn_" + sHdnName;
    for (var ndx = gdivSubmitValues.children.length - 1; ndx >= 0; ndx--) {
        var sIdValue = gdivSubmitValues.children[ndx].id;
        if (sSearch == sIdValue || sSearch + "_" == sIdValue.substring(0, sSearch.length + 1))
            gdivSubmitValues.children(ndx).removeNode(true);
    }
}

function alertCommodityNotSelected() {
    if (gSelectedRow == null) {
        alert("A commodity must be selected before performing this action.");
        window.event.cancelBubble = true;
        return true;
    }
    return false;
}

/*************************************************
 COMMODITY LISTING MAINTENANCE
 **************************************************/
function onClickCommRow() {
    src = window.event.srcElement;
    unselectPublishedListing();
    selectRow(src);
}

function selectRow(curRow) {
    // make sure we're dealing with a row
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;

    if (gSelectedRow != null && gSelectedRow != curRow) {
        // set the style of the old row back
        sLevel = curRow.getAttribute("CommLevel");
        if (gSelectedRow.rowIndex == 1)
            sClassName = "ROW1";
        else if (gSelectedRow.previousSibling.className == "ROW2")
            sClassName = "Row1"
        else
            sClassName = "ROW2";
        gSelectedRow.className = sClassName;
        // set all the tds and the span
        sCommodityId = gSelectedRow.getAttribute("CommodityId");
        var arrTDs = gSelectedRow.getElementsByTagName("TD");
        for (var i = 0; i < arrTDs.length; i++)
            arrTDs[i].className = sClassName;
        document.getElementById("_CommDisplay_" + sCommodityId).className = sClassName;
    }
    // set the row's class (and its children) to selected
    sClassName = "RowSelected";
    curRow.className = sClassName;
    sCommodityId = curRow.getAttribute("CommodityId");
    var arrTDs = curRow.getElementsByTagName("TD");
    for (var i = 0; i < arrTDs.length; i++)
        arrTDs[i].className = sClassName;
    document.getElementById("_CommDisplay_" + sCommodityId).className = sClassName;

    // mark the current row as the selected row
    gSelectedRow = curRow;

    // if this row has "Select" checked, highlight it in the Selected listing
    var chkSelect = document.getElementById("_CommSelect_" + sCommodityId);// the select Checkbox

    // update the growing method section to indicate that this is the commodity in use
    var tdGMAppliesTo = document.getElementById("_tdGMAppliesTo");
    if (tdGMAppliesTo != null) {
        if (chkSelect.checked)
            _tdGMAppliesTo.innerHTML = curRow.getAttribute("CommName");
        else
            _tdGMAppliesTo.innerHTML = "&nbsp;"
    }
    var tdGMAppliesTo = document.getElementById("_tdGMAppliesTo");
    //if (tdGMAppliesTo != null)
    //{    
    //    if (chkSelect.checked)
    //        _tdGMAppliesTo.innerHTML = curRow.CommName;
    //    else
    //        _tdGMAppliesTo.innerHTML = "&nbsp;"    
    //}
    var tdAppliesTo = document.getElementById("_tdAttributesApplyTo");
    if (tdAppliesTo != null) {
        if (chkSelect.checked)
            tdAppliesTo.innerHTML = curRow.getAttribute("CommName");
        else
            tdAppliesTo.innerHTML = "&nbsp;"
    }

    if (chkSelect.checked) {
        selectCommodityCodeById(sCommodityId)
    }
    else {
        // clear the currently selected commodity code in the 
        // selected commodity list
        clearSelectedCommodityCode();
        refreshSelectedAttributes();
    }
}

function onCommodityPublishClick() {
    src = window.event.srcElement;
    handleCommodityPublishClick(src);
}
function handleCommodityPublishClick(src) {
    if (src.checked)
        addPublishedCommodity(src);
    else
        removePublishedCommodity(src);
}

function onCommoditySelectClick() {
    src = window.event.srcElement;
    handleCommoditySelectClick(src);
}
function handleCommoditySelectClick(src) {
    if (src.checked)
        addSelectedCommodity(src);
    else
        removeSelectedCommodity(src);
}

function addSelectedCommodity(item) {
    //get the id value; starts with "_CommSelect_"
    var nId = item.id.substring("_CommSelect_".length);
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    var chkPublish = document.getElementById("_CommPublish_" + nId);

    createSubmitValue(nId, null, null, chkPublish.checked);

    rebuildSelectedCommodities();

    if (chkPublish.checked == true)
        rebuildPublishedCommodities();
}

function removeSelectedCommodity(item) {
    var nId = item.id.substring("_CommSelect_".length);
    removeSubmitValue(nId);

    // remove the published commodity
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    var chkPublish = document.getElementById("_CommPublish_" + nId);
    if (chkPublish.checked) {
        chkPublish.checked = false;
    }
    rebuildSelectedCommodities();
    rebuildPublishedCommodities();
}

function addPublishedCommodity(item) {
    //get the id value; starts with "_CommPublish_"
    var nId = item.id.substring("_CommPublish_".length);
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    var chkSelect = document.getElementById("_CommSelect_" + nId);
    if (chkSelect != null) {
        chkSelect.checked = true;
        addSelectedCommodity(chkSelect);
    }
}

function removePublishedCommodity(item) {
    //get the id value; starts with "_CommPublish_"
    var nId = item.id.substring("_CommPublish_".length);
    var sSearch = "spn_hdnComm_" + nId;
    for (var ndx = 0; ndx < gdivSubmitValues.children.length; ndx++) {
        var sIdValue = gdivSubmitValues.children[ndx].id;
        if (sIdValue == sSearch) {
            // get the input element containing the published value
            //oSequence = gdivSubmitValues.children[ndx].all("hdnComm_" + nId);
            oSequence = document.getElementById("hdnComm_" + nId);
            if (oSequence != null)
                oSequence.value = "-1";
            rebuildPublishedCommodities();
            break;
        }
    }
}

function rebuildSelectedCommodities() {
    var rowSelected = document.getElementById("_rowSelectedCommodities");
    while (rowSelected.cells.length > 0)
        rowSelected.deleteCell();

    var aAllOptions = gdivSubmitValues.getElementsByTagName("SPAN");

    for (ndx = 1; ndx < gtblCommodity.rows.length; ndx++) {
        var chkSelect = null;
        var row = gtblCommodity.rows[ndx];

        // check if the commodity is in the SubmitValues
        for (var i = 0; i < aAllOptions.length; i++) {
            var sSearch = "hdnComm_" + row.getAttribute("CommodityId");
            var sSpanName = aAllOptions[i].id;
            var sFullName = sSpanName.substring("spn_".length);

            var sHdnName = sFullName;
            var ndxName = sFullName.indexOf("_", "hdnComm_".length);
            if (ndxName > -1)
                sHdnName = sFullName.substring(0, ndxName);
            // if this starts with the commodity id
            if (sHdnName == sSearch) {
                chkSelect = document.getElementById("_CommSelect_" + row.getAttribute("CommodityId"));
                chkSelect.checked = true;
                // to check published, we have to find a very specific record in SubmitValues
                //txtSequence = gdivSubmitValues.all(sHdnName);
                txtSequence = GetElementInsideContainer(gdivSubmitValues, sHdnName);

                if (txtSequence != null) {
                    if (txtSequence.value != -1) {
                        chkPublish = document.getElementById("_CommPublish_" + row.getAttribute("CommodityId"));
                        chkPublish.checked = true;
                    }
                }
                break;
            }
        }
        // check the selected flag; if on add to the list
        if (chkSelect == null)
            chkSelect = document.getElementById("_CommSelect_" + row.getAttribute("CommodityId"));
        if (chkSelect.checked == true) {
            if (rowSelected.cells.length == 0)
                rowSelected.insertCell();

            var tdNew = rowSelected.insertCell();//(rowSelected.cells.length-1);
            //tdNew.id = "td_selectcomm_" + row.CommodityId;
            //tdNew.CommodityId = row.CommodityId;
            //tdNew.onclick=function(){unselectPublishedListing();selectCommodityCode(this);};
            //tdNew.innerHTML=row.CommCode+ " ";

            //alert ("{"+tdNew.outerHTML+"}");

            var spnNew = document.createElement("span");
            spnNew.id = "td_selectcomm_" + row.getAttribute("CommodityId");
            spnNew.align = "Left";
            spnNew.valign = "top";
            spnNew.innerText = row.getAttribute("CommCode") + " ";
            spnNew.setAttribute("CommodityId", row.getAttribute("CommodityId"));
            spnNew.setAttribute("CommLevel", row.getAttribute("CommLevel"));
            spnNew.setAttribute("CommCode", row.getAttribute("CommCode"));
            spnNew.setAttribute("PathNames", row.getAttribute("PathNames"));
            spnNew.setAttribute("PathCodes", row.getAttribute("PathCodes"));

            var spnText = spnNew.outerHTML;
            var ndxClose = spnText.indexOf(">");
            spnText = spnText.substring(0, ndxClose) +
                " onclick=\"unselectPublishedListing();selectCommodityCode(this);\" " +
                spnText.substring(ndxClose);
            rowSelected.cells[0].innerHTML += spnText;
        }
    }
}

function rebuildPublishedCommodities() {
    var rowSelected = document.getElementById("_rowSelectedCommodities");
    var rowPublished = document.getElementById("_rowPublishedCommodities");

    // clear all the published commodity spans
    while (rowPublished.cells[0].children.length)
        rowPublished.cells[0].children[0].removeNode(true);

    // get a list of all the values whether they are published or not
    var aAllOptions = gdivSubmitValues.getElementsByTagName("SPAN");
    for (var i = 0; i < aAllOptions.length; i++) {
        // determine if this is a commodity or attribute listing
        var sName = aAllOptions[i].id;
        var nCommId = -1;
        var nAttrId = -1;
        var nGMId = -1;
        var bPGM = false;
        var ndxAttr = sName.indexOf("_Attr_");
        var ndxGM = sName.indexOf("_GM_");

        if (ndxAttr > -1) {
            //if this is an attribute, determine if this record is for PublishWithGM
            var sAttr = sName.substring(ndxAttr + "_Attr_".length);
            var ndxPGM = sAttr.indexOf("_PGM"); // publish with GM tag
            if (ndxPGM > -1) {
                nAttrId = sAttr.substring(0, ndxPGM);
                bPGM = true;
            }
            else
                nAttrId = sAttr;
            sName = sName.substring(0, ndxAttr);
        }
        if (ndxGM > -1) {
            nGMId = sName.substring(ndxGM + "_GM_".length);
            sName = sName.substring(0, ndxGM);
        }
        nCommId = sName.substring(sName.lastIndexOf("_") + 1);
        //alert ("CommId: " + nCommId + " GMId: " + nGMId + " AttrId: " + nAttrId + " PGM: " + bPGM);

        var sHdnName = aAllOptions[i].id.substring("spn_".length);
        txtSequence = document.getElementById(sHdnName);
        txtPublishedDisplay = document.getElementById(sHdnName + "_Listing");

        // for now, update the published listing values until we complete the 
        // conversion and persistence pieces

        var tdCell = null;
        arrSpans = rowSelected.cells[0].getElementsByTagName("span");
        for (ndx = 0; ndx < arrSpans.length; ndx++) {
            tdCell = arrSpans[ndx];
            if (tdCell.getAttribute("CommodityId") == nCommId) {
                break;
            }
        }
        var sPubListing = "&nbsp;";

        var arrNames = tdCell.getAttribute("PathNames").split(",");
        var arrCodes = tdCell.getAttribute("PathCodes").split(",");

        // get the GM abbrev based upon the nGMId value
        // get the growing method
        var sGMAbbr = null;
        if (nGMId > -1) {
            var rowGM = document.getElementById("_GMRow_" + nGMId);
            if (rowGM != null)
                sGMAbbr = rowGM.getAttribute("Abbr");
        }
        // determine the attribute values
        var sAttrAbbr = null;
        var bAttrPlacementAfter = false;
        if (nAttrId > -1) {
            var rowAttr = document.getElementById("_tr_prat_" + nAttrId);
            if (rowAttr != null) {
                sAttrAbbr = rowAttr.getAttribute("Abbr");
                if (rowAttr.getAttribute("PlacementAfter") == "Y")
                    bAttrPlacementAfter = true;
            }
        }
        if (bPGM == false && sAttrAbbr != null) // do not use a growing method
            sGMAbbr = null;
        sPubListing = getCommodityListing(arrNames, arrCodes, tdCell.getAttribute("CommLevel"), sGMAbbr, sAttrAbbr, bAttrPlacementAfter);
        txtPublishedDisplay.value = sPubListing;

        // -1 indicates that this value is not published
        if (txtSequence.value != null && txtSequence.value != -1) {
            // now set the published listing rows value
            if (rowPublished.cells.length == 0)
                rowPublished.insertCell();
            var spnNew = document.createElement("span");
            spnNew.id = "_PubCommodity_" + aAllOptions[i].id.substring("spn_".length);
            spnNew.align = "Left";
            spnNew.valign = "top";
            spnNew.innerText = txtPublishedDisplay.value + " ";
            var spnText = spnNew.outerHTML;
            var ndxClose = spnText.indexOf(">");
            spnText = spnText.substring(0, ndxClose) +
                " onclick=\"selectPublishedListing()\" " +
                spnText.substring(ndxClose);
            rowPublished.cells[0].innerHTML += spnText;
        }
    }
}
/****************************
 Growing Method Management 
 **************************** */
function unselectGrowingMethods() {
    if (gSelectedGMRow != null) {
        // set the style of the old row back
        sClassName = "ROW1";
        gSelectedGMRow.className = sClassName;
        // set all the tds and the span
        sId = parseInt(gSelectedGMRow.id.substring("_GMRow_".length));
        var arrTDs = gSelectedGMRow.getElementsByTagName("TD");
        for (var i = 0; i < arrTDs.length; i++)
            arrTDs[i].className = sClassName;

        //gSelectedGMRow.all("_GMDisplay_" + sId).className = sClassName;
        document.getElementById("_GMDisplay_" + sId).className = sClassName;
    }
    gSelectedGMRow = null;
}

function onClickGMRow() {
    curRow = window.event.srcElement;
    handleGMRowClick(curRow);
}

function handleGMRowClick(curRow) {
    // make sure we're dealing with a row
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;

    if (gSelectedGMRow != null) {
        if (gSelectedGMRow != curRow) {
            unselectGrowingMethods();
            gSelectedGMRow = curRow;
        }
        else
            unselectGrowingMethods();
    }
    else {
        gSelectedGMRow = curRow;
    }

    unselectPublishedListing();
    refreshSelectedGrowingMethods();
    refreshSelectedAttributes();
}

function onClickGMSelect() {
    if (alertCommodityNotSelected() == true)
        return false;
    var item = window.event.srcElement;

    var retVal = handleGMSelectClick(item);
    return retVal;
}
function handleGMSelectClick(item) {
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    if (curRow == gSelectedGMRow)
        window.event.cancelBubble = true;

    if (item.checked)
        addSelectedGM(item);
    else
        removeSelectedGM(item);
    return true;
}

function onClickGMPublish() {
    if (alertCommodityNotSelected() == true)
        return false;
    var item = window.event.srcElement;
    return handleGMPublishClick(item);
}
function handleGMPublishClick(item) {
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    if (curRow == gSelectedGMRow)
        window.event.cancelBubble = true;

    if (item.checked)
        addPublishedGM(item);
    else
        removePublishedGM(item);
    return true;
}

function addSelectedGM(item) {
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    //get the id value; starts with "_GMSelect_"
    var nId = item.id.substring("_GMSelect_".length);
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    var chkPublish = document.getElementById("_GMPublish_" + nId);

    createSubmitValue(nCommId, nId, null, chkPublish.checked);
}

function removeSelectedGM(item) {
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    //get the id value; starts with "_GMSelect_"
    var nId = item.id.substring("_GMSelect_".length);
    removeSubmitValue(nCommId, nId);

    // remove the published GM checkbox
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    //var chkPublish = curRow.all("_GMPublish_" + nId);
    var chkPublish = document.getElementById("_GMPublish_" + nId);
    if (chkPublish.checked) {
        chkPublish.checked = false;
    }
    rebuildPublishedCommodities();
}

function addPublishedGM(item) {
    //get the id value; starts with "_GMPublish_"
    var nId = item.id.substring("_GMPublish_".length);
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;

    //var chkSelect = curRow.all("_GMSelect_" + nId);
    var chkSelect = document.getElementById("_GMSelect_" + nId);


    if (chkSelect != null) {
        chkSelect.checked = true;
        addSelectedGM(chkSelect);
    }
    rebuildPublishedCommodities();
}

function removePublishedGM(item) {
    //get the id value; starts with "_GMPublish_"
    var nId = item.id.substring("_GMPublish_".length);
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    var sSearch = "spn_hdnComm_" + nCommId + "_GM_" + nId;
    for (var ndx = 0; ndx < gdivSubmitValues.children.length; ndx++) {
        var sIdValue = gdivSubmitValues.children[ndx].id;
        if (sIdValue == sSearch) {
            // get the input element containing the published value
            //oSequence = gdivSubmitValues.children[ndx].all("hdnComm_" + nCommId + "_GM_" + nId);
            oSequence = document.getElementById("hdnComm_" + nCommId + "_GM_" + nId);
            if (oSequence != null)
                oSequence.value = "-1";
            rebuildPublishedCommodities();
            break;
        }
    }
}

function refreshSelectedGrowingMethods() {
    var tBody = gtblGrowingMethodSection.tBodies[0];

    if (gSelectedRow == null)
        return;

    // get the submitted values div
    if (gdivSubmitValues == null)
        gdivSubmitValues = document.getElementById("divSubmitValues");

    // update the attribute section to indicate that this is the commodity in use
    var tdAppliesTo = document.getElementById("_tdAttributesApplyTo");
    tdAppliesTo.innerHTML = gSelectedRow.getAttribute("CommName");

    // set the row's class (and its children) to selected
    if (gSelectedGMRow != null) {
        sClassName = "RowSelected";
        gSelectedGMRow.className = sClassName;
        sId = parseInt(gSelectedGMRow.id.substring("_GMRow_".length));
        var arrTDs = gSelectedGMRow.getElementsByTagName("TD");
        for (var i = 0; i < arrTDs.length; i++)
            arrTDs[i].className = sClassName;
        document.getElementById("_GMDisplay_" + sId).className = sClassName;

        var chkSelect = document.getElementById("_GMSelect_" + sId);// the select Checkbox
        if (chkSelect.checked) {
            // get the growing method name
            var spn = document.getElementById("_GMDisplay_" + sId);
            tdAppliesTo.innerHTML = spn.innerText + " " + gSelectedRow.getAttribute("CommName");
        }
    }

    var tBody = gtblGrowingMethodSection.tBodies[0];
    var aCheckboxes = tBody.getElementsByTagName("INPUT");
    // clear everything
    for (var ndx = 0; ndx < aCheckboxes.length; ndx++)
        aCheckboxes[ndx].checked = false;

    // based upon the commodity id and the AttrId, cycle through the submit values looking
    // for any GM matching values
    var iCommId = gSelectedRow.getAttribute("CommodityId");
    for (var ndx = 0; ndx < tBody.rows.length; ndx++) {
        // Growing method is actually stored as an attrbute
        AttrId = tBody.rows[ndx].getAttribute("AttrId");
        sSearchName = "hdnComm_" + iCommId + "_GM_" + AttrId;
        hdn = document.getElementById(sSearchName);
        if (hdn != null) {
            // turn on the select checkbox
            chk = document.getElementById("_GMSelect_" + AttrId);
            if (chk != null)
                chk.checked = true;
            if (hdn.value != -1) {
                // turn on the publish checkbox
                chk = document.getElementById("_GMPublish_" + AttrId);
                chk.checked = true;
            }
        }

    }

}

/****************************
 Attribute Management 
 **************************** */
function clearAttributes() {
    var tBody = gtblAttributeListing.tBodies[0];
    var aCheckboxes = tBody.getElementsByTagName("INPUT");
    // clear everything
    for (var ndx = 0; ndx < aCheckboxes.length; ndx++) {
        //if ((aCheckboxes[ndx].id == "_chkAttrSelect_35") || (aCheckboxes[ndx].id == "_chkAttrPublish_35")) {
        //    alert("Found one");
        //}
        aCheckboxes[ndx].checked = false;
    }
}

function onClickSelectAttr() {
    if (alertCommodityNotSelected() == true)
        return false;
    src = window.event.srcElement;
    handleAttrSelectClick(src);
}
function handleAttrSelectClick(item) {
    if (src.checked)
        addSelectedAttribute(item);
    else
        removeSelectedAttribute(item);
}
function onClickPublishAttr() {
    if (alertCommodityNotSelected() == true)
        return false;
    src = window.event.srcElement;
    handleAttrPublishClick(src);
}
function handleAttrPublishClick(item) {
    if (src.checked)
        addPublishedAttribute(item);
    else
        removePublishedAttribute(item);
}

function addSelectedAttribute(item) {
    if (gSelectedRow == null)
        return; // should never ba able to get here
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    // determine if a growing method is selected
    nGMId = null;
    if (gSelectedGMRow != null)
        nGMId = gSelectedGMRow.id.substring("_GMRow_".length);

    //get the id value; starts with "_chkAttrSelect_"
    var nId = item.id.substring("_chkAttrSelect_".length);
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    //use the current row to determine which publish check boxes are set


    //var chkPublish = curRow.all("_chkAttrPublish_" + nId);
    var chkPublish = document.getElementById("_chkAttrPublish_" + nId);

    // always create the normal entry
    createSubmitValue(nCommId, nGMId, nId, chkPublish.checked);

    //var chkPublishWithGM = curRow.all("_chkAttrPubWGM_" + nId);
    var chkPublishWithGM = document.getElementById("_chkAttrPubWGM_" + nId);


    // only create the Publish with Growing Method entry if the W/GM checkbox is selected
    if (chkPublishWithGM != null && chkPublishWithGM.checked == true)
        createSubmitValue(nCommId, nGMId, nId, chkPublishWithGM.checked, true);

}

function removeSelectedAttribute(item) {
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    // determine if a growing method is selected
    var nGMId = null;
    if (gSelectedGMRow != null)
        nGMId = gSelectedGMRow.id.substring("_GMRow_".length);

    //get the id value; starts with "_chkAttrSelect_"
    var nId = item.id.substring("_chkAttrSelect_".length);
    removeSubmitValue(nCommId, nGMId, nId);

    // remove the published GM checkbox
    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;

    //var chkPublish = curRow.all("_chkAttrPublish_" + nId);
    var chkPublish = document.getElementById("_chkAttrPublish_" + nId);
    chkPublish.checked = false;

    // now the With Growing Method option
    //var chkPublishWGM = curRow.all("_chkAttrPubWGM_" + nId);
    var chkPublishWGM = document.getElementById("_chkAttrPubWGM_" + nId);
    chkPublish.checked = false;

    rebuildPublishedCommodities();
}

function addPublishedAttribute(item) {
    // determine if this is the normal or the WGM (publish With Growing Method) checkbox
    var sIdValue = item.id;
    var ndxPGM = sIdValue.indexOf("_chkAttrPubWGM_");
    var nId = null;
    if (ndxPGM > -1) {
        nId = item.id.substring("_chkAttrPubWGM_".length);

        // First check to see if any growing methods are selected
        // if not, then just short circuit this.
        var selectGreenHouse = document.getElementById("_GMSelect_23");
        var selectHydroponic = document.getElementById("_GMSelect_24");
        var selectOrganic = document.getElementById("_GMSelect_25");

        if ((!selectGreenHouse.checked) && (!selectHydroponic.checked) && (!selectOrganic.checked)) {
            item.checked = false;
            return;
        }

    } else {
        nId = item.id.substring("_chkAttrPublish_".length);
    }

    //find the current row
    var curRow = item;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;

    //var chkSelect = curRow.all("_chkAttrSelect_" + nId);
    var chkSelect = document.getElementById("_chkAttrSelect_" + nId);
    if (chkSelect != null) {
        chkSelect.checked = true;
        addSelectedAttribute(chkSelect);
    }
    rebuildPublishedCommodities();
}

function removePublishedAttribute(item) {
    // determine if this is the normal or the WGM (publish With Growing Method) checkbox
    var sIdValue = item.id;
    var ndxPGM = sIdValue.indexOf("_chkAttrPubWGM_");
    var nId = null;
    if (ndxPGM > -1)
        nId = item.id.substring("_chkAttrPubWGM_".length);
    else
        nId = item.id.substring("_chkAttrPublish_".length);

    var nCommId = gSelectedRow.getAttribute("CommodityId");
    // determine if a growing method is selected
    var nGMId = null;
    if (gSelectedGMRow != null)
        nGMId = gSelectedGMRow.id.substring("_GMRow_".length);
    var sSearch = "spn_hdnComm_" + nCommId + "_GM_" + nGMId + "_Attr_" + nId;
    if (ndxPGM > -1)
        sSearch += "_PGM";
    for (var ndx = 0; ndx < gdivSubmitValues.children.length; ndx++) {
        var sIdValue = gdivSubmitValues.children[ndx].id;
        if (sIdValue == sSearch) {
            if (ndxPGM > -1)
                removeSubmitValue(nCommId, nGMId, nId, true);
            else {
                // get the input element containing the published value
                //oSequence = gdivSubmitValues.children[ndx].all(sSearch.substring(4));
                oSequence = document.getElementById(sSearch.substring(4));
                if (oSequence != null)
                    oSequence.value = "-1";
            }
            rebuildPublishedCommodities();
            break;
        }
    }
}

function refreshSelectedAttributes() {
    clearAttributes();

    if (gSelectedRow == null)
        return;
    // first determine if a growing method was selected
    nGMId = -1;
    if (gSelectedGMRow != null) {
        //get the growing method id; this will be used in attribute selection
        nGMId = parseInt(gSelectedGMRow.id.substring("_GMRow_".length));
    }

    // get the submitted values div
    if (gdivSubmitValues == null)
        gdivSubmitValues = document.getElementById("divSubmitValues");

    // based upon the commodity id, growing mehodid and the AttrId, 
    // cycle through the list looking for any matching values
    var nCommId = gSelectedRow.getAttribute("CommodityId");
    var tBody = gtblAttributeListing.tBodies[0];

    var sSearchRoot = "hdnComm_" + nCommId;
    // if a growing method is selected; use it
    if (nGMId != -1)
        sSearchRoot += "_GM_" + nGMId;

    for (var ndx = 0; ndx < tBody.rows.length; ndx++) {
        var nAttrId = tBody.rows[ndx].getAttribute("AttrId");
        // Groups have a prfix of 'G'; just skip them
        if (nAttrId.charAt(0) != "G") {
            // if we do not have a growing method, this will be the structure
            //    hdnComm_<nCommId>_Attr_<nAttrId>  * (no growing method)
            // otherwise the structure can be one or both of the following
            //    hdnComm_<nCommId>_GM_<nGMId>_Attr_<nAttrId>
            //    hdnComm_<nCommId>_GM_<nGMId>_Attr_<nAttrId>PGM

            var sSearchName = sSearchRoot + "_Attr_" + nAttrId;
            var hdn = document.getElementById(sSearchName);

            var chkSelect = document.getElementById("_chkAttrSelect_" + nAttrId);
            // this was the search for the first set of scenarios; it does not search for "_PGM" recs
            if (hdn != null) {
                // the search value exists, at a minimum, we are setting the "Select" checkbox
                if (chkSelect != null)
                    chkSelect.checked = true;
                if (hdn.value != -1) {
                    // turn on the publish checkbox
                    chk = document.getElementById("_chkAttrPublish_" + nAttrId);
                    chk.checked = true;
                }
            }
            if (nGMId != -1) {
                // check for PGM
                hdn = document.getElementById(sSearchName + "_PGM");
                if (hdn != null) {
                    if (chkSelect != null)
                        chkSelect.checked = true;
                    // turn on the publish With Growing Method checkbox
                    chk = document.getElementById("_chkAttrPubWGM_" + nAttrId);
                    chk.checked = true;
                }
            }
        }

    }
}
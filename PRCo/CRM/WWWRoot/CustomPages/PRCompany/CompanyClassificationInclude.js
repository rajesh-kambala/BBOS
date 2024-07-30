// create gloabal references to things we'll lookup often
var gtblClassificationListing = null;

var gtdClassDetailSection = null;

var ghdnSelectedCommodityIds = null;
var ghdnCommodityAttributes = null;

var gSelectedRow = null;

var bSaveFlag = false;
function save() {
    
    if (bSaveFlag === true) {
        return;
    }
    bSaveFlag = true;

    var count = $(".classification:checkbox:checked").length;
    var cid = $("#prc2_classificationid").val();

    if (count === 0 && cid === "-1")
    {
        alert("Please select a classification.");
        bSaveFlag = false;
        return;    
    }

    var nPercentUsed = new Number(document.getElementById("prc2_percentageused").value);
    var sPercentAssigned = document.getElementById("prc2_percentage").value;

    if (sPercentAssigned.charAt(sPercentAssigned.length-1) === "%")
    {
        sPercentAssigned = sPercentAssigned.substring(0, sPercentAssigned.length-1);
        document.getElementById("prc2_percentage").value = sPercentAssigned;
    }
    var nPercentAssigned = new Number(sPercentAssigned);
    if (nPercentAssigned < 0)
    {
        alert("The Percentage value cannot be negative.");
        bSaveFlag = false;
        return;    
    }
    
    if (nPercentUsed + nPercentAssigned > 100)
    {
        alert("The Percentage value cannot exceed " + (100 - nPercentUsed) + ".");
        bSaveFlag = false;
        return;    
    }
    
    document.getElementById("hdn_Action").value = "save";
    document.EntryForm.submit();
}

function makeRowVisible(testRow)
{
    // if this row is visible already, just leave
    if (testRow.style.display != "none")
        return;
        
    testRow.style.display != ""
    // Make sure that the row is visible by 
    // making sure the parent(s) are expanded
    if (testRow.CommLevel == 1)// level 1 is always visible
        return;
        
    parentRow = testRow.previousSibling;
    var ndxCommLevel = testRow.CommLevel;
    while (parentRow.rowIndex > 0 && parentRow.CommLevel > 0)
    {
        //once the first row (of the tbody which is 1 of the table) is hit or 
        // the commlevel decreases, jump out 
        while ( parentRow.rowIndex > 1 && parentRow.CommLevel >= ndxCommLevel)
        {
            parentRow = parentRow.previousSibling;
        }
        if (parentRow.RowState == "collapsed")
            expandRow(parentRow);
        // if this row is already visible, everything above it is visible
        if (parentRow.style.display != "none")
            return;
        
        ndxCommLevel = parentRow.CommLevel-1;
        parentRow = parentRow.previousSibling;
                    
    }
}

function bringRowIntoView(rowToSelect)
{    
    if (rowToSelect != null)
    {
        if (rowToSelect.rowIndex + 12 >= gtblCommodity.rows.length)
            rowToFocus = gtblCommodities.rows[gtblCommodity.rows.length -1];
        else if (rowToSelect.rowIndex - 20 <= 0)
            rowToFocus = gtblCommodity.rows[1];
        else
        {   
            if (gSelectedRow.rowIndex < rowToSelect.rowIndex)
                rowToFocus = gtblCommodity.rows[rowToSelect.rowIndex + 12];
            else
                rowToFocus = gtblCommodity.rows[rowToSelect.rowIndex - 12];
        }
        // go up to the next visible row
        while (rowToFocus.style.display == "none")
            rowToFocus = rowToFocus.previousSibling;
            
        cell = rowToFocus.getElementsByTagName("TD");
        selectRow(rowToSelect);
        cell[0].focus();//scrollIntoView();
    }            
    cursorDefault();
}


function selectRow(curRow) {

    // make sure we're dealing with a row
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    
    if (curRow.Selectable == 0)
    {
        /* we have removed all non-selectable rows except level 1 adn we do not want an alert for those
        if (curRow.NoSelectReason == "Level1")
            sMsg = "The Classification Group level cannot be assigned to a company.";
        else if (curRow.NoSelectReason == "Exists")
            sMsg = "The Classification, subclassification, or an associated classification has already been assigned to this company.";
        else 
            sMsg = "This Classification level cannot be assigned to a company.";
        alert(sMsg);
        */    
        return;
    }
    if (gSelectedRow != null && gSelectedRow != curRow)
    {
        // set the style of the old row back
        sLevel = curRow.TreLevel; 
        sClassName = "ROW2";
        // set all the tds and the span
        sRowId = gSelectedRow.getAttribute("RowId");
        var arrTDs = gSelectedRow.getElementsByTagName("TD");
        for (var i = 0; i < arrTDs.length; i++) {
            arrTDs[i].className = sClassName;
        }
        document.getElementById("_prclDisplay_" + sRowId).className = "";
    }
    sClassName = "RowSelected";
    sRowId = curRow.getAttribute("RowId");
    var arrTDs = curRow.getElementsByTagName("TD");
    for (var i=0; i < arrTDs.length; i++)
        arrTDs[i].className = sClassName;
    document.getElementById("_prclDisplay_" + sRowId).className = sClassName;
    gSelectedRow = curRow;
    
    // set the classification on the properties section
    document.getElementById("prc2_classificationid").value = curRow.getAttribute("RowId");
    if (gtdClassDetailSection == null)
        gtdClassDetailSection = document.getElementById("td_ClassDetailSection");

    if (curRow.getAttribute("Abbr") == "Ret" ||
        curRow.getAttribute("Abbr") == "Restaurant" ||
        //curRow.getAttribute("Abbr") == "FgtF"       ||
        curRow.getAttribute("RowId") == "2190" || // Retail Lumber Yard
        curRow.getAttribute("RowId") == "2191" || // Home Center
        curRow.getAttribute("RowId") == "2192")        // Pro Dealer
    {
        if (curRow.getAttribute("Abbr") == "Ret")
            document.getElementById("_divProps_Ret").style.display = "";
        else 
            document.getElementById("_divProps_Ret").style.display = "none";

        if (curRow.getAttribute("Abbr") == "Restaurant")
            document.getElementById("_divProps_Restaurant").style.display = "";
        else 
            document.getElementById("_divProps_Restaurant").style.display = "none";

        //        if (curRow.getAttribute("Abbr") == "FgtF")
//            gtdClassDetailSection.all("_divProps_FgtF").style.display = "";
//        else
//            gtdClassDetailSection.all("_divProps_FgtF").style.display = "none";


        if ((curRow.getAttribute("RowId") == "2190") || // Retail Lumber Yard
            (curRow.getAttribute("RowId") == "2191") || // Home Center
            (curRow.getAttribute("RowId") == "2192"))   // Pro Dealer
        {
            document.getElementById("_divProps_Lumber").style.display = "";
        } else {
            document.getElementById("_divProps_Lumber").style.display = "none";
        }            
    }
    else
    {
        document.getElementById("_divProps_Restaurant").style.display = "none";
        document.getElementById("_divProps_Ret").style.display = "none";
//        gtdClassDetailSection.all("_divProps_FgtF").style.display = "none";
        document.getElementById("_divProps_Lumber").style.display = "none";
    }
}

function expandAll()
{
    var iRowCount = gtblClassificationListing.rows.length;
    var iRowIndex = 0;
    var curRow = gtblClassificationListing.tBodies[0].rows[iRowIndex];
    while (curRow != null && curRow.rowIndex < iRowCount )
    {
        curRow.setAttribute("RowState", "expanded");
        rowImg = document.getElementById("_img_expcol_" + curRow.getAttribute("RowId"));
        rowImg.src = "/CRM/Img/prco/collapse.gif";
        if (curRow.getAttribute("TreeLevel") > 1)
            curRow.style.display = "";

        iRowIndex++;
        curRow = gtblClassificationListing.tBodies[0].rows[iRowIndex];
    }
}

function collapseAll()
{
    var iRowCount = gtblClassificationListing.rows.length;
    var iRowIndex = 0;
    var curRow = gtblClassificationListing.tBodies[0].rows[iRowIndex];
    while (curRow != null && curRow.rowIndex < iRowCount )
    {
        curRow.setAttribute("RowState", "collapsed");
        rowImg = document.getElementById("_img_expcol_" + curRow.getAttribute("RowId"));
        rowImg.src = "/CRM/Img/prco/expand.gif";
        if (curRow.getAttribute("TreeLevel") > 1)
            curRow.style.display = "none";

        iRowIndex++;
        curRow = gtblClassificationListing.tBodies[0].rows[iRowIndex];

    }
}

function toggleExpand(item)
{
    //find the current row 
    var curRow = null;
    curRow = item.parentElement;
    while (curRow.tagName != "TR")
        curRow = curRow.parentElement;
    if (curRow != null)
    {
        if (curRow.getAttribute("RowState") == "collapsed")
            expandRow(curRow);
        else
            collapseRow(curRow);
    }
    cursorDefault();
    event.cancelBubble=true;
}

function expandRow(curRow)
{
    iCurRowLevel = curRow.getAttribute("TreeLevel");
    // start down the rows until you hit a level <= curLevel
    // but only show children if the row is expanded; if collapsed, skip
    // all of that parent's children
    bExit = false;
    iIgnoreLevel = 7; // this value means don't ignore any levels (we only have 6)

    var rowIndex = curRow.rowIndex;
    rowIndex++;
    testRow = curRow.parentNode.rows[rowIndex];

    while (!bExit && testRow != null)
    {
        iTestRowLevel = testRow.getAttribute("TreeLevel");
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
            testRow = curRow.parentNode.rows[rowIndex];
        }
    }    
    rowImg = document.getElementById("_img_expcol_" + curRow.getAttribute("RowId"));
    rowImg.src = "/CRM/Img/prco/collapse.gif";
    curRow.setAttribute("RowState", "expanded");
}

function collapseRow(curRow)
{
    iCurRowLevel = curRow.getAttribute("TreeLevel");
    // start down the rows until you hit a level <= curLevel
    bExit = false;

    var rowIndex = curRow.rowIndex;
    rowIndex++;
    testRow = curRow.parentNode.rows[rowIndex];
    while (!bExit && testRow != null)        
    {
        iTestRowLevel = testRow.getAttribute("TreeLevel");
        if (iTestRowLevel <= iCurRowLevel)
            bExit = true;
        else 
            testRow.style.display = 'none';

        rowIndex++;
        testRow = curRow.parentNode.rows[rowIndex];
    }    
    rowImg = document.getElementById("_img_expcol_" + curRow.getAttribute("RowId"));
    rowImg.src = "/CRM/Img/prco/expand.gif";
    curRow.setAttribute("RowState", "collapsed");
}


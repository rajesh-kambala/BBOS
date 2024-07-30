<%
// sInstallName is defined in accpaccrmNoLang.js, a file included by all crm pages

var themePath = "/Themes/img/ergonomic";
var sBackgroundPath = "/" + sInstallName + themePath + "/backgrounds"


    

function createAccpacBlockHeader(blockName, caption, width, height)
{
    if (isEmpty(width))
        width = "100%";

    sWidth = "style=\"width:" + width + "\"";
    
    sHeight = "";
    if (!isEmpty(height))
    {
        sHeight = "HEIGHT=\""+ height + "\"";
    }
//  The following would build a Container
//	sReturn =           "\n<TABLE CELLPADDING=5 " + sWidth + " " + sHeight + " BORDER=1 ID=\"_tblblock_" + blockName + "\"> ";
//	sReturn = sReturn + "\n<TR> ";
//	sReturn = sReturn + "\n<TD VALIGN=TOP> ";

// Begin the table
	sReturn =           "\n    <TABLE style=\"width:100%\" CELLPADDING=0 CELLSPACING=0 BORDER=0 ID=\"_blk_" + blockName + "\"> ";
	sReturn = sReturn + "\n    <TR>";
    sReturn = sReturn + "\n    <td style=\"width: 15px;\"></td>";
	sReturn = sReturn + "\n    <TD WIDTH=\"95%\" >";
	sReturn = sReturn + "\n        <TABLE " + sWidth + " " + sHeight + " CELLPADDING=0 CELLSPACING=0 BORDER=0 ID=\"_blkinner_" + blockName + "\"> ";
	sReturn = sReturn + "\n        <TR class=\"GridHeader\">";
	sReturn = sReturn + "\n            <TD COLSPAN=3> ";
	sReturn = sReturn + "\n                <TABLE style=\"width:100%\" BORDER=0 CELLPADDING=0 CELLSPACING=0 ID=\"_blkheader_" + blockName + "\"> ";
	sReturn = sReturn + "\n                    <TR>";
	sReturn = sReturn + "\n                        <TD VALIGN=BOTTOM class=\"PanelCorners\"><IMG SRC=\"" + sBackgroundPath + "/paneleftcorner.jpg\" HSPACE=0 BORDER=0 ALIGN=TOP></TD>";
	sReturn = sReturn + "\n                        <TD NOWRAP=true WIDTH=10% CLASS=PANEREPEAT>"+ caption +"</TD>";
	sReturn = sReturn + "\n                        <TD VALIGN=BOTTOM class=\"PanelCorners\"><IMG SRC=\"" + sBackgroundPath + "/panerightcorner.gif\" HSPACE=0 BORDER=0 ALIGN=TOP></TD>";
	sReturn = sReturn + "\n                        <TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD>";
	sReturn = sReturn + "\n                        <TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD>";
	sReturn = sReturn + "\n                        <TD ALIGN=BOTTOM COPSPAN=30 WIDTH=90% CLASS=TABLETOPBORDER >&nbsp;</TD>";
	sReturn = sReturn + "\n                    </TR>";
	sReturn = sReturn + "\n                </TABLE>";
	sReturn = sReturn + "\n            </TD>";
	sReturn = sReturn + "\n        </TR>";
	sReturn = sReturn + "\n        <TR CLASS=CONTENT>";
	sReturn = sReturn + "\n            <TD WIDTH=1px CLASS=TABLEBORDERLEFT>";
	sReturn = sReturn + "\n                <IMG SRC=\"" + sBackgroundPath + "/tabletopborder.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
	sReturn = sReturn + "\n            </TD>";
//	sReturn = sReturn + "\n            <TD >&nbsp;</TD>";
	sReturn = sReturn + "\n            <TD HEIGHT=100% style=\"width:100%\" VALIGN=TOP>";
    return sReturn;

}

function createAccpacBlockFooter(sButtons)
{
	sReturn =           "\n            </TD> ";
//	sReturn = sReturn + "\n            <TD>&nbsp;</TD>";
	sReturn = sReturn + "\n            <TD WIDTH=1px CLASS=TABLEBORDERRIGHT>";
	sReturn = sReturn + "\n                <IMG SRC=\"" + sBackgroundPath + "/tabletopborder.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
	sReturn = sReturn + "\n            </TD>";
	sReturn = sReturn + "\n            <TD CLASS=\"MAINBODY\" valign=TOP>";
	if (sButtons != null)
	{
	    sReturn = sReturn + sButtons;
	}
	sReturn = sReturn + "\n            </TD>";
	sReturn = sReturn + "\n        </TR>";
	sReturn = sReturn + "\n        <TR HEIGHT=1>";
	sReturn = sReturn + "\n            <TD COLSPAN=3 WIDTH=1px CLASS=TABLEBORDERBOTTOM></TD>";
	sReturn = sReturn + "\n        </TR>";
	sReturn = sReturn + "\n        </TABLE>";
	sReturn = sReturn + "\n    </TD>";
	sReturn = sReturn + "\n    <TD>&nbsp;</TD>";
	sReturn = sReturn + "\n    </TR>";
	sReturn = sReturn + "\n    </TABLE>";
//  The following would build a Container
//	sReturn = sReturn + "\n</TD>";
//	sReturn = sReturn + "\n</TR>";
//	sReturn = sReturn + "\n</TABLE>";
    return sReturn;
}

function createAccpacEmptyGridBlock(sBlockName, sBlockCaption, sListComment, width, height)
{
    var sContent = "";
    sContent += createAccpacBlockHeader(sBlockName, sBlockCaption, sListComment, width, height);
    sContent += createAccpacEmptyGrid(sBlockName, sListComment);
    sContent += createAccpacBlockFooter();
    return sContent;
}

function createAccpacEmptyGrid(sListName, sListComment)
{
    sContent = "";
    sSQL = "SELECT capt_us, colp_entrytype, cobj_targettable, grip_ColName, grip_jump, grip_customaction, grip_customIDField " +
            "From Custom_Lists " + 
            "LEFT OUTER JOIN Custom_Captions ON grip_colName = capt_code " +
            "     AND capt_family = 'ColNames' and capt_FamilyType = 'Tags' " +
            "LEFT OUTER JOIN Custom_Edits ON grip_colname = colp_colname " +
            "JOIN Custom_ScreenObjects ON cobj_name = GriP_GridName " + 
            "WHERE GriP_GridName = '" + sListName + "' " +
            "Order by grip_order ";
    recHeaders = eWare.CreateQueryObj(sSQL);
    recHeaders.SelectSQL();
    sCols = "";
    sSelectList = "";
    sHyperLinkCols = "";
    
    nHeaderCount = recHeaders.RecordCount;
    
    sContent = sContent + "\n    <TABLE WIDTH=\"100%\" ID=\"_tbl_" + sListName + "\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff >";
    sContent = sContent + "\n    <THEAD>";
    sContent = sContent + "\n        <TR>";

    arrJumpFields = new Array();

    sTargetTable = "";
    while (!recHeaders.eof)
    {
        sTargetTable = recHeaders("cobj_targettable");
        sColName = recHeaders("grip_ColName");
        if (!isEmpty(sColName))
        {
            if (sCols != "")
                sCols = sCols + ",";
            if (sSelectList != "")
                sSelectList = sSelectList + ",";
            if (recHeaders("colp_entrytype") == 42)
            {
                sTempColName = sColName + "Display";
                sSelectList = sSelectList + "convert(varchar, " + sColName + ", 101) AS " + sTempColName;
            }
            else
            {
                sTempColName = sColName;
                sSelectList = sSelectList + sTempColName;
            }
            sCols = sCols + sTempColName;

            if (recHeaders("grip_jump") == "Custom")
            {
                if (sHyperLinkCols != "")
                    sHyperLinkCols = sHyperLinkCols + ",";
                sHyperLinkCols = sHyperLinkCols + sTempColName;
                grip_customidfield = recHeaders("grip_customIDField");
                arrHyperlink = new Array(sTempColName, recHeaders("grip_customaction"), grip_customidfield);
                arrJumpFields[arrJumpFields.length] = arrHyperlink;
                if (sSelectList.indexOf(grip_customidfield) == -1)
                {
                    if ( sSelectList != "")
                        sSelectList = sSelectList + ",";
                    sSelectList = sSelectList + grip_customidfield;                    
                }
            }
        }

        sDisplayName = sColName;
        if (!isEmpty(recHeaders("capt_US")))
            sDisplayName = recHeaders("capt_US");
        else 
        {
            sJump = recHeaders("grip_jump");
            if (!isEmpty(sJump) && sJump != "Custom")
                sDisplayName = sJump;
        }        
        sContent = sContent + "\n            <TD CLASS=GRIDHEAD >" +sDisplayName + "</TD> ";
        recHeaders.NextRecord();
    }
    sContent = sContent + "\n        </TR>";
    sContent = sContent + "\n    </THEAD>";
    sContent = sContent + "\n    <TBODY>";


    sClass = "ROW2";
    sContent = sContent + "\n        <TR CLASS=" + sClass + ">";
    if (sListComment == null) {
        for (var i=0; i<nHeaderCount;i++)
            sContent = sContent + "\n            <TD CLASS=" + sClass + " >&nbsp;</TD> ";
    } else {
        sContent = sContent + "\n            <TD ALIGN=MIDDLE COLSPAN=" + nHeaderCount + " CLASS=" + sClass + " >" + sListComment + "</TD> ";
    }
    sContent = sContent + "\n        </TR>";

    sContent = sContent + "\n    </TBODY>";
    sContent = sContent + "\n    </TABLE>";
    return sContent;
}

function createAccpacListBody(sListName, nMaxRows, recRows, sWhereClause, sOrderByClause)
{
    // If recRows is specified, the sWhereClause and sOrderByClause will be ignored.
    
    sContent = "";

    sSQL = "SELECT capt_us, colp_entrytype, cobj_targettable, grip_ColName, grip_jump, grip_customaction, grip_customIDField, grip_Alignment " +
            "From Custom_Lists " + 
            "LEFT OUTER JOIN Custom_Captions ON grip_colName = capt_code " +
            "     AND capt_family = 'ColNames' and capt_FamilyType = 'Tags' " +
            "LEFT OUTER JOIN Custom_Edits ON grip_colname = colp_colname " +
            "JOIN Custom_ScreenObjects ON cobj_name = GriP_GridName " + 
            "WHERE GriP_GridName = '" + sListName + "' " +
            "Order by grip_order ";
    recHeaders = eWare.CreateQueryObj(sSQL);
    recHeaders.SelectSQL();
    sCols = "";
    sSelectList = "";
    sHyperLinkCols = "";

    sContent = sContent + "\n    <table width=\"100%\" id=\"_tbl_" + sListName + "\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff >";
    sContent = sContent + "\n    <thead>";
    sContent = sContent + "\n        <tr>";

    var arrJumpFields = new Array();
    var arrColDataType = new Array();

    var alignment = "";

    sTargetTable = "";
    while (!recHeaders.eof)
    {
        sTargetTable = recHeaders("cobj_targettable");
        sColName = recHeaders("grip_ColName");
        if (!isEmpty(sColName))
        {
            arrColDataType[arrColDataType.length] = recHeaders("colp_entrytype");
        
            if (sCols != "")
                sCols = sCols + ",";
            if (sSelectList != "")
                sSelectList = sSelectList + ",";
            if (recHeaders("colp_entrytype") == 42)
            {
                sTempColName = sColName + "Display";
                sSelectList = sSelectList + "convert(varchar, " + sColName + ", 101) AS " + sTempColName;
            }
            else
            {
                sTempColName = sColName;
                sSelectList = sSelectList + sTempColName;
            }
            sCols = sCols + sTempColName;

            if (recHeaders("grip_jump") == "Custom")
            {
                if (sHyperLinkCols != "")
                    sHyperLinkCols = sHyperLinkCols + ",";
                sHyperLinkCols = sHyperLinkCols + sTempColName;
                grip_customidfield = recHeaders("grip_customIDField");
                arrHyperlink = new Array(sTempColName, recHeaders("grip_customaction"), grip_customidfield);
                arrJumpFields[arrJumpFields.length] = arrHyperlink;
                if (sSelectList.indexOf(grip_customidfield) == -1)
                {
                    if ( sSelectList != "")
                        sSelectList = sSelectList + ",";
                    sSelectList = sSelectList + grip_customidfield;                    
                }
            }
        }


        alignment = "";
        if (!isEmpty(recHeaders("grip_Alignment")))
            alignment = "style=\"text-align:center;\"";

        sDisplayName = sColName;
        if (!isEmpty(recHeaders("capt_US")))
            sDisplayName = recHeaders("capt_US");
        else 
        {
            sJump = recHeaders("grip_jump");
            if (!isEmpty(sJump) && sJump != "Custom")
                sDisplayName = sJump;
        }        
        sContent = sContent + "\n            <td class=\"GRIDHEAD\"" + alignment + ">" +sDisplayName + "</td> ";
        recHeaders.NextRecord();
    }
    sContent = sContent + "\n        </tr>";
    sContent = sContent + "\n    </thead>";
    sContent = sContent + "\n    <tbody>";

    if (recRows == null || recRows.eof )
    {
        sSQL = "SELECT ";
        if (nMaxRows != null)
            sSQL = sSQL + "TOP " + nMaxRows + " ";
        sSQL = sSQL + sSelectList + " " + 
                " FROM " + sTargetTable + " WITH (NOLOCK) "; 
        if (sWhereClause != null && sWhereClause != "")
            sSQL = sSQL + " WHERE " + sWhereClause + " ";
        if (sOrderByClause != null && sOrderByClause != "")
            sSQL = sSQL + " ORDER BY " + sOrderByClause + " ";
        recRows = eWare.CreateQueryObj(sSQL);
        recRows.SelectSQL();
    }

    sClass = "ROW2";
    arrCols = sCols.split(",");
    rowcounter = 0;
    
    var sAlign = "";
    
    while (!recRows.eof)
    {
        // don't exceed the specified number of rows
        if (nMaxRows != null)
            if (rowcounter > nMaxRows)
                break;
                
        sContent = sContent + "\n        <tr>";
        for (ndx=0; ndx<arrCols.length; ndx++)
        {
            sColName = arrCols[ndx];
            sValue = "";
            sAlign = "";

            sDataType = arrColDataType[ndx];
            switch(sDataType) {
                case "31":
                    sValue = recRows(sColName);
                    sAlign = "right";
                    break;

                case "32":
                    sValue = formatDollar(recRows(sColName));
                    sAlign = "right";
                    break;

                case "41":
                    sValue = getDateAsString(recRows(sColName));
                    sAlign = "center";
                    break;

                case "45":
                    sValue = recRows(sColName);
                    sAlign = "center";
                    break;

                case "51":
                    
                    if (isEmpty(recRows(sColName))) {
                        sValue = "&nbsp;"
                    } else {
                        sValue = formatCurrency(recRows(sColName))
                    }
                    sAlign = "right";
                    break;
                    
                default:
                    sValue = recRows(sColName);
                    
            }

            if (isEmpty(sValue))
                sValue = "&nbsp;"
            else 
            {
                if (sHyperLinkCols.indexOf(sColName) > -1)
                {
                    for (ndxInner=0; ndxInner<arrJumpFields.length; ndxInner++)
                    {
                        var arrHyperlink = arrJumpFields[ndxInner];
                        sLink = arrHyperlink[1] + "?" + arrHyperlink[2] + "=" + recRows(arrHyperlink[2]);
                        sLink = eWare.URL(sLink);
                        if (arrHyperlink[0] == sColName)
                        {
                            sValue = "<a href=\"" + sLink + "\">" + sValue + "</a>"
                        }
                    }
                }
            }
            sContent = sContent + "\n            <td class=" + sClass + " align=" + sAlign + " >" + sValue + "</td> ";
        
        }
        sContent = sContent + "\n        </tr>";
        recRows.NextRecord();
        if (sClass == "ROW1")
            sClass="ROW2";
        else 
            sClass="ROW1";
        rowcounter++;
    }

    sContent = sContent + "\n    </tbody>";
    sContent = sContent + "\n    </table>";
    return sContent;
}

function formatCurrency(num) {

    num = num.toString().replace(/\$|\,/g, "");

    if (isNaN(num)){
        num = "0";
    }

    sign = (num == (num = Math.abs(num)));

    num = Math.floor(num * 100 + 0.50000000001);
    cents = num % 100;
    
    num = Math.floor(num / 100).toString();
    
    if (cents < 10) 
        cents = "0" + cents;
        
    for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
        num = num.substring(0, num.length - (4 * i + 3)) + "," + num.substring(num.length - (4 * i + 3));

    return (((sign) ? "" : "-") + "$" + num + "." + cents);
}

function formatCurrency2(amount)
{
	var i = parseFloat(amount);
	if(isNaN(i)) { 
	    i = 0.00; 
	}

	var minus = '';
	if(i < 0) { 
	    minus = '-'; 
	}

	i = Math.abs(i);
	i = parseInt((i + .005) * 100);
	i = i / 100;

	s = new String(i);
	if(s.indexOf(".") < 0) {
	    s += ".00"; 
	}
	if(s.indexOf(".") == (s.length - 2)) {
	     s += "0"; 
	}

	s = minus + s;
	return s;
}

%>
<%
function makeCalendarField(sFieldName, sCaption, sDefaultValue, sSeparator)
{
	var sResult = "\n<TD  VALIGN=TOP >";
	sResult += "<SPAN ID=_Capt" + sFieldName + " class=VIEWBOXCAPTION>" + sCaption + ":</SPAN>"+sSeparator;
	sResult += "<SPAN ID=_Data" + sFieldName + " class=SEARCHBODY >";
	sResult += "<input type=\"hidden\" name=\"_HIDDEN" + sFieldName + "\" value=\""+ sDefaultValue +"\">";
	sResult += "<input type=\"text\" CLASS=EDIT ID=\"" + sFieldName + "\" name=\"" + sFieldName + "\"  value=\""+ sDefaultValue +"\" maxlength=10 size=10 onblur=\"\" onkeyup=\"if(event.ctrlKey&&event.keyCode==84){value='"+ sDefaultValue +"';event.cancelBubble=true;event.returnValue=false;}\">";
	sResult += "<span id=_Cal" + sFieldName + ">";
	sResult += "<A HREF=\"#\" ONCLICK=\"calendar_onclick(document.forms(0)." + sFieldName + ", oPopup_" + sFieldName + "_Date);\">";
	sResult += "<IMG SRC=\"/" + sInstallName + "/img/Buttons/calCalendar.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
	sResult += "</A>";
	sResult += "</span>";
	sResult += "<script> var oPopup_" + sFieldName + "_Date = window.createPopup();oPopup_" + sFieldName + "_Date.document.createStyleSheet(document.location.protocol+\"//\"+document.location.host+\"/" + sInstallName + "/eware.css\");function Hide" + sFieldName + "_Date(){oPopup_" + sFieldName + "_Date.hide();}</script>";
	sResult += "<input type=hidden name=" + sFieldName + "_HOUR value=\"\">";
	sResult += "<input type=hidden name=" + sFieldName + "_MINUTE value=\"\">";
	sResult += "<input type=hidden name=" + sFieldName + "_AMPM value=\"\">";
	sResult += "<input type=hidden name=" + sFieldName + "_TIME value=\"\">";
	sResult += "</SPAN>";
	sResult += "</TD>";
	return sResult;
}


        blkFilter = eWare.GetBlock("PRSSFileSearchBox");
        blkFilter.Title = "Filter By";
        setBlockCaptionAlignment(blkFilter, 2);
        
        entry = blkFilter.GetEntry("ssfileid");
        entry.Caption = "File Id:";

        //entry = blkFilter.GetEntry("prss_Status");
        //entry.LookupFamily = "Status_OpenClosed";

        // get the form variables that may or may not exist
        sDB_prss_createddate_begin = "NULL";
        prss_createddate_begin = String(Request.Form.Item("prss_createddate_begin"));
        if (prss_createddate_begin == null || isEmpty(prss_createddate_begin))
            prss_createddate_begin = "";
        else
            sDB_prss_createddate_begin = "'" + getDBDate(prss_createddate_begin) + "'";
    
        sDB_prss_createddate_end = "NULL";
        prss_createddate_end = String(Request.Form.Item("prss_createddate_end"));
        if (prss_createddate_end == null || isEmpty(prss_createddate_end))
            prss_createddate_end = "";
        else
            sDB_prss_createddate_end = "'" + getDBDate(prss_createddate_end) + " 11:59 PM'";
            
        // get opened date variables
        sDB_prss_openeddate_begin = "NULL";
        prss_openeddate_begin = String(Request.Form.Item("prss_openeddate_begin"));
        if (prss_openeddate_begin == null || isEmpty(prss_openeddate_begin))
            prss_openeddate_begin = "";
        else
            sDB_prss_openeddate_begin = "'" + getDBDate(prss_openeddate_begin) + "'";
    
        sDB_prss_openeddate_end = "NULL";
        prss_openeddate_end = String(Request.Form.Item("prss_openeddate_end"));
        if (prss_openeddate_end == null || isEmpty(prss_openeddate_end))
            prss_openeddate_end = "";
        else
            sDB_prss_openeddate_end = "'" + getDBDate(prss_openeddate_end) + " 11:59 PM'";

        // get closed date variables
        sDB_prss_closeddate_begin = "NULL";
        prss_closeddate_begin = String(Request.Form.Item("prss_closeddate_begin"));
        if (prss_closeddate_begin == null || isEmpty(prss_closeddate_begin))
            prss_closeddate_begin = "";
        else
            sDB_prss_closeddate_begin = "'" + getDBDate(prss_closeddate_begin) + "'";
    
        sDB_prss_closeddate_end = "NULL";
        prss_closeddate_end = String(Request.Form.Item("prss_closeddate_end"));
        if (prss_closeddate_end == null || isEmpty(prss_closeddate_end))
            prss_closeddate_end = "";
        else
            sDB_prss_closeddate_end = "'" + getDBDate(prss_closeddate_end) + " 11:59 PM'";


        sSeparator = "&nbsp;";
        sCreatedDates = "<table style=\"display:none;\"><tr ID=_trCreatedDates>" 
            + makeCalendarField("prss_createddate_begin", "Created",prss_createddate_begin,sSeparator)
            + makeCalendarField("prss_createddate_end", "Through",prss_createddate_end,sSeparator)
            + "</tr></table>";
        sOpenedDates = "<table style=\"display:none;\"><tr ID=_trOpenedDates>" 
            + makeCalendarField("prss_openeddate_begin", "Opened",prss_openeddate_begin,sSeparator)
            + makeCalendarField("prss_openeddate_end", "Through",prss_openeddate_end,sSeparator)
            + "</tr></table>";
        sClosedDates = "<table style=\"display:none;\"><tr ID=_trClosedDates>" 
            + makeCalendarField("prss_closeddate_begin", "Closed","",sSeparator)
            + makeCalendarField("prss_closeddate_end", "Through","",sSeparator)
            + "</tr></table>";
        Response.Write(sCreatedDates);
        Response.Write(sOpenedDates);
        Response.Write(sClosedDates);


        sFormLoadCommands = "";
        sFormLoadCommands += "InsertRow(\"_Captprss_status\", \"_trCreatedDates\");\n";
        sFormLoadCommands += "InsertRow(\"_Captprss_status\", \"_trOpenedDates\");\n";
        sFormLoadCommands += "InsertRow(\"_Captprss_status\", \"_trClosedDates\");\n";
        // now create the formload section to reload all the values with the submitted values
        sFormLoadCommands += "RemoveDropdownItemByName('prss_assigneduserid', '--None--');\n";
        sFormLoadCommands += "RemoveDropdownItemByName('prss_status', '--None--');\n";
        sFormLoadCommands += "RemoveDropdownItemByName('prss_type', '--None--');\n";
        
        //sFormLoadCommands += "forceTableCellsToLeftAlign('prss_type', '15%');";   
        
        var sGridFilterWhereClause = "";
        if (eWare.Mode != 6)
        {  
        
            
            sDBFileId = "NULL";
            prss_ssfileid = String(Request.Form.Item("ssfileid"));
            if (prss_ssfileid != "undefined")
            {
                if (!isEmpty(prss_ssfileid))
                {
                    sDBFileId = prss_ssfileid; 
                }
            }
            else
                prss_ssfileid = "";

            sDBAssignedUserId = "NULL";
            sUserIdToSelect = "";
            prss_assigneduserid = String(Request.Form.Item("prss_assigneduserid"));
            if (prss_assigneduserid != "undefined")
            {
                if (!isEmpty(prss_assigneduserid))
                {
                    sDBAssignedUserId = prss_assigneduserid; 
                    sUserIdToSelect = prss_assigneduserid;
                }
            }

            sDBType= "NULL";
            prss_type = String(Request.Form.Item("prss_type"));
            if (!isEmpty(prss_type))
                sDBType = "'" + prss_type + "'"; 

            sDBStatus = "NULL";
            prss_status = String(Request.Form.Item("prss_status"));
            if (!isEmpty(prss_status))
                sDBStatus = "'" + prss_status + "'"; 

            sDBClaimantCompanyId = "NULL";
            prss_claimantcompanyid = String(Request.Form.Item("prss_claimantcompanyid"));
            if (prss_claimantcompanyid != "undefined")
            {
                if (!isEmpty(prss_claimantcompanyid))
                {
                    sDBClaimantCompanyId = prss_claimantcompanyid; 
                }
            }
                
            sDBRespondentCompanyId = "NULL";
            prss_respondentcompanyid = String(Request.Form.Item("prss_respondentcompanyid"));
            if (prss_respondentcompanyid != "undefined")
            {
                if (!isEmpty(prss_respondentcompanyid))
                {
                    sDBRespondentCompanyId = prss_respondentcompanyid; 
                }
            }

            sDB3rdPartyCompanyId = "NULL";
            prss_3rdpartycompanyid = String(Request.Form.Item("prss_3rdpartycompanyid"));
            if (prss_3rdpartycompanyid != "undefined")
            {
                if (!isEmpty(prss_3rdpartycompanyid))
                {
                    sDB3rdPartyCompanyId = prss_3rdpartycompanyid; 
                }
            }

            // build the where cluase based upon the filter criteria
            if (sDBAssignedUserId != "NULL")
                sGridFilterWhereClause = "prss_AssignedUserId =" + sDBAssignedUserId;
            if (sDBFileId != "NULL")
                sGridFilterWhereClause = "prss_SSFileId =" + sDBFileId;
            if (!isEmpty(prss_createddate_begin))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_CreatedDate >= " + sDB_prss_createddate_begin;
            if (!isEmpty(prss_createddate_end))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_CreatedDate <= " + sDB_prss_createddate_end;
            if (!isEmpty(prss_openeddate_begin))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_openeddate_begin >= " + sDB_prss_openeddate_begin;
            if (!isEmpty(prss_openeddate_end))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_openeddate_begin <= " + sDB_prss_openeddate_end;
            if (!isEmpty(prss_closeddate_begin))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_closeddate_begin >= " + sDB_prss_closeddate_begin;
            if (!isEmpty(prss_closeddate_end))
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_closeddate_begin <= " + sDB_prss_closeddate_end;
            if (sDBStatus != "NULL")
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_status = " + sDBStatus;
            if (sDBType != "NULL")
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_type = " + sDBType;
            if (sDBClaimantCompanyId != "NULL")
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_claimantcompanyid = " + sDBClaimantCompanyId;
            if (sDBRespondentCompanyId != "NULL")
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_respondentcompanyid = " + sDBRespondentCompanyId;
            if (sDB3rdPartyCompanyId != "NULL")
                sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"prss_3rdpartycompanyid = " + sDB3rdPartyCompanyId;

            //sFormLoadCommands += "document.EntryForm.prss_createddate_begin.value = '"+ prss_createddate_begin + "';\n";
            //sFormLoadCommands += "document.EntryForm.prss_createddate_end.value = '"+ prss_createddate_end + "';\n";
            //sFormLoadCommands += "document.EntryForm.prss_openeddate_begin.value = '"+ prss_openeddate_begin + "';\n";
            //sFormLoadCommands += "document.EntryForm.prss_openeddate_end.value = '"+ prss_openeddate_end + "';\n";
            sFormLoadCommands += "document.EntryForm.ssfileid.value = '"+ prss_ssfileid + "';\n";
            sFormLoadCommands += "SelectDropdownItemByValue('prss_assigneduserid', '" + prss_assigneduserid + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('prss_status', '" + prss_status + "');\n";
            sFormLoadCommands += "SelectDropdownItemByValue('prss_type', '" + prss_type + "');\n";
        }        
            
%>


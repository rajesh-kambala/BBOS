<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\DLOrderCheckInclude.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    doPage();

function doPage() {
	var lineBreak = "<BR>";
	var user_userid = eWare.GetContextInfo("User", "User_UserID");
    var sSecurityGroups = "1,2,4,5,6,10";

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyDLInclude.js\"></script>");
    
    if (eWare.Mode == 99)
    {
        triggerDLOrder(comp_companyid, user_userid);
        var blkOrderedBanner = eWare.GetBlock('content');
        eWare.Mode = Edit;
    }


	sSQL = "SELECT COUNT(1) As DLCount FROM PRDescriptiveLine WITH (NOLOCK) WHERE prdl_CompanyID=" + comp_companyid; 
    recDLCount = eWare.CreateQueryObj(sSQL);
    recDLCount.SelectSQL();	    
	var beforeCount = recDLCount("DLCount");

	sSQL = "SELECT COUNT(1) As UnloadCount FROM PRUnloadHours WITH (NOLOCK) WHERE pruh_CompanyID=" + comp_companyid; 
    recUnlaodCount = eWare.CreateQueryObj(sSQL);
    recUnlaodCount.SelectSQL();	    
	var unloadCount = recUnlaodCount("UnloadCount");

    if (eWare.Mode == Save)
    {
	    szVal = Request("comp_prpublishDL");
	    if (szVal == "Y") {
	        recCompany("comp_PRPublishDL") = "Y";
	    } else {
	        recCompany("comp_PRPublishDL") = "";
        }

        
	    szVal = Request("comp_PRPublishUnloadHours");
	    if (szVal == "Y") {
	        recCompany("comp_PRPublishUnloadHours") = "Y";
	    } else {
	        recCompany("comp_PRPublishUnloadHours") = "";
        }
	    recCompany.SaveChanges();

	    var sProcessedUnload = String(Request.Form.Item("hdnProcessedUnload"));
        sProcessedUnload = prepareDL(sProcessedUnload);
	    var sSaveUnload = "EXEC usp_SaveUnloadHours @CompanyId = " + comp_companyid + ", @Content = '" + sProcessedUnload + "', @LineBreak = '" + lineBreak + "', @UserId = " + user_userid;

	    var qUnload = eWare.CreateQueryObj(sSaveUnload);
	    qUnload.ExecSQL();
	    qUnload = null;
   	    sProcessedUnload =  null;

	    
	    var sProcessedDL = String(Request.Form.Item("hdnProcessedDL"));
        sProcessedDL = prepareDL(sProcessedDL);
   
	    // Insert the dl lines.
	    var sSaveDL = "EXEC usp_SaveDL @CompanyId = " + comp_companyid + ", @Content = '" + sProcessedDL + "', @LineBreak = '" + lineBreak + "', @UserId = " + user_userid;
	    var qDL = eWare.CreateQueryObj(sSaveDL);
	    qDL.ExecSQL();
	    qDL = null;
   	    sProcessedDL =  null;


	    sSQL = "SELECT COUNT(1) As DLCount FROM PRDescriptiveLine WITH (NOLOCK) WHERE prdl_CompanyID=" + comp_companyid; 
        recDLCount = eWare.CreateQueryObj(sSQL);
        recDLCount.SelectSQL();	    
	    var afterCount = recDLCount("DLCount");

        sSQL = "INSERT INTO PRDLMetrics (prdlm_UserID, prdlm_CompanyID, prdlm_BeforeCount, prdlm_AfterCount, prdlm_ChangeCount, prdlm_CreatedBy, prdlm_CreatedDate, prdlm_UpdatedBy, prdlm_UpdatedDate, prdlm_Timestamp) " +
               "VALUES (" + user_userid + "," + comp_companyid + "," + beforeCount + ", " + afterCount + ", " + (afterCount - beforeCount).toString() + "," + user_userid + ", GETDATE(), " + user_userid + ", GETDATE(), GETDATE())";
        qryDLMetrics = eWare.CreateQueryObj(sSQL);
        qryDLMetrics.ExecSQL();

        // only create this task if the status is listed or hold
        if ("H,L".indexOf(recCompany("comp_prlistingstatus")) > -1) {
	        // create a task for a listing specialist review, if this user is not a listing specialist
	        if (!isUserInGroup("4")) {
                // make sure there is not already a task created for the assigned user to review this
                // duplicates are not desired..
                sSQL = "SELECT AssignedUserId = dbo.ufn_GetPRCoSpecialistUserId(" + comp_companyid + ", 3)";
                recAssignedUser = eWare.CreateQueryObj(sSQL);
                recAssignedUser.SelectSQL();
                
                sSQL = "SELECT 1 FROM vCommunication WHERE " +
                        "cmli_comm_UserId = " + recAssignedUser("AssignedUserId") + " AND " +
                        "comm_status = 'Pending' AND cmli_comm_CompanyId = " + comp_companyid + " AND " +
                        "comm_Note like 'Review the modified DL for%'";
                recTaskExists = eWare.CreateQueryObj(sSQL);
                recTaskExists.SelectSQL();
                if (recTaskExists.RecordCount == 0){
                    
                    sSQL = "EXEC usp_CreateTask " +
                            "@CreatorUserId=" + user_userid + ", " +  
                            "@AssignedToUserType=3, " +  
                            "@TaskNotes= 'Review the modified DL for " + padQuotes(recCompany("comp_name")) + "', " +
                            "@Subject= 'Review the modified DL for " + padQuotes(recCompany("comp_name")) + "', " +
                            "@RelatedCompanyId=" + comp_companyid + ", " +  
                            "@Status = 'Pending'" ;
                            "@Action = 'ToDo'" ;
                    recTask = eWare.CreateQueryObj(sSQL);
                    recTask.ExecSQL();
                }
	        }
        }
        eWare.Mode = Edit;
        Response.Redirect(eWare.Url("PRCompany/PRCompanyDLView.asp") + "&T=Company&Capt=Profile");
        return;
    }
    else
    {
        if (eWare.Mode<Edit) 
            eWare.Mode=Edit;

        if (!hasDLService(comp_companyid)) {

            var blkBanners = eWare.GetBlock('content');
            blkBanners.contents = getDLMsgBanner();
            
            if (hasDLServiceOrdered(comp_companyid)) {
                blkBanners.contents += getDLOrderedMsgBanner();
            }

            //blkContainer.AddBlock(blkBanners);
            //blkContainer.AddButton(eWare.Button("Create DL Order", "save.gif", changeKey(sURL, "em", "99"))) ;

        } 

        var listBoxRows = new Number(unloadCount);
        if (listBoxRows == 0) {
            listBoxRows = 10;
        } else {
            listBoxRows = listBoxRows + 5;
        }


        var blkUnloadHours = eWare.GetBlock("content");
        var recUnLoad = eWare.FindRecord("PRUnloadHours", "pruh_CompanyID=" + comp_companyid);
        recUnLoad.OrderBy = "pruh_UnloadHoursID";
        var sCompleteUnloadString = "";
        while (! recUnLoad.eof) 
        {
            sLine = recUnLoad("pruh_LineContent");
            if (isEmpty(sLine))
                sLine = "";
            recUnLoad.NextRecord();
            sCompleteUnloadString += sLine;
            if (!recUnLoad.eof)
                sCompleteUnloadString += "_BR_";
        }
        
        var sContents = createAccpacBlockHeader("EditableUnload","Unload Hours", "100%", "100%");

        sContents += "<input type=\"hidden\" name=\"hdnProcessedUnload\" id=\"hdnProcessedUnload\">\n";
        sContents += "<table CELLPADDING=0 CELLSPACING=0 BORDER=0>\n";
       
        szChecked = "";
        if (recCompany.comp_PRPublishUnloadHours) {
            szChecked = " checked ";
        }
        sContents += "<td  class=\"VIEWBOXCAPTION\">";
        sContents += "<input type=checkbox name=\"comp_PRPublishUnloadHours\" value=Y id=\"_IDcomp_PRPublishUnloadHours\"" + szChecked + "><label for=\"_IDcomp_PRPublishUnloadHours\">Publish Unload Hours</label>";
        sContents += "</td>\n";

        sContents += "</tr>\n";

        sContents += "<tr height=5><td></td></tr>\n";
        sContents += "<tr>\n";
        sContents += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Unprocessed Unload Hours Listing:</span><br/>";
        sContents += "<textarea class=\"EDIT\" ID=\"txtUnprocessedUnload\" NAME=\"txtUnprocessedUnload\" ROWS=\"" + listBoxRows.toString() + "\" COLS=\"34\" onKeyUp=\"refreshProcessedUnload();\" style=\"font-family:courier;\">";
        sContents += sCompleteUnloadString;
        sContents += "</textarea></td>\n";
        
        sContents += "<td>&nbsp;&nbsp;</td>\n";
        sContents += "<td valign=\"TOP\">\n<span class=\"VIEWBOXCAPTION\">Unload Listing:</span><br/>\n";
        sContents += "<div valign=\"TOP\" STYLE=\"margin:1;padding:2;border-style:solid;border-width:1px;WIDTH:230px;\" class=\"VIEWBOX\" id=\"spanProcessedUnload\" name=\"spanProcessedUnload\">\n";
        sContents += sCompleteUnloadString;
        sContents += "\n</div></td>\n";
        
        sContents += "</tr>\n";
        sContents += "</table>\n";

        sContents += createAccpacBlockFooter();
        blkUnloadHours.contents = sContents;



        listBoxRows = new Number(beforeCount);
        if (listBoxRows == 0) {
            listBoxRows = 10;
        } else {
            listBoxRows = listBoxRows + 5;
        }
            
        var blkDLDisplay = eWare.GetBlock("content");
        var recDLs = eWare.FindRecord("PRDescriptiveLine", "prdl_companyid=" + comp_companyid);
        recDLs.OrderBy = "prdl_DescriptiveLineId";
        var sCompleteDLString = "";
        while (! recDLs.eof) 
        {
            sLine = recDLs("prdl_LineContent");
            if (isEmpty(sLine))
                sLine = "";
            recDLs.NextRecord();
            sCompleteDLString += sLine;
            if (!recDLs.eof)
                sCompleteDLString += "_BR_";
        }
        
        sContents = createAccpacBlockHeader("EditableDL","Descriptive Lines", "100%", "400");

        sContents += "\n<input type=\"hidden\" name=\"txtClipboard\" id=\"txtClipboard\">\n";
        sContents += "<input type=\"hidden\" name=\"hdnProcessedDL\" id=\"hdnProcessedDL\">\n";
        sContents += "<table CELLPADDING=0 CELLSPACING=0 BORDER=0>\n";

        szChecked = "";
        if (recCompany.comp_prpublishDL) {
            szChecked = " checked ";
        }
        sContents += "<tr>\n";
        sContents += "<td  class=\"VIEWBOXCAPTION\">";
        sContents += "<input type=checkbox name=\"comp_prpublishDL\" value=Y id=\"_IDcomp_prpublishDL\"" + szChecked + "><label for=\"_IDcomp_prpublishDL\">Publish Descriptive Lines</label>";
        sContents += "</td>\n";
        sContents += "</tr>\n";



        sContents += "<tr><td COLSPAN=\"3\" valign=\"top\" style=\"padding-top:10px;\"><span class=\"VIEWBOXCAPTION\">Available Fields:</span></td></tr>\n";
        
        sContents += "<tr>\n";
        sContents += "\t<td valign=\"top\" style=\"padding-bottom:10px;\" COLSPAN=\"3\">\n<table CELLPADDING=2 CELLSPACING=0 BORDER=1 RULES=NONE>\n";
        sContents += "<tr>\n\t<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">DL Phrase:</span>";
        sContents += "<br/>\n\t<select class=\"VIEWBOX\" ID=\"prdlp_DLPhrase\">\n";
        var recPhrases = eWare.FindRecord("PRDLPhrase","");
        recPhrases.OrderBy = "prdlp_Order";
        while (!recPhrases.eof) 
        {
            sContents += "\t\t\t<option value=\""+ recPhrases("prdlp_DLPhraseId") + "\">" + recPhrases("prdlp_Phrase") + "</option>\n";
            recPhrases.NextRecord();
        }
        sContents += "\t</select>&nbsp;&nbsp;\n";
        sContents += "\t</td>\n\t<td>";    
        sContents += "<a class=\"ButtonItem\" href=\"javascript:insertTextAtCursor('txtUnprocessedDL', 'prdlp_DLPhrase');\">";
        sContents += "<img align=\"left\" border=0 src=\"../../img/Buttons/new.gif\"></a>";
        sContents += "</td>\n\t<td>";    
        sContents += "<a class=\"ButtonItem\" href=\"javascript:insertTextAtCursor('txtUnprocessedDL', 'prdlp_DLPhrase');\">";
        sContents += "Insert<br/>Phrase</a>";    
        sContents += "</td>\n</tr>\n";
        sContents += "</table></td>\n";

        sContents += "<td>\n</td>\n";
        
        sContents += "</tr>\n";

        sContents += "<tr height=5><td></td></tr>\n";
        sContents += "<tr>\n";
        sContents += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">Unprocessed D/L Listing:</span><br/>";
        sContents += "<textarea class=\"EDIT\" ID=\"txtUnprocessedDL\" NAME=\"txtUnprocessedDL\" ROWS=\"" + listBoxRows.toString() + "\" COLS=\"34\" onKeyUp=\"refreshProcessedDL();\" style=\"font-family:courier;\">";
        sContents += sCompleteDLString;
        sContents += "</textarea></td>\n";
        
        sContents += "<td>&nbsp;&nbsp;</td>\n";
        sContents += "<td valign=\"TOP\">\n<span class=\"VIEWBOXCAPTION\">D/L Listing:</span><br/>\n";
        sContents += "<div valign=\"TOP\" STYLE=\"margin:1;padding:2;border-style:solid;border-width:1px;WIDTH:230px;\" class=\"VIEWBOX\" id=\"spanProcessedDL\" name=\"spanProcessedDL\">\n";
        sContents += sCompleteDLString;
        sContents += "\n</div></td>\n";
        
        sContents += "</tr>\n";
        sContents += "</table>\n";

        sContents += createAccpacBlockFooter();
        blkDLDisplay.contents = sContents;


        blkContainer.AddBlock(blkUnloadHours);
        blkContainer.AddBlock(blkDLDisplay);
        blkContainer.CheckLocks = false;

        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyDLView.asp") + "&T=Company&Capt=Profile"));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

        eWare.AddContent(blkContainer.Execute(recCompany));
        Response.Write(eWare.GetPage('Company'));
        

%>
        <script type="text/javascript" >
            function initBBSI()
            {
                sProcessedDLString = "<%= sCompleteDLString %>";
                initializeProcessedDL();
                //document.EntryForm.txtUnprocessedDL.focus();
                setCaretTextRange(document.EntryForm.txtUnprocessedDL);
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
<%
    }
}

function prepareDL(content) {
	var lineBreak = "<BR>";

	// Look for an ending line break and remove it
	if (content.length >= lineBreak.length) {
	    if (content.substr(content.length - lineBreak.length, lineBreak.length) == lineBreak) {
            content = content.substr(0, content.length - lineBreak.length)
	    }
	}
	    
	// replace ampersand chars
    var re = new RegExp("&amp;", "gi");
	content = content.replace(re, "&");
	re = new RegExp("'", "g");
	content = content.replace(re, "''");
	re = null;

    return content;
}
%>
<!-- #include file ="CompanyFooters.asp" -->

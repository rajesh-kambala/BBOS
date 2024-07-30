<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2024

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
%>

<!-- #include file ="../PRCompany/CompanyHeaders.asp" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="DocumentDropInclude.asp" -->

<!-- Leave this block in; do not remove; it is helpful for debugging  -->
<!--
<HTML>
<HEAD>
</HEAD>
<BODY>
<TABLE><TR>
<TD ID=_icTD></TD></TR></TABLE>Please wait. Uploading attached object
<OBJECT align=center classid=clsid:3DFD2B52-C6E9-11D4-8226-005004F658FC 
CODEBASE="/<%= sInstallName %>/Plugin/eWarePluginX.cab#version=5,8,0,2" 
height=0 
width=0 >
<PARAM NAME="PluginAction" 
VALUE="&quot;Action=GetObject&quot;,
&quot;nextUrl=/<%= sInstallName %>/CustomPages/PRFile/PRFileInteraction.asp?SID=59251367477875&Key0=4&Key4=2&Key37=6001&Key50=7&F=PRGeneral/PRInteraction.asp&J=PRFile/PRFileInteraction.asp&Key6=422536&quot;,
&quot;failUrl=/<%= sInstallName %>/eware.dll/Do?SID=59251367477875&Act=183&Mode=102&CLk=T&Key0=4&Key4=2&Key6=422536&quot;,
&quot;Alias=/<%= sInstallName %>/Library/&quot;,
&quot;Host=http://sql01&quot;,
&quot;LocalPath=C%3A%5CDOCUME%7E1%5CRICHAR%7E1%5CLOCALS%7E1%5CTemp%5C&quot;,
&quot;/<%= sInstallName %>/eware.dll/Do?SID=59251367477875&Act=571&Mode=1&CLk=T&Key0=4&Key4=2&Key6=422536&quot;,
&quot;ServerLocation=Rich+Otruba&quot;,
&quot;FileName=2006110rao19.48 09-11-06.log&quot;,
&quot;LibraryId=10028&quot;">
</OBJECT>
</BODY>
</HTML>

    //return;
-->

<% 
    var sTopContentUrl = "";
    doPage();

function doPage()
{
    //bDebug = true;
    DEBUG(sURL);

    DEBUG("<BR>SaveDocDir: " + Request.QueryString("SaveDocDir"));
    DEBUG("<BR>SaveDocName: " + Request.QueryString("SaveDocName"));

    Session("bShowCompanyPhone") = 1;

    var sInitializeActions = "";
    
    var sEntity = "";
    var bNew = false;
    var sPostSaveUrl = "";
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    var sSecurityGroups = "1,2,3,4,5,6,7,8, 9,10,11";

    var recLibrary = null;
	var recvCommunication = null;
	var comm_communicationid = getIdValue("comm_CommunicationId");
	if (comm_communicationid == -1)
	    comm_communicationid = getIdValue("Key6");

    DEBUG("comm_communicationid:" + comm_communicationid);
  	var prss_ssfileid = "-1";
    
    var key0 = new String(Request.QueryString("Key0"));
    if (key0 == "1") 
        sTopContentUrl = "CompanyTopContent.asp"; 

    if (key0 == "2") {
      sTopContentUrl = "PersonTopContent.asp"; 
      pers_personid = getIdValue("Key2")
    }

    if (eWare.Mode < Edit)
        eWare.Mode = Edit;

    if (comm_communicationid == "-1")
    {
        bNew = true;
        recComm = eWare.CreateRecord("Communication");
        // check if a prss_ssfileid is passed    
        prss_ssfileid = getIdValue("prss_SSFileId");
    }
    else
    {
        recComm = eWare.FindRecord("Communication", "comm_communicationid=" + comm_communicationid);
        recvCommunication= eWare.FindRecord("vCommunication", "comm_communicationid=" + comm_communicationid);
        if (!recComm.eof)
        {
            if (!isEmpty(recComm("comm_PRFileId")) )
            {
                if(isEmpty(recComm("comm_PRSubcategory")) || recComm("comm_PRSubcategory") != "BV")
                    prss_ssfileid = recComm("comm_PRFileId");
            }

            if ((sTopContentUrl == "") &&
                (!isEmpty(recvCommunication("cmli_comm_CompanyID")))) {
                sTopContentUrl = "CompanyTopContent.asp"; 
                comp_companyid  = recvCommunication("cmli_comm_CompanyID");
            }
        }   
    }

    var blkContainer = eWare.GetBlock("Container");
	blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.CheckLocks = false;

    var blkTop = eWare.GetBlock("Container");
    blkPicker=eWare.GetBlock("CommWebPicker");
	blkPicker.Title = "Interaction For";
	blkPicker.ArgObj = recvCommunication;

    blkDetail=eWare.GetBlock("CustomCommunicationDetailBox");
	blkDetail.Title = "Details";

    if(bNew)
    {
        var fldPRC = blkDetail.GetEntry("comm_prcategory");
        fldPRC.LookupFamily = "comm_prcategory_curr";
        var fldPRSC = blkDetail.GetEntry("comm_prsubcategory");
        fldPRSC.LookupFamily = "comm_prsubcategory_curr";
    }

    blkSchedule=eWare.GetBlock("CommunicationSchedulingBox");
    blkSchedule.NewLine = false;
	blkSchedule.Title = "Schedule";
    
    var sFollowupRow = "<TR id=\"tr_FollowupTask\"><TD colspan=4><TABLE class=\"VIEWBOXCAPTION\"><TR><TD><input type=\"checkbox\" name=\"DoFollowUpTask\"></TD><TD><div style=\"cursor:hand\" onclick=\"javascript:document.forms[0].DoFollowUpTask.click();\">Create Follow-up Interaction</div></TD></TR></TABLE></TD></TR>";	
    var sFollowupTable = "<table style=\"display:none;\">" + sFollowupRow + "</table>";
    Response.Write(sFollowupTable);
    
    if (F != "" && prss_ssfileid != "-1")
	{
		sListingAction = eWare.Url("PRSSFile/PRSSFileInteraction.asp")+ "&prss_ssfileid="+ prss_ssfileid;
	}
	else
	{
        Key0 = new String(Request.QueryString("Key0"));
        var Key4 = new String(Request.QueryString("Key4"));
        var HNA = new String(Request.QueryString("HNA"));
        if (isEmpty(Key0)) {
            Key0 = "0"
        }

        sListingAction="";
        //Response.Write("<p>HNA: " + HNA);
        //Response.Write("<p>Key0: " + Key0);
        
        if (!isEmpty(HNA)) {  // My CRM
            sListingAction = eWare.Url(HNA);

            if (HNA == "2301")  
                sListingAction = sListingAction + "&T=User&ErgTheme=0&Key4=3";
        } else if (Key0 == "4") {  // My CRM
            //sListingAction = eWare.Url("183");
            //sListingAction = sListingAction + "&T=User&ErgTheme=0&Key4=3";
            sListingAction = eWare.Url("TravantCRM.dll-RunMyCRMInteractionListing");
            sListingAction = sListingAction.replace("TravantCRM.dll", "TravantCRM"); 
        } else if (Key0 == "5") {  // Team CRM
            sListingAction = eWare.Url("2300");
            sListingAction = sListingAction + "&T=Channel&ErgTheme=0&Key4=3";
        } else if (Key0 == "2") {  // Person
            //sListingAction = eWare.Url("183");
            sListingAction = eWare.Url("TravantCRM.dll-RunPersonInteractionListing");
        } else {
            sListingAction = eWare.Url("TravantCRM.dll-RunCompanyInteractionListing");
            
            // If we build the link with TravantCRM-, the link won't build correctly.  So we
            // build it with the file extention to get the correct format/query string parameters
            // and then remove the file extension.
            sListingAction = sListingAction.replace("TravantCRM.dll", "TravantCRM"); 
            
            // If we are going to the company interaction listing page, make sure our context
            // is set to Company, i.e. Key0=1.
            if (Key0 != "1") {
                sListingAction = sListingAction.replace("Key0=" + Key0, "Key0=1");    
            }
        } 
	}

    if (prss_ssfileid != "-1")
    {
        DEBUG("<BR>SSFile present: ["+ prss_ssfileid + "]" );
        sEntity = "PRSSFile";
        entry = blkPicker.GetEntry("comm_opportunityid");
        // RAO: We cannot just hide this because then the adv search fails; need to use javascript
        // to make it invisible below.
        //entry.Hidden = true;
        entryFileId = blkPicker.GetEntry("comm_PRFileId");

        if (bNew)
        {
            // to make matters worse, we have to make the comm_prfileid field hidden in the fields createscript
            // unless it is already populated.  For new it is not, so we are going to redraw it on the screen.
            sCustomSSFileIdContent = "<SPAN ID=_Captcomm_prfileid class=VIEWBOXCAPTION>SS File:&nbsp;</SPAN><SPAN ID=_Datacomm_prfileid class=VIEWBOXCAPTION >" + prss_ssfileid + "</SPAN>";
            sInitializeActions = "AppendRow(\"_Captcmli_comm_companyid\", \"" + sCustomSSFileIdContent + "\", true);";
            
        } else {
            
            entryFileId.ReadOnly = true;
            entryFileId.CaptionPos = 2;
        }
        entryFileId.DefaultValue = prss_ssfileid;
        recComm.comm_PRFileId = prss_ssfileid;


        entryNote = blkDetail.getEntry("comm_note");
        entryNote.DefaultValue = "File Id: " + prss_ssfileid + "\n";
        recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
        prss_respondentcompanyid = recSSFile("prss_RespondentCompanyId");
        if (!isEmpty(prss_respondentcompanyid))
        {
            recRespondentSearch = eWare.FindRecord("PRCompanySearch", "prcse_companyid=" + prss_respondentcompanyid);
            entryNote.DefaultValue +=  recRespondentSearch("prcse_FullName") + "\n";
        }

    	recComm.comm_Type = "Task";
    	
    	entry = blkSchedule.GetEntry("comm_todatetime");
    	entry.DefaultValue = "";
        sInitializeActions += "\nsetFieldValue(\"comm_todatetime\", \"\"); ";
        sInitializeActions += "\nsetFieldValue(\"comm_todatetime_TIME\", \"\"); ";
        sInitializeActions += "\nsetFieldValue(\"comm_todatetime_HOUR\", \"\"); ";
        sInitializeActions += "\nsetFieldValue(\"comm_todatetime_MINUTE\", \"\"); ";
    }
    
    var sCompanyId = getFormValue("cmli_comm_companyid");
    var sPersonId = getFormValue("cmli_comm_personid");

    //Defect 6880
    if(bNew && sCompanyId == "undefined" && sPersonId == "undefined") {
        var key7 = new String(Request.QueryString("Key7")); //OpportunityID

        if(key7 != "undefined") {
            recOpportunity = eWare.FindRecord("Opportunity", "oppo_opportunityid=" + key7);
            if (!recOpportunity.eof) {
                var ot = "";
                if(recOpportunity.oppo_type == "BP") ot = " - Blueprints Advertising";
                else if(recOpportunity.oppo_type == "DA") ot = " - Digital Advertising";
                else if(recOpportunity.oppo_type == "NEWM") ot = " - New Membership";
                else if(recOpportunity.oppo_type == "UPG") ot = " - Membership Upgrade"
                else ot=" - " + recOpportunity.oppo_type;

                fld = blkDetail.GetEntry("comm_Subject");  fld.DefaultValue = "Opportunity Note" + ot;
                fld = blkDetail.GetEntry("comm_Action");  fld.DefaultValue = "Note"; //Internal Note
                fld = blkDetail.GetEntry("comm_PRCategory");  fld.DefaultValue = "SM"; //Sales & Marketing
                fld = blkDetail.GetEntry("comm_Status");  fld.DefaultValue = "Pending";
                fld = blkDetail.GetEntry("comm_Priority");  fld.DefaultValue = "Normal";

                recComm.comm_opportunityid = key7;

                fld = blkPicker.GetEntry("cmli_comm_companyid");  fld.DefaultValue = recOpportunity("oppo_primarycompanyid");
            }
        }
    }

	blkTop.AddBlock(blkPicker);

    var blkMiddle = eWare.GetBlock("Container");

	// we need to make the schedule block look more like accpac's native one.
	entry = blkSchedule.GetEntry("comm_datetime");
	entry.Caption = "Due Date/Time:";
	entry = blkSchedule.GetEntry("comm_todatetime");
	entry.Caption = "Start Date/Time:";
	entry = blkSchedule.GetEntry("comm_notifydelta");
    if (entry != null)
        entry.Hidden = true;
    entry = blkSchedule.GetEntry("comm_smsnotification");       
    if (entry != null)
        entry.NewLine = true;
	
	var sOnLoadViewAttachement = "";
    var sOnLoadMoveDropzone = "";
    var sOnLoadMoveDroppedFilename = "";
	if (recComm("comm_HasAttachments") == "Y")
	{
	    recLibrary = eWare.FindRecord("Library", "libr_CommunicationId="+comm_communicationid);
	    if (!isEmpty( recLibrary("libr_FileName") ) )
	    {
	        DEBUG("libr_FilePath: " + recLibrary("libr_FilePath"))
	        DEBUG("libr_FileName: " + recLibrary("libr_FileName"));
	        sViewAttachment = "<table style=\"display:none;\"><tr id=\"tr_ViewAttachmentRow\"><td colspan=\"2\">" +
	            getViewAttachmentHTML(recLibrary("libr_FilePath"), recLibrary("libr_FileName"))+ "</td></tr></table>";
	        // add the table to the form
	        eWare.AddContent(sViewAttachment);
	        // set a command to move it to the appropriate location
	        sOnLoadViewAttachement = "AppendRow(\"_Captcomm_channelid\", \"tr_ViewAttachmentRow\");";
        }	
	}
    else
    {
        if(getIdValue("filename") == "-1")
        {
            //Defect 6934 - add our own file drop control instead of native page to prevent key6 issue on subsequent drag/drops
            var blkDropzone = eWare.GetBlock("content");

            var dzContent = "<table style=\"display:block;\"><tr id=\"tr_DropzoneRow\"><td colspan=\"2\">";
            dzContent += "<input type=\"hidden\" id=\"_HIDDropzoneFilename\" name=\"_HIDDropzoneFilename\" />\n";
            dzContent += "<iframe src=\"/CRM/CustomPages/PRGeneral/FileUpload.aspx\" width=\"175\" height=\"175\" scrolling=\"no\" seamless=\"seamless\" border=\"0\" frameborder=\"0\"></iframe>\n";
            dzContent += "<script> function fileUploadCallback(filename) { document.getElementById(\"_HIDDropzoneFilename\").value = filename; document.getElementById(\"td_DroppedFilename\").innerText = filename + \" will be attached when saved.\"; } </script>";
            dzContent += "</td></tr><tr id=\"tr_DroppedFilename\"><td></td><td id=\"td_DroppedFilename\" style=\"padding-top:10px; color:red;\"></td></tr></table>";
            blkDropzone.contents = dzContent;
            blkContainer.AddBlock(blkDropzone);
            
            sOnLoadMoveDropzone = "AppendRow(\"tr_FollowupTask\", \"tr_DropzoneRow\");";
            sOnLoadMoveDroppedFilename = "AppendRow(\"tr_FollowupTask\", \"tr_DroppedFilename\");";
        }
    }
	    
    blkMiddle.AddBlock(blkDetail);
    blkMiddle.AddBlock(blkSchedule);
    if (eWare.Mode==Edit || eWare.Mode==View) {
        blkDetail.ArgObj = recComm;
        blkSchedule.ArgObj = recvCommunication;
    }    

    if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        try{
            sql = "DELETE FROM Comm_Link WHERE cmli_comm_CommunicationId="+ comm_communicationid;
            qryDelete = eWare.CreateQueryObj(sql);
            qryDelete.ExecSql();
            sql = "DELETE FROM Communication WHERE comm_CommunicationId="+ comm_communicationid;
            qryDelete = eWare.CreateQueryObj(sql);
            qryDelete.ExecSql();
	        Response.Redirect(sListingAction);
        } catch (ex){
	        Response.Write("<span>Error occurred preventing the deletion of this record: "+ ex.description + "</span>");
        }
        return;
    } else {
        blkContainer.CheckLocks = false;

        blkContainer.AddBlock(blkTop);
        blkContainer.AddBlock(blkMiddle);
    
        if (eWare.Mode == Edit )
        {
            //Response.Write("<p>Edit: " + sListingAction);
            var cancelButton = eWare.Button("Cancel", "cancel.gif", sListingAction);
            cancelButton = cancelButton.replace("/crm/?", "/crm/eware.dll/Do?");
            blkContainer.AddButton(cancelButton);

	        if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"save();"));
        } else {
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
    	    if (isUserInGroup(sSecurityGroups))
            {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));
            }
        }

        var ReportURL = getReportServerURL() + "?/BBSReporting/InteractionDetail&rc:Parameters=false&CommID=" + comm_communicationid;
        var btnInteractionDetailReport = eWare.Button("Interaction Detail Report","componentpreview.gif", "javascript:ViewReport('" + ReportURL + "');");
        blkContainer.AddButton(btnInteractionDetailReport);


        //Add Attachment button that goes to native eWare.dll page
        sAddAttachmentUrl = removeKey(eWare.Url(340), "Key0");
        sAddAttachmentUrl = removeKey(sAddAttachmentUrl, "Key6");
        sAddAttachmentUrl = sAddAttachmentUrl + "&Key0=6&Key6=" + comm_communicationid;

        //var btnAddAttachment = eWare.Button("Add Attachment","componentpreview.gif", sAddAttachmentUrl);
        //blkContainer.AddButton(btnAddAttachment);


        if (eWare.Mode == Save) {
            try{
                var sFileName = getIdValue("SaveDocName");
                var sHasAttachments = "";
                if (sFileName != null &&  sFileName != "-1")
                {
                    sHasAttachments = "Y";
                    recComm.comm_HasAttachments = 'Y';
                }
                
                blkDetail.Execute(recComm);
 
                // accpac will not allow saves using the blkSchedule block; off to manual... again.
                var sTemp1 = getFormValue("comm_datetime");
                var sTemp2 = getFormValue("comm_datetime_TIME");
                if (sTemp1 != null && sTemp1 != "")
                {
                    if (sTemp2 != null && sTemp2 != "")
                        sTemp1 += " " + sTemp2;
                    recComm.comm_datetime = sTemp1;
                }
                sTemp1 = getFormValue("comm_todatetime");
                sTemp2 = getFormValue("comm_todatetime_TIME");
                if (sTemp1 != null && sTemp1 != "")
                {
                    if (sTemp2 != null && sTemp2 != "")
                        sTemp1 += " " + sTemp2;
                    recComm.comm_todatetime = sTemp1;
                }
                sTemp1 = getFormValue("comm_taskreminder");
                if (sTemp1 != null && sTemp1 == "on")
                    recComm.comm_taskreminder = "Y";
                else
                    recComm.comm_taskreminder = "";
                sTemp1 = getFormValue("comm_notifydelta");
                if (!isEmpty(sTemp1) )
                    recComm.comm_notifydelta = sTemp1;
                sTemp1 = getFormValue("comm_notifytime");
                sTemp2 = getFormValue("comm_notifytime_TIME");
                if (sTemp1 != null && sTemp1 != "")
                {
                    if (sTemp2 != null && sTemp2 != "")
                        sTemp1 += " " + sTemp2;
                    recComm.comm_notifytime = sTemp1;
                }
                sTemp1 = getFormValue("comm_smsnotification");
                if (sTemp1 != null && sTemp1 == "on")
                    recComm.comm_smsnotification = "Y";
                else
                    recComm.comm_smsnotification = "";
                sTemp1 = getFormValue("comm_channelid");
                if (sTemp1 != null && sTemp1 != "")
                    recComm.comm_channelid = sTemp1;

                recComm.SaveChanges();

                // Sometimes when creating a follow-up interaction
                // the Type is not set.  In that case, default it 
                // to "Task"
                if (isEmpty(recComm.comm_Type)) {
                    recComm.comm_Type = "Task";
                    recComm.SaveChanges();
                }

                comm_communicationid = recComm("comm_communicationid");
                if (bNew){
                    // manually save the comm link record
                    recCommLink = eWare.CreateRecord("Comm_Link");
                    recCommLink.cmli_comm_communicationid = comm_communicationid;
                } else {
                    recCommLink = eWare.FindRecord("Comm_Link", "cmli_Comm_CommunicationId=" + comm_communicationid);
                }
                
                if (sCompanyId != null)
                    recCommLink.cmli_comm_companyid = sCompanyId;
                
                if (sPersonId != null)
                    recCommLink.cmli_comm_personid = sPersonId;
                var sUserId = getFormValue("cmli_comm_userid");
                if (sUserId != null)
                    recCommLink.cmli_comm_userid = sUserId;

                //Defect 6880
                var key1 = new String(Request.QueryString("Key1")); //company
                var key2 = new String(Request.QueryString("Key2")); //person
                if(bNew && key1 == "undefined" && key2 == "undefined") {
                    var key7 = new String(Request.QueryString("Key7")); //OpportunityID

                    if(key7 != "undefined") {
                        recOpportunity = eWare.FindRecord("Opportunity", "oppo_opportunityid=" + key7);
                        if (!recOpportunity.eof) {
                            recComm.comm_opportunityid = key7;
                            recComm.SaveChanges();
    
                            recCommLink.cmli_comm_companyid = recOpportunity("oppo_primarycompanyid");
                        }
                    }
                }

                recCommLink.SaveChanges();

                var filename = getIdValue("filename");

                if(getFormValue("_HIDDropzoneFilename") != "" && getFormValue("_HIDDropzoneFilename") != "undefined" )
                {
                    filename = getFormValue("_HIDDropzoneFilename");
                }

                if (filename != "-1") {
                    var oFS = Server.CreateObject("Scripting.FileSystemObject");

                    var recDocDir = eWare.FindRecord("custom_sysparams", "parm_Name='DocStore'");
                    recCompany = eWare.FindRecord("Company", "comp_Companyid=" + sCompanyId);   

                    // Move our file from the temp area to the company folder.
                    var sourceFile = "D:\\Applications\\CRM\\WWWRoot\\TempReports\\" + filename; 
                    var targetFolder = recDocDir("Parm_Value") + recCompany("comp_LibraryDir") ;

                    var folderExists = oFS.FolderExists(targetFolder);
                    if (!folderExists)
                        oFS.CreateFolder(targetFolder);

                    var targetFile = targetFolder + "\\" + filename;

                    var count = 1;
                    var originalFileName = null;


                    var fileExists = oFS.FileExists(targetFile);
                    while (fileExists) {

                        if (originalFileName == null)
                            originalFileName = filename;

                        var fileext = oFS.GetExtensionName(originalFileName);
                        var filenameWOExt = originalFileName.substring(0,  (originalFileName.length - (fileext.length + 1)));

                        count++;
                        filename = filenameWOExt + count.toString() + "." + fileext;
                        targetFile = targetFolder + "\\" + filename;
                        fileExists = oFS.FileExists(targetFile);
                    }

                    oFS.MoveFile(sourceFile, targetFile);

                    createLibraryRecord(filename, recCompany, recComm, recCommLink)
                }

                // no attachments? Just redirect and exit
                if (sHasAttachments == "")
                {
                    var sDoFollowUpTask = getFormValue("DoFollowUpTask");
                    if (sDoFollowUpTask != null && sDoFollowUpTask=="on" )
                    {

                        var sNewTaskLink = eWare.URL("PRGeneral/PRInteraction.asp");
                        // cannot have key6 on the url or an existing interaction will load
                        sNewTaskLink = removeKey(sNewTaskLink, "Key6");
        
                        if (prss_ssfileid != -1) {
                            sNewTaskLink += "&prss_SSFileId=" + prss_ssfileid;
                        }

                        sNewTaskLink = changeKey(sNewTaskLink, "Key1", sCompanyId);
                        sNewTaskLink = changeKey(sNewTaskLink, "Key2", sPersonId);
                       
                        Response.Redirect(sNewTaskLink);
                        return;
                    }
                    Response.Redirect(sListingAction);
                    return;
                }
                else
                {
                    //Need to save a document attachment; start by getting fields
                    var sNote = getFormValue("comm_Note");
                    var sDir = Request.QueryString("SaveDocDir");
                    // first create library record
                    var sLibId = createLibraryRecord(sFileName, sNote, recComm, recCommLink);
                    DEBUG("<BR>Library Id: " + sLibId);
                    
                    eWare.AddContent(getDocDropButtonForSave(sDir, sFileName, 
                            sLibId, comm_communicationid, 
                            "PRSSFile/PRSSFileInteraction.asp", 
                            "&prss_SSFileId="+prss_ssfileid));
                    Response.Write(eWare.GetPage());
                    return;
                    
                }
            } catch (ex){
                Response.Write("<p><span>Error occurred preventing save: " + ex.description  + "</span><br/>");
                Response.Write("<span>Line: " + ex.Line + "</span><br/>");
                Response.Write("<span>Source: " + ex.Source + "</span><br/>");
                Response.Write("<span>ASPCode: " + ex.ASPCode + "</span><br/>");
                Response.Write("<span>ASPDescription: " + ex.ASPDescription + "</span><br/>");
                Response.Write("<span>Category: " + ex.Category + "</span><br/>");
                Response.Write("<span>Column: " + ex.Column + "</span><br/>");
                Response.Write("<span>Number: " + ex.Number + "</span><br/>");
                Response.Write("<span>File: " + ex.File + "</span><br/>");
                Response.Write(ex);

                Response.Write("<span>linenumber: " + ex.linenumber + "</span><br/>");
                Response.Write("<span>message: " + ex.message + "</span><br/>");
                Response.Write("<span>number: " + ex.number + "</span><br/>");
            }
            return;            
        } 

        Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");

        eWare.AddContent(blkContainer.Execute());
        if (eWare.Mode == Edit) 
            Response.Write(eWare.GetPage());
        else 
            Response.Write(eWare.GetPage(sEntity));

        // Handle the status change
        var statusChange = "";
        if (eWare.Mode == Edit) {
            var newStatus = Request.QueryString("NewStatus");

            if (!isEmpty(newStatus)) {
                //statusChange = "document.getElementById('comm_status').value = '" + newStatus + "';\n";
                statusChange = "$('#comm_status').val('" + newStatus + "');\n";
            }
        }
	}
%>
    <script type="text/javascript" >
        function initBBSI() 
        {
            <%= "userlogon = '" + recUser("user_logon") + "';" %>
            // hide the opportunity selection row
            var item = document.EntryForm._HIDDENcomm_opportunityid;
    
            // show the followup row
	        AppendRow("_Captcomm_channelid", "tr_FollowupTask");
            AddCompanySummaryButton();

            initializePage();

            <%= sInitializeActions %>
            <%= sOnLoadViewAttachement %>

            <%= sOnLoadMoveDropzone %>
            <%= sOnLoadMoveDroppedFilename %>
                
            <%= statusChange %>

            processNSChange();
            processOrganizer();

            replaceSpecialCharacters_text('comm_note');
            replaceSpecialCharacters_text('comm_subject');
        }

        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
<%
}

function createLibraryRecord(sSrcFileName, recCompany, recComm, recCommLink)
{
    var sDestDir = recCompany("comp_LibraryDir") + "\\";
    
    var recLibrary = eWare.CreateRecord("Library");
    recLibrary.Libr_FilePath = sDestDir;
    recLibrary.Libr_FileName = sSrcFileName;
    recLibrary.Libr_FileSize = -1;

    recLibrary.libr_CommunicationId = recComm("comm_CommunicationId");
    recLibrary.libr_OpportunityId = recComm("comm_OpportunityId");
    recLibrary.libr_CaseId = recComm("comm_CaseId");
    recLibrary.libr_ChannelId = recComm("comm_ChannelId");
    recLibrary.libr_PRFileId = recComm("comm_PRFileId");
    recLibrary.libr_Note = recComm("comm_Note");

    recLibrary.libr_CompanyId = recCommLink("cmli_comm_CompanyId");
    recLibrary.libr_PersonId = recCommLink("cmli_comm_PersonId");
    recLibrary.libr_LeadId = recCommLink("cmli_comm_LeadId");
    recLibrary.libr_UserId = recCommLink("cmli_comm_userid");
    recLibrary.SaveChanges();  

    recComm.comm_HasAttachments = "Y";
    recComm.SaveChanges();
     
    return recLibrary("libr_libraryid");
}
    
%>

<!-- #include file="../RedirectTopContent.asp" --> 
<!-- #include file="../PRCoPageFooter.asp" -->
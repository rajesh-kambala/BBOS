<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2020

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
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyIDInclude.asp" -->

<%
    var user_userid = eWare.getContextInfo("User", "User_UserId");
    var sListingFileVersion = Request.Form("hdn_listingfileversion").Count > 0 ? String(Request.Form("hdn_listingfileversion")) : (new Date().valueOf());

    if (eWare.Mode == Save)
    {
        // let's set the defaults for sending
	    var sCommAction = Request.Form("comm_action");

        var sReqCompanyId = Request.Form("cmli_comm_companyid");
        if (isEmpty(sReqCompanyId))
            sReqCompanyId  = "null";
        var sReqPersonId = Request.Form("cmli_comm_personid");
        if (isEmpty(sReqPersonId))
            sReqPersonId  = "null";

        var sSQL = "";//"Declare @result int;"
        
        var sSafeCompanyName = recCompany("comp_Name");
        var objRegExp  = new RegExp("'", "gi");
        sSafeCompanyName = sSafeCompanyName.replace(objRegExp, "''");
        
        if (sCommAction == 'FaxOut' || sCommAction == 'EmailOut')
        {
			var qTempReports = eWare.CreateQueryObj("SELECT Capt_US FROM Custom_Captions WHERE Capt_Family = 'TempReports' AND Capt_Code = 'Local'");
			qTempReports.SelectSQL();
			var sAttachmentPath;
			if (! qTempReports.Eof) {
				sAttachmentPath = qTempReports("Capt_US");
	        } else {
	            sAttachmentPath = Server.MapPath("/" + sInstallName + "/TempReports");
			}
			qTempReports = null;

            var sFrom = "BlueBookServices@bluebookservices.com";
            var sTo = Request.Form("comm_emailfax");
            DEBUG("<br>Email Sent To: " + sTo);
            var sSubject = "Your Listing Report for " + sSafeCompanyName;
            var sBody = getFileText(Server.MapPath("/" + sInstallName + "/Templates") + "/CompanyListingEmailContent.txt");
            var sEmailBody = GetFormattedEmail(sReqCompanyId, sReqPersonId, sSubject, sBody, '');


            var sFileName = "CompanyListing" + comp_companyid + "_" + sListingFileVersion + ".pdf";
            var sAttachmentFilePath = sAttachmentPath + "\\" + sFileName ;
            sSQL = "exec usp_CreateEmail " +
                        "@CreatorUserId=" + user_userid + ", " +  
                        "@To='" + sTo + "', " +  
                        "@Subject='" + sSubject + "', " +  
                        "@Content='" + padQuotes(sEmailBody) + "', " +  
                        "@Action='" + sCommAction + "', " +
                        "@RelatedCompanyId=" + sReqCompanyId + ", " +  
                        "@RelatedPersonId=" + sReqPersonId + ", " +  
                        "@AttachmentDir='" + sAttachmentPath + "', " +  
                        "@AttachmentFileName='" + sAttachmentFilePath + "', " +
                        "@Source='CRM Listing Request', " +
                        "@PRCategory = 'L', " +
                        "@PRSubcategory = 'LI', " +
                        "@Content_Format='HTML';";
        }
        else
        {
            sSQL = "exec usp_CreateTask " +
                    "@CreatorUserId=" + user_userid + ", " +  
                    "@AssignedToUserId=" + user_userid + ", " +  
                    "@TaskNotes= 'Sent a printed Company Listing to " + sSafeCompanyName + "', " +
                    "@RelatedCompanyId=" + sReqCompanyId + ", " +  
                    "@RelatedPersonId=" + sReqPersonId + ", " +  
                    "@Action = 'LetterOut', " +
                    "@PRCategory = 'L', " +
                    "@PRSubcategory = 'LI'";
        
        }
        //Response.Write("<br>SQL: " + sSQL);
	    
	    try
	    {
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql();
            Response.Redirect("/" + sInstallName + "/CustomPages/PRCompany/PRCompanyListingReport.aspx?close=1&cleanup=0&comp_companyid="+comp_companyid+"&listingfileversion=" + sListingFileVersion);
            //    Response.Write("<script language=javascript >window.close();</script>");
        }
        catch (exception)
        {
            Session.Contents("prco_exception") = exception;
            Session.Contents("prco_exception_continueurl") = "javascript:window.close();";
            Response.Redirect(eWare.Url("PRCoErrorPage.asp"));
        
        }
         
    }
    else
    {
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyListing.js\"></script>");
        
        var bIsHQ = false;
        if (recCompany("comp_PRType") == "H")
            bIsHQ = true;
        
        blkContainer = eWare.GetBlock('container');
        blkContainer.DisplayButton(Button_Default) = false;

        recPRCommLink = eWare.CreateRecord("vPRCommunication");
        eWare.Mode = Edit;
        blkMain=eWare.GetBlock("CommLinkSummary");
        blkMain.Title="Delivery Info";
        
        Entry = blkMain.GetEntry("cmli_comm_PersonId");
        Entry.CaptionPos = 6;    
        Entry.Restrictor = "cmli_comm_companyid";

        var personID = String(Request.Form.Item("cmli_comm_personid"));
        if (!isEmpty(personID))
            Entry.DefaultValue = personID;    


        Entry = blkMain.GetEntry("cmli_comm_companyid");
        Entry.CaptionPos = 6;
        Entry.DefaultValue = comp_companyid;


        Entry = blkMain.GetEntry("comm_action");
        Entry.CaptionPos = 6;
        Entry.AllowBlank = false;
        Entry.OnChangeScript = "setDefaultOutAddress();";
        Entry.RemoveLookup("E");
        Entry.RemoveLookup("L");
        Entry.RemoveLookup("M");
        Entry.RemoveLookup("F");
        Entry.RemoveLookup("O");
        Entry.RemoveLookup("P");
        Entry.RemoveLookup("S");
        Entry.RemoveLookup("T");
        Entry.RemoveLookup("MT");
        Entry.RemoveLookup("OT");
        Entry.RemoveLookup("Demo");
        Entry.RemoveLookup("EmailIn");
        Entry.RemoveLookup("FaxIn");
        Entry.RemoveLookup("LetterIn");
        Entry.RemoveLookup("Meeting");
        Entry.RemoveLookup("Note");
        Entry.RemoveLookup("PhoneIn");
        Entry.RemoveLookup("PhoneOut");
        Entry.RemoveLookup("ToDo");
        Entry.RemoveLookup("Vacation");
        Entry.RemoveLookup("LetterOut");
        Entry.RemoveLookup("OnlineIn");
        Entry.RemoveLookup("EMarketingDripEmail");
        Entry.RemoveLookup("EMarketingEmail");
        Entry.RemoveLookup("SMSOut");

        recPRCommLink.comm_Action = "EmailOut";

        var action = String(Request.Form.Item("comm_action"));
        if (!isEmpty(action)) {
            recPRCommLink.comm_Action = action;
            Entry.DefaultValue = action;   
        }

        /*
        Entry = blkMain.GetEntry("comm_attn");
        Entry.CaptionPos = 6;
        Entry.Size = 75;
        */
        Entry = blkMain.GetEntry("comm_emailfax");
        Entry.CaptionPos = 6;
        Entry.Size = 75;

        // Hide these fields for now
        Entry = blkMain.GetEntry("comm_companyname");
        Entry.Hidden =true;
        Entry.CaptionPos = 6;
        Entry.Size = 75;
        Entry = blkMain.GetEntry("comm_addressline1");
        Entry.Hidden =true;
        Entry.CaptionPos = 6;
        Entry.Size = 75;
        Entry = blkMain.GetEntry("comm_citystatezip");
        Entry.Hidden =true;
        Entry.CaptionPos = 6;
        Entry.Size = 75;

        blkMain.ArgObj = recPRCommLink;

        blkContainer.AddButton(eWare.Button("Save & Send", "sendletter.gif", "#\" onClick=\"if (validate()) save();\""));
        blkContainer.AddButton(eWare.Button("Close", "cancel.gif", "#\" onClick=\"window.close();\""));
        blkContainer.AddButton(eWare.Button("Refresh", "refresh.gif", "#\" onClick=\"refresh();\""));

		var blkContent = eWare.GetBlock("Content");
		blkContent.Contents = "<input type=\"hidden\" id=\"hdn_listingfileversion\" name=\"hdn_listingfileversion\" value=\"" + sListingFileVersion + "\" />";

		blkContainer.AddBlock(blkContent);		
        blkContainer.AddBlock(blkMain);

        // create a checkbox for displaying Include Branches
        sIncludeBranchesQueryString = "";
        sCheckIncludeBranches = "";
        sIncludeBranchesFormLoad = "";
        if (bIsHQ)
        {
            sIncludeBranches = String(Request.Form.Item("chk_includebranches"));
            if (sIncludeBranches != null && sIncludeBranches == "on")
            {
                sCheckIncludeBranches = "CHECKED";
                sIncludeBranchesQueryString = "&includebranches=1"
            }
            sContent = "<table style=\"display:none;\" ><tr id=\"tr_includebranches\"><td colspan=\"2\" class=\"VIEWBOXCAPTION\"><INPUT class=VIEWBOX TYPE=CHECKBOX " + sCheckIncludeBranches+ " ID=chk_includebranches NAME=chk_includebranches>Include Branches</td></tr></table>";
            Response.Write(sContent);
            // append the Include Branches checkbox
            sIncludeBranchesFormLoad = "AppendRow(\"_Captcomm_emailfax\", \"tr_includebranches\");\n";
        }

        // create the total lines and DL line count display 
        var sSQL = "SELECT results = dbo.ufn_CountOccurrences(CHAR(10), dbo.ufn_GetListingFromCompany(" + comp_companyid + ", 1, 1))"
        var qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSql();
        var nLineCount = new Number(qryListing("results")) + 1;
        
        // get the DL line count
        sSQL = "SELECT results = dbo.ufn_GetListingDLLineCount(" + comp_companyid + ")"
        qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSql();
        var nDLCount = new Number(qryListing("results"));
        
        // get the Body line count
        sSQL = "SELECT results = dbo.ufn_GetListingBodyLineCount(" + comp_companyid + ")"
        qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSql();
        var nBodyCount = new Number(qryListing("results"));

        // get the Classification, Volume, and Commodity Line count
        sSQL = "SELECT results = dbo.ufn_GetListingClassVolCommLineCount(" + comp_companyid + ")"
        qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSql();
        var nCVCCount = new Number(qryListing("results"));
        
        // now draw everything to the screen
        Response.Write("<table style=\"display:none\"><tr id=\"_trLineCount\"><td colspan=\"4\"><table id=\"_tblLineCount\" cellpadding=\"0\" cellspacing=\"0\"><tr>" +
                "<td class=\"VIEWBOXCAPTION\">Total Line Count: </td>" + 
                "<td class=\"VIEWBOX\">&nbsp;" + nLineCount +"&nbsp;Lines</td>" +
                "<td>&nbsp;&nbsp;&nbsp;</td>" +
                "<td class=\"VIEWBOXCAPTION\">Body Line Count: </td>" + 
                "<td class=\"VIEWBOX\">&nbsp;"+ nBodyCount +"&nbsp;Lines</td>"+
                "<td>&nbsp;&nbsp;&nbsp;</td>" +
                "<td class=\"VIEWBOXCAPTION\">Descriptive Line Count: </td>" + 
                "<td class=\"VIEWBOX\">&nbsp;"+ nDLCount +"&nbsp;Lines</td>"+
                "<td>&nbsp;&nbsp;&nbsp;</td>" +
                "<td class=\"VIEWBOXCAPTION\">Class/Vol/Comm Line Count: </td>" + 
                "<td class=\"VIEWBOX\">&nbsp;"+ nCVCCount +"&nbsp;Lines</td>"+
                "</tr></table>" +
                "</tr></table><td>");
        var sLineCountString = "AppendRow(\"_Captcomm_emailfax\", \"_trLineCount\");\n"; 
        
        // determine if any of the addtional banners should show
        var sBannerMsg = "";
        var blkBanners = eWare.GetBlock('content');
        var sInnerMsg = "";
        if (nLineCount > 174) {
            sInnerMsg = "<tr class=\"ErrorContent\"><td>The total number of lines for this listing exceeds 174.  This exceeds the number of lines allowed for a two column listing.</td></tr>";
        }
        if (nBodyCount > 152) {
            sInnerMsg += "<tr><td>The number of body lines for this listing exceeds 152.  This exceeds the number of lines allowed for the body of the listing.</td></tr>";
        }

        if (nLineCount > 87) {
            sInnerMsg += "<tr><td>The total number of lines for this listing exceeds 87 resulting in the listing being split into a second column.</td></tr>";
        }


        if (recCompany("comp_PRIndustryType")  == "S") {
            if (nCVCCount >= 40) {
                sInnerMsg += "<tr><td>The number of Classification lines for this listing exceeds 40.</td></tr>";
            }
        } else if (recCompany("comp_PRIndustryType")  == "T") {
            if (nCVCCount >= 8) {
                sInnerMsg += "<tr><td>The number of Classification/Volume  lines for this listing exceeds 8.</td></tr>";
            }
        } else {
            if (nCVCCount >= 16) {
                sInnerMsg += "<tr><td>The number of Classification/Volume/Commodity lines for this listing exceeds 16.</td></tr>";
            }
        }

        if (sInnerMsg != "")
        {
            sBannerMsg = "<table width=\"100%\" cellspacing=\"0\" class=\"MessageContent\">" + sInnerMsg + "</table> ";
            blkBanners.contents = sBannerMsg;
            blkContainer.AddBlock(blkBanners);
        }

        var sURL = "/" + sInstallName + "/CustomPages/PRCompany/PRCompanyListingReport.aspx?comp_companyid=" + comp_companyid + "&listingfileversion=" + sListingFileVersion + sIncludeBranchesQueryString + "&dummy=x.pdf";
        var blkCustom = eWare.GetBlock('Content');
        blkCustom.contents = '<div style="z-index:0;margin-top:135px;position:relative;"><iframe ID="ifrmCustom" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:900px;width:100%;" src="'+sURL +'"></iframe></div>';
        blkContainer.AddBlock(blkCustom);

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage("New"));

        var qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSql();

        sSQL = "SELECT results = dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) FROM vPRCompanyPhone WITH (NOLOCK) WHERE plink_RecordID = " + comp_companyid + " AND phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'";
  
        var qryFax = eWare.CreateQueryObj(sSQL);
        sFax = '';
        qryFax.SelectSql();
        if (!qryFax.EOF) {
            var sFax = new String(qryFax("results"));
            if (sFax == 'undefined') {
                sFax = '';
            }
        }
        
        sEmail = '';
        sSQL = "SELECT results = RTRIM(Emai_EmailAddress) FROM vCompanyEmail WITH (NOLOCK) WHERE elink_RecordID = " + comp_companyid + " AND elink_Type='E' AND emai_PRPreferredInternal = 'Y'";

        var qryEmail = eWare.CreateQueryObj(sSQL);
        qryEmail.SelectSql();
        if (!qryEmail.EOF) {
            var sEmail = new String(qryEmail("results"));
            if (sEmail == 'undefined') {
                sEmail = '';
            }
        }

        var emailfax = String(Request.Form.Item("comm_emailfax"));
        if (!isEmpty(emailfax)) {
            if (action == "EmailOut") {
                sEmail = emailfax;
            }
            if (action == "FaxOut") {
                sFax = emailfax;
            }
        }

%>
        <script type="text/javascript">
            var sDefaultFax = '<% =sFax %>';
            var sDefaultEmail = '<% =sEmail %>';

            function initBBSI() 
            {
                <%= sLineCountString %>
                <%= sIncludeBranchesFormLoad %>
                setDefaultOutAddress();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }

            document.getElementById("cmli_comm_personidTEXT").addEventListener("blur", SetPersonListener);
        </script>
<%
    }
%>

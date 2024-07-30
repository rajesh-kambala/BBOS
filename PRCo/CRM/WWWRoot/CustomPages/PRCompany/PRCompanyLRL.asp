<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2011-2020

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc..
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

    var HQID = recCompany("comp_PRHQID");

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
			var qTempReports = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_Family = 'TempReports' And Capt_Code = 'Local'");
			qTempReports.SelectSQL();
			var sAttachmentPath;
			if (! qTempReports.Eof) {
				sAttachmentPath = qTempReports("Capt_US");
	        } else {
	            sAttachmentPath = Server.MapPath("/" + sInstallName + "/TempReports");
			}
			qTempReports = null;

            var sTo = Request.Form("comm_emailfax");
            DEBUG("<br>Email Sent To: " + sTo);
            var sSubject = "Your Listing Report Letter for " + sSafeCompanyName;
            var sBody = getFileText(Server.MapPath("/" + sInstallName + "/Templates")+"/LRL Email.txt");

            var sEmailBody = GetFormattedEmail(sReqCompanyId, sReqPersonId, sSubject, sBody, '');

            var sFileName = "CompanyLRL" + comp_companyid + "_" + sListingFileVersion + ".pdf";
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
                        "@Source='CRM LRL Request', " +
                        "@PRCategory = 'L', " +
                        "@PRSubcategory = 'LRL', " +
                        "@Content_Format='HTML';";
        }
        else
        {
            sSQL = "exec usp_CreateTask " +
                    "@CreatorUserId=" + user_userid + ", " +  
                    "@AssignedToUserId=" + user_userid + ", " +  
                    "@TaskNotes= 'Sent a printed Company Listing Report Letter to " + sSafeCompanyName + "', " +
                    "@RelatedCompanyId=" + sReqCompanyId + ", " +  
                    "@RelatedPersonId=" + sReqPersonId + ", " +  
                    "@Action = 'LetterOut', " + 
                    "@PRCategory = 'L', " +
                    "@PRSubcategory = 'LRL'";
        
        }
        //Response.Write("<br>SQL: " + sSQL);
	    
	    try
	    {
            recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql();
            Response.Redirect("/" + sInstallName + "/CustomPages/PRCompany/PRCompanyLRL.aspx?close=1&cleanup=0&comp_companyid="+HQID+"&listingfileversion=" + sListingFileVersion);
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
        Response.Write("<script type=text/javascript src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=text/javascript src=\"PRCompanyListing.js\"></script>");
        
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
		blkContent.Contents = "<input type='hidden' id='hdn_listingfileversion' name='hdn_listingfileversion' value='" + sListingFileVersion + "' />";

        blkContainer.AddBlock(blkMain);
		blkContainer.AddBlock(blkContent);		

		var blkFrame = eWare.GetBlock("Content");
        //blkFrame.contents = '<div style="z-index:-5000;margin-top:100px;position:relative;"><iframe ID="ifrmCustom" src=\"PRCompanyLRL.aspx?comp_companyid=" + HQID + "&listingfileversion=" + sListingFileVersion + "&dummy=x.pdf\" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:900px;width:100%;border:none;z-index:-500" src="'+sURL +'"></iframe></div>';
		blkFrame.Contents = "<div style=\"z-index:0;margin-top:135px;position:relative;\" id=divDoc><iframe src=\"PRCompanyLRL.aspx?comp_companyid=" + HQID + "&listingfileversion=" + sListingFileVersion + "&dummy=x.pdf\" style=\"width:100%; height:800px;\" frameborder=\"0\"></iframe></div>"
        //blkFrame.Contents = "<object data=\"test.pdf\" type=\"application/pdf\" width=\"100%\" height=\"100%\">";
        blkContainer.AddBlock(blkFrame);		
        


        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage("New"));


        sSQL = "SELECT results =  dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) FROM vPRCompanyPHone WITH (NOLOCK) WHERE plink_RecordID = " + comp_companyid + " AND phon_PRIsFax = 'Y' AND phon_PRPreferredInternal = 'Y'";
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
        sSQL = "SELECT results = RTRIM(Emai_EmailAddress) FROM vCompanyEmail WITH (NOLOCK) WHERE  elink_RecordID = " + comp_companyid + " AND elink_Type='E' AND emai_PRPreferredInternal = 'Y'";
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

            function initBBSI() {
                setDefaultOutAddress();
                document.getElementById("divDoc").zIndex = -5000;
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }

            document.getElementById("cmli_comm_personidTEXT").addEventListener("blur", SetPersonListener);
        </script>
<%
    }
%>

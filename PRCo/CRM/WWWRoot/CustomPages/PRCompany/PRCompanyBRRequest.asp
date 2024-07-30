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
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
	doPage();

function doPage()
{
    bDebug = false;
    DEBUG(sURL);
    // cannot include CompanyHeaders.asp because we do not want this to be "PRCo transactioned"
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    var blkAdditionalFields = eWare.GetBlock('content');    // block to hold extra fields needed by client side code
    
    var sCompanyId = comp_companyid;
    var sHQId = recCompany("comp_PRHQId") || -1;
    var sPersonId = getFormValue("prbr_requestingpersonid");
    var sUsageType = getFormValue("prbr_methodsent");
    var sRegardingCompanyID = getFormValue("prbr_requestedcompanyid");
    var sRequestorInfo = getFormValue("prbr_requestorinfo");
    var sAddressLine1 = getFormValue("prbr_addressline1");
    var sAddressLine2 = getFormValue("prbr_addressline2");
    var sCityStateZip = getFormValue("prbr_citystatezip");
    var sCountry = getFormValue("prbr_country");
    var sFax = getFormValue("prbr_fax");
    var sEmailAddress = getFormValue("prbr_emailaddress");
    var sNoCharge = getFormValue("prbr_donotchargeunits");
    var sBRFileVersion = (Request.Form.Item("hdn_brfileversion").Count > 0 ? String(Request.Form.Item("hdn_brfileversion")) : (new Date()).valueOf());
    
    var sProductID = parseInt(getFormValue("prbr_productid"));
    if (isNaN(sProductID)) {
		sProductID = 47;    // defaults to a level 3
	}
    var lkPricingList = { "EBR":16013, "FBR":16011, "OBR":16010, "VBR":16012 };  // Lookup table to translate the method sent to the pricing list.
    var sPricingListId;

    blkAdditionalFields.Contents = "<input type='hidden' id='hdn_brfileversion' name='hdn_brfileversion' value='" + sBRFileVersion + "' /><input type='hidden' id='hdn_hqid' name='hdn_hqid' value='" + sHQId + "' />";

    var bError = false;
    if (eWare.Mode == Save)
    {
        DEBUG("sUsageType:" + sUsageType);

        if (!isEmpty(F))
            sListingAction = eWare.Url(F);
        else
            sListingAction = eWare.Url("PRCompany/PRCompanySummary.asp");
        sListingAction += "&comp_CompanyId=" + comp_companyid;
        
        // collect the information and pass it on to the DB usp_ that will persist it.
        // This function will also decrement the units appropriately
        if (!isEmpty(sNoCharge) )
            sNoCharge = 1;
        else 
            sNoCharge = 0;
        
        var sErrorContent = "";
        var sAction = "Edit";
        // make sure that the Requested Company actually has a business report.
        recRequestedCompany = eWare.FindRecord("Company","comp_Companyid="+sRegardingCompanyID);
        if (!recRequestedCompany.eof)
        {
            sStatus = recRequestedCompany("comp_PRListingStatus");
            if ("L,H,N3,N5,N6".indexOf(sStatus) == -1)
            {
                sErrorContent = getErrorHeader("Business reports can only be generated for companies with a status of Listed, Hold, or Not Listed (Previously Listed-Reported Closed/Inactive/Not A Factor).");
                bError = true;
            }
        }
     
        if (bError)
        {
            //eWare.AddContent(sErrorContent + "<br>");
	        blkContent = eWare.GetBlock("content");
	        blkContent.Contents = sErrorContent;
	        blkContainer.AddBlock(blkContent);
	        if (sAction == "Edit") {
	            eWare.Mode = Edit;        
	        } else {
	            blkContainer.AddButton(eWare.Button("continue", "continue.gif", sListingAction));
                eWare.AddContent(blkContainer.Execute());
                Response.Write(eWare.GetPage());
            }
        } else {

            // get the requested company
            recRequestedCompany = eWare.FindRecord("Company", "comp_Companyid=" + sRegardingCompanyID);
            

            if (sUsageType != "VBR") {
                // if we can generate the report, determine if we need a balance sheet and a survey
                bIncludeBalance = false;
                bIncludeSurvey = false;
                
                // determine "Include Survey"
                var sSurveySQL = "Select dbo.ufn_IsEligibleForBRSurvey("+ comp_companyid + ") as bEligible ";
                recQuery = eWare.CreateQueryObj(sSurveySQL);
                recQuery.SelectSql();
                if (recQuery("bEligible") == "1")
                    bIncludeSurvey = true;
            
                var filepath_local = "";
			    var qTempReports = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_Family = 'TempReports' And Capt_Code = 'Local'");
			    qTempReports.SelectSQL();
			    if (! qTempReports.Eof) {
				    filepath_local = qTempReports("Capt_US");
	            } else {
	                filepath_local = Server.MapPath("/" + sInstallName + "/TempReports");
			    }

                var filepath_share = "";
			    qTempReports = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_Family = 'TempReports' And Capt_Code = 'Share'");
			    qTempReports.SelectSQL();
			    if (! qTempReports.Eof) {
				    filepath_share = qTempReports("Capt_US");
	            } else {
	                filepath_share = Server.MapPath("/" + sInstallName + "/TempReports");
			    }
			    qTempReports = null;
			
                var szReportName = "BusinessReportOn" + sRegardingCompanyID + "For" + comp_companyid;
                var filename_local = filepath_local + "\\" + szReportName + "_" + sBRFileVersion + ".pdf";
                var filename_share = filepath_share + "\\" + szReportName + "_" + sBRFileVersion + ".pdf";

                Response.Write("<p>" + filename_share + "</p>");
                DEBUG(filename_share);

                // build the report
                var BBSReportInterface = Server.CreateObject("PRCo.BBS.ReportInterface");


                if (BBSReportInterface  != null) {

                    var oReport = BBSReportInterface.GenerateBusinessReport(sRegardingCompanyID, 3, bIncludeBalance, bIncludeSurvey, new Number(comp_companyid));
                    BBSReportInterface = null;

                    if (oReport != null) {
                        //Response.Write("<p>" + oReport + "</p>");
                        //var chw = "D:\\Temp\\" + szReportName + "_" + sBRFileVersion + ".pdf"
                        //saveFileBinary(chw, oReport);
                        saveFileBinary(filename_share, oReport);
                    }
                }
            }

           
            // once the report is generated start the database saves
            if ((sHQId = recCompany("comp_PRHQId")) == null)
                sHQId = -1;

            if ((sPricingListId = lkPricingList[sUsageType.toUpperCase()]) == null) {
                sPricingListId = 16002;  // set to default
            }

            var sSQL = "EXECUTE usp_ConsumeServiceUnits " + 
                    "@CompanyID = " + sCompanyId + ", " +
                    "@PersonID = " + sPersonId + ", " +
                    "@UsageType = '" + sUsageType + "', " +
                    "@SourceType = 'C', " +
                    "@ProductID = " + sProductID + ", " +
                    "@PricingListID = " + sPricingListId + ", " +
                    "@RegardingCompanyID = " + sRegardingCompanyID + ", " +
                    "@RequestorInfo = '" + padQuotes(sRequestorInfo) + "', " +
                    "@AddressLine1 = '" + padQuotes(sAddressLine1) + "', " +
                    "@AddressLine2 = '" + padQuotes(sAddressLine2) + "', " +
                    "@CityStateZip = '" + padQuotes(sCityStateZip) + "', " +
                    "@Country = '" + sCountry + "', " +
                    "@Fax = '" + sFax + "', " +
                    "@EmailAddress = '" + padQuotes(sEmailAddress) + "', " +
                    "@NoCharge = " + sNoCharge + ", " +
                    "@CRMUserID = " + user_userid + ", "  +
                    "@HQID = " + sHQId


    DEBUG(sSQL);

            try
            {

                recQuery = eWare.CreateQueryObj(sSQL);
                recQuery.ExecSql();
           
                if (sUsageType == 'EBR' || sUsageType == 'FBR')
                {
                    var sCommAction = 'EmailOut';
                    var sTo = sEmailAddress;
                    if (sUsageType == 'FBR'){
                        sTo = sFax;
                        sCommAction = 'FaxOut';
                    }
                    var sFrom = "BlueBookServices@bluebookservices.com";
                    DEBUG("<br/>Email Sent To: " + sTo);
                    var sSubject = "Blue Book Services Business Report for " + padQuotes(recRequestedCompany("comp_name"));

			        var qEmailBody = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_Family = 'SendBR' And Capt_Code = 'Body'");
			        qEmailBody.SelectSQL();
    		        var sBody = qEmailBody("Capt_US");
                    var sEmailBody = GetFormattedEmail(sCompanyId, sPersonId, sSubject, sBody, '');

                    sSQL = "EXEC usp_CreateEmail " +
                                "@CreatorUserId=" + user_userid + ", " +  
                                "@To='" + sTo + "', " +  
                                "@Subject='" + sSubject + "', " +  
                                "@Content='" + padQuotes(sEmailBody) + "', " +  
                                "@Action='" + sCommAction + "', " +
                                "@RelatedCompanyId=" + sCompanyId + ", " +  
                                "@RelatedPersonId=" + sPersonId + ", " +  
                                "@AttachmentDir='" + filepath_local + "', " +  
                                "@AttachmentFileName='" + filename_local + "', " +
                                "@Source='CRM BR Request', " +
                                "@Content_Format='HTML';";
                }
                else
                {
                    sSQL = "EXEC usp_CreateTask " +
                            "@CreatorUserId=" + user_userid + ", " +  
                            "@AssignedToUserId=" + user_userid + ", " +  
                            "@TaskNotes= 'Provided Business Report to " + padQuotes(recCompany("comp_name")) + 
                                " on " + padQuotes(recRequestedCompany("comp_name")) + "', " +
                            "@RelatedCompanyId=" + sCompanyId + ", " +  
                            "@RelatedPersonId=" + sPersonId + ", " +  
                            "@Action = 'LetterOut'" ;
                
                }
                recQuery = eWare.CreateQueryObj(sSQL);
                recQuery.ExecSql();
            
                // Finally, send a survey, which goes out by email regardless of how it was sent.
                sSQL = "EXEC usp_SendBusinessReportSurvey @PersonID = " + sPersonId + ", @CompanyID = " + comp_companyid + ";";
                recQuery = eWare.CreateQueryObj(sSQL);
                recQuery.ExecSql();
                Response.Redirect(sListingAction);
            
            }
            catch (exception)
            {
                Session.Contents("prco_exception") = exception;
                Session.Contents("prco_exception_continueurl") = sListingAction;
                Response.Redirect(eWare.Url("PRCoErrorPage.asp"));
            }
        }                
    } 
    if (eWare.Mode <= Edit)
    {
        // this screen will always show in edit mode
        if (eWare.Mode<Edit) eWare.Mode=Edit;

        // create a baner for addtional info at the top of the page
        var blkBanners = eWare.GetBlock('content');
        sBannerContent = "<table style={display:none;} id=header_banner width=\"100%\" cellspacing=0 class=\"MessageContent\">";
        sBannerContent += "<tr id=tr_canuseunits class=\"ErrorContent\"><td><span id=header_canuseunits></span></td></tr>";
        sBannerContent += "<tr id=tr_hasavailableunits class=\"ErrorContent\"><td><span id=header_hasavailableunits></span></td></tr>";
        sBannerContent += "</table> ";

        blkBanners.contents = sBannerContent;

        blkRequesting = eWare.GetBlock("PRBusinessReportRequestBlock");
        blkRequesting.Title = "Business Report Request";

        Entry = blkRequesting.GetEntry("prbr_RequestingCompanyId");
        Entry.DefaultValue = comp_companyid;
        Entry.Hidden = true;

        Entry = blkRequesting.GetEntry("prbr_RequestingPersonId");
        Entry.Restrictor = "prbr_requestingcompanyid";
        Entry.OnChangeScript = "onRequestingPersonChange();";

        Entry = blkRequesting.GetEntry("prbr_donotchargeunits");
        Entry.OnChangeScript = "onDoNotChargeUnitsChange();";

        Entry = blkRequesting.GetEntry("prbr_methodsent");
        Entry.OnChangeScript = "onMethodSentChange();";
        Entry.DefaultValue = "VBR";
        
		blkAdditionalFields.Contents += "<span id=\"span_prbr_productid\" name=\"span_prbr_productid\"><span class=\"VIEWBOXCAPTION\" id=\"_Captprbr_productid\" name=\"_Captprbr_productid\">Product:</span><br /><select class=\"EDIT\" id=\"prbr_productid\" name=\"prbr_productid\">";
		var recProducts = eWare.CreateQueryObj("Select Prod_ProductID, Prod_Name From NewProduct Where prod_ProductFamilyId = 2 and prod_Active is not null Order By Prod_PRSequence");
		recProducts.SelectSQL();
		while (! recProducts.Eof) {
			blkAdditionalFields.Contents += "<option value=\"" + recProducts("Prod_ProductID") + "\"" + (recProducts("prod_ProductID") == sProductID ? "selected" : "") + ">" + recProducts("Prod_Name") + "</option>";
			recProducts.NextRecord();
		}
		blkAdditionalFields.Contents += "</select></span>";

        blkContainer.AddBlock(blkBanners);
        blkContainer.AddBlock(blkRequesting);
        blkContainer.AddBlock(blkAdditionalFields);
        blkContainer.CheckLocks = false;

        recCompany = eWare.FindRecord("Company", "comp_CompanyID=" + comp_companyid);

        Entry = blkRequesting.GetEntry("prbr_MethodSent");
        Entry.AllowBlank = false;

        if ((recCompany("comp_PRListingStatus") != 'L') &&
            (recCompany("comp_PRListingStatus") != 'N3') &&
            (recCompany("comp_PRListingStatus") != 'N5') &&
            (recCompany("comp_PRListingStatus") != 'N6')) {
            Entry.RemoveLookup("FBR");
            Entry.RemoveLookup("MBR");
            Entry.RemoveLookup("OBR");
        }
        
	    var sCancel = eWare.URL(F) + "&comp_CompanyID=" + comp_companyid;
	    
	    blkContainer.AddButton(eWare.Button("Save & Send", "save.gif",  "#\" onClick=\"this.disabled=true;save('"+ comp_companyid +"');this.disabled=false;\""));
        
    
        var testAction = eWare.Url("PRCompany/PRCompanyBRRequest.aspx") + "&user_userid=" + user_userid;
        //blkContainer.AddButton(eWare.Button("Save & Send TEST", "save.gif",  "#\" onClick=\"this.disabled=true;document.EntryForm.action='" + testAction + "';save('"+ comp_companyid +"');this.disabled=false;\""));
	    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancel));
        
        // create a PRBusinessReportRequest object to be saved
        recBRRequest = eWare.CreateRecord("PRBusinessReportRequest");
        recBRRequest.prbr_RequestingCompanyId = comp_companyid;

        // if this is a failed save reload the values
        if (bError)
        {
            Entry = blkRequesting.GetEntry("prbr_requestingpersonid");
            Entry.DefaultValue = sPersonId;
            Entry = blkRequesting.GetEntry("prbr_methodsent");
            Entry.DefaultValue = sUsageType;
            Entry = blkRequesting.GetEntry("prbr_requestedcompanyid");
            Entry.DefaultValue = sRegardingCompanyID;
            Entry = blkRequesting.GetEntry("prbr_requestorinfo");
            Entry.DefaultValue = sRequestorInfo;
            Entry = blkRequesting.GetEntry("prbr_addressline1");
            Entry.DefaultValue = sAddressLine1;
            Entry = blkRequesting.GetEntry("prbr_addressline2");
            Entry.DefaultValue = sAddressLine2;
            Entry = blkRequesting.GetEntry("prbr_citystatezip");
            Entry.DefaultValue = sCityStateZip;
            Entry = blkRequesting.GetEntry("prbr_country");
            Entry.DefaultValue = sCountry;
            Entry = blkRequesting.GetEntry("prbr_fax");
            Entry.DefaultValue = sFax;
            Entry = blkRequesting.GetEntry("prbr_emailaddress");
            Entry.DefaultValue = sEmailAddress;
            Entry = blkRequesting.GetEntry("prbr_donotchargeunits");
            Entry.DefaultValue = sNoCharge;
        } else {
            recPRAddress = eWare.FindRecord("vPRAddress", "adli_PRDefaultMailing='Y' AND adli_companyid="+comp_companyid);
            if (!recPRAddress.eof)
            {
                Entry = blkRequesting.GetEntry("prbr_addressline1");
                Entry.DefaultValue = recPRAddress.addr_Address1;
                recBRRequest.prbr_AddressLine1 = recPRAddress.addr_Address1;
                Entry = blkRequesting.GetEntry("prbr_addressline2");
                Entry.DefaultValue = recPRAddress.addr_Address2;
                recBRRequest.prbr_AddressLine2 = recPRAddress.addr_Address2;
                Entry = blkRequesting.GetEntry("prbr_CityStateZip");
                var sValue = recPRAddress.prci_City + ", " + recPRAddress.prst_State;
                Entry.DefaultValue = sValue;
                recBRRequest.prbr_AddressLine2 = sValue;
            }

            recPRPhone = eWare.FindRecord("vPRCompanyPhone", "phon_PRPreferredInternal='Y' AND phon_PRIsFax='Y' AND plink_RecordID="+comp_companyid);
            if (!recPRPhone.eof)
            {
                Entry = blkRequesting.GetEntry("prbr_Fax");
                Entry.DefaultValue = recPRPhone.phon_FullNumber;
                recBRRequest.prbr_Fax = recPRPhone.phon_FullNumber;
            }
        }
        
        eWare.AddContent(blkContainer.Execute(recBRRequest));

        Response.Write(eWare.GetPage());
        

        Response.Write("\n<script type=text/javascript src=\"../PRCoGeneral.js\"></script>\n");
        Response.Write("<script type=text/javascript src=\"../ajax.js\"></script>\n");
        Response.Write("<script type=text/javascript src=\"PRCompanyBRRequest.js\"></script>\n");
        var sViewBRAction = changeKey(eWare.URL("PRCompany/PRCompanyBRReport.aspx"), "BRFileVersion", Server.URLEncode(sBRFileVersion));
        Response.Write("<script type=text/javascript>sBRRootUrl = \"" +  sViewBRAction + "\";</script>\n");

        var sBRCheckAction = eWare.URL("PRCompany/BusinessReportGeneratorCheck.asp");
        Response.Write("<script type=text/javascript>sBRValidCompanyCheckUrl = \"" +  sBRCheckAction + "\";</script>\n");
        
        var sBRPreview = "<div style=\"display:none;\" ID=\"div_BRPreview\" >";
        sBRPreview += "</div>\n";
        Response.Write(sBRPreview);

        // create a url to the PRCompanyBRRequestChecks.asp page; 
        // do not use eware.url for this, we do not want eware to record this in the F/J parms
        sBRChecksUrl = "/"+ sInstallName + "/CustomPages/PRCompany/PRCompanyBRRequestChecks.asp?SID="+ SID 

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() ");
        Response.Write("\n    {");
        Response.Write("\n        sBRChecksUrl = '" + sBRChecksUrl + "';");
        Response.Write("\n        AppendCell(\"_Captprbr_requestedcompanyid\", \"div_BRPreview\");");
        Response.Write("\n        AppendCell(\"_Captprbr_methodsent\", \"span_prbr_productid\");");
        Response.Write("\n        document.all[\"div_BRPreview\"].style.display='inline';");
        Response.Write("\n        InsertDivider(\"Requestor and Delivery Info\", \"_Captprbr_requestingpersonid\");"); 
        Response.Write("\n        InsertDivider(\"Business Report On\", \"_Captprbr_requestedcompanyid\");");
        Response.Write("\n        forceTableCellsToLeftAlign(\"_Captprbr_requestingpersonid\");");
        Response.Write("\n        onDoNotChargeUnitsChange();");
        Response.Write("\n        document.getElementById(\"prbr_requestingcompanyid\").value = " + comp_companyid + ";");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
}
%>

<!-- #include file ="CompanyFooters.asp" -->

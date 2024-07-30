<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2023

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

<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="CompanyARAgingHeader.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->


<%
    doPage();

function doPage()
{
	var sSecurityGroups = "1,2,10"; //Chan_ChannelId

	//bDebug = true;
	var Key0 = String(Request.QueryString("Key0"));
	var Key1 = String(Request.QueryString("Key1"));
	var Key2 = String(Request.QueryString("Key2"));
	var sRedirectUrl = "";

	if (Key2 != "undefined" )
	{
		sRedirectUrl = eWare.URL("PRCompany/PRCompanySummary.asp");
		// remove the person key as it can cause some confusion
		sRedirectUrl = removeKey(sRedirectUrl, "Key2");
	}

	// if comp_companyid exists but Key1 does not, redirect to add Key1 to the query string
	if (comp_companyid != "-1")
	{
		// Accpac will not pass along the comp_companyid querystring param but it will pass 
		// Key1 to other native calls
		if (Key1 == "undefined" || Key1.valueOf() != comp_companyid.valueOf() )
		{
			if (sRedirectUrl == "" )
				sRedirectUrl = eWare.URL("PRCompany/PRCompanySummary.asp");
			
			// depending upon where this link came from the url can be a mess
			// simply it and resend
			sRedirectUrl = changeKey(sRedirectUrl, "Key0", "1");
			sRedirectUrl = changeKey(sRedirectUrl, "Key1", comp_companyid);

			Key0 = "1";
			
			sPrevVal = String(Request.QueryString("PrevCustomURL"));
			if (sPrevVal != "undefined")
			{
				reg = new RegExp("&","gi");
				var sFValue = sPrevVal.replace(reg, "%26");
				sRedirectUrl = changeKey(sRedirectUrl, "F", sFValue);
				reg = null;
			}
		} 
	} 
	
	if (Key0 != "1") {
		sRedirectUrl = eWare.URL("PRCompany/PRCompanySummary.asp");        
		sRedirectUrl = changeKey(sRedirectUrl, "Key0", "1");
	}

	if (sRedirectUrl != "")
	{
		DEBUG("<BR>Redirect: " + sRedirectUrl);
		Response.Redirect(sRedirectUrl+"&redirected=true" );
		return;
	}       
	
	var sInitialValuesString = "";

	var blkIncludes = eWare.GetBlock('content');
    blkIncludes.contents = "\n<meta http-equiv=\"Page-Enter\" content=\"RevealTrans(Duration=0,Transition=0)\" />\n";
    blkIncludes.contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkIncludes.contents += "<script type=\"text/javascript\" src=\"CompanyClient.js\"></script>\n";
    blkIncludes.contents += "<script type=\"text/javascript\" src=\"PRCompanySummary.js\"></script>\n\n";
    

	eWare.GetContextInfo("person","pers_personid");

	recCompany.comp_UpdatedBy = user_UserId;

	var blkSpecialInstr = eWare.GetBlock("PRSpecialInstructions");
	blkSpecialInstr.Title = "Special Instructions";
	//blkSpecialInstr.NewLine = true;
	blkSpecialInstr.ArgObj = recCompany;

	
	// define the company info block along with security
	var blkCompanyInfo = eWare.GetBlock("PRCompanyInfo");
	blkCompanyInfo.Title = "Company Info";
	blkCompanyInfo.NewLine = true;
	blkCompanyInfo.ArgObj = recCompany;
	// these fields are always read only
	entry = blkCompanyInfo.GetEntry("comp_name");
	entry.ReadOnly = true;
	entry = blkCompanyInfo.GetEntry("comp_PRCorrTradestyle");
	entry.ReadOnly = true;
	entry = blkCompanyInfo.GetEntry("comp_PRBookTradestyle");
	entry.ReadOnly = true;
	
	entry = blkCompanyInfo.GetEntry("comp_prlistingstatus");
	entry.AllowBlank = false;
	entry = blkCompanyInfo.GetEntry("comp_prindustrytype");
	entry.AllowBlank = false;
	entry = blkCompanyInfo.GetEntry("comp_PRCommunicationLanguage");
	entry.AllowBlank = false;

	if (recCompany("comp_PRType") == "H")
	{
		entry = blkCompanyInfo.GetEntry("comp_PRHQId");
		entry.Hidden = true;
	}

	// these fields have very specific security
	if (!isUserInGroup("5,10"))
	{
		entry = blkCompanyInfo.GetEntry("comp_PRDataQualityTier");
		entry.ReadOnly = true;
	}
	if (!isUserInGroup("6,7,10"))
	{
		entry = blkCompanyInfo.GetEntry("comp_PRAccountTier");
		entry.ReadOnly = true;
	}

    if (eWare.Mode == Edit) {
        var qryListingCountry = eWare.CreateQueryObj("SELECT prcn_CountryID FROM vPRLocation WHERE prci_CityID = " + recCompany.comp_PRListingCityID);
	    qryListingCountry.SelectSql();
        var CountryID = qryListingCountry("prcn_CountryID");

        if ((recCompany.comp_PRIndustryType == "L") ||
            (CountryID >= 4)) {
            blkCompanyInfo.GetEntry("comp_PROnlineOnly").ReadOnly = true;
        }

        if((recCompany.comp_PRIndustryType == "L") ||
           (recCompany.comp_PRIndustryType == "P") ||
           (recCompany.comp_PRIndustryType == "T"))
        {
            blkCompanyInfo.GetEntry("comp_PRPublishBBScore").ReadOnly = false;
        }
        else
        {
            blkCompanyInfo.GetEntry("comp_PRPublishBBScore").ReadOnly = true;
        }

        //Check service code ITALIC instead of access level
        var qryLimitado = eWare.CreateQueryObj("SELECT COUNT(*) LimitadoCount FROM PRWebUser WHERE ISNULL(prwu_AccessLevel,0) = 100 AND prwu_BBID = " + recCompany.comp_CompanyId + " AND prwu_Deleted IS NULL AND prwu_Disabled IS NULL");
	    qryLimitado.SelectSql();
        var iLimitadoCount = qryLimitado("LimitadoCount");

        if(iLimitadoCount == 0)
        {
            blkCompanyInfo.GetEntry("comp_PRHasITAAccess").ReadOnly = false;
        }
        else
        {
            blkCompanyInfo.GetEntry("comp_PRHasITAAccess").ReadOnly = true;
        }

		entry = blkCompanyInfo.GetEntry("comp_prlegalname");
        entry.Size = 50;
    }

	//Create Total Lines and DL line count display
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
    Response.Write("<table><tr id=\"_trLineCount\"><td colspan=\"4\"><table id=\"_tblLineCount\" cellpadding=\"0\" cellspacing=\"0\"><tr>" +
        "<td class=\"VIEWBOXCAPTION\">Total Line Count: </td>" +
        "<td class=\"VIEWBOX\">&nbsp;" + nLineCount + "&nbsp;Lines</td>" +
        "<td>&nbsp;&nbsp;&nbsp;</td>" +
        "<td class=\"VIEWBOXCAPTION\">Body Line Count: </td>" +
        "<td class=\"VIEWBOX\">&nbsp;" + nBodyCount + "&nbsp;Lines</td>" +
        "<td>&nbsp;&nbsp;&nbsp;</td>" +
        "<td class=\"VIEWBOXCAPTION\">Descriptive Line Count: </td>" +
        "<td class=\"VIEWBOX\">&nbsp;" + nDLCount + "&nbsp;Lines</td>" +
        "<td>&nbsp;&nbsp;&nbsp;</td>" +
        "<td class=\"VIEWBOXCAPTION\">Class/Vol/Comm Line Count: </td>" +
        "<td class=\"VIEWBOX\">&nbsp;" + nCVCCount + "&nbsp;Lines</td>" +
        "</tr></table>" +
        "</tr></table><td>");
		var sLineCountString = "AppendRow(\"_Captcomp_prebbtermsaccepteddate\", \"_trLineCount\");\n";
	
	var blkTeam = eWare.GetBlock("PRCoAccountTeam");
	blkTeam.Title = "BBSI Account Team";
	blkTeam.NewLine = true;
	var recAccountTeam = eWare.FindRecord("vPRCoAccountTeam", "Comp_CompanyID = " + comp_companyid);
	blkTeam.ArgObj = recAccountTeam;
	
	if (eWare.Mode == View) {
		var blkLogoSpotlight = eWare.GetBlock("PRLogoSpotlight");
		blkLogoSpotlight.Title = "Logo";
		blkLogoSpotlight.NewLine = true;
		blkLogoSpotlight.ArgObj = recCompany;

        if (!isEmpty(recCompany.comp_PRLogo)) {
            var tmp = recCompany.comp_PRLogo.substr(0, 6);
            blkLogoSpotlight.AddButton(eWare.Button("Logo Directory", "componentpreview.gif", "javascript:ViewReport('/logos/" + tmp + "/');"));
        }
	}
	
	//<!-- Setup Block Container -->
	// Covers the full width in one block
	var blkTopContainer = eWare.GetBlock('Container');

	// Covers the 2 block wide blocks
	var blkBodyContainer = eWare.GetBlock('Container');
	var myBlockContainer = eWare.GetBlock('Container');
	
	// Set up the file version for viewing business reports.
	var blkCustomFields = eWare.GetBlock('Content');
	var sBRFileVersion = (Request.Form.Item("hdn_brfileversion").Count > 0 ? String(Request.Form.Item("hdn_brfileversion")) : (new Date()).valueOf());
	blkCustomFields.Contents = "<input type='hidden' id='hdn_brfileversion' name='hdn_brfileversion' value='" + sBRFileVersion + "' />";

    var branchCount = 0;
    var onlineOnlyBranchCount = 0;
	if (recCompany("comp_PRType") == "H")
	{
        var recBranches = eWare.FindRecord("Company", "comp_PRHQID = " + comp_companyid + " AND comp_PRType='B' AND comp_PRListingStatus IN ('L', 'H')");
        branchCount = recBranches.RecordCount;

        recBranches = eWare.FindRecord("Company", "comp_PRHQID = " + comp_companyid + " AND comp_PRType='B' AND comp_PRListingStatus IN ('L', 'H') AND comp_PROnlineOnly = 'Y'");
        onlineOnlyBranchCount = recBranches.RecordCount;

    }
    blkCustomFields.Contents += "<input type='hidden' id='hdn_branchCount' name='hdn_branchCount' value='" + branchCount.toString() + "' /><input type='hidden' id='hdn_OnlineOnlybranchCount' name='hdn_OnlineOnlybranchCount' value='" + onlineOnlyBranchCount.toString() + "' />";

	myBlockContainer.AddBlock(blkCustomFields);

	// determine if any of the addtional banners should show
	var sBannerMsg = "";
	var blkBanners = eWare.GetBlock('content');
	if (eWare.Mode == View)
	{
		var sInnerMsg = "";
		var cols = 3;
		var i = 0

        //IGNORE year-round blueprints advertiser message
		var qry = eWare.CreateQueryObj("SELECT * FROM dbo.ufn_GetCompanyMessages(" + comp_companyid +  ", '" + recCompany("comp_PRIndustryType") + "') WHERE Message NOT LIKE ('%year-round Blueprints%')");
		qry.SelectSQL();

		while (!qry.eof) {
			if (i % cols == 0) {
				sInnerMsg += "<tr>\n";
			}

			var msg = qry("Message");
            var additionalData = qry("AdditionalData");

			if (additionalData != null) {
				var innerQry = eWare.CreateQueryObj("SELECT prcse_CompanyID, prcse_FullName FROM PRCompanySearch WITH (NOLOCK) WHERE prcse_CompanyID IN (" + qry("AdditionalData") +  ")");
				innerQry.SelectSQL();

				while (!innerQry.eof) {
					
					var summaryURL =  eWareUrl("PRCompany/PRCompanySummary.asp");
					summaryURL = changeKey(summaryURL, "Key0", "1");
					summaryURL = changeKey(summaryURL, "Key1", innerQry("prcse_CompanyID"));

					msg += " <a href=\"" + summaryURL + "\">" + innerQry("prcse_FullName") + "</a>";
					innerQry.NextRecord();
				}
			}
            
            if(msg.substr(0,10) == "lightblue:")
            {
                msg = msg.replace("lightblue:", "");
                sInnerMsg += "\t<td width=\"33%\" align=\"center\" class=\"MessageContent3\">" + msg + "</td>\n";
            }
			else if(msg == "This company's Membership Service has been suspended due to non-payment.")
				sInnerMsg += "\t<td width=\"33%\" align=\"center\" class=\"MessageContent4\">" + msg + "</td>\n";    
            else
			    sInnerMsg += "\t<td width=\"33%\" align=\"center\">" + msg + "</td>\n";    


			if ((i+1) % cols == 0) {
				sInnerMsg += "</tr>\n";
			}

			i++;
			qry.NextRecord();
		}

		if (sInnerMsg != "") {
			if (i % cols != 0) {
				sInnerMsg += "</tr>\n";
			}

			sBannerMsg = "\n\n<table width='100%' style='padding-left:10px !important; padding-right:10px !important'><tr><td width='100%' align='center'>\n";
			sBannerMsg += "<table class='MessageContent' align='center>'\n";
			sBannerMsg += sInnerMsg;
			sBannerMsg += "</table>\n";
			sBannerMsg += "</td></tr></table>\n\n";

			blkBanners.contents = sBannerMsg;
		}
	}

	with (blkTopContainer) 
	{
		// we only need to show this in view mode
		if (eWare.Mode == View){
			AddBlock(blkTrxHeader);
			if (sBannerMsg != "")
				AddBlock(blkBanners);
		}
		AddBlock(blkSpecialInstr);
	}
	with (blkBodyContainer) 
	{
		if (eWare.Mode == View || (eWare.Mode >= Edit && isUserInGroup("1,2,3,4,5,6,10")) )
		{

			AddBlock(blkCompanyInfo);
			if (eWare.Mode == View)
				AddBlock(blkTeam);
		}
		
		 if (eWare.Mode == View) {
			AddBlock(blkLogoSpotlight);         
		 }
	}

    blkIncludes.contents += "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n\n";

	// Add Block to Container to build screen.
	with (myBlockContainer) 
	{
		AddBlock(blkTopContainer);
		AddBlock(blkBodyContainer);
        AddBlock(blkIncludes);
    
		CheckLocks = false;

		DisplayButton(Button_Default) = false;
		if ( eWare.Mode == Edit )
		{
			AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRCompanySummary.asp")+ "&comp_companyid="+comp_companyid));
			AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"save();\""));
			//AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
			
			// In edit mode, we have to set a couple of fields to pass values to the client side 
			// javascript validation.  For instance, Listing Status changing to listed requires
			// a classification, a tradestyle1 value, a listing city, a listed phone number, a listed
			// address, (possibly a commodity depending upon IndustryType)
			sInitialValuesString = "\nsIndustryTypeCode = '" + recCompany("comp_PRIndustryType") + "';";

			var recClassifications = eWare.FindRecord("PRCompanyClassification", "prc2_CompanyId=" + comp_companyid);
			sInitialValuesString += "\nnClassificationCount = " + recClassifications.RecordCount + ";";
			var recCommodities = eWare.FindRecord("PRCompanyCommodityAttribute", "prcca_CompanyId=" + comp_companyid);
			sInitialValuesString += "\nnCommodityCount = " + recCommodities.RecordCount + ";";
			var recPublishedPhones = eWare.FindRecord("vPRCompanyPhone", "phon_Deleted is null AND phon_PRPublish= 'Y' AND plink_RecordID=" + comp_companyid);
			sInitialValuesString += "\nnPublishedPhoneCount = " + recPublishedPhones.RecordCount + ";";
			var recPublishedAddresses = eWare.FindRecord("vPRAddress", "addr_Deleted is null AND addr_PRPublish= 'Y' AND adli_CompanyId=" + comp_companyid);
			sInitialValuesString += "\nnPublishedAddressCount = " + recPublishedAddresses.RecordCount + ";";
			var recHeadExecs = eWare.FindRecord("Person_Link", "peli_Deleted is null AND peli_PRStatus=1 AND peli_PRRole like '%,HE,%' AND peli_CompanyId=" + comp_companyid);
			sInitialValuesString += "\nnHeadExecCount = " + recHeadExecs.RecordCount + ";";
			
			// If the company has associated stock symbols, then they are a public company and thus
			// the financial statements are not confidential
			var recHasStockSymbols = eWare.FindRecord("PRCompanyStockExchange", "prc4_CompanyID=" + comp_companyid);
			if (recHasStockSymbols.RecordCount > 0) {
				entryFSConfidential = blkCompanyInfo.GetEntry("comp_PRConfidentialFS");
				entryFSConfidential.DefaultValue = "";
				entryFSConfidential.ReadOnly = true;
			}
			

            var blkDialog = eWare.GetBlock("Content");
            var sDialog = "\n\n<div id=\"pnlSendCompanyRequest\" class=\"Popup\" style=\"width:400px;display:none;\">\n";
            sDialog += "<span style=\"font-family:Tahoma,Arial;font-size:12px;font-weight:bold;\">Now that this company is listed, should a request for a Financial Statement and Reference List be sent?</span>\n";
            sDialog += "<input type=\"hidden\" id=\"hidSendCompanyRequest\" name=\"hidSendCompanyRequest\"  />\n"
            sDialog += "<p style=\"text-align:center;\"><button onclick=\"sendCompanyRequest();return false;\">Yes</button> <button onclick=\"closeCompanyRequest();return false;\">No</button></p>\n";
            sDialog += "</div>\n\n";
            blkDialog.contents = sDialog;
            AddBlock(blkDialog);

		}
		else if ( eWare.Mode == View )
		{
			if (iTrxStatus == TRX_STATUS_EDIT)
			{
				AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));

                if (recCompany.comp_PRLocalSource !=  "Y") {
                    if ((isUserInGroup("4,10,17"))||
                         (user_userid == 26) ||
                         (user_userid == 20) ||
                         (user_userid == 51))
				    {
					    if (recCompany("comp_PRType") == "H")
					    {
						    AddButton( eWare.Button("Convert to Branch","edit.gif", eWare.URL("PRCompany/PRCompanyConvert.asp") + "&Action=C2B"));
					    } else {
						    AddButton( eWare.Button("Convert to HQ","edit.gif", eWare.URL("PRCompany/PRCompanyConvert.asp") + "&Action=C2H"));
					    }
				    }
                }

				if (isUserInGroup(sSecurityGroups))
				{
					AddButton( eWare.Button("Create New Record","save.gif", eWare.URL("TravantCRM.dll-RunCompanyCreateNew")));
				}
			}

            if (recCompany.comp_PRLocalSource !=  "Y") {
			    var btnViewCompanyBR = eWare.Button("View B/R","componentpreview.gif", "#\" onClick=\"viewBusinessReport(" + comp_companyid + ", null, null, false, false, false)\")");
			    AddButton(btnViewCompanyBR);
			
			    var btnProvideBRtoThisCompany = eWare.Button("New B/R Request","new.gif", eWare.URL("PRCompany/PRCompanyBRRequest.asp")+"&comp_companyid="+comp_companyid);
			    AddButton(btnProvideBRtoThisCompany);
			
			
			    if (recCompany("comp_PRType") == "H")
			    {
				    var btnBranches = eWare.Button("Branches","list.gif", eWare.URL("PRCompany/PRCompanyBranchListing.asp"));
				    AddButton(btnBranches);
			    }
			    var btnNewAlias = eWare.Button("Aliases","list.gif", eWare.URL("PRCompany/PRCompanyAliasListing.asp"));
			    AddButton(btnNewAlias);

			    var btnInfo = eWare.Button("Info Profile","list.gif", eWare.URL("PRCompany/PRCompanyInfoProfile.asp"));
			    AddButton(btnInfo);

                if (recCompany.comp_PRIndustryType !=  "L") {
			        var btnInfo = eWare.Button("Send Requests","componentpreview.gif", eWare.URL("PRCompany/PRCompanySendRequests.asp"));
			        AddButton(btnInfo);
                }
            }
			
			var btnLogo = eWare.Button("Edit Logo", "edit.gif", eWare.URL("PRCompany/PRCompanyLogo.asp"));
			AddButton(btnLogo);

			// If in View mode, rebuild the URL so that
			// it points to the correct virtual directory.
			sCompanyLogo = '';
			if ((recCompany.comp_PRPublishLogo == "Y") &&
                (recCompany.comp_PRLogo != null)) {
				var sLogo = recCompany.comp_PRLogo;
				var re = new RegExp(/\\/g);
				sLogo = sLogo.replace(re, "/");  

				var sLogo2 = recCompany.comp_PRLogo;
				sLogo2 = sLogo2.replace(re, "&#92;");  
				re = null;
												
				var qryLogoURL = eWare.CreateQueryObj("SELECT results = dbo.ufn_GetCustomCaptionValue('PIKSUtils', 'LogoURL', 'en-us')");
				qryLogoURL.SelectSql();

				var logoURL = qryLogoURL("results") + sLogo;
				sCompanyLogo =  sLogo2 + "<br/><img src=\"" + logoURL + "\">";

			} else {
				if (recCompany.comp_PRLogo != null) {
					var sLogo = recCompany.comp_PRLogo;
					var re = new RegExp(/\\/g);
					sCompanyLogo = sLogo.replace(re, "&#92;");  
				}
			}

			if (recCompany.comp_PRIndustryType ==  "L") {
				hideFieldsInBlock(blkCompanyInfo, ",comp_PRAdministrativeUsage,comp_PRHandlesInvoicing,comp_PRReceivesBBScoreReport,");
			}
		}
	}

	//<!--Output Block to Web -->
	eWare.AddContent(myBlockContainer.Execute());
	if (eWare.Mode == View || eWare.Mode == Save)
	{
		Response.Write(eWare.GetPage('Company'));
	} 
	else
	{
		Response.Write(eWare.GetPage('Company'));
	}

   // if the company record has just been edited, return to the summary screen
   if (eWare.Mode == Save) {
        if (Request.Form.Item("hidSendCompanyRequest") == "Y") {
            Response.Redirect(eWare.URL("PRCompany/PRCompanySendRequests.asp"));
        } else {
	        Response.Redirect(eWare.URL("PRCompany/PRCompanySummary.asp"));
        }
   }

   // If the record has been deleted ,then return to the company search screen
   if (eWare.Mode == PostDelete) {
	  Response.Redirect(eWare.URL(130));
   }

%>
	<script type="text/javascript" >
		function initBBSI() {
			<%= sLineCountString %>
	        initialize();
	        <%=sInitialValuesString %>
	
	
	<%  if (eWare.Mode == View)  {  %>
			setFieldValue('_Datacomp_prlogo', '<% =sCompanyLogo %>');
    <% }  %>
	
    <%  if (eWare.Mode == Edit)  {  %>

        <%  if (recCompany.comp_prlistingstatus != "N5")   {  %>
            RemoveDropdownItemByValue('comp_prlistingstatus', 'N5');
        <% }  %>

        <%  if (recCompany.comp_prlistingstatus != "D")   {  %>
            RemoveDropdownItemByValue('comp_prlistingstatus', 'D');
        <% }  %>
    <% }  %>
	    }

	    if (window.addEventListener) { 
	        window.addEventListener("load", initBBSI); 
	    } else {
	        window.attachEvent("onload", initBBSI); 
	    }
    </script>
<%
}

 %>
<!-- #include file="CompanyFooters.asp" -->
<%

	blkTeam= null;
	blkLogoSpotlight = null;
	blkTrxHeader= null;
	blkBanners= null;
	blkSpecialInstr= null;
	blkTopContainer= null;
	blkBodyContainer= null;
	myBlockContainer = null;
	recCompany = null;
	recUser = null;
	recCity = null;
	eWare = null;
	sURL = null;
	comp_companyid = null;
	F= null;
	J= null;
 
 %>
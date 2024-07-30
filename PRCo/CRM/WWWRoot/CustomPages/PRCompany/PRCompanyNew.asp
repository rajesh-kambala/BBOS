<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

doPage();
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

function doPage() {
    //bDebug = true;

	DEBUG("URL: " + sURL); 
	DEBUG("<br>Mode: " + eWare.Mode);

    var dupCompanyMsg = "";
    blkContainer.CheckLocks = false;

	// comp_prtype is passed from the branch listing; if not set, this is a HQ
	var comp_prtype = new String(Request.QueryString("comp_prtype"));
	
    var isPACASource = false;
	var pril_ImportPACALicenseId = new String(Request("pril_ImportPACALicenseId"));
	if (isEmpty(pril_ImportPACALicenseId)) {
	    pril_ImportPACALicenseId = "";
	} else {
        isPACASource = true;
    }

    var isBBOSSource = false;
	var oppo_OpportunityID = new String(Request("oppo_OpportunityID"));
	if (isEmpty(oppo_OpportunityID)) {
	    oppo_OpportunityID = "";
	} else {
        isBBOSSource = true;
    }
   
    if (eWare.Mode == Save) 
    {
	    //DumpFormValues();
        
	    var recCompany = eWare.CreateRecord("Company");
	    var blkCompany = eWare.GetBlock("PRCompanyNew");
	    blkCompany.ArgObj = recCompany;
    
        recCompany.comp_PRListingStatus = "N2";
        
        // this is also covered in the company triggers
        if (recCompany.comp_PRType == "H") {
            recCompany.comp_PRHQId = recCompany.comp_CompanyID;
        }
        
        // Notice we only execute the specific block, 
        // not a container with the block included
        blkCompany.Execute();
        
        // At this point the Company Should exist.
	    var recTrx = eWare.CreateRecord("PRTransaction");
        recTrx.prtx_CompanyId = recCompany.comp_companyid;
        
        var blkTrx = eWare.GetBlock("PRTransactionNewEntry");
        blkTrx.ArgObj = recTrx;
        blkTrx.Execute();

        // Now the Company and transaction will exist. Add a detail record
        var sNewValue = String(recCompany.comp_Name);
        var sSQL = "EXECUTE usp_CreateTransactionDetail " + 
                        "@prtx_TransactionId = " + recTrx.prtx_TransactionId + ", " +
                        "@Entity = 'Company', " +
                        "@Action = 'Insert', " +
                        "@NewValue = '" + sNewValue.replace(/'/g, "''") + " Created', " +
                        "@UserId = " + user_userid;

        var recQuery = eWare.CreateQueryObj(sSQL);
        recQuery.ExecSql()                        


        // If our transaction was closed by the user, we'll need to temporarily
        // reopen it to save the address and phone data.
        var trxStatus = getFormValue("prtx_status");
Response.Write("<br/>trxStatus=" + trxStatus);

        if (trxStatus == "C") {

    Response.Write("<br/>Opening Transaction");
            recTrx.prtx_Status = "O";
            recTrx.SaveChanges();
        }

    //return;
        if ((!isEmpty(getFormValue("addr_address1"))) ||
	        (!isEmpty(getFormValue("addr_prcityid")))) {

            var recAddress = eWare.CreateRecord("Address");
            var blkAddress = eWare.GetBlock("PRCompanyAddressNew");
            blkAddress.ArgObj = recAddress;
            blkAddress.Execute();

            // This should have been created when the Address
            // block was executed.  Now we have to update it.
            var recAddressLink = eWare.FindRecord("Address_Link", "adli_AddressId=" +  recAddress.addr_AddressId);
	        recAddressLink.adli_Type = "M";
            recAddressLink.adli_PRDefaultMailing = "Y";
            recAddressLink.adli_PRDefaultTax = "Y";
            recAddressLink.SaveChanges();
        }

        if (!isEmpty(getFormValue("phon_number"))) {
            var recPhone = eWare.CreateRecord("Phone");
            recPhone.phon_PRDescription = "Phone";
            recPhone.phon_PRPreferredInternal = "Y";
            recPhone.Phon_CountryCode = getFormValue("phon_countrycode");
            recPhone.Phon_AreaCode = getFormValue("phon_areacode");
            recPhone.Phon_Number = getFormValue("phon_number");

            if (getFormValue("phon_prpublish") == "on") {
                recPhone.phon_PRPublish = "Y";
                recPhone.phon_PRPreferredPublished = "Y";
            }
            recPhone.SaveChanges();

            var recPhoneLink = eWare.CreateRecord("PhoneLink");
            recPhoneLink.PLink_EntityID = 5;
            recPhoneLink.PLink_RecordID = recCompany.comp_companyid;
            recPhoneLink.PLink_PhoneId = recPhone.phon_PhoneID;
            recPhoneLink.PLink_Type = "P";
            recPhoneLink.SaveChanges();
        }


        if (!isEmpty(getFormValue("phon_numberfax"))) {
            var recFax = eWare.CreateRecord("Phone");
            recFax.phon_PRDescription = "FAX";
            recFax.phon_PRPreferredInternal = "Y";
            recFax.Phon_CountryCode = getFormValue("phon_countrycodefax");
            recFax.Phon_AreaCode = getFormValue("phon_areacodefax");
            recFax.Phon_Number = getFormValue("phon_numberfax");

            if (getFormValue("phon_prpublishfax") == "on") {
                recFax.phon_PRPublish = "Y";
                recFax.phon_PRPreferredPublished = "Y";
            }
            recFax.SaveChanges();

            var recFaxLink = eWare.CreateRecord("PhoneLink");
            recFaxLink.PLink_EntityID = 5;
            recFaxLink.PLink_RecordID = recCompany.comp_companyid;
            recFaxLink.PLink_PhoneId = recFax.phon_PhoneID;
            recFaxLink.PLink_Type = "F";
            recFaxLink.SaveChanges();
        }


        if (!isEmpty(getFormValue("emai_prwebaddress"))) {
            var recWebSite= eWare.CreateRecord("Email");
            recWebSite.emai_PRDescription = "Web Site";
            recWebSite.emai_PRWebAddress = getFormValue("emai_prwebaddress");
            if (getFormValue("emai_prpublish") == "on") {
                recWebSite.emai_PRPublish = "Y";
                recWebSite.emai_PRPreferredPublished = "Y";
            }
            
            recWebSite.SaveChanges();

            var recWebSiteLink= eWare.CreateRecord("EmailLink");
            recWebSiteLink.ELink_EmailId = recWebSite.emai_EmailID;
            recWebSiteLink.ELink_EntityID = 5;
            recWebSiteLink.ELink_RecordID = recCompany.comp_companyid;
            recWebSiteLink.ELink_Type = "W";
            recWebSiteLink.SaveChanges();
        }


        if (!isEmpty(getFormValue("emai_emailaddress"))) {
            var recEmail = eWare.CreateRecord("Email");
            recEmail.emai_PRDescription = "E-Mail";
            recEmail.emai_EmailAddress = getFormValue("emai_emailaddress");
            recEmail.emai_PRPreferredInternal = "Y";

            if (getFormValue("emai_prwebaddress_prpublish") == "on") {
                recEmail.emai_PRPublish = "Y";
                recEmail.emai_PRPreferredPublished = "Y";
            }
            recEmail.SaveChanges();

            var recEmailLink= eWare.CreateRecord("EmailLink");
            recEmailLink.ELink_EmailId = recEmail.emai_EmailID;
            recEmailLink.ELink_EntityID = 5;
            recEmailLink.ELink_RecordID = recCompany.comp_companyid;
            recEmailLink.ELink_Type = "E";
            recEmailLink.SaveChanges();
        }



        // Now if we reopened the CRM transaction,
        // we can close it.
        if (trxStatus == "C") {
            recTrx.prtx_Status = "C";
            recTrx.SaveChanges();
        } 

        if (isBBOSSource) {
	        var oppo_Record = eWare.FindRecord("Opportunity", "oppo_OpportunityID=" + oppo_OpportunityID);
            oppo_Record.oppo_PrimaryCompanyId = recCompany.comp_companyid;
            oppo_Record.SaveChanges();

            var prwu_Record = eWare.FindRecord("PRWebUser", "prwu_WebUserID=" + oppo_Record.oppo_PRWebUserID);
            prwu_Record.prwu_BBID = recCompany.comp_companyid;
            prwu_Record.prwu_HQID = recCompany.comp_companyid;
            prwu_Record.SaveChanges();
        }

        if (isPACASource) {
            // Invoke the action to automatically assigned our newly created
            // company to the imported license
            var szRedirect = eWare.URL("InvokeStoredProc.aspx") + "&customact=AssignImportedPACA&sp_type=1&pril_ImportPACALicenseId=" + pril_ImportPACALicenseId + "&prpa_companyid=" + recCompany.comp_companyid;
            Response.Redirect(szRedirect);
        
        } else if (isBBOSSource) {
            Response.Redirect(eWare.URL("PRCompany/PRCompanySummary.asp")+"&Key0=1&Key1=" + recCompany.comp_companyid);
        
        } else if (recCompany.comp_PRType == "B") {
            Response.Redirect(eWare.URL("PRCompany/PRCompanyBranchListing.asp")+"&comp_companyid=" + recCompany.comp_prhqid);
        
        } else {
            Response.Redirect(eWare.URL("PRCompany/PRCompanyContactInfoListing.asp")+"&Key0=1&Key1=" + recCompany.comp_companyid + "&T=Company&Capt=Contact+Info");
        }

        return;
    }

	// include the client side scripting functions
	Response.Write("<script type=\"text/javascript\" src=\"CompanyClient.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanySummary.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"../PRAddressPA.js\"></script>");

    var defaultCompanyName = "";
    var defaultLegalName = "";
    var defaultMethodSourceRecieved = "";
    var defaultSource = "";
    var defaultTxStatus = "O";
    var defaultTxExplanation = "";
    var defaultTxAuthorizedInfo = "";

    var defaultAddress1 = "";
    var defaultAddress2 = "";
    var defaultCity = "";
    var defaultState = "";
    var defaultCityID = "";
    var defaultStateID = "";
    var defaultPostalCode = "";
    var defaultCounty = "";
    var defaultAreaCode = "";
    var defaultPhoneNumber = "";
    var defaultCountryCode = "1";
    var defaultWebsite = "";
    var defaultEmail = "";
    var defaultIndustryType;

    var defaultCountryFax = "1";
    var defaultAreaCodeFax = "";
    var defaultPhoneNumberFax = "";

            
    if (isPACASource) {

    	// find the record based upon the ID
        var pril_record = eWare.FindRecord("PRImportPACALicense", "pril_ImportPACALicenseId=" + pril_ImportPACALicenseId);

        if (!isEmpty(pril_record.pril_PrimaryTradeName)) {
            defaultCompanyName = pril_record.pril_PrimaryTradeName;
            defaultLegalName = pril_record.pril_CompanyName;
        } else {
            defaultCompanyName = pril_record.pril_CompanyName;
        }

        defaultMethodSourceRecieved = "PD";
        defaultSource = "PACA";
        defaultTxStatus = "C";
        defaultTxExplanation = "Company created from PACA Import process.";
        defaultTxAuthorizedInfo = "PACA";
        defaultAddress1 = pril_record.pril_Address1;
        defaultAddress2 = pril_record.pril_Address2;
        defaultCity = pril_record.pril_City;
        defaultState = pril_record.pril_State;

        if (!isEmpty(pril_record.pril_PostCode)) {
            
            if (pril_record.pril_PostCode.length == 9) {
                defaultPostalCode = pril_record.pril_PostCode.substring(0, 5) + "-" + pril_record.pril_PostCode.substring(5);
            } else {
                defaultPostalCode = pril_record.pril_PostCode;
            }
        }

        defaultIndustryType = "P";

        defaultWebsite = pril_record.pril_WebAddress;
        defaultEmail = pril_record.pril_Email;

        if (!isEmpty(pril_record.pril_Telephone)) {
            defaultCounty = "1";
            defaultAreaCode = pril_record.pril_Telephone.substring(0, 3);
            defaultPhoneNumber = pril_record.pril_Telephone.substring(3, 6) + "-" + pril_record.pril_Telephone.substring(6);
        }

        if (!isEmpty(pril_record.pril_Fax)) {
            defaultCountryFax = "1";
            defaultAreaCodeFax = pril_record.pril_Fax.substring(0, 3);
            defaultPhoneNumberFax = pril_record.pril_Fax.substring(3, 6) + "-" + pril_record.pril_Fax.substring(6);
        }
        dupCompanyMsg = checkforDupByPhone(pril_record.pril_Telephone);
    }
        
    if (isBBOSSource) {
	    var oppo_Record = eWare.FindRecord("Opportunity", "oppo_OpportunityID=" + oppo_OpportunityID);
        var prwu_Record = eWare.FindRecord("PRWebUser", "prwu_WebUserID=" + oppo_Record.oppo_PRWebUserID);
        
        defaultCompanyName = prwu_Record.prwu_CompanyName;
        defaultMethodSourceRecieved = "W";
        defaultSource = "WEB";
        defaultTxStatus = "C";
        defaultTxExplanation = "Company created from BBOS Inquiry opportunity.";
        defaultTxAuthorizedInfo = "BBOS Inquiry";        
        defaultAddress1 = prwu_Record.prwu_Address1;
        defaultAddress2 = prwu_Record.prwu_Address2;
        defaultCity = prwu_Record.prwu_City;
        defaultStateID = prwu_Record.prwu_StateID;
        defaultPostalCode = prwu_Record.prwu_PostalCode;
        defaultCounty  = prwu_Record.prwu_County;
        defaultAreaCode = prwu_Record.prwu_PhoneAreaCode;
        defaultPhoneNumber = prwu_Record.prwu_PhoneNumber;
        defaultWebsite = prwu_Record.prwu_WebSite;
        defaultIndustryType = prwu_Record.prwu_IndustryTypeCode;
    }

	// make sure we're in edit mode
	if (eWare.Mode<Edit) {
        eWare.Mode=Edit;
    }

    if (dupCompanyMsg != "") {
        var blkBanners = eWare.GetBlock('content');

        var	sBannerMsg = "<link rel=\"stylesheet\" href=\"../../prco.css\">";
		sBannerMsg += "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
		sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
		sBannerMsg += "<tr><td>" +  dupCompanyMsg + "</td></tr>";
		sBannerMsg += "</table>\n";
		sBannerMsg += "</td></tr></table>\n\n";

        blkBanners.contents = sBannerMsg;
        blkContainer.AddBlock(blkBanners);
    }

	var recCompany = eWare.CreateRecord("Company");
	var blkCompany = eWare.GetBlock("PRCompanyNew");
	blkCompany.ArgObj = recCompany;
	blkCompany.Title="New Company";

	blkCompany.GetEntry("comp_prtype").ReadOnly = true;
	blkCompany.GetEntry("comp_prhqid").ReadOnly = true;
	blkCompany.GetEntry("comp_PRTradestyle1").DefaultValue = defaultCompanyName;
    blkCompany.GetEntry("comp_PRListingCityID").AllowBlank = false;
	    
    entry = blkCompany.GetEntry("comp_name");
	entry.ReadOnly = true;
    entry.DefaultValue = defaultCompanyName;
	    
    entry = blkCompany.GetEntry("comp_PRCorrTradestyle");
    entry.ReadOnly = true;
    entry.DefaultValue = defaultCompanyName;

	entry = blkCompany.GetEntry("comp_PRBookTradestyle");
	entry.ReadOnly = true;
    entry.DefaultValue = defaultCompanyName;
    
	blkCompany.GetEntry("comp_PRLegalName").DefaultValue = defaultLegalName;

	if ((isPACASource) ||
        (isBBOSSource)) {

        var locationCondition = null;
        if (isBBOSSource) {
            locationCondition = "prci_City = '" + padQuotes(defaultCity) + "' AND prst_StateID = " + defaultStateID;
        }

        if (isPACASource) {
            locationCondition = "prci_City = '" + padQuotes(defaultCity) + "' AND prst_Abbreviation = '" + padQuotes(defaultState) + "'";
        }

	    var recCity = eWare.FindRecord("vPRLocation", locationCondition);
        if (!recCity.eof) {
	        defaultCityID = recCity.prci_CityId;

            defaultCountryCode = recCity.prcn_CountryCode;
            if (isEmpty(defaultCountryCode))
                defaultCountryCode = "1";
        }
	}


    blkCompany.GetEntry("comp_PRListingCityID").DefaultValue = defaultCityID;

	entry = blkCompany.GetEntry("comp_PRIndustryType");
	entry.AllowBlank = false;
    entry.DefaultValue = defaultIndustryType;

	entry = blkCompany.GetEntry("comp_PRCommunicationLanguage");
	entry.AllowBlank = false;
	entry.DefaultValue =  "E";

	entry = blkCompany.GetEntry("comp_PRMethodSourceReceived");
	entry.AllowBlank = false;
    entry.DefaultValue = defaultMethodSourceRecieved;
	    
	entry = blkCompany.GetEntry("comp_Source");
	entry.AllowBlank = false;
    entry.DefaultValue = defaultSource;
	    
	entry = blkCompany.GetEntry("comp_prhqid");
	entry.ReadOnly = true;
    if (!isEmpty(comp_companyid) && comp_companyid != -1)
        entry.DefaultValue = comp_companyid;

	entry = blkCompany.GetEntry("comp_prtype");
	if (comp_prtype == "B")
	    entry.DefaultValue = "B";
	else
	    entry.DefaultValue = "H";

	blkContainer.AddBlock(blkCompany);
    


   //
	// Set up the transaction information
    //
    var blkTrx = eWare.GetBlock("PRTransactionNewEntry");
    blkTrx.Title = "Transaction";
        
    entry = blkTrx.GetEntry("prtx_Status");
    entry.ReadOnly = true;
    entry.DefaultValue = defaultTxStatus;

    blkTrx.GetEntry("prtx_CloseDate").hidden = true;        
    blkTrx.GetEntry("prtx_Explanation").DefaultValue = defaultTxExplanation;
    blkTrx.GetEntry("prtx_AuthorizedInfo").DefaultValue = defaultTxAuthorizedInfo;
        
    // This is custom code to add the "Close Transaction" checkbox
    // to the Transaction block
	var szChecked = new String();
	if ((isPACASource) ||
        (isBBOSSource)) {
        szChecked = " checked ";
    }        
       
    var sCloseTrxDisplay = "<table style=\"display:none\"><tr id=\"tr_closetrx\"><td id=\"td_closetrx\" class=\"VIEWBOXCAPTION\">" + 
        "<input type=\"checkbox\" class=\"EDIT\" " +
        "onclick=\"if (this.checked==true) document.getElementById('prtx_status').value='C'; else document.getElementById('prtx_status').value='O'; \" " + szChecked + 
        ">Close Transaction Upon Save</td></tr></table>" ;
    Response.Write(sCloseTrxDisplay);
    
    var sCloseTrxDraw = " AppendCell(\"_Captprtx_status\", \"td_closetrx\");";
                                        
	blkContainer.AddBlock(blkTrx);
        	

    //
    // Set up the address block
    //
    var recAddress = eWare.CreateRecord("Address");
    var blkAddress = eWare.GetBlock("PRCompanyAddressNew");
    blkAddress.Title = "Company Mailing Address";
    blkAddress.ArgObj = recAddress;

	if ((isPACASource) ||
        (isBBOSSource)) {
        blkAddress.GetEntry("addr_Address1").DefaultValue = defaultAddress1;
        blkAddress.GetEntry("addr_Address2").DefaultValue = defaultAddress2;
        blkAddress.GetEntry("addr_PRCityID").DefaultValue = defaultCityID;
        blkAddress.GetEntry("addr_PostCode").DefaultValue = defaultPostalCode;
        blkAddress.GetEntry("addr_PRCounty").DefaultValue = defaultCounty;
    }
    blkContainer.AddBlock(blkAddress);

    //Create the Perfect Address Verification Block
    var blkPerfectAddress = eWare.GetBlock("Content");  //style={display:none}
    var sContent = createAccpacBlockHeader("PerfectAddress", "Address Verification");
    sContent  += "<table \"width=100%\" ><tr ID=\"tr_PerfectAddress\"><td width=\"100%\">";
    sContent += "<IFRAME border=0 width=100% ID=\"embed_PerfectAddress\" ></IFRAME> ";
    sContent += "</td><td valign=\"top\"><input id=\"btnVerify\" type=\"button\" value=\"Refresh\" onclick=\"refreshPerfectAddress()\"/></td></tr></table>";
    sContent += createAccpacBlockFooter();
    blkPerfectAddress.contents = sContent;
    blkContainer.AddBlock(blkPerfectAddress);

    //Add the usage message
    sMsg = "If this address has a special building or market description, place the value in the 'Address 1' field.";
    Response.Write("<table style=\"display:none;\"><tr ID=_trUsage><td colspan=4 class=GRAYEDTEXT>"+ sMsg +"</td></tr></table>");

        	

    //
    // Set up the phone block
    //
    var recPhone = eWare.CreateRecord("Phone");
    var blkPhone = eWare.GetBlock("PhoneCompanyNewEntry");
    blkPhone.Title = "Company Phone";
    blkPhone.ArgObj = recPhone;
    
    blkPhone.GetEntry("phon_CountryCode").DefaultValue = defaultCountryCode;
    blkPhone.GetEntry("phon_AreaCode").DefaultValue = defaultAreaCode;
    blkPhone.GetEntry("phon_Number").DefaultValue = defaultPhoneNumber;
    blkContainer.AddBlock(blkPhone);


    //
    // Set up the fax block
    //
    var blkFax = eWare.GetBlock("Content");
    sContent = createAccpacBlockHeader("Fax", "Company Fax");
    sContent += "<table class=CONTENT WIDTH=\"100%\">";
    sContent += "<tr><td VALIGN=TOP ><SPAN class=VIEWBOXCAPTION>Country:</SPAN><br/><SPAN class=VIEWBOXCAPTION ><input type=\"text\" CLASS=EDIT ID=\"phon_countrycodeFax\" name=\"phon_countrycodeFax\"  value=\"" + defaultCountryFax + "\" maxlength=5 size=5></span></td>";
    sContent += "    <td VALIGN=TOP ><SPAN class=VIEWBOXCAPTION>Area/City Code:</SPAN><br/><SPAN class=VIEWBOXCAPTION ><input type=\"text\" CLASS=EDIT ID=\"phon_areacodeFax\" name=\"phon_areacodeFax\"  value=\"" + defaultAreaCodeFax + "\" maxlength=20 size=5></span></td>";
    sContent += "    <td VALIGN=TOP ><SPAN class=VIEWBOXCAPTION>Phone Number:</SPAN><br/><SPAN class=VIEWBOXCAPTION ><input type=\"text\" CLASS=EDIT ID=\"phon_numberFax\" name=\"phon_numberFax\"  value=\"" + defaultPhoneNumberFax + "\" maxlength=34 size=34></span></td>";
    sContent += "</tr>";
    sContent += "<tr>";
    sContent += "	<td><TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><tr><td><input type=checkbox name=\"phon_prpublishFax\" ID=\"phon_prpublishFax\">&nbsp;</TD><TD CLASS=VIEWBOXCAPTION><LABEL FOR=\"phon_prpublishFax\">Publish</LABEL></TD></TR></TABLE></td>";
    sContent += "</tr>";
    sContent += "</table>";
    sContent += createAccpacBlockFooter();
    blkFax.contents = sContent;
    blkContainer.AddBlock(blkFax);


    //
    // Set up the Website Block
    //
    var recEmail = eWare.CreateRecord("Email");
    var blkWebsite = eWare.GetBlock("EmailCompanyNewEntry");
    blkWebsite.Title = "Company Website";
    blkWebsite.ArgObj = recEmail;
    blkWebsite.GetEntry("emai_PRWebAddress").DefaultValue = defaultWebsite;
    blkContainer.AddBlock(blkWebsite);


    //
    // Set up the Email Block
    //
    var blkEmail = eWare.GetBlock("Content");
    sContent = createAccpacBlockHeader("Email", "Company Email");
    sContent += "<TABLE CLASS=CONTENT WIDTH=\"100%\">";
    sContent += "<TR><TD  VALIGN=TOP ><SPAN class=VIEWBOXCAPTION>Email Address:</SPAN><br/><SPAN class=VIEWBOXCAPTION ><input type=\"text\" CLASS=EDIT ID=\"emai_emailaddress\" name=\"emai_emailaddress\"  value=\"" + defaultEmail + "\" maxlength=255 size=50></SPAN></TD></TR>";
    sContent += "<TR><TD ><TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><TD ><input type=checkbox name=\"emai_prwebaddress_prpublish\" ID=\"emai_prwebaddress_prpublish\">&nbsp;</TD><TD CLASS=VIEWBOXCAPTION><LABEL FOR=\"emai_prwebaddress_prpublish\">Publish</LABEL></TD></TR>";
    sContent += "</TABLE></TD></TR></TABLE>";
    sContent += createAccpacBlockFooter();
    blkEmail.contents = sContent;
    blkContainer.AddBlock(blkEmail);


    //
    // Setup the PACA Blocks
    //    	    
	if (isPACASource) {
	    
	    var sImportLicenseTD = "<table><tr><td id=\"pril_ImportPACALicenseIdTD\"><input type=\"hidden\" id=\"pril_ImportPACALicenseId\" value=\"" + pril_ImportPACALicenseId + "\"></td></tr></table>";
	    var sImportLicenseDraw = "\nAppendCell(\"_Captpril_licensenumber\", \"pril_ImportPACALicenseIdTD\");";
	    
        var blkSummaryContent = eWare.GetBlock("PRImportPACALicenseNewEntry");
        blkSummaryContent.ArgObj = pril_record;
        blkSummaryContent.Title = "Pending PACA License";
        blkSummaryContent.GetEntry("pril_LicenseNumber").ReadOnly = true;
        blkSummaryContent.GetEntry("pril_Fax").ReadOnly = true;
        blkSummaryContent.GetEntry("pril_Email").ReadOnly = true;
        blkSummaryContent.GetEntry("pril_WebAddress").ReadOnly = true;
        blkContainer.AddBlock(blkSummaryContent);

        // add the Principal and Trade grids 
        BottomContainer=eWare.GetBlock("container");

        blkPrincipalGrid=eWare.GetBlock("PRImportPACAPrincipalGrid");
        blkPrincipalGrid.DisplayForm = false;
        blkPrincipalInner = eWare.GetBlock("Content");

        blkTradeInner = eWare.GetBlock("Content");
        blkTradeInner.NewLine = false;
        blkTradeGrid=eWare.GetBlock("PRImportPACATradeGrid");
        blkTradeGrid.DisplayForm = false;
        blkTradeGrid.NewLine = false;

        blkPrincipalInner.contents = blkPrincipalGrid.Execute("prip_LicenseNumber='" + pril_record.pril_LicenseNumber+"'");
        blkTradeInner.contents = blkTradeGrid.Execute("prit_LicenseNumber='" + pril_record.pril_LicenseNumber+"'");

        BottomContainer.AddBlock(blkPrincipalInner);
        BottomContainer.AddBlock(blkTradeInner);
            
        blkContainer.AddBlock(BottomContainer);
	}
	    
    Response.Write("<script type=\"text/javascript\" src=\"../PRTransaction/PRTransactionInclude.js\"></script>");
	var sCheckDupUrl = eWare.URL("PRCompany/PRCompanyNew_CheckDup.asp") + "&companyname=" 
	
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"save();"));

	fvalue = getIdValue("F");
    var cancelURL = null;
    if (isBBOSSource) {    
        cancelURL = eWare.Url("PROpportunity/PROpportunitySummary.asp");
    } else  if (isPACASource) {
        cancelURL = eWare.Url("PRPACALicense/PRImportPACALicenseSummary.asp") + "&pril_ImportPACALicenseId=" + pril_ImportPACALicenseId;
	} else if (isEmpty(fvalue) || fvalue == "-1") {
	    cancelURL = eWare.Url(130);
    } else {
        cancelURL = eWare.Url(fvalue) + "&comp_companyid=" + comp_companyid;	    
    }
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", cancelURL));

	eWare.AddContent(blkContainer.Execute());
	Response.Write(eWare.GetPage("New"));
    Response.Write(sImportLicenseTD);
    
%>
<!-- #include file="CompanyFooters.asp" -->
    <script type="text/javascript">
        var sCheckDupUrl = '';
        var bSaveInProgress = false;

        function save()
        {
            var sCompanyName = new String(document.getElementById("_HIDDENcomp_name").value);
            if (sCompanyName.length == 0) {
                return true;
            }

            var regexp = new RegExp("&", "gi");
            sCompanyName = sCompanyName.replace(regexp, "%26");

            //Check for dup
            xmlHttp = new XMLHttpRequest();
            xmlHttp.onreadystatechange = SetDupCompanyNameCheck;
            xmlHttp.open("GET", "/CRM/CustomPages/ajaxhelper.asmx/DoesCompanyExist?companyName=" + sCompanyName, true);
            xmlHttp.send();

            return false;
        }

        function SetDupCompanyNameCheck() {
            if (xmlHttp.readyState == 4) {
                if (xmlHttp.responseXML != null) {
                    var result = $(xmlHttp.responseText)[2].innerText;
                    var bConfirm = false;

                    if (result == "true") {
                        bConfirm = confirm("A company with an identical tradestyle name exists.  Do you want to save this record anyway?");
                    }
                    else {
                        bConfirm = true;
                    }

                    if (bConfirm) {
                        if (bSaveInProgress)
                            return false; //prevent double-click
                        else {
                            if (validate() && validateTransaction()) {
                                bSaveInProgress = true;
                                document.EntryForm.submit();
                            }
                        }
                    }
                }
            }
        } 

        function initBBSI() 
        {
            <% Response.Write(sCloseTrxDraw ) %>
            <% Response.Write(sImportLicenseDraw ) %>
                
            document.getElementById("prtx_effectivedate").value = getDateAsString();

            initPerfectAddressAutoRefresh();

            <% Response.Write("sCheckDupUrl = '" + eWare.URL("PRCompany/PRCompanyNew_CheckDup.asp") + "&companyname=';"); %>


            $('form').keypress(function (event) {

                var keycode = (event.keyCode ? event.keyCode : event.which);
                if ((keycode == '13') &&
                    (event.srcElement.type != 'textarea'))  {
                    saveNew();
                    event.preventDefault();
                    event.cancelBubble = true;
                    event.returnValue = false;
                    return false;
                }

            });

<% if (comp_prtype == "B") {
                var hqCompany = eWare.FindRecord("Company", "comp_CompanyID=" +  comp_companyid);
%>
              setTradestyles("<% =hqCompany.comp_PRTradestyle1 %>","<% =hqCompany.comp_PRTradestyle2 %>","<% =hqCompany.comp_PRTradestyle3 %>","<% =hqCompany.comp_PRTradestyle4 %>");
<%  } %>
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }

        function setTradestyles(tradestyle1, tradestyle2, tradestyle3, tradestyle4) {
            if (confirm("Should this branch's tradestyles match the HQ's tradestyles?")) {
                document.getElementById("comp_prtradestyle1").value = tradestyle1;
                document.getElementById("comp_prtradestyle2").value = tradestyle2;
                document.getElementById("comp_prtradestyle3").value = tradestyle3;
                document.getElementById("comp_prtradestyle4").value = tradestyle4;
                UpdateTradestyles();
                
            }
        }
    </script>
<%
}

function checkforDupByPhone(phoneNumber) {

    if (isEmpty(phoneNumber)) {
        return "";
    }

    var phoneRec = eWare.FindRecord("vPRCompanyPhone", "phon_PhoneMatch = dbo.ufn_GetLowerAlpha('" + phoneNumber + "')");
    if (!phoneRec.eof) {
        return "Found an existing company record with the PACA license phone number: <a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + phoneRec("plink_RecordID") + "\">BBID " + phoneRec("plink_RecordID") + "</a>";
    }

    return "";
}
%>

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Reporter Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/


	//DumpFormValues();
	var sJS = "<script type=\"text/javascript\">";
	sJS += "var szUnconfirmed = 'N';";
    sJS += "var szLocalSource = 'N';";
	sJS += "document.onkeydown = function() { ";
    sJS += "      return submitOnEnter(event) ";
    sJS += "}; ";

    sJS += "function submitOnEnter(e) { ";
    sJS += "  if( !e ) { ";
    sJS += "    e = window.event; ";
    sJS += "  } ";

    sJS += "  e = e.keyCode; ";
    sJS += "  if(e==13) { ";
    sJS += "     document.EntryForm.submit(); ";
    sJS += "     return false; ";
    sJS += "  } ";
    sJS += "} ";
	
	
	sJS += "</script>";
    Response.Write(sJS); 
	
	// By default the eWare mode is View.
	// We want it to be Edit so that when the
	// user click's Find, it is incremented to 
	// Find.
	if (eWare.Mode == View) {
	    eWare.Mode = Edit;
	}
	
	
    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkSearchBox = eWare.GetBlock("CompanyAdvancedSearchBox");
	blkSearchBox.Title = "Company Advanced Search";

	var enField = blkSearchBox.GetEntry("comp_name");
    enField.Caption = "All Company Names:";
	
	var enField = blkSearchBox.GetEntry("prdr_LicenseNumber");
    enField.Caption = "DRC License Number:";
    
    blkSearchBox.AddButton(eWare.Button("Find", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkSearchBox.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

	blkContainer.AddBlock(blkSearchBox);

    // Don't display any results unless we're
    // actively searching
    if (eWare.Mode == 2) {
    
        var szCompanyName = GetStringForQuery(Request("comp_name"), "DEFAULT", true);
        var szCompanyType = GetStringForQuery(Request("comp_PRType"), "DEFAULT", true);
        var szCompanyListingStatus = GetStringForQuery(Request("comp_PRListingStatus"), "DEFAULT", true);
        var szPhoneAreaCode = GetStringForQuery(Request("phon_AreaCode"), "DEFAULT", true);
        var szPhoneNumber = GetStringForQuery(Request("phon_Number"), "DEFAULT", true);
        var szCityID = GetIntForQuery(Request("comp_PRListingCityId"), "DEFAULT", true);
        var szStateID = GetIntForQuery(Request("prst_StateID"), "DEFAULT", true);
        var szEmail = GetStringForQuery(Request("emai_EmailAddress"), "DEFAULT", true);
        var szDRCLicenseNumber = GetStringForQuery(Request("prdr_LicenseNumber"), "DEFAULT", true);
        var szBrand = GetStringForQuery(Request("prc3_Brand"), "DEFAULT", true);
        var szMasterInvoiceNo = GetStringForQuery(Request("UDF_MASTER_INVOICE"), "DEFAULT", true);
        var szAddress1 = GetStringForQuery(Request("Addr_Address1"), "DEFAULT", true);

        var ssUnconfirmedRaw = getFormValue("comp_prunconfirmed");
        switch (ssUnconfirmedRaw) {
            case "Checked":
                szUnconfirmed = "'Y'";
                break;
            case "NotChecked":
                szUnconfirmed = "'N'";
                break;
            case "Either":
                szUnconfirmed = "DEFAULT";
                break;
        }

        var szLocalSourceRaw = getFormValue("comp_prlocalsource");
        switch (szLocalSourceRaw) {
            case "Checked":
                szLocalSource = "'Y'";
                break;
            case "NotChecked":
                szLocalSource = "'N'";
                break;
            case "Either":
                szLocalSource = "DEFAULT";
                break;
        }

        var szIndustryType = GetStringForQuery(Request("comp_prindustrytype"), "DEFAULT", true);
        var szCompanyID = GetStringForQuery(Request("comp_companyid"), "DEFAULT", true);
        
        var szLegalNameOnly = GetStringForQuery(Request("legalnameonly"), "DEFAULT", true);

        Response.Write("<script type=\"text/javascript\">var szUnconfirmed = '" + ssUnconfirmedRaw + "';</script>"); 
        Response.Write("<script type=\"text/javascript\">var szLocalSource = '" + szLocalSourceRaw + "';</script>"); 

        //
        //  Starting with Sage CRM 7.2, the clause "WITH (NOLOCK)" was being appended to this
        //  query, which resulting in a SQL syntax error.  Couldn't figure out how to tell CRM
        //  to not do that.  Had to join to a simple view to work around the problem.
        //
        var szSQL = "SELECT cas.* FROM dbo.ufn_CompanyAdvancedSearch(" + szCompanyName + 
                                                            ", " + szCompanyType + 
                                                            ", " + szCompanyListingStatus + 
                                                            ", " + szPhoneAreaCode + 
                                                            ", " + szPhoneNumber + 
                                                            ", " + szCityID + 
                                                            ", " + szStateID + 
                                                            ", " + szEmail + 
                                                            ", " + szDRCLicenseNumber + 
                                                            ", " + szBrand +
                                                            ", " + szUnconfirmed + 
                                                            ", " + szIndustryType + 
                                                            ", " + szCompanyID + 
                                                            ", " + szMasterInvoiceNo +
                                                            ", " + szLegalNameOnly +
                                                            ", " + szLocalSource +
                                                            ", " + szAddress1 +
                                                            ") cas INNER JOIN vPRCompanyID ON comp_CompanyID = CompanyID";
    
        var qry = eWare.CreateQueryObj(szSQL);
        blkSearchResults = eWare.GetBlock("CompanyGrid");
        blkSearchResults.SelectSQL = szSQL;
        //blkSearchResults.ArgObj = qry;
	    blkContainer.AddBlock(blkSearchResults);
	}
	
	eWare.AddContent(blkContainer.Execute());
	Response.Write(eWare.GetPage('Find'));

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>	
<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at infovar sztravant.com.
 

***********************************************************************
***********************************************************************/

	//DumpFormValues();
    Response.Write("<script type=\"text/javascript\">var szUnconfirmed = 'N';var szDeceased = '';</script>"); 
	
	// By default the eWare mode is View.
	// We want it to be Edit so that when the
	// user click's Find, it is incremented to 
	// Find.
	if (eWare.Mode == View) {
	    eWare.Mode = Edit;
	}
	
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    blkSearchBox = eWare.GetBlock("PersonAdvancedSearchBox");
	blkSearchBox.Title = "Person Advanced Search";

    blkSearchBox.AddButton(eWare.Button("Find", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkSearchBox.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

	blkContainer.AddBlock(blkSearchBox);

    // Don't display any results unless we're
    // actively searching
    if (eWare.Mode == 2) {
    
        var szFirstName = GetStringForQuery(Request("pers_FirstName"), "DEFAULT", true);
        var szLastName = GetStringForQuery(Request("pers_LastName"), "DEFAULT", true);
        var szMiddleName = GetStringForQuery(Request("pers_MiddleName"), "DEFAULT", true);
        var szMaidenName = GetStringForQuery(Request("pers_PRMaidenName"), "DEFAULT", true);
        var szPhoneAreaCode = GetStringForQuery(Request("phon_AreaCode"), "DEFAULT", true);
        var szPhoneNumber = GetStringForQuery(Request("phon_Number"), "DEFAULT", true);
        var szCityID = GetIntForQuery(Request("prci_CityID"), "DEFAULT", true);
        var szStateID = GetIntForQuery(Request("prst_StateID"), "DEFAULT", true);
        var szIndustryType = GetStringForQuery(Request("comp_PRIndustryType"), "DEFAULT", true);
        var szNickName = GetStringForQuery(Request("pers_PRNickname1"), "DEFAULT", true);

        var ssUnconfirmedRaw = getFormValue("pers_prunconfirmed");
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

        var szDeceasedRaw = getFormValue("_DeceasedSearch");
        switch (szDeceasedRaw) {
            case "Checked":
                szDeceased = "'Y'";
                break;
            case "NotChecked":
                szDeceased = "'N'";
                break;
            case "Either":
                szDeceased = "DEFAULT";
                break;
        }

        var szLocalSourceRaw = getFormValue("pers_prlocalsource");
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


        var szEmailAddress = GetStringForQuery(Request("emai_EmailAddress"), "DEFAULT", true);
        Response.Write("<script type=\"text/javascript\">var szUnconfirmed = '" + ssUnconfirmedRaw + "';var szDeceased = '" + szDeceasedRaw + "';</script>"); 
    
        //
        //  Starting with Sage CRM 7.2, the clause "WITH (NOLOCK)" was being appended to this
        //  query, which resulting in a SQL syntax error.  Couldn't figure out how to tell CRM
        //  to not do that.  Had to join to a simple view to work around the problem.
        //
        szSQL = "SELECT pas.* FROM dbo.ufn_PersonAdvancedSearch(" + szFirstName + 
                                                            ", " + szLastName + 
                                                            ", " + szMaidenName + 
                                                            ", " + szPhoneAreaCode + 
                                                            ", " + szPhoneNumber + 
                                                            ", " + szCityID + 
                                                            ", " + szStateID +
                                                            ", " + szUnconfirmed + 
                                                            ", " + szEmailAddress + 
                                                            ", " + szIndustryType + 
                                                            ", " + szNickName + 
                                                            ", " + szDeceased + 
                                                            ", " + szLocalSource +
                                                            ", " + szMiddleName + ") pas LEFT OUTER JOIN vPRCompanyID ON comp_CompanyID = CompanyID";
    
        //Response.Write(szSQL);
        blkSearchResults = eWare.GetBlock("PersonAdvancedSearchGrid");
        blkSearchResults.SelectSQL = szSQL;
	    blkContainer.AddBlock(blkSearchResults);
	}
	
	eWare.AddContent(blkContainer.Execute());
	Response.Write(eWare.GetPage('Find'));

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>	
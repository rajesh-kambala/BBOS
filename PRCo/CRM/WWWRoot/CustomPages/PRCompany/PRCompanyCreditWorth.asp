<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2017

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="CompanyHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,10,18";
    //DumpFormValues();
    //DEBUG("<br>nMode: " + eWare.Mode);
    if (eWare.Mode == View)
        eWare.Mode = Edit;
    blkEntry=eWare.GetBlock("PRCreditWorthCap");
    blkEntry.Title="Credit Worth Cap";

    sListingAction = eWare.Url("PRCompany/PRCompanyRatingListing.asp")+ "&comp_CompanyId=" + comp_companyid;

    if (eWare.Mode == Save) {
        recCompany.comp_PRCreditWorthCap = Request("comp_PRCreditWorthCap");
        recCompany.comp_PRCreditWorthCapReason = Request("comp_PRCreditWorthCapReason");

        if (recCompany.comp_PRIndustryType == "L") {        
            recCompInfoProfile = eWare.FindRecord("PRCompanyInfoProfile","prc5_CompanyId=" + comp_companyid);
            if (recCompInfoProfile.eof) {
                recCompInfoProfile = eWare.CreateRecord("PRCompanyInfoProfile");
                recCompInfoProfile.prc5_CompanyId = comp_companyid;
            }
            
            recCompInfoProfile.prc5_RedbookRating = Request("prc5_RedbookRating");
            recCompInfoProfile.SaveChanges();
            
            if (getFormValue("comp_prpublishpayindicator") == "on") {
                recCompany.comp_PRPublishPayIndicator = "Y";
            } else {
                recCompany.comp_PRPublishPayIndicator = "";
            }
        }

        recCompany.SaveChanges();
        Response.Redirect(sListingAction);
    }
    
    
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit)
    {
        sInsertString = "<TABLE><TR><TD ID=tdCreditWorthCap valign=top>"
        sInsertString = sInsertString + "<SPAN ID=_Captcomp_prcreditworthcap class=VIEWBOXCAPTION>Credit Worth Cap:</SPAN><br>"
        sInsertString = sInsertString + "<INPUT TYPE=HIDDEN NAME=\"_HIDDENcomp_prcreditworthcap\">" + 
                        "<SELECT CLASS=EDIT SIZE=1 NAME=\"comp_prcreditworthcap\">" + 
                        "<OPTION VALUE=\"\" SELECTED >--None--</OPTION> ";

        sSQL = "SELECT prcw_CreditWorthRatingId, prcw_Name " +
                 "FROM PRCreditWorthRating WITH (NOLOCK) " + 
                "WHERE prcw_IsNumeral IS NULL " + 
                 " AND prcw_IndustryType LIKE '%," + recCompany.comp_PRIndustryType + "%' " +
             "ORDER BY prcw_Order";
        recCWR = eWare.CreateQueryObj(sSQL,"");
        recCWR.SelectSQL();
        while (!recCWR.eof)
        {
            sSelected = "";
            if (Defined(recCompany) && !recCompany.eof)
            {
                if (recCompany.comp_PRCreditWorthCap == recCWR("prcw_CreditWorthRatingId"))
                    sSelected = "SELECTED ";
            }
            sInsertString = sInsertString + "<OPTION " + sSelected + "VALUE=\""+ recCWR("prcw_CreditWorthRatingId") + "\" >" + recCWR("prcw_Name") + "</OPTION> ";

            recCWR.NextRecord();
        }
    
        sInsertString = sInsertString + "</SELECT></SPAN>";
        sInsertString = sInsertString + "</TD></TR></TABLE>";
        
        Response.Write(sInsertString);
        
        sInsertString = "AppendCell(\"_Captcomp_prcreditworthcapreason\", \"tdCreditWorthCap\", true);"; 

    
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        if (isUserInGroup(sSecurityGroups))
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));


        blkEntry.ArgObj = recCompany;
        blkContainer.CheckLocks = false;
        blkContainer.AddBlock(blkEntry);
        
        if (recCompany.comp_PRIndustryType == "L") {
            blkRB = eWare.GetBlock("PRCompanyInfoProfileRedbook");
            blkRB.Title = "Redbook Rating";
            recCompInfoProfile = eWare.FindRecord("PRCompanyInfoProfile","prc5_CompanyId=" + comp_companyid);
            blkRB.ArgObj = recCompInfoProfile;
            blkContainer.AddBlock(blkRB);
            
            var blkPayIndicator = eWare.GetBlock("PRPayIndicator");
            blkPayIndicator.Title = "Pay Indicator";
            var recCompany2 = eWare.FindRecord("Company","comp_CompanyID=" + comp_companyid);
            blkPayIndicator.ArgObj = recCompany2;
            blkContainer.AddBlock(blkPayIndicator);            
        }        
        
            
        eWare.AddContent(blkContainer.Execute());

        //DEBUG("<br>nMode: " + eWare.Mode);
        if (eWare.Mode == Edit) 
        {
            // hide the tabs
            Response.Write(eWare.GetPage('Company'));
        }
        else
	        Response.Redirect(sListingAction);
    	    

        Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI()"); 
        Response.Write("\n    { ");
        
        if (sInsertString.length > 0) {
            Response.Write("\n    " + sInsertString);
        }
        
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
%>

<!-- #include file="CompanyFooters.asp" -->

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="PRCompanyTradeInclude.asp" --> 

<!-- #include file ="..\AccpacScreenObjects.asp" -->

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
    var sSecurityGroups = "1,2,3,4,5,6,8,9,10";

    if (eWare.Mode == Clear) {
        Session("TradeReportListing_CompanyID") = 0;
        var sNewURL = changeKey(sURL, "em", "2");
        Response.Redirect(sNewURL);
    }


    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkTradeReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing trade reports BY " + recCompany("comp_Name") + "</td></tr></table> ";
    blkTradeReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkTradeReportHeader);

    if (eWare.Mode == View || eWare.Mode == Find)
    {
        //DumpFormValues();
        
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyTradeReportInclude.js\"></script>");

        eWare.Mode = Edit;
        //blkFilter is created in PRCompanyTradeInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        sWhere = "prtr_responderid="+comp_companyid ;
        if (!isEmpty(sFormStartDate))
            sWhere += " AND prtr_Date >= " + sDBStartDate;
        if (!isEmpty(sFormEndDate))
            sWhere += " AND prtr_Date <= " + sDBEndDate;
        if (sDBException != "NULL")
        {
            if (sDBException == "Y")
                sWhere += " AND prtr_Exception = '" + sDBException + "'";
            else
                sWhere += " AND prtr_Exception is NULL ";
        }        
        if (sDBDisputeInvolved != "NULL")
        {
            if (sDBDisputeInvolved == "Y")
                sWhere += " AND prtr_DisputeInvolved = '" + sDBDisputeInvolved + "'";
            else
                sWhere += " AND prtr_DisputeInvolved  is NULL ";
        }        
        if (sDBDuplicate != "")
        {
            if (sDBDuplicate == "Y")
                sWhere += " AND prtr_Duplicate = 'Y' ";
            else
                sWhere += " AND (prtr_Duplicate IS NULL or prtr_Duplicate = 'N') ";
        }        
        if (sDBClassListForInClause != "")
        {
            sWhere += " AND " +
             " prtr_SubjectId in " +
             " (select distinct prtr_SubjectId from  " +
             "    (select prtr_SubjectId, highest_level = Left(prcl_Path, charindex(',',prcl_Path)-1) " + 
             "     from PRTradeReport " + 
	         "     LEFT OUTER JOIN PRCompanyClassification ON prc2_CompanyId = prtr_SubjectId " +
	         "     LEFT OUTER JOIN PRClassification ON prc2_ClassificationId = prcl_classificationId " +
             "     where prtr_ResponderId = " + comp_companyid + " ) ATable " +
             "  WHERE highest_level in (" + sDBClassListForInClause + ") " +
             " ) " ;
        }
        recTradeReports = eWare.FindRecord("vPRTradeReportBy", sWhere);

        // add the listing block
        blkList = eWare.GetBlock("PRTradeReportByGrid");
        blkList.ArgObj = recTradeReports;
        entry=blkList.GetGridCol("prtr_Date");
        entry.OrderByDesc = true;
        blkContainer.AddBlock(blkList);    


        // Show the buttons
        sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        
        // Causes the PRCompanyTradeReport page to blow up.  The users haven't noticed
        // so just removing the button for now since it clearly isn't used.
        //if (isUserInGroup(sSecurityGroups))
        //{
        //    sNewUrl = eWare.URL("PRCompany/PRCompanyTradeReport.asp") + "&prtr_ResponderId=" + comp_companyid;
        //    blkContainer.AddButton(eWare.Button("New Trade Report", "new.gif", sNewUrl));
        //}
        
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
	    Response.Write("\n<table><tr id=tr_tblSearchClassOptions><TD colspan=3 ROWSPAN=8 ALIGN=LEFT ID=\"td_tblSearchClassOptions\">" + sSearchClassContent + "</td></tr></table>");
	    Response.Write("\n<table><tr><td ALIGN=LEFT VALIGN=TOP ID=\"td_tblSearchDateRange\">" + szDateRange + "</td></tr></table>");
        Response.Write(szDuplicateSelect);
    %>
        <script type="text/javascript">
            function initBBSI() 
            {
                // remove this option in lieu of the existing Date Range: option which users really like
                RemoveDropdownItemByName("DateTimeModesprtr_date", "Relative");
                RemoveDropdownItemByName("_exceptionselect", "--None--");
                RemoveDropdownItemByName("_disputeinvolvedselect", "--None--");
    <%            
                if (sDBException != "NULL")
                    Response.Write("SelectDropdownItemByValue('_ExceptionSelect', '" + sDBException + "');");

                if (sDBDisputeInvolved != "NULL")
                    Response.Write("SelectDropdownItemByValue('_DisputeInvolvedSelect', '"+  sDBDisputeInvolved + "');");

    %>
                AppendCell("_Captprtr_date", "td_tblSearchDateRange");
                AppendRow("_Captprtr_date", "tr_tblSearchClassOptions");
                AppendRow("_disputeinvolvedselect", "td_DuplicateSelect");

                toggleDateFieldsForRange();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>
    <%
    }
    %>
<!-- #include file="CompanyFooters.asp" -->

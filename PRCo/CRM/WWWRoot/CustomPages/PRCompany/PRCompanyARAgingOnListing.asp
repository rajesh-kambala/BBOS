<!-- #include file ="..\accpaccrm.js" -->
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
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = "3,4,10";

    // This needs to be defined prior to the following include.
    var sScreenType = "ARAgingOn";
    var isLumber = ((recCompany != null) ? (recCompany("comp_PRIndustryType") == "L") : false );    
    var jsException;
%>
<!-- #include file ="CompanyTradeActivityFilterInclude.asp" --> 
<%
    var sGridFilterWhereClause = "praad_SubjectCompanyId=" + comp_companyid;
    if (!isEmpty(sFormStartDate))
        sGridFilterWhereClause += " AND praa_Date >= " + sDBStartDate;
    if (!isEmpty(sFormEndDate))
        sGridFilterWhereClause += " AND praa_Date <= " + sDBEndDate;
    if (sDBException != "NULL")
        sGridFilterWhereClause += " AND ISNULL(praad_Exception, 'N') " + sDBException;
    if (sDBClassListForWhereClause != "")
        sGridFilterWhereClause += " AND " + sDBClassListForWhereClause;
    if (sResponderID != "")
        sGridFilterWhereClause += " AND praad_ReportingCompanyID = " + sResponderID;

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var blkReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing A/R Aging reports ON " + recCompany("comp_Name") + "</td></tr></table> ";
    blkReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkReportHeader);
    
    if (eWare.Mode == View || eWare.Mode == Find)
    {
        //DumpFormValues();
        
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

        eWare.Mode = Edit;
        //blkFilter is created in PRCompanyTradeInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        // add the listing block
        sWhere = sGridFilterWhereClause;
        var recViewResults = null;
        if (isLumber) {
            recViewResults = eWare.FindRecord("vPRARAgingDetailOnLumber", sWhere);
            blkList = eWare.GetBlock("PRARAgingOnLumberGrid");
        } else {
            recViewResults = eWare.FindRecord("vPRARAgingDetailOnProduce", sWhere);
            blkList = eWare.GetBlock("PRARAgingOnGrid");
        }

        blkList.GetGridCol("praa_Date").OrderByDesc = true;

        blkList.ArgObj = recViewResults;
        blkContainer.AddBlock(blkList);    

        // determine whether to show dollars or percents (dollars is the default)
        sColDisplay = "d";
        var colDisplay = new String(Request.QueryString("coldisplay"));
        if (!isEmpty(colDisplay))
            sColDisplay = colDisplay;
        
        var hidden_fields;
        if (sColDisplay == "d") {
            if (isLumber) {
                hidden_fields = [ "praad_AmountCurrentPercent", "praad_Amount1to30Percent", "praad_Amount31to60Percent", "praad_Amount61to90Percent", "praad_Amount91PlusPercent" ];
            } else {
                hidden_fields = [ "praad_Amount0to29Percent", "praad_Amount30to44Percent", "praad_Amount45to60Percent", "praad_Amount61PlusPercent"];
            }
        } else {
            if (isLumber) {
                hidden_fields = [ "praad_AmountCurrent", "praad_Amount1to30", "praad_Amount31to60", "praad_Amount61to90", "praad_Amount91Plus" ];
            } else {
                hidden_fields = [ "praad_Amount0to29", "praad_Amount30to44", "praad_Amount45to60", "praad_Amount61Plus" ];
            }
        }
        for (var i in hidden_fields)
        {
            blkList.DeleteGridCol(hidden_fields[i]);
        }

        // Show the buttons
        sContinueUrl = eWare.URL("PRCompany/PRCompanyTradeActivityListing.asp") + "&T=Company&Capt=Trade+Activity";
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        if (sColDisplay == "d")
        {
            sDollarPercentToggleUrl = changeKey(sURL, "coldisplay", "p");
            blkContainer.AddButton(eWare.Button("Display %", "recurr.gif", sDollarPercentToggleUrl));
        }
        else
        {
            sDollarPercentToggleUrl = changeKey(sURL, "coldisplay", "d");
            blkContainer.AddButton(eWare.Button("Display $", "recurr.gif", sDollarPercentToggleUrl));
        }
        
        //sNewUrl = eWare.URL("PRCompany/PRCompanyARAgingHeader.asp") + "&praa_CompanyId=" + comp_companyid;
        //blkContainer.AddButton(eWare.Button("New A/R Aging", "new.gif", sNewUrl));

        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage('Company'));
        
	    Response.Write("\n<table><TR ID=\"tr_tblSearchClassOptions\"><TD COLSPAN=6 ALIGN=LEFT ID=\"td_tblSearchClassOptions\">" + sSearchClassContent + "</TD></tr></table>");

        Response.Write("\n<script type=text/javascript >");
        Response.Write("\n    function initBBSI()");
        Response.Write("\n    {");
        Response.Write("\n        RemoveDropdownItemByName(\"DateTimeModesprtr_date\", \"Relative\");");
        //Response.Write("\n        document.all(\"_startdate\").value = \"" + sFormStartDate + "\";");
        //Response.Write("\n        document.all(\"_enddate\").value = \"" + sFormEndDate  + "\";");

        if (sDBException != "NULL")
            Response.Write(jsException);

        Response.Write("\n        AppendRow(\"prtr_date\", \"tr_tblSearchClassOptions\");");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
%>
<!-- #include file="CompanyFooters.asp" -->
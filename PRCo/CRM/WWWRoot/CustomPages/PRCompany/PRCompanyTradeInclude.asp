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
        
        if ((Session("TradeReportListing_CompanyID") != comp_companyid) ||
            (eWare.Mode == Clear)) {
            Session("TradeReportListing_DateRangeFilter") = null; 
            Session("TradeReportListing_prtr_date_start") = null;
            Session("TradeReportListing_prtr_date_end") = null;
            Session("TradeReportListing_disputeinvolvedselect") = null;   
            Session("TradeReportListing_ExceptionSelect") = null;   
            Session("TradeReportListing_DuplicateSelect") = null; 
            Session("TradeReportListing_DBClassificationList") = null;
            Session("TradeReportListing_DBClassListForInClause") = null;
            Session("TradeReportListing_comp_PRIndustryType") = null;   
            Session("TradeReportListing_cbMostRecentOnly") = null; 
        }

        Session("TradeReportListing_CompanyID") = comp_companyid;
        


        sUserDateFormat = "mm/dd/yyyy"; 
        var sDateRange = new String(Request.Form.Item("_DateRangeFilter") + "");
        
        if (Request.Form.Item("_FirstTime") != "N") {
            sDateRange = Session("TradeReportListing_DateRangeFilter");            
            if (sDateRange == null) {
                sDateRange = "3";        
            }    
        }        

        
        if ((sDateRange != "undefined") && (sDateRange.length > 0)) {
            dtToday = new Date(new Date().getTime() + 86400000);

            sFormEndDate = getDBDate2(dtToday);
            sDBEndDate = "'" + sFormEndDate + "'";
                  
            sFormStartDate = getDBDate2(new Date(dtToday.getYear(), dtToday.getMonth()- new Number(sDateRange), dtToday.getDate()));
            sDBStartDate = "'" + sFormStartDate + "'"; 
        
        } else {
            sDateRange = "";
            
            // get the form variables that may or may not exist
            sDBStartDate = "NULL";
            sFormStartDate = String(Request.Form.Item("prtr_date_start"));
            if (Request.Form.Item("_FirstTime") != "N") {
                sFormStartDate = Session("TradeReportListing_prtr_date_start");
            }

            if (sFormStartDate == null || isEmpty(sFormStartDate) || sFormStartDate == "0") {
                sFormStartDate = "";
            } else {
                // call the PRCoGeneral.asp function for help getting the db date format
                sDBStartDate = "'" + getDBDate(sFormStartDate, sUserDateFormat) + "'";
            }
        


            sDBEndDate = "NULL";
            sFormEndDate = String(Request.Form.Item("prtr_date_end"));
            if (Request.Form.Item("_FirstTime") != "N") {
                sFormEndDate = Session("TradeReportListing_prtr_date_end");
            }

            if (sFormEndDate == null || isEmpty(sFormEndDate) || sFormEndDate == "0") {
                sFormEndDate = "";
            } else {
                sDBEndDate = "'" + getDBDate(sFormEndDate, sUserDateFormat) + " 23:59:59'";
            }
        }

        Session("TradeReportListing_DateRangeFilter") = sDateRange;
        Session("TradeReportListing_prtr_date_start") = sFormStartDate;
        Session("TradeReportListing_prtr_date_end") = sFormEndDate;        



        sDBDisputeInvolved = "NULL";
        sFormDisputeInvolved = String(Request.Form.Item("_disputeinvolvedselect"));
        if (Request.Form.Item("_FirstTime") != "N") {
            sFormDisputeInvolved = Session("TradeReportListing_disputeinvolvedselect");
        }

        if (!isEmpty(sFormDisputeInvolved))
        {
            sDBDisputeInvolved = sFormDisputeInvolved ; 
        }

        sDBException = "NULL";
        sFormException = String(Request.Form.Item("_ExceptionSelect"));
        if (Request.Form.Item("_FirstTime") != "N") {
            sFormException = Session("TradeReportListing_ExceptionSelect");
        }

        if (!isEmpty(sFormException))
        {
            sDBException = sFormException ; 
        }
        
        sFormDuplicate = String(Request.Form.Item("_DuplicateSelect"));
        if (Request.Form.Item("_FirstTime") != "N") {
            sFormDuplicate = Session("TradeReportListing_DuplicateSelect");
        }




        sDBDuplicate = "N";

        if (!isEmpty(sFormDuplicate))
            sDBDuplicate = sFormDuplicate;

	    szDuplicateSelect = "\n<table ID='tblDuplicateOptions' style='{display:none}' CELLPADDING=0 BORDER=0 align=left>";
        szDuplicateSelect += "\n <tr ID=tr_DuplicateSelect><td ID=td_DuplicateSelect width=\"33%\" ><span class=VIEWBOXCAPTION align=LEFT >Duplicate:</span><br/>";
        szDuplicateSelect += "\n <select class=EDIT name=_DuplicateSelect>";
        
        sSelected = "";
        if (sDBDuplicate == "Y") {
            sSelected=  " selected ";
        } 
        szDuplicateSelect += "\n      <option value=\"Y\" " + sSelected + ">Yes</option>";

        sSelected = "";
        if (sDBDuplicate == "N") {
            sSelected=  " selected ";
        }
        szDuplicateSelect += "\n      <option value=\"N\" " + sSelected + ">No</option>";

        sSelected = "";
        if (sDBDuplicate == "") {
            sSelected=  " selected ";
        }
        szDuplicateSelect += "\n      <option value=\"\" " + sSelected + ">--All--</option>";
        
        szDuplicateSelect += "\n</select>";
        szDuplicateSelect += "\n</td></tr></table>";
        
        Session("TradeReportListing_disputeinvolvedselect") = sFormDisputeInvolved;   
        Session("TradeReportListing_ExceptionSelect") = sFormException;   
        Session("TradeReportListing_DuplicateSelect") = sFormDuplicate;   


        // finally get the list of business type (classification) values 
        var sDBClassificationList = "";
        var sDBClassListForInClause = "";

        if (Request.Form.Item("_FirstTime") != "N") {
            if (!isEmpty(Session("TradeReportListing_DBClassificationList"))) {
                sDBClassificationList = Session("TradeReportListing_DBClassificationList");
            }

            if (!isEmpty(Session("TradeReportListing_DBClassListForInClause"))) {
                sDBClassListForInClause = Session("TradeReportListing_DBClassListForInClause");
            }
        }

        for (x = 1; x <= Request.Form.count(); x++) {
            sFieldName = String(Request.Form.Key(x));
            if (sFieldName.substr(0,10) == "chk_class_")
            {
                sClassAbbr = sFieldName.substr(10);
                sFieldValue = String(Request.Form.Item(x));
                if (sFieldValue == "on")
                {
                    if (sDBClassificationList != "")
                        sDBClassificationList += ",";
                    sDBClassificationList += sClassAbbr;
                    if (sDBClassListForInClause != "")
                        sDBClassListForInClause += ",";
                    sDBClassListForInClause += "'"+ sClassAbbr + "'";
                }    
            }
        }

        Session("TradeReportListing_DBClassificationList") = sDBClassificationList;
        Session("TradeReportListing_DBClassListForInClause") = sDBClassListForInClause;

        if (sDBClassificationList == "")
            sDBClassificationList = "NULL";
        else
            sDBClassificationList = "'" + sDBClassificationList + "'";
        
        

        
            
        blkFilter = eWare.GetBlock("PRTradeReportSearchBox");
        blkFilter.Title = "Filter By";
        
    /*** setting the form values like this does not work so we'll set it again in form load
        if (!isEmpty(sFormStartDate))
        {
            entry = blkFilter.getEntry("prtr_startdate");
            entry.DefaultValue = sFormStartDate;
        }
        if (!isEmpty(sFormEndDate))
        {
            entry = blkFilter.getEntry("prtr_enddate");
            entry.DefaultValue = sFormEndDate;
        }
    ***/
        
        // create an html table to hold the classification options.
        sSQL = "SELECT * FROM PRClassification WITH (NOLOCK) WHERE prcl_Level = 1"
        recClassification = eWare.CreateQueryObj(sSQL);
        recClassification.SelectSQL();

	    sSearchClassContent = "\n<table ID='tblSearchClassOptions' width=100% CELLPADDING=0 BORDER=0 align=left>";
        sSearchClassContent += "\n  <tr><td colspan=2 class=VIEWBOXCAPTION align=LEFT >Classifications:</td></tr>";
        while (!recClassification.eof)
        {
            sName = "chk_class_" + recClassification("prcl_ClassificationId") ; 
            sChecked = "";
            if (sDBClassificationList.indexOf(recClassification("prcl_ClassificationId")) > -1)
                sChecked = " checked ";
            sSearchClassContent += "\n  <tr>";
            sSearchClassContent += "\n    <td WIDTH=20 CLASS=VIEWBOXCAPTION ALIGN=LEFT ><input type=CHECKBOX " + sChecked+ " ID="+ sName + " NAME="+sName+"></td>"
                    +"<td CLASS=VIEWBOXCAPTION ALIGN=LEFT width=50% >" + recClassification("prcl_Name") + "</td>";
            recClassification.NextRecord();
            if (recClassification.eof)
            {
                sSearchClassContent += "\n  </tr>";
                break;
            }
            sName = "chk_class_" + recClassification("prcl_ClassificationId") ; 
            sChecked = "";
            if (sDBClassificationList.indexOf(recClassification("prcl_ClassificationId")) > -1)
                sChecked = " checked ";
            sSearchClassContent += "\n    <td WIDTH=20 CLASS=VIEWBOXCAPTION ALIGN=LEFT ><input type=CHECKBOX " + sChecked+ " ID="+ sName + " NAME="+sName+"></td>"
                    +"<td CLASS=VIEWBOXCAPTION ALIGN=LEFT width=50% >" + recClassification("prcl_Name") + "</td>";
            sSearchClassContent += "\n  </tr>";
            recClassification.NextRecord();
        }
        sSearchClassContent += "\n</table>";
        
	    szDateRange = "\n<table id=\"tblSearchClassOptions\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\" align=\"left\">";
        szDateRange += "\n  <tr><td valign=\"top\"><span class=\"VIEWBOXCAPTION\" align=\"left\" >Date Range:</span><br/><input type=hidden value=N name=_FirstTime>";
        szDateRange += "\n  <select class=\"EDIT\" name=\"_DateRangeFilter\" onchange=\"toggleDateFieldsForRange(false);\">";
        
        sSelected = "";
        if (sDateRange == "") {
            sSelected=  " selected ";
        } 
        szDateRange += "\n      <option value=\"\" " + sSelected + ">None</option>";

        sSelected = "";
        if (sDateRange == "3") {
            sSelected=  " selected ";
        }
        szDateRange += "\n      <option value=\"3\" " + sSelected + ">Past 3 Months</option>";

        sSelected = "";
        if (sDateRange == "6") {
            sSelected=  " selected ";
        }
        szDateRange += "\n      <option value=\"6\" " + sSelected + ">Past 6 Months</option>";
        
        sSelected = "";        
        if (sDateRange == "12") {
            sSelected=  " selected ";
        }
        szDateRange += "\n      <option value=\"12\" " + sSelected + ">Past 12 Months</option>";
        szDateRange += "\n</select>";
        szDateRange += "\n</td></tr></table>";
        
        sSelected = "";
        var sIncludeBranches =  String(Request.Form.Item("_cbIncludeBranches"));  // getValue(Request("_cbIncludeBranches"));
        if (Request.Form.Item("_FirstTime") != "N") {
            sIncludeBranches = Session("TradeReportListing_cbIncludeBranches");
        }

        //if (sIncludeBranches != "") {
        if (!isEmpty(sIncludeBranches)) {
            sSelected =  " CHECKED ";
        }

        Session("TradeReportListing_cbIncludeBranches") = sIncludeBranches;   

	    szIncludeBranches = "\n<TABLE ID='tblIncludeBranches' CELLSPACING=0 CELLPADDING=0 BORDER=0 align=left>";
        szIncludeBranches += "\n  <TR><TD ID=td_IncludeBranches><SPAN CLASS=VIEWBOXCAPTION ALIGN=LEFT ><input type=checkbox name=_cbIncludeBranches " + sSelected + ">Include Branches</SPAN>";
        szIncludeBranches += "\n</TD></TR></TABLE>";

        sSelected = "";
        var sMostRecentOnly = String(Request.Form.Item("_cbMostRecentOnly"));  //getValue(Request("_cbMostRecentOnly"));
        if (Request.Form.Item("_FirstTime") != "N") {
            sMostRecentOnly = Session("TradeReportListing_cbMostRecentOnly");
        }

        //if (sMostRecentOnly != "") {
        if (!isEmpty(sMostRecentOnly)) {
            sSelected =  " CHECKED ";
        }
        
	    szMostRecentOnly = "\n<TABLE ID='tblMostRecentOnly' CELLSPACING=0 CELLPADDING=0 BORDER=0 align=left>";
        szMostRecentOnly += "\n  <TR><TD ID=td_MostRecentOnly><SPAN CLASS=VIEWBOXCAPTION ALIGN=LEFT ><input type=checkbox name=_cbMostRecentOnly " + sSelected + ">Most Recent by Responder Only</SPAN>";
        szMostRecentOnly += "\n</TD></TR></TABLE>";
        Session("TradeReportListing_cbMostRecentOnly") = sMostRecentOnly;   
        
        sFilterAction = changeKey(sURL, "em", Find);
        blkFilter.AddButton(eWare.Button("Apply Filter", "search.gif", "javascript:document.EntryForm.action='"+sFilterAction+ "';document.EntryForm.submit();" ));
        
        sClearAction = changeKey(sURL, "em", Clear);
        blkFilter.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.action='"+sClearAction+ "';document.EntryForm.submit();"));

            
        var comp_PRIndustryType = getValue(Request("comp_prindustrytype"));   
        var tmpIndustryType = String(Request.Form.Item("comp_prindustrytype"));         
        if ((Request.Form.Item("_FirstTime") != "N") &&
            (!isEmpty(Session("TradeReportListing_comp_PRIndustryType")))) {
            comp_PRIndustryType = Session("TradeReportListing_comp_PRIndustryType");            
            tmpIndustryType = Session("TradeReportListing_comp_PRIndustryType");  
        }
        Session("TradeReportListing_comp_PRIndustryType") = tmpIndustryType;   
%>


<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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
    var praa_ARAgingid = getIdValue("praa_ARAgingId");

    //Defect 7023 - reset checked items to current
    sHdn_Chk = getFormValue("hdn_Chk");
    //Response.Write("hdn_Chk = " + sHdn_Chk);
    if (sHdn_Chk.length > 0 && sHdn_Chk != 'undefined') {
        var arr = [];
        arr = sHdn_Chk.split(",");
    
        Response.Write("<br>");
        for(i=0; i<arr.length; i++) {
            //Response.Write(arr[i] + " adjusted to Current<br>");
            adjustARToCurrent(arr[i]);
        }

        Response.Write("\n<script language=Javascript>\n ");
        Response.Write("    document.getElementById(\"hdn_Chk\").value = \"\"");
        Response.Write("\n</script>\n ");
    }

    if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRARAgingDetail WHERE praad_ARAgingId ="+ praa_ARAgingid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        sql = "DELETE FROM PRARAging WHERE praa_ARAgingId ="+ praa_ARAgingid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

	    Response.Redirect(eWare.URL("PRCompany/PRCompanyARAgingByListing.asp") + "&T=Company&Capt=Trade+Activity");
    }


    var startTime = new Date();

    Server.ScriptTimeout = 3600;
    var iCount = 0;
    var iMaxCount = 5000;
    var bBreak = false;

    var sWorkContent = "";

    var Content01 = "";
    var Content02 = "";
    var Content03 = "";
    var Content04 = "";
    var Content05 = "";
    var Content06 = "";
    var Content07 = "";
    var Content08 = "";
    var Content09 = "";
    var Content10 = "";
    var Content11 = "";
    var Content12 = "";
    var Content13 = "";
    var Content14 = "";
    var Content15 = "";
    var Content16 = "";
    var Content17 = "";
    var Content18 = "";
    var Content19 = "";
    var Content20 = "";
    var Content21 = "";
    var Content22 = "";
    var Content23 = "";
    var Content24 = "";
    var Content25 = "";
    var Content26 = "";
    var Content27 = "";
    var Content28 = "";
    var Content29 = "";
    var Content30 = "";

    var sSecurityGroups = "2,3,4,10";

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    var colDisplay = new String(Request.QueryString("coldisplay"));
    
    var detailView;
    var jsException;
    var isLumber = ((recCompany != null) ? (recCompany("comp_PRIndustryType") == "L") : false );
    var i, amountFields, totalAmountFields, pctFields, totalAmountPctFields, masterHeaderCaptions, detailHeaderCaptions, lineTotalField, linePctField;
    if (isLumber) {

        amountFields = [ "praad_AmountCurrent", "praad_Amount1to30", "praad_Amount31to60", "praad_Amount61to90", "praad_Amount91Plus", "praad_LineTotal2"  ];
        totalAmountFields = [ "praa_TotalCurrent", "praa_Total1to30", "praa_Total31to60", "praa_Total61to90", "praa_Total91Plus", "praa_Total"  ];
        pctFields = [  "praad_AmountCurrentPercent", "praad_Amount1to30Percent", "praad_Amount31to60Percent", "praad_Amount61to90Percent", "praad_Amount91PlusPercent", "praad_LinePercent2"];
        totalAmountPctFields = [ "praad_TotalAmountCurrentPercent", "praad_TotalAmount1to30Percent" , "praad_TotalAmount31to60Percent", "praad_TotalAmount61to90Percent", "praad_TotalAmount91PlusPercent"];
        masterHeaderCaptions = [ "Total Current", "Total 1-30", "Total 31-60", "Total 61-90", "Total 91+", "Total" ];
        detailHeaderCaptions = [ "Current", "1-30", "31-60", "61-90", "91+" ]

        lineTotalField = "praad_LineTotal2";
        linePctField = "praad_LinePercent2";

        if ( colDisplay == "p" ) {
            detailView = "vPRLumberARAgingDetailBy_PERC";
        } else {
            detailView = "vPRLumberARAgingDetailBy_DOLL";
        }

    } else {
        amountFields = [ "praad_Amount0to29", "praad_Amount30to44", "praad_Amount45to60", "praad_Amount61Plus", "praad_LineTotal" ];
        //totalAmountFields = [ "praad_TotalAmount", "praad_TotalAmount0to29", "praad_TotalAmount30to44", "praad_TotalAmount45to60", "praad_TotalAmount61Plus" ];
        totalAmountFields = [ "praa_Total", "praa_Total0to29", "praa_Total30to44", "praa_Total45to60", "praa_Total61Plus" ];
        pctFields = ["praad_Amount0to29Percent", "praad_Amount30to44Percent", "praad_Amount45to60Percent", "praad_Amount61PlusPercent", "praad_LinePercent"  ];
        totalAmountPctFields = [ "praad_TotalAmount0to29Percent", "praad_TotalAmount30to44Percent", "praad_TotalAmount45to60Percent", "praad_TotalAmount61PlusPercent" ];
        masterHeaderCaptions = [ "Total", "Total 0-29", "Total 30-44", "Total 45-60", "Total 61+" ];
        detailHeaderCaptions = [ "0-29", "30-44", "45-60", "61+" ]
        lineTotalField = "praad_LineTotal";
        linePctField = "praad_LinePercent";

       
        if ( colDisplay == "p" ) {
            detailView = "vPRProduceARAgingDetailBy_PERC";
        } else {
            detailView = "vPRProduceARAgingDetailBy_DOLL";
        }        
    }

    
    if (eWare.Mode != View)
    {
        eWare.Mode = View;
    }

    recARAging = eWare.FindRecord("PRARAging", "praa_ARAgingId=" + praa_ARAgingid);
        
        
    Response.Write("<script type=\"text/javascript\" src=\"CompanyARAgingInclude.js\"></script>");
    //DumpFormValues();
    // This needs to be defined prior to the following include.
    sScreenType = "ARAgingOn";
%>
<!-- #include file ="CompanyTradeActivityFilterInclude.asp" --> 


<%
    var sGridFilterWhereClause = "praa_ARAgingId =" + praa_ARAgingid;
    if (!isEmpty(sFormStartDate))
        sGridFilterWhereClause += " AND praa_Date >= " + sDBStartDate;
    if (!isEmpty(sFormEndDate))
        sGridFilterWhereClause += " AND praa_Date <= " + sDBEndDate;
    if (sDBException != "NULL")
        sGridFilterWhereClause += " AND ISNULL(praad_Exception, 'N')  " + sDBException;
    if (sDBClassListForWhereClause != "")
        sGridFilterWhereClause += " AND " + sDBClassListForWhereClause;

    var blkReportHeader = eWare.GetBlock('content');
    var sMsg = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You are currently viewing A/R Aging Report Details BY " + recCompany("comp_Name") + "</td></tr></table> ";
    blkReportHeader.contents = sMsg;
    blkContainer.AddBlock(blkReportHeader);


    //blkFilter is created in PRCompanyTradeInclude.asp
    blkFilter.Width = "95%";
    blkContainer.AddBlock(blkFilter);    
        
    sWhere = sGridFilterWhereClause;

    recViewResults = eWare.FindRecord(detailView, sWhere);

    sHiddenOrderBy = "praad_ARAgingDetailId";
    sHiddenOrderByDesc = "FALSE";
    sTemp = String(Request.Form.Item("PRCoHIDDENORDERBY"));
    if (!isEmpty(sTemp))
        sHiddenOrderBy = sTemp;
    sTemp = String(Request.Form.Item("PRCoHIDDENORDERBYDESC"));
    if (!isEmpty(sTemp))
        sHiddenOrderByDesc = sTemp;
        

    sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/up.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";

    if (sHiddenOrderBy != "")
    {
        if (sHiddenOrderByDesc == "FALSE")
        {
            recViewResults.OrderBy = sHiddenOrderBy;
            sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/up.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
        } else {
            recViewResults.OrderBy = sHiddenOrderBy + " DESC";
            sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/down.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
        }
    }
 

    // determine whether to show dollars or percents (dollars is the default)
    sColDisplay = "d";
    if (!isEmpty(colDisplay))
        sColDisplay = colDisplay;

    // Create the header information from an accpac es block
    blkHeader = eWare.GetBlock("PRARAgingNewEntry");
    blkHeader.DisplayButton(Button_Default) = false;
    recHeader = eWare.FindRecord("PRARAging", "praa_ARAgingId=" + praa_ARAgingid);
    bManuallyEntered = false;
    if (recHeader("praa_ManualEntry") == "Y")
        bManuallyEntered = true;
            
    blkHeader.ArgObj = recHeader;
    sHeaderContent = blkHeader.Execute();

    // REMOVE THE ORIGINAL FORM CONTROL.
    sHeaderContent = sHeaderContent.replace("<FORM METHOD=\"POST\" NAME=\"EntryForm\">", "");
    sHeaderContent = sHeaderContent.replace("<INPUT TYPE=\"HIDDEN\" NAME=\"em\" VALUE=\"1\">", "");
    sHeaderContent = sHeaderContent.replace("</FORM>", "");

    blkARAgingTotals = eWare.GetBlock("content");

    // do not rename the ARAgingTotals table below; the javascript function that 
    // hides and shows this block looks for that name.
    sTotalsContent = createAccpacBlockHeader("ARAgingTotals", "A/R Aging Header");
    sTotalsContent += "\n" + sHeaderContent + "\n";

    //Response.Write("<pre>")
    //Response.Write(sHeaderContent)
    //Response.Write("</pre>")

    // add the totals if detail records exist
    if (recViewResults.RecordCount > 0)
    {
            
        sTotalsContent = sTotalsContent + "\n    <table class=\"CONTENT\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\" width=\"100%\">";
            
        sClass="ROW1";
        sTotalsContent = sTotalsContent + "\n        <tr>";
        sTotalsContent = sTotalsContent + "\n            <td  class=\"GRIDHEAD\" WIDTH=25>&nbsp;</td>";
        for (i in masterHeaderCaptions) {
            sTotalsContent = sTotalsContent + "\n            <td  class=\"GRIDHEAD\" align=\"center\" WIDTH=100>" + masterHeaderCaptions[i] + "</td>";
        }
        sTotalsContent = sTotalsContent + "\n        </tr>";
        sTotalsContent = sTotalsContent + "\n        <tr>";
        sTotalsContent = sTotalsContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >$'s</td> ";
        for (i in totalAmountFields) {
            sTotalsContent = sTotalsContent + "\n            <td align=\"right\" class=\"" + sClass + "\" >" + formatDollar(recViewResults(totalAmountFields[i])) + "</td> ";
        }
        sTotalsContent = sTotalsContent + "\n        </tr>";

        if ( colDisplay == "p" ) {
            sClass="ROW2";
            sTotalsContent = sTotalsContent + "\n        <tr>";
            sTotalsContent = sTotalsContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >%'s</td>";
            sTotalsContent = sTotalsContent + "\n            <td align=\"right\" class=\"" + sClass + "\" >&nbsp;</td> ";
            for (i in totalAmountPctFields) {
                sTotalsContent = sTotalsContent + "\n            <td align=\"right\" class=\"" + sClass + "\" >" + formatPrec(recViewResults(totalAmountPctFields[i])) + "</td> ";
            }            
                
            sTotalsContent = sTotalsContent + "\n        </tr>";
        }
        sTotalsContent = sTotalsContent + "\n</TABLE>";

    }
    sTotalsContent = sTotalsContent + createAccpacBlockFooter();
    blkARAgingTotals.Contents=sTotalsContent;
    blkContainer.AddBlock(blkARAgingTotals);    

    // create variable to quickly jump from $ to %
    sColHeaderStr = "$";
    // determine whether to show dollars or percents (dollars is the default)
    sColDisplay = "d";
    var colDisplay = new String(Request.QueryString("coldisplay"));
    if (!isEmpty(colDisplay))
    {
        if ( colDisplay == "p" ) 
        {
            sColDisplay = "p";
            sColHeaderStr = "%";
        }
    }

    // Create a custom listing display including hyperlinks in the column headers
    var displayColumns = (sColDisplay == "d" ? amountFields : pctFields);
    blkARAgingDetails = eWare.GetBlock("content");
    sContent = createAccpacBlockHeader("ARAgingDetail", recViewResults.RecordCount+ " A/R Aging Records");
    sContent = sContent + "\n    <table class=\"CONTENT\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\" width=\"100%\">";
        
    sClass="ROW1";
    sContent = sContent + "\n        <tr>";
    if(isLumber)
    {
        sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\" width=\"30px\"></td>";
    }

    sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\" width=\"75px\"><A class=\"GRIDHEADLINK\" href=\"javascript:sortGrid('praa_Date');\">Aging Date</A>";
    if (sHiddenOrderBy=="praa_Date")
        sContent = sContent + sImgSortOrder;
    sContent = sContent + "</td>";

    sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\" width=\"75px\"><A class=\"GRIDHEADLINK\" href=\"javascript:sortGrid('praad_SubjectCompanyID');\">BB ID</A>";
    if (sHiddenOrderBy=="praad_SubjectCompanyID")
        sContent = sContent + sImgSortOrder;
    sContent = sContent + "</td>";


    sContent = sContent + "\n            <td class=\"GRIDHEAD\" ><A class=\"GRIDHEADLINK\" href=\"javascript:sortGrid('praad_CompanyName');\">Company Name</A>";
    if (sHiddenOrderBy=="praad_CompanyName")
        sContent = sContent + sImgSortOrder;
    sContent = sContent + "</td>";
            
    sContent = sContent + "\n            <td class=\"GRIDHEAD\">Listing Location</td>";
    sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\"><A class=\"GRIDHEADLINK\" href=\"javascript:sortGrid('ListingStatus');\">Listing Status</A></td>";


    for (i in detailHeaderCaptions) {
        sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\" NOWRAP width=\"75px\">" + detailHeaderCaptions[i] + "<br/>(" + sColHeaderStr + ")</td>";
    }

    sContent = sContent + "\n            <td class=\"GRIDHEAD\" align=\"center\" NOWRAP width=\"100px\"><A class=\"GRIDHEADLINK\" href=\"javascript:sortGrid('" + 
                            (sColDisplay == "d" ? lineTotalField : linePctField) + "');\">Total</A>";
    if (sHiddenOrderBy == lineTotalField || sHiddenOrderBy == linePctField)
        sContent = sContent + sImgSortOrder;
    sContent = sContent + "</td>";

    sContent = sContent + "\n            <td class=\"GRIDHEAD\">Exception</td>";
    sContent = sContent + "\n        </tr>";
        
    sDetailUrl = eWare.URL("PRCompany/PRCompanyARAgingDetailListing.asp");

    if (recViewResults.RecordCount == 0)
    {
        sContent = sContent + "\n        <tr>";
        sContent = sContent + "\n            <td colpsan=\"10\" align=\"center\" class=\"" + sClass + "\" >" +
                        "No A/R Aging Records were found." + "</td> ";
        sContent = sContent + "\n        </tr>";
    }
    else
    {
   
        sCompanyUrl = changeKey(eWare.URL("PRCompany/PRCompanySummary.asp"), "Key0", "1");
        sDetailUrl = eWare.URL("PRCompany/PRCompanyARAgingDetail.asp");
        while (!recViewResults.eof)
        {
            sWorkContent = sWorkContent + "\n        <tr>";
            if(isLumber)
            {
                sWorkContent = sWorkContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >" + "<input type=\"checkbox\" name=\"chk\" value=\"" + recViewResults("praad_ARAgingDetailId") + "\"></td> ";
            }

            sWorkContent = sWorkContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >";
            //if (bManuallyEntered)
                sWorkContent = sWorkContent +  "<a href=\"" +  sDetailUrl  + "&praad_ARAgingDetailId="+ recViewResults("praad_ARAgingDetailId") + "\">";
            sWorkContent = sWorkContent +   getDateAsString(recViewResults("praa_Date")) + "</a></td> ";

            sTemp = recViewResults("praad_SubjectCompanyID");
            if (!isEmpty(String(sTemp))) {
                sTemp = "<a href=\"" + changeKey(sCompanyUrl, "Key1", sTemp)  +"\">" + sTemp + "</a>";
            }
            sWorkContent = sWorkContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";

            sTemp = recViewResults("praad_CompanyName");

            sWorkContent = sWorkContent + "\n            <td align=\"left\" class=\"" + sClass + "\" >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";

            sTemp = recViewResults("CityStateCountryShort");
            sWorkContent = sWorkContent + "\n            <td align=\"left\" class=\"" + sClass + "\" >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";

            sTemp = recViewResults("ListingStatus");
            sWorkContent = sWorkContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";

            for (i in displayColumns) {
                
                if ( colDisplay == "p" ) {
                    value = formatPrec(recViewResults(displayColumns[i]));
                } else {
                    value = formatDollar(recViewResults(displayColumns[i]));
                }
                
                sWorkContent = sWorkContent + "\n            <td align=\"right\" class=\"" + sClass + "\" nowrap>" + value + "</td> ";
            }
                
            sTemp = recViewResults("praad_Exception");
            sWorkContent = sWorkContent + "\n            <td align=\"center\" class=\"" + sClass + "\" >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";
            sWorkContent = sWorkContent + "\n        </tr>";
            recViewResults.NextRecord();
            if (sClass == "ROW1")
                sClass="ROW2";
            else
                sClass="ROW1";

            // This is to deal with large numbers of records.  We keep appending to the same string, but since
            // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
            // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
    	    switch(iCount) {
            	case 250: 
                	Content01 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 500: 
                	Content02 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 750: 
                	Content03 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1000: 
                	Content04 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1250: 
                	Content05 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1500: 
                	Content06 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1750: 
                	Content07 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2000: 
                	Content08 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2250: 
                	Content09 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2500: 
                	Content10 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2750: 
                	Content11 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3000: 
                	Content12 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3250: 
                	Content13 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3500: 
                	Content14 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3750: 
                	Content15 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4000: 
                	Content16 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4250: 
                	Content17 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4500: 
                	Content18 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4750: 
                	Content19 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 5000: 
                	Content20 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 5500: 
                	Content21 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 6000: 
                	Content22 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 6500: 
                	Content23 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 7000: 
                	Content24 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 7500: 
                	Content25 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 8000: 
                	Content26 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 8500: 
                	Content27 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 9000: 
                	Content28 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 9500: 
                	Content29 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 10000: 
                	Content30 = sWorkContent;
                        sWorkContent = "";
                        break;

	        }

            iCount++;
	        if (iCount >= iMaxCount) {
                bBreak = true
			    break;
		    }
        }
    }

    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 + Content16 + Content17 + Content18 + Content19 + Content20 + 
                Content21 +  Content22 +  Content23 +  Content24 +  Content25 + Content26 + Content27 + Content28 + Content29 + Content30 + sWorkContent+ "\n</table>";


	if (bBreak) {
	    sContent = sContent + "<script type=\"text/javascript\">alert('The number of detail rows exceeds the maximum allowed.  Only " + iMaxCount.toString() + " have been displayed');</script>";
	}

    sContent = sContent + createAccpacBlockFooter();

    // Hide the totals selection checkbox at the beginning of this table
    sCheckHideTotals = "";
    sHideTotals = String(Request.Form.Item("chk_hidetotals"));
    if (sHideTotals != null && sHideTotals == "on")
        sCheckHideTotals = "CHECKED";
    sContent = "<input type=\"CHECKBOX\" style=\"display:none\" " + sCheckHideTotals+ " id=\"chk_hidetotals\" name=\"chk_hidetotals\">" 
        + sContent;

    sContent = "<input type=\"hidden\" name=\"PRCoHIDDENORDERBY\" id=\"PRCoHIDDENORDERBY\" value=\"" + (sHiddenOrderBy==""?"praa_Date":sHiddenOrderBy) + "\">" +
               "<input type=\"hidden\" name=\"PRCoHIDDENORDERBYDESC\" id=\"PRCoHIDDENORDERBYDESC\" value=\"" + sHiddenOrderByDesc + "\">" +
               "<input type=\"hidden\" name=\"hdn_Chk\" id=\"hdn_Chk\" value=\"\">"
               + sContent;

    blkARAgingDetails.Contents=sContent;
    blkContainer.AddBlock(blkARAgingDetails);    


    // Show the buttons
    sContinueUrl = eWare.URL("PRCompany/PRCompanyARAgingByListing.asp");
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sContinueUrl));
        
    // if this was manually entered, it can be editted
    //if (bManuallyEntered)
    //{
        if (isUserInGroup(sSecurityGroups ))
        {
            sEditURL = eWare.URL("PRCompany/PRCompanyARAging.asp")+ "&praa_ARAgingId=" + praa_ARAgingid + "&comp_companyid="+comp_companyid + "&T=Company&Capt=Trade+Activity";
            blkContainer.AddButton(eWare.Button("Change","edit.gif",sEditURL));

            if (bManuallyEntered)
            {
                sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this A/R report?  All " + iCount.toString() + " A/R detail records will also be deleted.')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
	    		blkContainer.AddButton(eWare.Button("Delete A/R Report", "delete.gif", sDeleteUrl));
            }

            sAddDetailURL = eWare.URL("PRCompany/PRCompanyARAgingDetail.asp")+ "&praa_ARAgingId=" + praa_ARAgingid + "&T=Company&Capt=Trade+Activity";
            blkContainer.AddButton(eWare.Button("Add A/R Detail","new.gif",sAddDetailURL));
        }
    //}
        
    if (recViewResults.RecordCount > 0)
    {
        blkContainer.AddButton(eWare.Button("Show Header", "Showanalysis.gif", "javascript:showTotals();"));
        blkContainer.AddButton(eWare.Button("Hide Header", "Showanalysis.gif", "javascript:hideTotals();"));
    }
        
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

    if (isUserInGroup(sSecurityGroups ))
    {
        sManageTranslationsUrl = eWare.URL("PRCompany/PRCompanyARTranslationListing.asp") + "&prar_CompanyId=" + comp_companyid+ "&praa_ARAgingId=" + praa_ARAgingid;
        blkContainer.AddButton(eWare.Button("Manage this File's A/R Translations", "PrepareDatabase.gif", sManageTranslationsUrl));

        var AUSLinkParmaters = "&praa_ARAgingId="+praa_ARAgingid;
        blkContainer.AddButton( eWare.Button("Add Subject Companies to AUS", "New.gif", eWare.URL("PRCompany/PRCompanyARAgingAUS.asp") + AUSLinkParmaters) );

        if (isLumber) {
            sAdjustToCurrentUrl= "javascript:if (confirm('Are you sure you want to adjust selected line items to Current?')) { adjCurrent(); }";
            blkContainer.AddButton(eWare.Button("Adjust Line Items to Current","save.gif", sAdjustToCurrentUrl));
        }
    }
        
    eWare.AddContent(blkContainer.Execute(recARAging));
    Response.Write(eWare.GetPage('Company'));
        
	Response.Write("\n<table><tr ID=\"tr_tblSearchClassOptions\"><td colspan=\"6\" align=\"left\" ID=\"td_tblSearchClassOptions\">" + sSearchClassContent + "</td></tr></table>");

    Response.Write("\n<script type=\"text/javascript\">");
    Response.Write("\n    function initBBSI()"); 
    Response.Write("\n    {");
    if (sCheckHideTotals=="" )
        Response.Write("                showTotals();");
    else
        Response.Write("                hideTotals();");
    //Response.Write("\n        document.all(\"_startdate\").value = \"" + sFormStartDate + "\";");
    //Response.Write("\n        document.all(\"_enddate\").value = \"" + sFormEndDate  + "\";");
    if (sDBException != "NULL")
        Response.Write(jsException);
    //Response.Write("\n        AppendRow(\"_Capt_startdate\", \"tr_tblSearchClassOptions\");");
    Response.Write("\n        AppendRow(\"_Captprtr_date\", \"tr_tblSearchClassOptions\");");

    Response.Write("\n    }");
    Response.Write("\n    function sortGrid(sColName){");
    Response.Write("\n        sCurr = document.EntryForm.PRCoHIDDENORDERBY.value;");
    Response.Write("\n        sCurrOrder = document.EntryForm.PRCoHIDDENORDERBYDESC.value;");
    Response.Write("\n        if (sCurr == sColName) ");
    Response.Write("\n        {");
    Response.Write("\n            if (sCurrOrder == \"FALSE\") ");
    Response.Write("\n                document.EntryForm.PRCoHIDDENORDERBYDESC.value = \"TRUE\";");
    Response.Write("\n            else ");
    Response.Write("\n                document.EntryForm.PRCoHIDDENORDERBYDESC.value = \"FALSE\";");
    Response.Write("\n        } else {");
    Response.Write("\n            document.EntryForm.PRCoHIDDENORDERBY.value = sColName;");
    Response.Write("\n            document.EntryForm.PRCoHIDDENORDERBYDESC.value = \"FALSE\";");
    Response.Write("\n        }");
    Response.Write("\n        document.EntryForm.submit();");
    Response.Write("\n    }");
    Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");        
    Response.Write("\n</script>");
        
    var endTime = new Date();
    var timeDiff = endTime - startTime;
        
    Response.Write("<p class=\"SmallButtonItem\">Total Execution Time: " + timeDiff.toString() + "</p>");
    
    
function formatPrec(sValue)
{
    sValue = String((parseFloat(sValue)*100).toFixed(3));
    return formatCommaSeparated(sValue);
}    
%>
<!-- #include file="CompanyFooters.asp" -->
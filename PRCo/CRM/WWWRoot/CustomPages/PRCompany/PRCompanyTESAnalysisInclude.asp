<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2014

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<%
function generateTESAnalsyisBlock(screenType, companyID, dbStartDate, dbEndDate) {

    if (dbStartDate == "NULL") {
        dbStartDate = "'1900-01-01'";
    }

    if (dbEndDate == "NULL") {
        dbEndDate = "'2100-12-31'";
    }

	var sSQL = "SELECT COUNT(1) as TotalSent, " +
                  "COUNT(CASE WHEN prtr_TESRequestID > 0 THEN 'x' ELSE NULL END) As TotalResponsesReceived, " +
                  "COUNT(CASE WHEN prtesr_CreatedDate BETWEEN " + dbStartDate + " AND " + dbEndDate + " THEN 'X' ELSE NULL END) as TotalSentInDateRange, " +
                  "COUNT(CASE WHEN prtesr_CreatedDate BETWEEN " + dbStartDate + " AND " + dbEndDate + " THEN CASE WHEN prtr_TESRequestID > 0 THEN 'x' ELSE NULL END ELSE NULL END) as TotalResponsesReceivedInDateRange " +
            "FROM PRTESRequest WITH (NOLOCK) "+
                 "LEFT OUTER JOIN PRTradeReport WITH (NOLOCK) ON prtr_TESRequestID = prtesr_TESRequestID AND prtr_Duplicate IS NULL AND prtr_SubjectID=prtesr_SubjectCompanyID";

    if (screenType == "TESAbout") {
        sSQL += " WHERE prtesr_SubjectCompanyID = " + companyID;
    } else {
        sSQL += " WHERE prtesr_ResponderCompanyID = " + companyID;
    }

    //Response.Write("<p>" + sSQL + "</p>");

 	recAnalysis = eWare.CreateQueryObj(sSQL);
	recAnalysis.SelectSQL();

	var sBlockContent = createAccpacBlockHeader("tblAnalysisBlock", "Analysis Summary");
	sBlockContent += "\n<table id=\"tblAnalysis\" width=\"100%\" cellpadding=\"0\" border=\"0\" align=\"left\">";

	
	// if a record is not found, just display a message
	if (recAnalysis.eof)
	{
        sBlockContent += "\n<tr><td align=\"center\" class=\"VIEWBOXTEXT\">No Trade Experince Survey information is available for this company.</td></tr>";
    }
    else
    {
	    sClass = "VIEWBOX";
	    sClassCaption = "VIEWBOXCAPTION";

        var responsePerc = 0;
        if (recAnalysis("TotalSent") > 0) {
            responsePerc =  (recAnalysis("TotalResponsesReceived") / recAnalysis("TotalSent")) * 100;
        }

        sBlockContent += "\n<tr><td>";
	    sBlockContent += "\n      <table id=\"tblAnalysis\" cellpadding=\"0\" border=\"0\" align=\"left\">";
	    sBlockContent += "\n      <tr>";
        sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Total Sent:</span><br/><span class=\"VIEWBOX\">" + formatCommaSeparated(recAnalysis("TotalSent")) + "</span></td>";
	    sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Total Received:</span><br/><span class=\"VIEWBOX\">" + formatCommaSeparated(recAnalysis("TotalResponsesReceived")) + "</span></td>";
	    sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Percentage Received:</span><br/><span class=\"VIEWBOX\">" + responsePerc.toFixed(2).toString() + "%</span></td>";
	    sBlockContent += "\n      </tr>";

        var responsePerc = 0;
        if (recAnalysis("TotalSentInDateRange") > 0) {
            responsePerc =  (recAnalysis("TotalResponsesReceivedInDateRange") / recAnalysis("TotalSentInDateRange")) * 100;
        }

	    sBlockContent += "\n      <tr>";
        sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Total Sent in Date Range:</span><br/><span class=\"VIEWBOX\">" + formatCommaSeparated(recAnalysis("TotalSentInDateRange")) + "</span></td>";
	    sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Total Received in Date Range:</span><br/><span class=\"VIEWBOX\">" + formatCommaSeparated(recAnalysis("TotalResponsesReceivedInDateRange")) + "</span></td>";
	    sBlockContent += "\n            <td><span class=\"VIEWBOXCAPTION\" align=\"left\">Percentage Received in Date Range:</span><br/><span class=\"VIEWBOX\">" + responsePerc.toFixed(2).toString() + "%</span></td>";
	    sBlockContent += "\n      </tr>";      
        sBlockContent += "\n      </table>";
        sBlockContent += "\n</td></tr>";
    }


    sBlockContent += "\n</table>";
    sBlockContent += createAccpacBlockFooter();

    return sBlockContent;
}
 %>
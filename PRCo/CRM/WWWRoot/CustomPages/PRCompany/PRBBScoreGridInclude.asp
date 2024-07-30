<%
function buildProduceBBScoreGrid(recBBScore,
                                 sGridName,
                                 sGridTitle) {  

    var sWorkContent = "";
    var Content01 = "";

    
    //Response.Write("<br/>" + sGridName + " Start: " + new Date());
   
    var sContent;
    sContent = createAccpacBlockHeader(sGridName, recBBScore.RecordCount + sGridTitle);

  sContent += "\n\n<table class=\"CONTENTGRID\" cellspacing=\"0\" cellpadding=\"1\" width=\"100%\">" +
                "\n<thead>" +
                "\n<tr>" +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Date", "prbs_Date") + "</TD> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Score", "prbs_BBScore") + "</TD> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Prv Month<br/>Diff", "prbs_Deviation") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Survey<br/>Score", "prbs_SurveyScore") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Survey<br/>Lag", "prbs_SurveyLag") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Survey<br/>Nage", "prbs_SurveyNage") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Survey<br/>Nage Pctl", "prbs_SurveyNagePercentile") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Survey<br/>Weight", "prbs_SurveyWeight") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "AR<br/>Score", "prbs_ARScore") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "AR<br/>Lag", "prbs_ARLag") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "AR<br/>Nage", "prbs_ARNage") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "AR<br/>Nage Pctl", "prbs_ARNagePercentile") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "AR<br/>Weight", "prbs_ARWeight") + "</td> "+
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Conf", "prbs_ConfidenceScore") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Min Trade<br/>Report Count", "prbs_MinimumTradeReportCount") + "</td> ";
    sContent += "</tr>";
    sContent += "\n</thead>";

    sClass = "ROW2";
    var iCount = 0;
    while (!recBBScore.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getDateValue(recBBScore("prbs_Date")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\"><a href=\"" + eWareUrl("PRCompany/PRBBScore.asp") + "&prbs_BBScoreId=" + recBBScore("prbs_BBScoreId") + "&comp_CompanyID=" + recBBScore("prbs_CompanyId") + "\">" + recBBScore("prbs_BBScore") + "</a></td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_Deviation")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_SurveyScore")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_SurveyLag")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_SurveyNage")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_SurveyNagePercentile")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_SurveyWeight")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ARScore")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ARLag")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ARNage")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ARNagePercentile")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ARWeight")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_ConfidenceScore")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recBBScore("prbs_MinimumTradeReportCount")) + "</td>";
        sWorkContent += "</tr>";
        
        iCount++;
        recBBScore.NextRecord();
    }      
    
    sContent += sWorkContent;
    
    
    while (iCount < 10) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        var colCount = 0
        sContent += "\n<tr>";
        while (colCount < 15) {
            sContent += "<td class=\"" + sClass + "\">&nbsp;</td>";
            colCount++;
        }
        sContent += "</tr>";
    
        iCount ++;
    }
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
    //Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}

%>
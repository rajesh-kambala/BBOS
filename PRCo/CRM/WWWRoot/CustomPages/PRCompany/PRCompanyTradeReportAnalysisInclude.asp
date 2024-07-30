<%
    /* ************************
        To use this file, the following includes should be defined in the calling routine:
        #include file ="..\accpaccrm.js" 
        #include file ="CompanyHeaders.asp" 
        #include file ="PRCompanyTradeInclude.asp" 
        #include file ="..\AccpacScreenObjects.asp" 
           
        The result of this include in the creation of the content block for the TradeReport Analysis.
        This block is added to blkContainer (defined in CompanyHeaders) before leaving this routine.
      
    *************************/

    var blkTRAIncludes = eWare.GetBlock("content");
    blkTRAIncludes.contents += "\n<script type=\"text/javascript\" src=\"PRCompanyTradeReportAnalysisInclude.js\"></script>";
    blkContainer.AddBlock(blkTRAIncludes);

    var pamList = (isEmpty(sIncludeBranches) ? comp_companyid : "NULL")  + ", " 
            + sDBStartDate + ", " 
            + sDBEndDate +", " 
	        + (sDBException == "NULL" ? "NULL" : "'" + sDBException + "'") + ", " 
	        + (sDBDisputeInvolved == "NULL" ? "NULL" : "'" + sDBDisputeInvolved + "'") + ", " 
	        + (sDBDuplicate == "" ? "NULL" : "'" + sDBDuplicate + "'") + ", " 
	        + sDBClassificationList + ", "
	        + (isEmpty(sMostRecentOnly) ? "NULL" : "'Y'") + ", "   
            + (comp_PRIndustryType == "" ? "NULL" : "'" + comp_PRIndustryType + "'") + ", "
	        + (isEmpty(sIncludeBranches) ? "NULL" : recCompany("comp_PRHQID"));

	sSQL = "SELECT * FROM ufn_GetTradeReportAnalysis(" + pamList + ")";
    //Response.Write("<p>" + sSQL);

	recAnalysis = eWare.CreateQueryObj(sSQL);
	recAnalysis.SelectSQL();
	
	// if a record is not found, just display a message
	if (recAnalysis.eof)
	{
	    sBlockContent = createAccpacBlockHeader("tblAnalysisBlock", "Analysis Summary");
	    sBlockContent += "\n<TABLE ID='tblAnalysis' WIDTH='100%' CELLPADDING=0 BORDER=0 align=left>";
        sBlockContent += "\n  <TR><TD ALIGN=CENTER CLASS=VIEWBOXTEXT>No Trade Report Analysis information is available for this company.</TD></TR>";
        sBlockContent += "\n</TABLE>";
        sBlockContent += createAccpacBlockFooter();
    }
    else
    {
	    sClass = "VIEWBOX";
	    sClassCaption = "VIEWBOXCAPTION";

	    sBlockContent = createAccpacBlockHeader("tblAnalysisBlock", "Analysis Summary");
	    sBlockContent += "\n<TABLE ID='tblAnalysis'  style=\"width:100%\" CELLPADDING=0 BORDER=0 align=left>";
        sBlockContent += "\n  <TR><TD ALIGN=LEFT COLSPAN=4 >";
	    sBlockContent += "\n      <TABLE ID='tblAnalysis' CELLPADDING=0 BORDER=0 align=left>";
	    sBlockContent += "\n        <TR><TD CLASS=VIEWBOXTEXT><b>Dates: </b></TD>";
	    sBlockContent += "\n            <TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + sFormStartDate + "&nbsp;-&nbsp;" + sFormEndDate + "</TD>";
	    sBlockContent += "\n        </TR>";
	    sBlockContent += "\n        <TR><TD CLASS=VIEWBOXTEXT><b>Report Count:&nbsp;&nbsp;</b></TD>";
	    sBlockContent += "\n            <TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + recAnalysis("prtr_ReportCount") + "</TD>";
	    sBlockContent += "\n        </TR>";
	    sBlockContent += "\n        <TR><TD CLASS=VIEWBOXTEXT><b>Unique Submitter Count:&nbsp;&nbsp;</b></TD>";
	    sBlockContent += "\n            <TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + recAnalysis("prtr_UniqueResponderCount") + "</TD>";
	    sBlockContent += "\n        </TR>";
        sBlockContent += "\n      </TABLE>";
        sBlockContent += "\n      </TD>";
        sBlockContent += "\n  </TR>";
        sBlockContent += "\n  <TR>";
        sBlockContent += "\n      <TD VALIGN=TOP WIDTH=140 >";
	    sBlockContent += "\n          <TABLE ID='tblIntegrity' WIDTH='100%' CELLPADDING=0 BORDER=0 align=left>";
	    sBlockContent += "\n            <TR><TD CLASS=VIEWBOXTEXT COLSPAN=6><u><b>TRADE PRACTICES</b></u></TD></TR>";
	    sBlockContent += "\n            <TR><TD CLASS=VIEWBOXTEXT ALIGN=LEFT>COUNT:&nbsp;</TD><TD CLASS=VIEWBOXTEXT>" + recAnalysis("prtr_INT_Count") + "</TD>"
	                                    +"<TD CLASS=VIEWBOXTEXT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</TD>"
	                                    +"<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>AVG:&nbsp;</TD><TD CLASS=VIEWBOXTEXT>" + parseFloat(recAnalysis("prtr_INT_Avg")).toFixed(2) + "X</TD>"
	                                    +"<TD CLASS=VIEWBOXTEXT WIDTH='100%'>&nbsp;</TD></TR>";
//	    sBlockContent += "\n            <TR><TD COLSPAN=6>&nbsp;</TD></TR>";
	    sBlockContent += "\n            <TR>";
	    sBlockContent += "\n              <TD COLSPAN=6>";
	    sBlockContent += "\n                <table ID='tblIntegrityDetail' CELLPADDING=0 align=left>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=30>&nbsp;</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=40 align=right><u>COUNT</u></td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=50 align=right><u>&nbsp;&nbsp;&nbsp;PCT&nbsp;&nbsp;&nbsp;</u></td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>X</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_INT_XCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_INT_XPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>XX</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_INT_XXCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_INT_XXPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>XXX</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_INT_XXXCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_INT_XXXPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>XXXX</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_INT_XXXXCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_INT_XXXXPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                </table>";
	    sBlockContent += "\n              </TD>";
	    sBlockContent += "\n            </TR>";
        sBlockContent += "\n          </TABLE>";
        sBlockContent += "\n      </TD>";
	    sBlockContent += "\n      <TD WIDTH=25>&nbsp;</TD>";
        sBlockContent += "\n      <TD VALIGN=TOP WIDTH=180 >";
	    sBlockContent += "\n          <TABLE ID='tblCredit' WIDTH='100%' CELLPADDING=0 BORDER=0 align=left>";
	    sBlockContent += "\n            <TR><TD CLASS=VIEWBOXTEXT COLSPAN=3><u><b>HIGH CREDIT</b></u></TD></TR>";
	    sBlockContent += "\n            <TR><TD CLASS=VIEWBOXTEXT ALIGN=LEFT>COUNT: </TD><TD CLASS=VIEWBOXTEXT>" + recAnalysis("prtr_Credit_Count") + "</TD><TD WIDTH='100%'></TD></TR>";
//	    sBlockContent += "\n            <TR><TD COLSPAN=3>&nbsp;</TD></TR>";
	    sBlockContent += "\n            <TR>";
	    sBlockContent += "\n              <TD COLSPAN=3>";
	    sBlockContent += "\n                <table ID='tblIntegrityDetail' CELLPADDING=0 align=left>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=70>&nbsp;</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=35 align=right><u>COUNT</u></td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=50 align=right><u>&nbsp;&nbsp;&nbsp;PCT&nbsp;&nbsp;&nbsp;</u></td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>5-10M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_5MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_5MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>10-50M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_10MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_10MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>50-75M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_50MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_50MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>75-100M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_75MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_75MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>100-250M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_100MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_100MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";

		sBlockContent += "\n                  <tr>";
		sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>Over 250M</td>";
		sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_250MCountOver") + "</td>";
		sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_250MPctOver")*100).toFixed(1) + "%</td>";
		sBlockContent += "\n                  </tr>";

	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>250-500M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_250MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_250MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>500-1000M</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_500MCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_500MPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>Over 1 million</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Credit_1000MCountOver") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Credit_1000MPctOver")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";

	    sBlockContent += "\n                </table>";
	    sBlockContent += "\n              </TD>";
	    sBlockContent += "\n            </TR>";
        sBlockContent += "\n          </TABLE>";
        sBlockContent += "\n      </TD>";
	    sBlockContent += "\n      <TD WIDTH=25>&nbsp;</TD>";
        sBlockContent += "\n      <TD ALIGN=LEFT VALIGN=TOP WIDTH=220>";
	    sBlockContent += "\n          <TABLE ID='tblPay' WIDTH='100%' CELLPADDING=0 BORDER=0 align=left>";
	    sBlockContent += "\n            <TR><TD CLASS=VIEWBOXTEXT COLSPAN=6><u><b>PAY</b></u></TD></TR>";
	    sBlockContent += "\n            <TR>";
	    sBlockContent += "\n                <TD CLASS=VIEWBOXTEXT ALIGN=LEFT >COUNT: </TD>"
	                                      +"<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + recAnalysis("prtr_Pay_Count") + "</TD>"
	                                      +"<TD CLASS=VIEWBOXTEXT WIDTH='30%'>&nbsp;</TD>"
	                                      +"<TD CLASS=VIEWBOXTEXT ALIGN=RIGHT >MEDIAN: </TD>";
        sTemp = recAnalysis("prtr_Pay_Median");
        if (isEmpty(sTemp))
            sTemp = "";
	    sBlockContent += "<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + sTemp + "</TD>";

        sBlockContent += "<TD CLASS=VIEWBOXTEXT ALIGN=RIGHT >AVG: </TD>";
        sTemp = recAnalysis("prtr_Pay_Avg");
        if (isEmpty(sTemp))
            sTemp = "";
	    sBlockContent += "<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + sTemp + "</TD>"
	                                      +"<TD WIDTH='100%'></TD>";

	    sBlockContent += "\n            </TR>";
	    sBlockContent += "\n            <TR>";
	    sBlockContent += "\n                <TD ALIGN=LEFT CLASS=VIEWBOXTEXT >LOW: </TD>";
        sTemp = recAnalysis("prtr_Pay_Low");
        if (isEmpty(sTemp))
            sTemp = "";
	    sBlockContent += "<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + sTemp + "</TD>"
	                                      +"<TD CLASS=VIEWBOXTEXT WIDTH='30%'>&nbsp;</TD>"
	                                      +"<TD ALIGN=RIGHT CLASS=VIEWBOXTEXT >HIGH: </TD>";
        sTemp = recAnalysis("prtr_Pay_High");
        if (isEmpty(sTemp))
            sTemp = "";
	    sBlockContent += "<TD CLASS=VIEWBOXTEXT ALIGN=LEFT>" + sTemp + "</TD>"
	                                      +"<TD WIDTH='100%'></TD>";
	    sBlockContent += "\n            </TR>";
//	    sBlockContent += "\n            <TR><TD COLSPAN=6>&nbsp;</TD></TR>";
	    sBlockContent += "\n            <TR>";
	    sBlockContent += "\n              <TD COLSPAN=6 VALIGN=TOP>";
	    sBlockContent += "\n                <table ID='tblPayDetail' CELLPADDING=0 align=left>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=40 >&nbsp;</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=40 align=LEFT><u>DAYS</u></td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=40 align=right><u>COUNT</u></td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT WIDTH=50 align=right><u>&nbsp;&nbsp;&nbsp;PCT&nbsp;&nbsp;&nbsp;</u></td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>AA</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>1-14</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_AACount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_AAPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>A</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>15-21</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_ACount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_APct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>B</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>22-28</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_BCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_BPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>C</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>29-35</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_CCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_CPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>D</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>36-45</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_DCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_DPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>E</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>46-60</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_ECount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_EPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                  <tr>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>F</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=left>60+</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + recAnalysis("prtr_Pay_FCount") + "</td>";
	    sBlockContent += "\n                    <td CLASS=VIEWBOXTEXT align=right>" + parseFloat(recAnalysis("prtr_Pay_FPct")*100).toFixed(1) + "%</td>";
	    sBlockContent += "\n                  </tr>";
	    sBlockContent += "\n                </table>";
	    sBlockContent += "\n              </TD>";
	    sBlockContent += "\n            </TR>";
        sBlockContent += "\n          </TABLE>";
    //    sBlockContent += "\n            </TD>";
    //    sBlockContent += "\n          </TR>";
    //	sBlockContent += "\n        </TABLE>";
	    sBlockContent += "\n      </TD>";
	    sBlockContent += "\n      <TD>&nbsp;</TD>";
	    sBlockContent += "\n  </TR>";
        sBlockContent += "\n</TABLE>";
        sBlockContent += createAccpacBlockFooter();
    }
    
    blkAnalysis = eWare.GetBlock("content");
    blkAnalysis.contents = sBlockContent;
    blkContainer.AddBlock(blkAnalysis);

%>
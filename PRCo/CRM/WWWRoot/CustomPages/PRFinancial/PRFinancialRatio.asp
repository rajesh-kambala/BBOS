<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2014

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
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->

<%
/* this function will look for values for recFinancial  */
function getRatioBlockContents(sBlockName) 
{
	var blkMain = eWare.GetBlock(sBlockName);
	var colFields = new Enumerator(blkMain);
	sBlockContent = "\n  <table width=100\% CELLPADDING=0 BORDER=0 align=left>";
	nBlockTotal = 0;
	while (!colFields.atEnd()) {
		sFieldName = String(colFields.item());
		sTranslation = eWare.GetTrans('ColNames', sFieldName);
		sTranslation = "<b>" + sTranslation + "</b>";

		sClass = "VIEWBOX";
		sClassCaption = "VIEWBOXCAPTION";
		sClassFormula = "VIEWBOXTEXT";
        // put the caption on the page
		sBlockContent += "\n<tr><td width='200' class=" + sClassCaption + " align=right valign=top>" + sTranslation + ": </td>";

        // determine the value for the field
        sFieldValue = recFinancial(sFieldName);
		if (isEmpty(sFieldValue))
		    sFieldValue = "Not Available";

		sBlockContent += "\n    <td>&nbsp;&nbsp;</td>";
		
		sBlockContent += "\n    <td class=" + sClass + " valign=top width=50>";
		if (!isNaN(parseFloat(sFieldValue)))
		    sFieldValue = parseFloat(sFieldValue).toFixed(2);
		sBlockContent += "    <span id='"+sFieldName+"' style='height:15px;'><b>"+sFieldValue+"</b></span>";
		sBlockContent += "\n    </td>";

        // show the formula
		sFormula = ""
		if (sFieldName == "prfs_currentratio")
		    sFormula = "Current Assets / Current Liabilities";
		else if (sFieldName == "prfs_quickratio")
		    sFormula = "Cash & Equivalents + A/R from Trade) / Current Liab.";
		else if (sFieldName == "prfs_arturnover")
		    sFormula = "Net Sales / A/R from Trade";
		else if (sFieldName == "prfs_dayspayableoutstanding")
		    sFormula = "(Accounts Payable X 365) / Cost of Goods Sold";
		else if (sFieldName == "prfs_debttoequity")
		    sFormula = "Total Liabilities / Equity";
		else if (sFieldName == "prfs_fixedassetstonetworth")
		    sFormula = "Fixed Assets / Equity";
		else if (sFieldName == "prfs_debtserviceability")
		    sFormula = "(Net Income + Depreciation + Amortization) / Current Maturity of Long Term Debt";
		else if (sFieldName == "prfs_operatingratio")
		    sFormula = "(Cost of Goods Sold + Operating Expenses) / Sales";
		else if (sFieldName == "prfs_zscore")
        {
            recCompanyExchange = eWare.FindRecord("PRCompanyStockExchange","prc4_companyid=" + comp_companyid);
            if (!recCompanyExchange.eof)
            {
		        sFormula = "3.3 X (Operating Income / Total Assets)<br>"+
		                "+ 0.99 X (Net Sales / Total Assets)<br>"+
		                "+ 0.6 X (Equity / Total Liabilities)<br>"+
		                "+ 1.2 X (Working Captial / Total Assets)<br>"+
		                "+ 1.4 X (Retained Earnings / Total Assets)";
            }
            else 
            {
		        sFormula = "6.72 X (Operating Income / Total Assets)<br>"+
		                "+ 1.05 X (Equity / Total Liabilities)<br>"+
		                "+ 6.56 X (Working Captial / Total Assets)<br>"+
		                "+ 3.26 X (Retained Earnings / Total Assets)";
            }
        }
		sBlockContent += "\n    <td class=" + sClassFormula+ " align=left valign=top>" + sFormula + "</td>";
		sBlockContent += "\n</tr>";
	    colFields.moveNext();
	}

	sBlockContent += "</table>";
	return sBlockContent;
}

    var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
    var prfs_financialid = getIdValue("prfs_financialid");
    if (prfs_financialid != -1)
    {
        recFinancial = eWare.FindRecord("PRFinancial", "prfs_FinancialId=" + prfs_financialid);
    }
    else
    {
        // A valid PRFinancial record is required; if one is not passed create a new one
        recFinancial = eWare.CreateRecord("PRFinancial");
    }    

    
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

    cntMain = eWare.GetBlock("container");

    // header block
    blkFinancial = eWare.GetBlock("PRFinancialHeader");
    blkFinancial.Title="Financial";
    cntMain.AddBlock(blkFinancial);

    // Create the container for the ratio contents
    sRatioContents = createAccpacBlockHeader("tblRatios", "Ratios");
    
    sRatioContents += getRatioBlockContents("PRFinancialRatio");
    sRatioContents += createAccpacBlockFooter();

    blkContent = eWare.GetBlock("content");
    blkContent.contents = sRatioContents;
    cntMain.AddBlock(blkContent);
    
    cntMain.DisplayButton(1)=false;



    if(eWare.Mode > View) 
        eWare.Mode == View;

	cntMain.AddButton(eWare.Button("Continue", "continue.gif", eWare.URL("PRCompany/PRCompanyFinancial.asp")));
	cntMain.AddButton(eWare.Button("Balance Sheet", "calendar.gif", eWare.URL("PRFinancial/PRFinancialSummary.asp")+"&E=PRCompany&prfs_Financialid=" + prfs_financialid));
	cntMain.AddButton(eWare.Button("Income Statement", "calendar.gif", eWare.URL("PRFinancial/PRFinancialIncome.asp")+"&E=PRCompany&prfs_Financialid=" + prfs_financialid));

    eWare.AddContent(cntMain.Execute(recFinancial));
    Response.Write(eWare.GetPage('Company'));
%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->


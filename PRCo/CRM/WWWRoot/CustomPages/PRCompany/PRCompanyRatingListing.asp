<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="PRBBScoreGridInclude.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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
var blkCompanyInfo = eWare.GetBlock("Company1");
blkCompanyInfo.Title = "Company";
blkCompanyInfo.Mode = View;
blkCompanyInfo.ArgObj = recCompany;

var sSecurityGroups = "1,2,10,4,5,6,8";

// For lumber companies, display the Pay Report Count
if (recCompany.comp_PRIndustryType == "L") {
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    var sBannerMsg = "";
    var sInnerMsg = "";
    var blkBanners = eWare.GetBlock('content');

    var qry = eWare.CreateQueryObj("SELECT dbo.ufn_GetPayReportCount(" + comp_companyid + ") As Cnt;");
    qry.SelectSQL();
    sInnerMsg = "<tr><td>This company has " + qry("Cnt").toString() + " current Industry Pay Reports.</td></tr>";
    
    sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sInnerMsg + "</table> ";
    blkBanners.contents = sBannerMsg;    
    blkContainer.AddBlock(blkBanners);
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

var List = eWare.GetBlock("PRRatingGrid");
List.prevURL = sURL;

var blkCW = eWare.GetBlock("PRCreditWorthCap");
blkCW.Title = "Credit Worth Cap";
blkCW.Mode = View;
blkCW.ArgObj = recCompany;

// Build our CreditWorthCap field
var sInsertString = "<table><tr><td id=\"tdCreditWorthCap\" valign=\"top\">"
sInsertString = sInsertString + "<span id=\"_Captcomp_prcreditworthcap\" class=\"VIEWBOXCAPTION\">Credit Worth Cap:</span><br/>"

if ((recCompany.comp_PRCreditWorthCap == null) || (recCompany.comp_PRCreditWorthCap == 0)) {
    szCreditWorth = "-None Selected-";
} else {
    recCRM = eWare.FindRecord("PRCreditWorthRating","prcw_CreditWorthRatingId=" + recCompany.comp_PRCreditWorthCap);
    szCreditWorth = recCRM.prcw_Name;
}

sInsertString = sInsertString + "<span id=\"_Datacomp_prcreditworthcapreason\" class=\"VIEWBOX\">" + szCreditWorth + "</span>";
sInsertString = sInsertString + "</td></tr></table>";
Response.Write(sInsertString);

sInsertString = "AppendCell(\"_Captcomp_prcreditworthcapreason\", \"tdCreditWorthCap\", true);"; 



var grdRating = eWare.GetBlock("content");
var sContent = "";
sContent = createAccpacBlockHeader("PRRatingGrid", "Rating Records (Last 10)");

var szGridName = "PRRatingGrid";
if (recCompany.comp_PRIndustryType == "L") {
    szGridName = "PRRatingLumberGrid";
}
sContent = sContent + createAccpacListBody(szGridName, 10, null,
                            "prra_companyid = " + comp_companyid , 
                            "prra_Date Desc ");

sContent = sContent + createAccpacBlockFooter();
grdRating.Contents=sContent;

blkContainer.AddBlock(blkCompanyInfo);
blkContainer.AddBlock(blkCW);

if (recCompany.comp_PRIndustryType == "L") {
    var blkRB = eWare.GetBlock("PRCompanyInfoProfileRedbook");
    blkRB.Title = "Redbook Rating";
    var recCompInfoProfile = eWare.FindRecord("PRCompanyInfoProfile","prc5_CompanyId=" + comp_companyid);
    blkRB.ArgObj = recCompInfoProfile;
    blkContainer.AddBlock(blkRB);
    
    var blkPayIndicator = eWare.GetBlock("PRPayIndicator");
    blkPayIndicator.Title = "Pay Indicator";
    //var recCompany2 = eWare.FindRecord("Company","comp_CompanyID=" + comp_companyid);
    blkPayIndicator.ArgObj = recCompany;
    blkContainer.AddBlock(blkPayIndicator);
    
    var blkPayIndicatorGrid = eWare.GetBlock("content");
    sContent = "";
    sContent = createAccpacBlockHeader("PRCompanyPayIndicator", "Pay Indicator Records (Last 12)");

    sContent = sContent + createAccpacListBody("PRPayIndicatorGrid", 12, null, 
                                "prcpi_companyid = " + comp_companyid , 
                                "prcpi_CreatedDate Desc ");

    sContent = sContent + createAccpacBlockFooter();
    blkPayIndicatorGrid.Contents=sContent;    
    blkContainer.AddBlock(blkPayIndicatorGrid);
}

    blkContainer.AddBlock(grdRating);

    var sContent = "";

    if (recCompany.comp_PRIndustryType == "L") {
        var bbscoreGridName = "PRBBScoreLumberGrid";
        sContent = createAccpacBlockHeader(bbscoreGridName, "BB Score Records (Last 12)");
        sContent = sContent + createAccpacListBody(bbscoreGridName, 12, null, 
                                                   "prbs_companyid = " + comp_companyid , 
                                                   "prbs_Date Desc ");
        sContent = sContent + createAccpacBlockFooter();
    } else {
        var recBBScores = eWare.CreateQueryObj("SELECT TOP 12 * FROM PRBBScore WITH (NOLOCK) WHERE prbs_CompanyID=" + comp_companyid + " ORDER BY prbs_Date DESC");
        recBBScores.SelectSQL();
        sContent = buildProduceBBScoreGrid(recBBScores, "BBScoreGrid", " BB Score Record");
    }

    var grdBBScores = eWare.GetBlock("content");
    grdBBScores.Contents=sContent;
    blkContainer.AddBlock(grdBBScores);

   tabContext = "&T=Company&Capt=Rating";

if (recCompany.comp_PRLocalSource !=  "Y") {

    if (recCompany.comp_PRIndustryType != "S") {
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup("1,2,10,18"))
            {
                blkContainer.AddButton(eWare.Button("Change", "edit.gif", eWare.URL("PRCompany/PRCompanyCreditWorth.asp") + "&E=PRCompany" + tabContext));
            }
            if (isUserInGroup(sSecurityGroups))
            {
                blkContainer.AddButton(eWare.Button("New Rating", "new.gif", eWare.URL("PRRating/PRRating.asp") + tabContext));
            }
        }
    }
    
    if ((recCompany.comp_PRIndustryType != "S") && (recCompany.comp_PRIndustryType != "L")) {
        blkContainer.AddButton(eWare.Button("TM/FM Status", "list.gif", eWare.URL("PRCompany/PRCompanyTM.asp") + tabContext));
    }
    
    if (recCompany.comp_PRIndustryType != "S") {    
        blkContainer.AddButton(eWare.Button("View&nbsp;All Rating&nbsp;Data", "list.gif", eWare.URL("PRCompany/PRCompanyRatingFull.asp") + tabContext));
    }

    if (recCompany.comp_PRIndustryType == "L") {

        var sAddPIURL = "javascript:if (confirm('Are you sure you want to add a new Pay Indicator to this company?')) { location.href='" + eWare.URL("PRCompany/PRCompanyPayIndicatorGenerate.aspx") + tabContext + "';}";
        blkContainer.AddButton(eWare.Button("Add Pay Indicator", "new.gif", sAddPIURL));
        //blkContainer.AddButton(eWare.Button("View&nbsp;All Pay Indicators", "list.gif", eWare.URL("PRCompany/PRCompanyPayIndicatorListing.asp") + tabContext));
    }

    if (recCompany.comp_PRIndustryType != "S")  {
        blkContainer.AddButton(eWare.Button("View&nbsp;All BB&nbsp;Scores", "list.gif", eWare.URL("PRCompany/PRBBScoreListing.asp") + tabContext));
    }

    blkContainer.AddButton(eWare.Button("Financials", "list.gif", eWare.URL("PRCompany/PRCompanyFinancial.asp") + tabContext));
    blkContainer.AddButton(eWare.Button("Court Cases", "list.gif", eWare.URL("PRCompany/PRCourtCases.asp") + tabContext));
    blkContainer.AddButton(eWare.Button("PACA Complaints", "list.gif", eWare.URL("PRCompany/PRPACAComplaints.asp") + tabContext));
}

if (!isEmpty(comp_companyid)) {
   eWare.AddContent(blkContainer.Execute());
}

Response.Write(eWare.GetPage('Company'));

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

%>
<!-- #include file="CompanyFooters.asp" -->

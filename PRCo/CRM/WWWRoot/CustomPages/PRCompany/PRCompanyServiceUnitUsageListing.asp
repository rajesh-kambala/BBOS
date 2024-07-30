<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2016

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

	doPage();

function doPage() {

	var sSecurityGroups = "1,2,3,5,6,10,11";

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;
	var f_value = new String(Request.QueryString("F"));
	if (isEmpty(f_value))
	{
		f_value = "PRCompany/PRCompanySummary.asp";
	}

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");    

	// determine if any of the addtional banners should show
	var blkBanners = eWare.GetBlock('content');
	blkBanners.contents = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr><td>This page displays the Business Report usage for this company's ENTERPRISE.</td></tr></table> ";
	blkContainer.AddBlock(blkBanners);

	var sCurrentUnitsSQL = "SELECT dbo.ufn_GetAvailableUnits(" + recCompany("comp_PRHQID") + ") as nUnits ";
	recQuery = eWare.CreateQueryObj(sCurrentUnitsSQL);
	recQuery.SelectSql();
	sUnits = recQuery("nUnits");

	var sCurrentUnitsAllocatedSQL = "SELECT dbo.ufn_GetAllocatedUnits("+ recCompany("comp_PRHQID") + ") as nUnitsAllocated ";
	recQuery = eWare.CreateQueryObj(sCurrentUnitsAllocatedSQL);
	recQuery.SelectSql();
	sUnitsAllocated = recQuery("nUnitsAllocated");

	var blkContent = eWare.GetBlock("content");
	var sContents = createAccpacBlockHeader("Reports","Available Reports", "100%");
	sContents += "<table cellpadding=0 cellspacing=0 border=0><tr><td width=100%  CLASS=ROW2><SPAN ID=_Captprbr_remainingunits class=VIEWBOXCAPTION>&nbsp;Currently Remaining Reports:&nbsp;</SPAN><SPAN >" + sUnits + " of " + sUnitsAllocated + "</SPAN></TD></TR></TABLE>";
	sContents += getUnitUsageHistorySummary(recCompany("comp_PRHQID"));
	sContents +=createAccpacBlockFooter();
	blkContent.contents = sContents;
	blkContainer.AddBlock(blkContent);

	var lstMain = eWare.GetBlock("PRServiceUnitUsageHistoryGrid");
	lstMain.prevURL = eWare.URL(f_value);
	entry=lstMain.GetGridCol("prsuu_CreatedDate");
	entry.OrderByDesc = true;
	
	lstMain.GetGridCol("FullName").Title = "Person";
	lstMain.GetGridCol("RequestingCompany").Title = "Location"
	lstMain.GetGridCol("AdditionalInfo").Title = "Additional Info"

	
	blkContainer.AddBlock(lstMain);

	sContinueAction = "PRCompany/PRCompanyService.asp";
	blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + "&T=Company&Capt=Services"));

	var btnProvideBRtoThisCompany = eWare.Button("New B/R Request","new.gif", eWare.URL("PRCompany/PRCompanyBRRequest.asp")+"&comp_companyid="+comp_companyid + "&T=Company&Capt=Services");
	blkContainer.AddButton(btnProvideBRtoThisCompany);


	//Response.Write("<br/>recCompany(\"comp_PRHQID\"):" + recCompany("comp_PRHQID"));

	if (!isEmpty(recCompany("comp_PRHQID"))) 
	{   
		eWare.AddContent(blkContainer.Execute("prsuu_HQID=" + recCompany("comp_PRHQID")));
	}

	Response.Write(eWare.GetPage('Company'));
}

function getUnitUsageHistorySummary(HQID) {

	var sClass = "ROW2";
	var buffer = "<table class=\"CONTENT\" style=\"margin-top:10px;margin-bottom:5px;\" ><tr><th class=\"GRIDHEAD\" align=center>Year</th><th class=\"GRIDHEAD\" align=center>Online Business Report</th><th class=\"GRIDHEAD\" align=center>Fax Business Report</th><th class=\"GRIDHEAD\" align=center>Verbal Business Report</th><th class=\"GRIDHEAD\" align=center>Email Business Report</th><th class=\"GRIDHEAD\" align=center>Totals</th></tr>";

	var qryRecords = eWare.CreateQueryObj("SELECT * FROM dbo.ufn_GetUnitUsageHistorySummary(" + HQID + ", 4) ORDER BY [Year] DESC");
	qryRecords.SelectSQL();
	while (!qryRecords.eof) {

		if (sClass == "ROW2") {
			sClass = "ROW1";
		} else {
			sClass = "ROW2";
		}

		buffer += "<tr>";
		buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"100px\">" + qryRecords("Year") + "</td>";
		buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"175px\">" + qryRecords("OBR") + "</td>";
		buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"175px\">" + qryRecords("FBR") + "</td>";
		buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"175px\">" + qryRecords("VBR") + "</td>";
		buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"175px\">" + qryRecords("EBR") + "</td>";
        buffer += "<td class=\"" + sClass + "\" align=\"center\" width=\"250px\">" + qryRecords("TOTAL") + "</td>";
		buffer += "</tr>";
		qryRecords.NextRecord();
	}
	
	buffer += "</table>";
	return buffer;
}
%>
<!-- #include file="CompanyFooters.asp" -->

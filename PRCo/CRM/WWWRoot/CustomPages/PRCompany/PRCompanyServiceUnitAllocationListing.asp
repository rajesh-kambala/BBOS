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
    var sSecurityGroups = "1,2,3,5,6,11";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    var f_value = new String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRCompanySummary.asp";
    }

    if (eWare.Mode == "95")
    {
        var sql = "EXEC usp_CancelAllServiceUnits " + comp_companyid + ", 0";
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        Response.Write("<script>alert('The service units have been successfully cancelled.');</script>");
        eWare.Mode = View;
    }


    var sCurrentUnitsSQL = "Select dbo.ufn_GetAvailableUnits("+ comp_companyid + ") as nUnits ";
    recQuery = eWare.CreateQueryObj(sCurrentUnitsSQL);
    recQuery.SelectSql();
    sUnits = recQuery("nUnits");

    var sCurrentUnitsAllocatedSQL = "Select dbo.ufn_GetAllocatedUnits("+ comp_companyid + ") as nUnitsAllocated ";
    recQuery = eWare.CreateQueryObj(sCurrentUnitsAllocatedSQL);
    recQuery.SelectSql();
    sUnitsAllocated = recQuery("nUnitsAllocated");

    blkContent = eWare.GetBlock("content");
    var sContents = createAccpacBlockHeader("Units","Available Business Reports", "100%");
    sContents += "<table border=\"0\"><tr>";
    sContents += "<tr><td width=\"100%\"><span class=\"VIEWBOXCAPTION\">Total Allocated Business Reports:&nbsp;</span><br/><span class=\"VIEWBOX\">" + sUnitsAllocated + "</span></td></tr>";
    sContents += "<tr><td width=\"100%\"><span class=\"VIEWBOXCAPTION\">Remaining Business Reports:&nbsp;</span><br/><span class=\"VIEWBOX\">" + sUnits +  "</span></td></tr>";
    sContents += "</TABLE>";
    sContents +=createAccpacBlockFooter();
    blkContent.contents = sContents;
    blkContainer.AddBlock(blkContent);

    lstMain = eWare.GetBlock("PRServiceUnitAllocationGrid");
    lstMain.prevURL = eWare.URL(f_value);
    
    blkContainer.AddBlock(lstMain);

    sContinueAction = "PRCompany/PRCompanyService.asp";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + "&T=Company&Capt=Services"));
    blkContainer.AddButton( eWare.Button("Add'l Business Reports Package","New.gif", eWare.URL("PRCompany/PRCompanyServiceUnitAllocation.asp") + "&T=Company&Capt=Services"));

    if (sUnits > 0) {
        var confirm = "javascript:if (confirm('Are you sure you want to cancel all business report allocations for this company?')) { location.href='" + changeKey(sURL, "em", "95") + "';}";
        blkContainer.AddButton(eWare.Button("Cancel Business Report Allocations", "delete.gif", confirm));
    }


    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("prun_CompanyId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));
%>
    <!-- #include file="CompanyFooters.asp" -->
<%
}
%>
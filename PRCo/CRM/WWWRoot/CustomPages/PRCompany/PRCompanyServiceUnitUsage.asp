<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
    var sSecurityGroups = "1,2,3,5,6,10,11";

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    // this screen will always show in view mode
    eWare.Mode=View;

    var blkMain=eWare.GetBlock("PRServiceUnitUsageSummary");
    blkMain.Title="Business Report Usage";
    Entry = blkMain.GetEntry("prsuu_CompanyId");
    Entry.Hidden = true;

    // Determine if this is new or edit
    var prsuu_ServiceUnitUsageId = getIdValue("prsuu_ServiceUnitUsageId");

    sListingAction = eWare.Url("PRCompany/PRCompanyServiceUnitUsageListing.asp")+ "&prsuu_CompanyId=" + comp_companyid + "&T=Company&Capt=Services";

    recSUU = eWare.FindRecord("vPRServiceUnitUsage", "prsuu_ServiceUnitUsageId=" + prsuu_ServiceUnitUsageId);

    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

    // if this is a reversal, do not show the "Reverse Bus Report Charge" button
    if ( recSUU("prsuu_TransactionTypeCode") != "R" && recSUU("prsuu_Units") > 0 )
    {
        if (isUserInGroup(sSecurityGroups))
        {
            sDeleteUrl = eWare.URL("PRCompany/PRCompanyServiceUnitReversal.asp")+"&prsuu_ServiceUnitUsageId=" + prsuu_ServiceUnitUsageId + "&T=Company&Capt=Services";
            blkContainer.AddButton(eWare.Button("Reverse Bus Report Charge", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
        }
    }
    
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recSUU));
    
    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->
<script type="text/javascript">
    function initBBSI()
    {
        InsertDivider("Businss Report Request Info", "_Captprbr_requestorinfo"); 
    }
    if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
</script>

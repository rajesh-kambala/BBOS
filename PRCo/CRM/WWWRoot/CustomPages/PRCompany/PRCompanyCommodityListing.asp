<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%
    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkContainer.AddBlock(blkGeneralContent);

    var sSecurityGroups = "1,2,3,4,5,6,10";

    List=eWare.GetBlock("CompanyPRCommodityGrid");
    List.prevURL=sURL;
    blkContainer.AddBlock(List);

    sContinueAction = eWare.Url("PRCompany/PRCompanyProfile.asp")+"&comp_companyid=" + comp_companyid + "&T=Company&Capt=Profile";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));

    if (isUserInGroup(sSecurityGroups))
    {
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            blkContainer.AddButton(eWare.Button("Assign Commodities", "selectall.gif", eWare.URL("PRCompany/PRCompanyCommodityAssign2.asp")));
        }
        sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=4&RepId=" + comp_companyid + "&comp_CompanyId=" + comp_companyid;
        blkContainer.AddButton(eWare.Button("Replicate", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
    }
    
    eWare.AddContent(blkContainer.Execute("prcca_CompanyId=" + comp_companyid));
    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->

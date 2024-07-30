<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkContainer.AddBlock(blkGeneralContent);

    var sSecurityGroups = "1,2,3,4,5,6,10";

    var sGridName = "PRCompanyClassificationGrid";
    var sAddNewPage = "PRCompany/PRCompanyClassification.asp";
    var sEntityCompanyIdName = "prc2_CompanyId";
    var sNewCaption = "New";
    // override the default continue location
    sContinueAction = "PRCompany/PRCompanyProfile.asp";

    lstMain = eWare.GetBlock(sGridName);
    lstMain.prevURL = eWare.URL(f_value);;
    blkContainer.AddBlock(lstMain);

    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + "&T=Company&Capt=Profile"));
    
    if (isUserInGroup(sSecurityGroups))
    {
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            blkContainer.AddButton( eWare.Button(sNewCaption,"New.gif", eWare.URL(sAddNewPage)) );
            blkContainer.AddButton(eWare.Button("Sequence", "selectall.gif", eWare.URL("PRCompany/PRCompanyClassificationAssign2.asp")));
        }
        sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=5&RepId=" + comp_companyid + "&comp_CompanyId=" + comp_companyid;
        blkContainer.AddButton(eWare.Button("Replicate", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
    }
    
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute(sEntityCompanyIdName + "=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->

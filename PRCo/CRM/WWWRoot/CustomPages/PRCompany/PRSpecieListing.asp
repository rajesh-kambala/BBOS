<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    var sGridName = "PRCompanySpecieGrid";
    var sAddNewPage = "PRCompany/PRSpecieAssign.asp";
    var sEntityCompanyIdName = "prcspc_CompanyID";
    var sNewCaption = "Assign Species";
    // override the default continue location
    sContinueAction = "PRCompany/PRCompanyProfile.asp";
    var sSecurityGroups = "1,2,3,4,5,6,10";

    lstMain = eWare.GetBlock(sGridName);
    lstMain.prevURL = eWare.URL(f_value);;
    blkContainer.AddBlock(lstMain);

    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + "&T=Company&Capt=Profile"));
    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        if (isUserInGroup(sSecurityGroups))
        {
            blkContainer.AddButton( eWare.Button(sNewCaption,"New.gif", 
                                    eWare.URL(sAddNewPage)) );
                                    
            var sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=8&RepId=" + comp_companyid + "&comp_CompanyId=" + comp_companyid;
            blkContainer.AddButton(eWare.Button("Replicate", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
        }
    }
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute(sEntityCompanyIdName + "=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));
%>
<!-- #include file="CompanyFooters.asp" -->
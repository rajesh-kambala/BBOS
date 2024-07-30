<%
    lstMain = eWare.GetBlock(sGridName);
    lstMain.prevURL = eWare.URL(f_value);;
    blkContainer.AddBlock(lstMain);

     // sContinueAction defaults to "PRCompany/PRCompanySummary.asp" in CompanyHeaders.asp
     // override in the calling routine for a different location --see PRCompanyBankListing.asp
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + tabContext));
    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        if (isUserInGroup(sSecurityGroups))
        {
            blkContainer.AddButton( eWare.Button(sNewCaption,"New.gif", 
                                    eWare.URL(sAddNewPage)) );
        }
    }
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute(sEntityCompanyIdName + "=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));
%>

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCOGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2018-2019

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

function doPage()
{
    bDebug=false;

    var blkMain = eWare.GetBlock("CompanyTradeShowContactNewEntry");
    blkMain.Title = "Trade Show Contact";
    Entry = blkMain.GetEntry("prctsc_CompanyId");
    Entry.Hidden = true;

    var recCompany = null;
    recCompany = eWare.FindRecord("company","comp_companyid=" + comp_companyid);

    var bNew = false;
    
    var prctsc_CompanyTradeShowContactID = getIdValue("prctsc_CompanyTradeShowContactID");
    var edit = getIdValue("edit");

    // Determine if this is new or edit
    if (prctsc_CompanyTradeShowContactID == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }

    if(edit == "1")
    {
        //Force into edit mode without a transaction
        eWare.Mode = Edit;
        sURL = removeKey(sURL, "edit");
    }

    DEBUG("bNew=" + bNew);
    DEBUG("eWare.Mode=" + eWare.Mode);
    DEBUG("comp_companyid=" + comp_companyid);
    
    EntryPerson = blkMain.GetEntry("prctsc_PersonId");
    EntryPerson.Restrictor = "prctsc_CompanyId";

    sListingAction = eWare.Url("PRCompany/PRCompanyTradeShowContactListing.asp")+ "&comp_companyid="+ comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyTradeShowContact.asp")+ "&comp_companyid="+ comp_companyid + "&prctsc_CompanyTradeShowContactID=" + prctsc_CompanyTradeShowContactID;

    recPRCompanyTradeShowContact = eWare.FindRecord("PRCompanyTradeShowContact", "prctsc_CompanyTradeShowContactID=" + prctsc_CompanyTradeShowContactID);

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyTradeShowContact.js\"></script>");

    if(recCompany.comp_PRIndustryType == "L")
    {
        blkMain.GetEntry("prctsc_TradeShowCode").LookupFamily = "prctsc_TradeShowCode_L";
    }
    else
    {
        if(eWare.Mode == Edit)
            blkMain.GetEntry("prctsc_TradeShowCode").LookupFamily = "prctsc_TradeShowCode_PTS";
    }

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recPRCompanyTradeShowContact=eWare.CreateRecord("PRCompanyTradeShowContact");
                recPRCompanyTradeShowContact.prctsc_CompanyId = comp_companyid;
                Entry.DefaultValue = comp_companyid;
            }
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }

        sSaveAction = changeKey(sURL, "em", "2");
        sSaveAction = removeKey(sSaveAction, "edit");
        blkContainer.AddButton(eWare.Button("Save", "Save.gif", "javascript:document.EntryForm.action='" + sSaveAction + "'; save();"));
    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyTradeShowContact WHERE prctsc_CompanyTradeShowContactID="+ prctsc_CompanyTradeShowContactID;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        sChangeAction = changeKey(sURL, "edit", "1");
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sChangeAction + "';document.EntryForm.submit();"));

        tabContext = "&Capt=Sales+Mgmt";
        blkContainer.AddButton(eWare.Button("New Opportunity", "NewOpportunity.gif", removeKey(eWare.URL("PROpportunity/PROpportunitySummary.asp"), "Key7") + "&Type=NEWM&PPID=" + recPRCompanyTradeShowContact.prctsc_PersonId + tabContext));
    }

    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recPRCompanyTradeShowContact));

    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else
    {
        Response.Write(eWare.GetPage());
    }
}
%>
<!-- #include file="CompanyFooters.asp" -->

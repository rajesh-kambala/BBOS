<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2011

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
%>

<!-- #include file ="CompanyHeaders.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10,11";
    
    var sBankCountMaxMsg = "";
    blkMain=eWare.GetBlock("PRCompanyBankNewEntry");
    blkMain.Title="Bank";
    Entry = blkMain.GetEntry("prcb_CompanyId");
    //Entry.Hidden = true;

    // Determine if this is new or edit
    var prcb_CompanyBankId = getIdValue("prcb_CompanyBankId");
    // indicate that this is new
    if (prcb_CompanyBankId == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRCompany/PRCompanyBankListing.asp")+ "&prcb_CompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyBank.asp")+ "&prcb_CompanyBankId="+ prcb_CompanyBankId;

    recCompanyBank = eWare.FindRecord("PRCompanyBank", "prcb_CompanyBankId=" + prcb_CompanyBankId);

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");  
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyBank.js\"></script>");  

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recCompanyBank=eWare.CreateRecord("PRCompanyBank");
                recCompanyBank.prcb_CompanyId = comp_companyid;
                Entry.DefaultValue = comp_companyid;
            }
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups ))
    	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"save();\""));

        }

    	if (eWare.Mode == Edit)
    	{
            sSQL = " SELECT prcb_CompanyBankId from PRCompanyBank where prcb_Publish = 'Y' and prcb_CompanyId="+comp_companyid;
            recPublishedBanks = eWare.CreateQueryObj(sSQL);
            recPublishedBanks.SelectSQL();

            if ((recPublishedBanks.RecordCount >= 2) &&
                (recCompanyBank.prcb_Publish != "Y"))
            {
                entry = blkMain.GetEntry("prcb_Publish");
                entry.Hidden = true;    
                sBankCountMaxMsg = "This bank cannot be published because two published banks already exist.";
                Response.Write("<table style=\"display:none;\"><tr ID=\"_trUsage\"><td colspan=\"4\" class=\"GRAYEDTEXT\">"+ sBankCountMaxMsg +"</td></tr></table>");
            
            }
    	
    	}

	}
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyBank WHERE prcb_CompanyBankId="+ prcb_CompanyBankId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups ))
            {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
    	}

    }
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recCompanyBank));
    
    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");

        if (sBankCountMaxMsg != "")
        {
            Response.Write("\n        InsertRow(\"_Captprcb_name\", \"_trUsage\"); " ); 
        }        
        
        Response.Write("\n        document.getElementById('prcb_companyid').value='" + comp_companyid + "';");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
        
    }
    else
        Response.Write(eWare.GetPage());

%>
<!-- #include file="CompanyFooters.asp" -->

<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2018

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
%>

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    /********************************************************************************* 
     * It is possible that a PRCompanyInfoProfile record will not exist for this entity.
     * If this is the case just show the empty screen.  Otherwise, show it populated.
     * When the user tries to go into edit mode, we'll determine if a record exists and
     * act accordingly.
     *
     ********************************************************************************/
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    // Create the form
	blkEntry1 = eWare.GetBlock("PRCompanyInfoProfileHeader");
	blkEntry1.Title = "Info Profile Header";

	blkEntry5 = eWare.GetBlock("PRCompanyInfoProfileFlags");
	blkEntry5.Title = "Profile Flags";
    if (recCompany.comp_PRIndustryType != "L") {
        blkEntry5.GetEntry("prc5_CLSubmitter").Hidden = true;
    }

	blkEntry3 = eWare.GetBlock("PRCompanyCreditProcess");
	blkEntry3.Title = "Credit Decision Making Process";

	blkEntry4 = eWare.GetBlock("PRCompanyAccountingSoftware");
	blkEntry4.Title = "Accounting Software Used";

	blkEntry6 = eWare.GetBlock("PRCompanyChristmasCards");
	blkEntry6.Title = "BBSI Christmas Card Settings";

    blkEntry7 = eWare.GetBlock("PRCompanyExperian");
	blkEntry7.Title = "Experian Flags";

    blkEntry7.GetEntry("prcex_UpdatedDate").ReadOnly = true;
    blkEntry7.GetEntry("prcex_UpdatedBy").ReadOnly = true;

    if(eWare.Mode == 95)
    {
        var qryExperianBIN = eWare.CreateQueryObj("EXEC usp_ExperianBINSearch " + comp_companyid + ", " + user_userid);
        qryExperianBIN.ExecSql();

        var qryExperianResults = eWare.CreateQueryObj("SELECT prcex_SearchResultCode, prcex_SearchResultMessage FROM PRCompanyExperian WHERE prcex_CompanyID = " + comp_companyid);
        qryExperianResults.SelectSQL();
        if(!qryExperianResults.eof)
        {
            var sCode = qryExperianResults("prcex_SearchResultCode");
            var sMessage = qryExperianResults("prcex_SearchResultMessage");
       
            Session("sUserMsg") = sMessage;
        }

        eWare.Mode = View;
    }

    if (eWare.Mode != Edit)
    	blkContainer.AddBlock(blkEntry1);
    
    blkContainer.AddBlock(blkEntry5);
	blkContainer.AddBlock(blkEntry3);
	blkContainer.AddBlock(blkEntry4);
    blkContainer.AddBlock(blkEntry6);
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkEntry7);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        recCompanyInfoProfile = eWare.FindRecord("PRCompanyInfoProfile", "prc5_CompanyId=" + comp_companyid);
        if (recCompanyInfoProfile.eof)
        {
	        recCompanyInfoProfile = eWare.CreateRecord("PRCompanyInfoProfile");
            recCompanyInfoProfile.prc5_CompanyId = comp_companyid;
            Entry = blkEntry1.AddEntry("prc5_CompanyId");
            Entry.DefaultValue = comp_companyid;
            Entry.Hidden = true;
	    }
                
        sCancelAction = eWare.Url("PRCompany/PRCompanyInfoProfile.asp");
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));

		recCompanyExperian = eWare.FindRecord("PRCompanyExperian", "prcex_CompanyId=" + comp_companyid);
		if (recCompanyExperian.eof)
		{
			recCompanyExperian = eWare.CreateRecord("PRCompanyExperian");
			recCompanyExperian.prcex_CompanyId = comp_companyid;
			Entry = blkEntry7.AddEntry("prcex_CompanyId");
			Entry.DefaultValue = comp_companyid;
			Entry.Hidden = true;
		}
    }
    else 
    {
        recCompanyInfoProfile = eWare.FindRecord("PRCompanyInfoProfile", "prc5_CompanyId=" + comp_companyid);
        sContinueAction = eWare.Url("PRCompany/PRCompanySummary.asp");
        blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));
	    blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("Lookup Experian Bin", "save.gif", "javascript:document.EntryForm.em.value='95';document.EntryForm.submit();"));

		blkContainer.AddButton(eWare.Button("Tradeshow Contacts","list.gif", eWare.URL("PRCompany/PRCompanyTradeShowContactListing.asp") + "&comp_companyId=" + comp_companyid));
		
		recCompanyExperian = eWare.FindRecord("PRCompanyExperian", "prcex_CompanyId=" + comp_companyid);
    }

	blkEntry1.ArgObj = recCompanyInfoProfile;
	blkEntry3.ArgObj = recCompanyInfoProfile;
	blkEntry4.ArgObj = recCompanyInfoProfile;
	blkEntry5.ArgObj = recCompanyInfoProfile;
	blkEntry6.ArgObj = recCompanyInfoProfile;
	
	blkEntry7.ArgObj = recCompanyExperian;

    eWare.AddContent(blkContainer.Execute());

    if (eWare.Mode == Save) {
	    Response.Redirect(eWare.Url("PRCompany/PRCompanyInfoProfile.asp"));
    }
    if (eWare.Mode == Edit) 
	    Response.Write(eWare.GetPage("Company"));
	else
	    Response.Write(eWare.GetPage("Company"));

    if (eWare.Mode == Edit)
    {
    %>
        <script type="text/javascript" >
            function initBBSI() 
            {
                document.getElementById('_IDprc5_receivechristmascard').onclick = toggleChristmasCard;
                toggleChristmasCard();
            }

            function toggleChristmasCard() {
                if (document.getElementById("_IDprc5_receivechristmascard").checked) {
                    document.getElementById("prc5_christmascardassociate1Input").disabled = false;
                    document.getElementById("prc5_christmascardassociate1").disabled = false;
                    document.getElementById("prc5_christmascardassociate2Input").disabled = false;
                    document.getElementById("prc5_christmascardassociate2").disabled = false;
                    document.getElementById("prc5_christmascardassociate3Input").disabled = false;
                    document.getElementById("prc5_christmascardassociate3").disabled = false;
                    document.getElementById("prc5_christmascardfieldrepInput").disabled = false;
                    document.getElementById("prc5_christmascardfieldrep").disabled = false;
                } else {
                    document.getElementById("prc5_christmascardassociate1Input").disabled = true;
                    document.getElementById("prc5_christmascardassociate1").disabled = true;
                    document.getElementById("prc5_christmascardassociate2Input").disabled = true;
                    document.getElementById("prc5_christmascardassociate2").disabled = true;
                    document.getElementById("prc5_christmascardassociate3Input").disabled = true;
                    document.getElementById("prc5_christmascardassociate3").disabled = true;
                    document.getElementById("prc5_christmascardfieldrepInput").disabled = true;
                    document.getElementById("prc5_christmascardfieldrep").disabled = true;
                }
            }

            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>

        
    <%
    }

    displayUserMsg();
    %>
<!-- #include file="CompanyFooters.asp" -->

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="PACASupportFunctions.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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

<%
    var sEntityName="PRImportPACALicense";
    var sEntityTitle="Pending PACA License";
    var sEntityIdField="pril_ImportPACALicenseId";

    var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
    //Response.Write("URL: " + sURL); 
    //Response.Write("<br>nMode: " + eWare.Mode);

    user_UserId = eWare.getContextInfo("User", "User_UserId");

    // check the custom action parameter
    customact = getString(Request.QueryString("customact"));

    // Determine the key id for this entity type
    var pril_ImportPACALicenseId = new String(eWare.GetContextInfo('PRImportPACALicense','pril_ImportPACALicenseId'));
    if (pril_ImportPACALicenseId.toString() == "undefined" || pril_ImportPACALicenseId.toString() == "") 
    {
        pril_ImportPACALicenseId = new String(Request.Querystring(sEntityIdField));
    }
    if (pril_ImportPACALicenseId.toString() == "undefined" || pril_ImportPACALicenseId.toString() == "") 
    {
    // Last chance
    pril_ImportPACALicenseId = new String(Request.Querystring("Key58"));
    }

    if (pril_ImportPACALicenseId.toString() == "undefined" || pril_ImportPACALicenseId.toString() == "" || pril_ImportPACALicenseId.toString() == "0") 
    {
        Response.Redirect(eWare.URL("PRPACALicense/PRImportPACALicenseFind.asp"));    
    }

    // now set it again to hide the tabs
    eWare.SetContext("Find");

    // find the record based upon the ID
    pril_record = eWare.FindRecord(sEntityName, sEntityIdField+"="+pril_ImportPACALicenseId);


    // We should never hit this if, but leave it here as an example
    if (isEmpty(pril_ImportPACALicenseId) || pril_ImportPACALicenseId.toString() == "0")   {
        Valid = false;
        ErrorStr = "The Import PACA License record could not be determined.";
    } else  { 

        sPageContinue =eWare.URL("PRPACALicense/PRImportPACALicenseFind.asp");

        // For some reason the eWare.URL call above returns a link to the eWare DLL and not our
        // page.  This is a hack work-around.
        sPageContinue = sPageContinue.replace("eware.dll/Do", "CustomPages/PRPACALicense/PRImportPACALicenseFind.asp");

        if( eWare.Mode == Clear )
        {
            //record.DeleteRecord = true;
            //record.SaveChanges();
        }
        // This screen should always present as view
        eWare.Mode = View;
        MainContainer=eWare.GetBlock("container");

        MainContainer.DisplayButton(Button_Default) = false;
        TopContainer=eWare.GetBlock("container");
        if (!isEmpty(customact))
        {
            if (customact.toString() == "assigncomp")
            {
                eWare.Mode = Edit;    
                blkAssign = eWare.GetBlock("PRPACALicenseAssignBBId");
                blkAssign.Title = "Assign Company";
                TopContainer.AddBlock(blkAssign);

                sSaveLink = eWare.URL("InvokeStoredProc.aspx")+"&customact=AssignImportedPACA&sp_type=0&pril_ImportPACALicenseId="+pril_ImportPACALicenseId;
                sCancelLink = removeKey(sURL, "customact");

                var sCheckActiveUrl = eWare.URL("PRPACALicense/PRImportPACALicenseActiveCheck.asp") + "&prpa_companyid=" 
                sSaveLinkWithCheck= "#\" onclick=\"if (validateAssignCompany()) checkActiveLicense('" + sCheckActiveUrl + "', '" + sSaveLink + "');";

                MainContainer.AddButton(eWare.Button("Save", "save.gif", sSaveLinkWithCheck));
                MainContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelLink)); 

            } else if (customact.toString() == "assignpaca")
            {
                eWare.Mode = Edit;    
                blkAssign = eWare.GetBlock("PRPACALicenseAssign");
                blkAssign.Title = "Assign Existing PACA License";
                TopContainer.AddBlock(blkAssign);
                               
                sSaveLink = eWare.URL("InvokeStoredProc.aspx")+"&customact=AssignImportedPACA&sp_type=2&pril_ImportPACALicenseId="+pril_ImportPACALicenseId;
                sCancelLink = removeKey(sURL, "customact");
                MainContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='"+sSaveLink+"';document.EntryForm.submit()"));
                MainContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelLink)); 

            }    
        
        }
        else
        {
            MainContainer.DisplayButton(Button_Default) = false;
    
            sExistingCompanyLink = "#\" onclick=\"checkDupLicense('" + eWare.URL("PRPACALicense/PRImportPACALicenseSummary.asp")+"&customact=assigncomp&pril_ImportPACALicenseId="+pril_ImportPACALicenseId+"&em="+Edit + "');";
            sNewCompanyLink = "#\" onclick=\"checkDupLicense('" + eWare.URL("PRCompany/PRCompanyNew.asp")+"&pril_ImportPACALicenseId="+pril_ImportPACALicenseId + "');";
            sExistingLicenseLink = eWare.URL("PRPACALicense/PRImportPACALicenseSummary.asp")+"&customact=assignpaca&pril_ImportPACALicenseId="+pril_ImportPACALicenseId;

            MainContainer.AddButton(eWare.Button("Continue","continue.gif", sPageContinue)); 
            MainContainer.AddButton("<b>Assign To:</b>"); 
            MainContainer.AddButton(eWare.Button("Existing BBS Company","new.gif", sExistingCompanyLink)); 
            MainContainer.AddButton(eWare.Button("New BBS Company","new.gif", sNewCompanyLink)); 
            MainContainer.AddButton(eWare.Button("Existing PACA License","new.gif", sExistingLicenseLink)); 
        }
        
        blkSummaryContent=eWare.GetBlock("PRImportPACALicenseNewEntry");
        entry = blkSummaryContent.GetEntry("pril_LicenseNumber");
        entry.ReadOnly = true;
        blkSummaryContent.ArgObj = pril_record;
        blkSummaryContent.Title = sEntityTitle;
        TopContainer.AddBlock(blkSummaryContent);

        // add the Principal and Trade grids 
        BottomContainer=eWare.GetBlock("container");

        blkPrincipalGrid=eWare.GetBlock("PRImportPACAPrincipalGrid");
        blkPrincipalGrid.DisplayForm = false;
        blkPrincipalInner = eWare.GetBlock("Content");

        blkTradeInner = eWare.GetBlock("Content");
        blkTradeInner.NewLine = false;
        blkTradeGrid=eWare.GetBlock("PRImportPACATradeGrid");
        blkTradeGrid.DisplayForm = false;
        blkTradeGrid.NewLine = false;

        blkPrincipalInner.contents = blkPrincipalGrid.Execute("prip_LicenseNumber='"+pril_record.pril_LicenseNumber+"'");
        blkTradeInner.contents = blkTradeGrid.Execute("prit_LicenseNumber='"+pril_record.pril_LicenseNumber+"'");

        BottomContainer.AddBlock(blkPrincipalInner);
        BottomContainer.AddBlock(blkTradeInner);
        
        MainContainer.AddBlock(TopContainer);
        MainContainer.AddBlock(BottomContainer);
        
        MainContainer.Checklocks = false;
    eWare.AddContent(MainContainer.Execute());
    //eWare.AddContent(MainContainer.Execute("pril_LicenseNumber='"+pril_record.pril_LicenseNumber+"'"));
    }

    Response.Write("<script src=./PRImportPACAInclude.js></script>");
    Response.Write(eWare.GetPage());

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
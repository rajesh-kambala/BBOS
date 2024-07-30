<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission ofBlue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc..
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
%>
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<%
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    

    // set up the main record
    blkMain=eWare.GetBlock("PRCompanyNotes");

    var CompanyID = new String(Request.QueryString("Key1"));
    var nt = new String(Request.QueryString("notetype"));

    entry = blkMain.GetEntry("prcomnot_CompanyNoteNote");

    if(nt=="FINANCIAL")
    {
        blkMain.Title="Financial Statements Analysis Notes";
        entry.Caption = "FS Analysis Notes:";
        sListingAction = eWare.Url("PRCompany/PRCompanyFinancial.asp")+ "&comp_companyID=" + comp_companyid + "&T=Company&Capt=Rating";
    }
    else if(nt=="TRADEACTIVITY")
    {
        blkMain.Title="Trade Activity Notes";
        entry.Caption = "Trade Activity Notes:";
        sListingAction = eWare.Url("PRCompany/PRCompanyTradeActivityListing.asp")+ "&comp_companyID=" + comp_companyid + "&T=Company&Capt=Trade+Activity";
    }
    else if(nt=="DL")
    {
        blkMain.Title="Descriptive Line Notes";
        entry.Caption = "Descriptive Line Notes:";
        sListingAction = eWare.Url("PRCompany/PRCompanyDLView.asp") + "&comp_companyID=" + comp_companyid + "&T=Company&Capt=Profile";                                                       
    }
    else if(nt=="PRCCI")
    {
        blkMain.Title="Contact Info Notes";
        entry.Caption = "Contact Info Notes:";
        sListingAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + "&comp_companyID=" + comp_companyid + "&T=Company";
    }
    else
    {
        Response.Write("Invalid notetype");
        Response.End;
    }
        
    if (eWare.Mode < Edit)
        eWare.Mode = Edit;

    recCompanyNote = eWare.FindRecord("PRCompanyNote", "prcomnot_CompanyId=" + comp_companyid + " AND prcomnot_CompanyNoteType='" + nt + "'");

    if (eWare.Mode == Edit)
    {
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
    }

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);
    
    if (eWare.Mode == Save) 
    {
        if(recCompanyNote.eof)
        {
            //Not found - create record
            recCompanyNote = eWare.CreateRecord("PRCompanyNote");
            recCompanyNote.prcomnot_CompanyId = CompanyID;
            recCompanyNote.prcomnot_CompanyNoteType = nt;
        }

        recCompanyNote.prcomnot_CompanyNoteNote = getFormValue("prcomnot_CompanyNoteNote");
        recCompanyNote.SaveChanges();
        Response.Redirect(sListingAction);
    }
    else
    {
        eWare.AddContent(blkContainer.Execute(recCompanyNote));
        Response.Write(eWare.GetPage("Company"));
    }

%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->
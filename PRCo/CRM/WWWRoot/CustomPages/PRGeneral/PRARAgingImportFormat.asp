<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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

<!-- #include file ="../PRCOGeneral.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10,11";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    blkHeader=eWare.GetBlock("PRARAgingImportNewEntryHeader");
    blkHeader.Title="A/R Aging Import Format Header";
    Entry = blkHeader.GetEntry("praaif_ARAgingImportFormatID");
    Entry.Hidden = true;

    blkMain=eWare.GetBlock("PRARAgingImportNewEntry");
    blkMain.Title="A/R Aging Import Format";
    

    // Determine if this is new or edit
    var praaif_ARAgingImportFormatID = getIdValue("praaif_ARAgingImportFormatID");
    // indicate that this is new
    if (praaif_ARAgingImportFormatID == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRGeneral/PRARAgingImportFormatListing.asp");

    recARAgingImportFormat = eWare.FindRecord("PRARAgingImportFormat", "praaif_ARAgingImportFormatID=" + praaif_ARAgingImportFormatID);

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        Response.Write("<script language=javascript src=\"PRARAgingImportFormat.js\"></script>");
        if (bNew)
        {
            if (!isEmpty(praaif_ARAgingImportFormatID)) 
            {
                recARAgingImportFormat=eWare.CreateRecord("PRARAgingImportFormat");
                recARAgingImportFormat.praaif_ARAgingImportFormatID = praaif_ARAgingImportFormatID;
                Entry.DefaultValue = praaif_ARAgingImportFormatID;
            }
	    }
	    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    
        if (isUserInGroup(sSecurityGroups ))
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"if (validate()) save();\""));
	}
    
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (isUserInGroup(sSecurityGroups ))
        {
            sEditAction = eWare.Url("PRGeneral/PRARAgingImportFormat.asp")+ "&praaif_ARAgingImportFormatID="+ praaif_ARAgingImportFormatID;
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sEditAction + "';document.EntryForm.submit();"));
    	}

    }
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkHeader);
    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recARAgingImportFormat));
    
    if (eWare.Mode == Save) 
    {
        Response.Redirect(sListingAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('New'));
    }
    else
        Response.Write(eWare.GetPage("Find"));

%>
<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010

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

function doPage() {

    if (eWare.Mode < Edit) {
        eWare.Mode = Edit;
    }
    var sReturnAction = Session("PublicationArticleCompanyReturn");

    var blkContainer = eWare.GetBlock("container");
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.forms[0].submit();"));
    blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", sReturnAction));


    var prpbarc_PRPublicationArticleCompanyId = getIdValue("prpbarc_PRPublicationArticleCompanyId");
    var prpbar_PublicationArticleId = getIdValue("prpbar_PublicationArticleId");
    
    if (prpbarc_PRPublicationArticleCompanyId != -1) {
        recPRPublicationArticleCompany = eWare.FindRecord("PRPublicationArticleCompany", "prpbarc_PRPublicationArticleCompanyId=" + prpbarc_PRPublicationArticleCompanyId);
    } else {
        // get a new record and edit it.
        recPRPublicationArticleCompany = eWare.CreateRecord("PRPublicationArticleCompany");

    }

    if (eWare.Mode == PreDelete) {
        var qryDelete = eWare.CreateQueryObj("DELETE FROM PRPublicationArticleCompany WHERE prpbarc_PRPublicationArticleCompanyId=" + prpbarc_PRPublicationArticleCompanyId);
        qryDelete.ExecSql();
	    Response.Redirect(sReturnAction);        
        return;
    }

    var blkEntry = eWare.GetBlock("PRPublicationArticleCompanyEntry");

    if (eWare.Mode == Save) {
        blkEntry.Execute(recPRPublicationArticleCompany);
        Response.Redirect(sReturnAction);   
        return;
    }

    blkEntry.Title = "Associate Company";
    blkEntry.ArgObj=recPRPublicationArticleCompany;


    var entryArticleId = blkEntry.GetEntry("prpbarc_PublicationArticleID");    
    if (prpbarc_PRPublicationArticleCompanyId == -1) {
        entryArticleId.DefaultValue = prpbar_PublicationArticleId;
    } else {
        blkContainer.AddButton(eWare.Button("Delete", "Delete.gif", changeKey(sURL, "em", PreDelete)));    
    }
    entryArticleId.ReadOnly = 'true';




    blkContainer.AddBlock(blkEntry);
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage(""));
}

%>

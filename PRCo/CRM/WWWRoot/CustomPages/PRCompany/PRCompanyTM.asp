<!--#include file ="..\accpaccrm.js" -->
<!--#include file ="CompanyHeaders.asp"-->
<!--#include file ="..\AccpacScreenObjects.asp"-->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2010

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

<%
    var sSecurityGroups = "1,2,10";

    sListingAction = eWare.Url("PRCompany/PRCompanyRatingListing.asp")+ "&comp_companyid=" + comp_companyid + "&T=Company&Capt=Rating";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyTM.asp")+ "&comp_companyid="+ comp_companyid + "&T=Company&Capt=Rating";
    sSummaryAction = removeKey(sSummaryAction, "J");
    sSummaryAction = removeKey(sSummaryAction, "F");

    // We have one block that can be edited outside of a transaction.  The include files, however, reset
    // the eware mode to view if it is set to edit and no transaction is found.  So we put an 'Edit' variable
    // on the form action and use it here to reset the eWare mode to Edit.
    if (Request.QueryString("Edit") == "Y") {
        eWare.Mode = Edit;
    }

    var saveval=new String( Request.QueryString("saveval") );
    if ( !isEmpty(saveval) )
    {
	    // this is a return from InvokeStoredProc after a save action
	    // 0 indicates immediate return to the listing
	    // 1 indicates display of a user message regarding updated branch info
	    // Return Value: 1 = The branches were updated due to a change of TM/FM Awarded 
	    //                   from True to false on the HQ
        if (saveval == 0)
            Response.Redirect(sListingAction);
            
        if (saveval == 1)
        blkMessages = eWare.GetBlock("content");
        sContent = createAccpacBlockHeader("Messages", "Processing Messages");
        sContent = sContent + "\n    <TABLE>";
        
        sClass="ROW1";
        sContent = sContent + "\n        <TR>";
        sContent = sContent + "\n            <TD CLASS=" + sClass + " >" +
                        "Branches were updated due to a change of TM/FM Awarded." + "</TD> ";
        sContent = sContent + "\n        </TR>";

        sContent = sContent + "\n</TABLE>";

        sContent = sContent + createAccpacBlockFooter();
        blkMessages.Contents=sContent;

        blkContainer.AddBlock(blkMessages);
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
            
        eWare.AddContent(blkContainer.Execute());
        
        Response.Write(eWare.GetPage('Company'));
        
    }
    else
    {
        var bDisplayMain = true;
        var szCommentOnly = "N";
        
        // The comments can be edited outside of a transaction, so
        // if we are in edit mode, but not in a CRM transaction, do not
        // display the "Main" block.
        if ((eWare.Mode == Edit ) &&
            (iTrxStatus != TRX_STATUS_EDIT))
        {
            bDisplayMain = false;
            szCommentOnly = "Y";
        }
        
        if (bDisplayMain) {
            blkMain = eWare.GetBlock("PRTradingMember");
            blkMain.Title = "Trading Member Status";
            blkMain.ArgObj = recCompany;
        }
    
        blkComments = eWare.GetBlock("PRTradingMemberComment");
        blkComments.Title = "Trading Member Status Comments";
        blkComments.ArgObj = recCompany;


        if (eWare.Mode == Edit )
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
            if (isUserInGroup(sSecurityGroups))
            {
                // invoke the stored procedure module to save the record
                sSummaryAction = sSummaryAction.replace(/\&/g, "%26");
                sSaveLink = eWare.URL("InvokeStoredProc.aspx")+
                        "&customact=SaveCompanyTMFM&comp_companyid="+comp_companyid + "&CommentOnly=" + szCommentOnly +
                        "&RedirectURL="+ Server.UrlEncode(sSummaryAction);
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.action='"+sSaveLink+"';document.EntryForm.submit();"));
            }
	    }
        else 
        {
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
            if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "&Edit=Y';document.EntryForm.submit();"));
        }
        blkContainer.CheckLocks = false;

        if (bDisplayMain)
        {
            blkContainer.AddBlock(blkMain);
        }
        blkContainer.AddBlock(blkComments);

        eWare.AddContent(blkContainer.Execute(recCompany));
        
        if (eWare.Mode == Edit) 
            Response.Write(eWare.GetPage('Company'));
        else
            Response.Write(eWare.GetPage());
    }

%>
<!-- #include file="CompanyFooters.asp" -->

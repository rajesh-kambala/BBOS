<!-- #include file ="..\accpaccrm.js" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2011-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
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

    doPage();

function doPage()
{  

    var bNew = false;
    var recCase = null;
    var bKey8Null = false;
    
    var case_caseid = getIdValue("case_caseid");
    if (case_caseid == -1) {
        case_caseid = getIdValue("Key8");
    }
    if (case_caseid == -1)
        case_caseid = getIdValue("Key58");


    if (case_caseid == -1) {
        bNew = true;
    
        // start this in edit mode
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;

    } else {

        // If we have a case_caseid and it's not equal
        // to Key8, reset Key8.
        if ((getIdValue("case_caseid") != -1) &&
            (getIdValue("case_caseid") != getIdValue("Key8"))) {


            // If this isn't new, and we have an ID, but Key8 is not set
            // Then let's redirect to ourselves making sure Key8 is set.
            var url = eWare.URL("PRCase/PRCaseSummary.asp");
            var url = removeKey(url, "case_caseid");
            var url = removeKey(url, "Key58");
            //var url = changeKey(url, "Key0", "8");
        
            var url = changeKey(url, "Key8", case_caseid);
            Response.Write(url);
            Response.Redirect(url);
            return;
        }
    }


    // the listing can be from Company, User, or Team
    var sListingAction = eWare.Url("PRCase/PRCaseListing.asp");
    var sSummaryAction = eWare.URL("PRCase/PRCaseSummary.asp");
                
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.DisplayButton(Button_Default) = false;     
    blkContainer.CheckLocks = false;   
    
    if (eWare.mode == View) {
    
        recCompanyInfo = eWare.FindRecord("vPRCaseCompanyInfo", "case_caseID=" + case_caseid);    
        var blkCompanyInfo = eWare.GetBlock("PRCaseCompanyInfo");
        blkCompanyInfo.ArgObj = recCompanyInfo;
        blkCompanyInfo.Title = "Company Info"
        blkContainer.AddBlock(blkCompanyInfo);


        recInvoiceInfo = eWare.FindRecord("vPRCaseInvoiceInfo", "case_caseID=" + case_caseid);    
        var blkInvoiceInfo = eWare.GetBlock("PRCaseInvoiceInfo");
        blkInvoiceInfo.ArgObj = recInvoiceInfo;
        blkInvoiceInfo.Title = "Invoice Info"
        blkContainer.AddBlock(blkInvoiceInfo);

        recServiceInfo = eWare.FindRecord("PRService", "prse_HQID= dbo.ufn_BRGetHQID(" + recCompanyInfo("case_PrimaryCompanyID") + ") AND SalesKitItem='N'");    
	    var gridServiceInfo=eWare.GetBlock("PRCaseServicesGrid");
        gridServiceInfo.ArgObj = recServiceInfo;
        gridServiceInfo.PadBottom = false;
        blkContainer.AddBlock(gridServiceInfo);


	    var recPhone = eWare.FindRecord("VPRCompanyPhone","plink_RecordId=" + recCompanyInfo("case_PrimaryCompanyID"));
        var grdPhone = eWare.GetBlock("CompanyPhoneGrid");
        //grdPhone.DeleteGridCol("phon_companyid");
        grdPhone.DisplayForm=false;
        grdPhone.ArgObj = recPhone;
        grdPhone.PadBottom = false;
        blkContainer.AddBlock(grdPhone);


        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        
        var sEditAction = sSummaryAction + "&case_caseID=" + case_caseid;
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));

        eWare.AddContent(blkContainer.Execute());        
        Response.Write(eWare.GetPage("Case"));
        
        sTopContentUrl = eWare.URL("/PRCompany/CompanyTopContent.asp") + "&comp_companyid=" + recCompanyInfo("case_PrimaryCompanyID"); 
        return;
    }
    
    var errorMsg = null;
    if (eWare.mode == Save) {
        var sSQL = "SELECT COUNT(1) As ServiceInvCount FROM MAS_PRC.dbo.vBBSiMasterInvoices WITH (NOLOCK) WHERE UDF_MASTER_INVOICE='" + getFormValue("case_PRMasterInvoiceNumber") + "'";
        var qry = eWare.CreateQueryObj(sSQL);
        qry.SelectSQL();
        var cnt = qry("ServiceInvCount");
        if (cnt == 0) {
           errorMsg = "Unable to find the specified invoice number, " +  getFormValue("case_PRMasterInvoiceNumber") + ", in MAS.";
        }    
    
        sSQL = "SELECT COUNT(1) As CaseInvCount FROM Cases WITH (NOLOCK) WHERE case_PRMasterInvoiceNumber='" + getFormValue("case_PRMasterInvoiceNumber") + "' AND case_caseID <> " + case_caseid;
        qry = eWare.CreateQueryObj(sSQL);
        qry.SelectSQL();
        var cnt = qry("CaseInvCount");
        if (cnt > 0) {
           errorMsg = "The specified invoice number, " +  getFormValue("case_PRMasterInvoiceNumber") + ", is already associated with a case.";
        }    
    
    
        if (errorMsg != null) {
            eWare.mode = Edit;

            var blkBanners = eWare.GetBlock('content');
            blkBanners.contents = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\"><tr class=\"ErrorContent\"><td>" + errorMsg + "</td></tr></table> ";            
            blkContainer.AddBlock(blkBanners);
        }
    }
    
    
    
    blkSummary=eWare.GetBlock("PRCaseSummary");
    blkSummary.Title="Case Summary";     
    blkContainer.AddBlock(blkSummary);
    
    if (bNew) {
        
        recCase = eWare.CreateRecord("Cases");

        // set the defaults for the screen (for edit) and the record (for saves)
        recCase.case_AssignedUserId = user_userid;
        blkSummary.GetEntry("case_AssignedUserId").DefaultValue = user_userid;
        
        recCase.case_Status = "Open";
        blkSummary.GetEntry("case_Status").DefaultValue = "Open";
        
        if (!isEmpty(comp_companyid)) 
        {
            recCase.case_PrimaryCompanyId = comp_companyid;
            blkSummary.GetEntry("case_PrimaryCompanyId").DefaultValue = comp_companyid;
        }
    } else {
        recCase = eWare.FindRecord("Cases", "case_caseid=" + case_caseid);
    }    
    
    if ((eWare.mode == Edit)) {

        blkSummary.GetEntry("case_PrimaryCompanyId").ReadOnly = true;
        blkSummary.GetEntry("Case_PrimaryPersonId").Restrictor = "case_PrimaryCompanyId";

        if (bNew)
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", changeKey(sSummaryAction, "case_caseid", case_caseid)));

        blkContainer.AddButton(eWare.Button("save", "save.gif", "javascript:save();"));

        if (bNew)
        {
            eWare.AddContent(blkContainer.Execute()); 
        } else {
            eWare.AddContent(blkContainer.Execute(recCase)); 
        }
        
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCaseSummary.js\"></script>");
        Response.Write(eWare.GetPage("New"));
        
%>
       <script type="text/javascript">
           document.body.onload = function() {
               document.getElementById('case_primarycompanyid').value='<% =comp_companyid %>';
               RemoveDropdownItemByName("case_status", "--None--");

<% if (!bNew) { %>
               document.getElementById('case_prmasterinvoicenumber').disabled = true;
<% } %>

               //LoadComplete();
           }
        </script>
<%         
        return;    
    }
    
    var errorMsg = null;
    
    if (eWare.mode == Save) {
    
        blkContainer.Execute(recCase); 
        
        if (bNew) {
            recCase.case_Opened = getDBDateTime(new Date());
            recCase.SaveChanges();        
        } 
        
        if ((getFormValue("case_status") == "Collected") ||
            (getFormValue("case_status") == "NotCollected")) {
            
            if ((getFormValue("_HIDDENcase_status") != "Collected") &&
                (getFormValue("_HIDDENcase_status") != "NotCollected")) {
                recCase.Case_Closed = getDBDateTime(new Date());
                recCase.Case_ClosedBy = user_userid;
                recCase.SaveChanges();        
            }
        }
        
        var redirectURL = changeKey(sSummaryAction, "case_caseid", recCase("case_CaseID"));
        Response.Redirect(redirectURL);
        return;    
    }    
    
}
 %>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->
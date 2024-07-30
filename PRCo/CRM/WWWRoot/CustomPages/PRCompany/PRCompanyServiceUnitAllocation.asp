<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012-2016

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
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
    doPage();


function doPage() {

    Response.Write("A<br/>");

    var f_value = String(Request.QueryString("F"));
    if (isEmpty(f_value))
    {
        f_value = "PRCompany/PRCompanySummary.asp";
    }
    // Default Actions
    var sCancelAction = f_value;
    var sContinueAction = String("PRCompany/PRCompanySummary.asp");
    var tabContext = "";
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    // default button actions
    var btnContinue = eWare.Button("Continue","continue.gif", eWare.URL(sContinueAction));
    var btnCancel = eWare.Button("Cancel","cancel.gif", eWare.URL(sCancelAction));




    var blkEntry=eWare.GetBlock("PRServiceUnitAllocationEntry");
    var prun_ServiceUnitAllocationId = getIdValue("prun_ServiceUnitAllocationId");
    var recServiceUnitAllocation;
    var companyIDEntry = blkEntry.GetEntry("prun_CompanyId");
    companyIDEntry.Hidden = true;

    //DumpFormValues();
    sListingAction = eWare.Url("PRCompany/PRCompanyServiceUnitAllocationListing.asp") + "&T=Company&Capt=Services";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyServiceUnitAllocation.asp")+ "&prun_ServiceUnitAllocationID="+ prun_ServiceUnitAllocationId + "&T=Company&Capt=Services";

    // indicate that this is new
    if (prun_ServiceUnitAllocationId == -1 )
    {
    	recServiceUnitAllocation = eWare.CreateRecord("PRServiceUnitAllocation");
        recServiceUnitAllocation.prun_CompanyId = comp_companyid;
        recServiceUnitAllocation.prun_HQID = recCompany("comp_PRHQID");
        recServiceUnitAllocation.prun_SourceCode = "C";
        companyIDEntry.DefaultValue = comp_companyid;

    	if (eWare.Mode < Edit)
    	    eWare.Mode = Edit;
    }
    else
    {
        recServiceUnitAllocation = eWare.FindRecord("PRServiceUnitAllocation", "prun_ServiceUnitAllocationId="+ prun_ServiceUnitAllocationId);
    }
        

	// handle saves before anything else, because we'll redirect away upon completion
	if (eWare.Mode == Save) 
    {
        if (prun_ServiceUnitAllocationId == -1) {
            recServiceUnitAllocation.prun_UnitsRemaining = getFormValue("prun_unitsallocated");
        }

        blkEntry.Execute(recServiceUnitAllocation)
   	    
    	// Go back to the listing page
        if (prun_ServiceUnitAllocationId == -1)
            Response.Redirect(sListingAction);
        else
            Response.Redirect(sSummaryAction);

        return;
    }
    else if (eWare.Mode == PreDelete )
    {
        sql = "EXEC usp_CancelServiceUnits " + comp_companyid + ", " + prun_ServiceUnitAllocationId
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {	

        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"PRCompanyServiceUnitAllocation.js\"></script>");
	    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        
        blkEntry.Title="Business Report Allocation";
        blkEntry.ArgObj = recServiceUnitAllocation;

        // based upon the mode determine the buttons and actions
        if (eWare.Mode == Edit)
        {
            sPageAction = "New";
            if (prun_ServiceUnitAllocationId == -1 )
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            else
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
           
   	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

            var entry = blkEntry.GetEntry("prun_AllocationTypeCode");
            entry.AllowBlank = false;
            entry.OnChangeScript = "onAllocationTypeChange();";

        }
        else 
        {
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

            if (recServiceUnitAllocation.prun_UnitsRemaining > 0) {
                sDeleteUrl = "javascript:if (confirm('Are you sure you want to cancel this business report allocation?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
                blkContainer.AddButton(eWare.Button("Cancel Allocation", "delete.gif", sDeleteUrl));
            }

            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
        }


        blkContainer.AddBlock(blkEntry);
        blkContainer.CheckLocks = false;

      
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage());

        Response.Write("\n<script type=\"text/javascript\">");
        if (eWare.Mode == Edit) 
        {
            if (prun_ServiceUnitAllocationId == -1 ) {
                Response.Write("\n        isNew = true;");
                Response.Write("\n        document.getElementById('prun_startdate').value='" + getDateAsString(null) + "';");
                Response.Write("\n        onAllocationTypeChange();");
                Response.Write("\n        document.getElementById('prun_startdate').onblur = onAllocationTypeChange;");
            }
           Response.Write("\n        document.getElementById('prun_companyid').value='" + comp_companyid + "';");
           Response.Write("\n        RemoveDropdownItemByName('prun_allocationtypecode', '--None--');");
        }
        Response.Write("\n</script>");
    }
}
%>
<!-- #include file="CompanyFooters.asp" -->

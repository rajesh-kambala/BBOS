<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
function doPage()
{
	//bDebug = false;
	DEBUG("URL: " + sURL); 
	DEBUG("<br>Mode: " + eWare.Mode);

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;

	var sSecurityGroups = "6,10,15"; //CS, IT and Accounting
	var prsoat_SalesOrderAuditTrailID = getIdValue("prsoat_SalesOrderAuditTrailID");
	
	DEBUG("prsoat_SalesOrderAuditTrailID=" + prsoat_SalesOrderAuditTrailID);

	var sAction = String(Request.QueryString("Action"));
	sAction = (sAction != "undefined") ? sAction.toLowerCase() : "";

	blkEntry=eWare.GetBlock("PRSalesOrderAuditTrailNewEntry");
	blkEntry.Title="Sales Order Audit Trail ";
	blkEntry.GetEntry("prsoat_ItemCode").ReadOnly = true;
	blkEntry.GetEntry("prsoat_CreatedDate").ReadOnly = true;
	blkEntry.GetEntry("prsoat_extensionamt").ReadOnly = true;
	blkEntry.GetEntry("prsoat_QuantityChange").ReadOnly = true;
	//blkEntry.GetEntry("prsoat_ActionCode").ReadOnly = true;

	//blkEntry.GetEntry("prsoat_ActionCode").LookupFamily = "prsoat_ActionCode";
	
	blkContainer.CheckLocks = false;
	    
	eWare.AddContent("<script type=\"text/javascript\" src=\"PRSalesOrderAuditTrail.js\"></script>");

	recPRSalesOrderAuditTrail = eWare.FindRecord("PRSalesOrderAuditTrail", "prsoat_SalesOrderAuditTrailID=" + prsoat_SalesOrderAuditTrailID);

    sListingAction = eWare.Url("PRSalesOrderAuditTrail/PRSalesOrderAuditTrailListing.asp");
	sSummaryAction = eWare.Url("PRSalesOrderAuditTrail/PRSalesOrderAuditTrail.asp")+ "&prsoat_SalesOrderAuditTrailID="+ prsoat_SalesOrderAuditTrailID;

	if (eWare.Mode == Edit || eWare.Mode == Save)
	{
		blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

		if (isUserInGroup(sSecurityGroups))
		{
			blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
		}
	}
	else if (eWare.Mode == PreDelete )
	{
		//Perform a physical delete of the record
		sql = "DELETE FROM PRSalesOrderAuditTrail WHERE prsoat_SalesOrderAuditTrailID="+ prsoat_SalesOrderAuditTrailID;
		qryDelete = eWare.CreateQueryObj(sql);
		qryDelete.ExecSql();
		Response.Redirect(sListingAction);
	}
	else 
	{
		blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
		if (isUserInGroup(sSecurityGroups))
		{
            sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
			blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));

			blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
			var sNewUrl = eWare.Url(J);
			sNewUrl = changeKey(sNewUrl, "prsoat_SalesOrderAuditTrailID", prsoat_SalesOrderAuditTrailID);
		}
	}

	blkContainer.CheckLocks = false;
	blkContainer.AddBlock(blkEntry);

	eWare.AddContent(blkContainer.Execute(recPRSalesOrderAuditTrail));
	
	if (eWare.Mode == Save) 
	{
		Response.Redirect(sSummaryAction);
	}
	else if (eWare.Mode == Edit) 
	{
		// hide the tabs
		Response.Write(eWare.GetPage('New'));
	}
	else
		Response.Write(eWare.GetPage());
}

doPage();
%>

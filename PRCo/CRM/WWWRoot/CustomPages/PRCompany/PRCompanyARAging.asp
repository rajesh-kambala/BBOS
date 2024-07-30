<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%
    var sSecurityGroups = "3,4,10";

	var sEntityName = "PRARAging";

    var blkEntry=eWare.GetBlock("PRARAgingNewEntry");
    blkEntry.Title="A/R Aging Report";

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    // get the AR Aging Id
    var praa_id = getIdValue("praa_ARAgingId");

    // we never will show an view mode for this form; it is for new or manually editted AR Aging only
    if (eWare.Mode < Edit)
        eWare.Mode = Edit;
    // indicate that this is new
    if (praa_id == "-1" )
    {
        var bNew = true;
    }
    
   
    var sListingAction = eWare.Url("PRCompany/PRCompanyARAgingByListing.asp") + "&comp_CompanyId=" + comp_companyid + "&T=Company&Capt=Trade+Activity";
    var sSummaryAction = eWare.Url("PRCompany/PRCompanyARAgingDetailListing.asp") + "&praa_ARAgingId="+ praa_id + "&T=Company&Capt=Trade+Activity";
    var rec = eWare.FindRecord(sEntityName, "praa_ARAgingId=" + praa_id);
    
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
	        rec = eWare.CreateRecord(sEntityName);
			
			rec("praa_CompanyId") = comp_companyid;
			rec("praa_ManualEntry") = "Y";
            
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
	    if (isUserInGroup(sSecurityGroups))
        	blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRARAgingDetail WHERE praad_ARAgingId ="+ praa_id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
        sql = "DELETE FROM " + sEntityName + " WHERE praa_ARAgingId ="+ praa_id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    blkContainer.CheckLocks = false; 

    // Setup our fields so that we can retrict the
    // Person find to only those Person records
    // for our company.
    field = blkEntry.GetEntry("praa_CompanyId");
    field.defaultValue = comp_companyid;

    field = blkEntry.GetEntry("praa_PersonId");
    field.Restrictor = "praa_CompanyId";


    blkContainer.AddBlock(blkEntry);
    eWare.AddContent(blkContainer.Execute(rec)); 

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
    }
    else
        Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
function doPage()
{
	DEBUG("URL: " + sURL); 
	DEBUG("<br>Mode: " + eWare.Mode);

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;

	var sSecurityGroups = "4,5,10";
	var prci_cityid = getIdValue("prci_CityId");
	
	var sAction = String(Request.QueryString("Action"));
	sAction = (sAction != "undefined") ? sAction.toLowerCase() : "";

	blkEntry=eWare.GetBlock("PRCityNewEntry");
	blkEntry.Title="City ";
	blkContainer.CheckLocks = false;
    
	eWare.AddContent("<script type=\"text/javascript\" src=\"PRCity.js\"></script>");

	// indicate that this is new
	bNew = false;
	if (prci_cityid == -1) {
		bNew = true;
		recCity = eWare.CreateRecord("PRCity");
		if (eWare.Mode < Edit)
			eWare.Mode = Edit;
    } else if (sAction == "mirror") {
        bNew = true;
        var recExistingCity = eWare.FindRecord("PRCity", "prci_CityId=" + prci_cityid);
        recCity = eWare.CreateRecord("PRCity");
        
        // Copy the interesting interesting columns
        if (! recExistingCity.Eof) {
            var fld;
            fld = blkEntry.GetEntry("prci_StateId"); fld.DefaultValue = recExistingCity("prci_StateId"); 
            fld = blkEntry.GetEntry("prci_RatingTerritory"); fld.DefaultValue = recExistingCity("prci_RatingTerritory"); 
            fld = blkEntry.GetEntry("prci_RatingUserId"); fld.DefaultValue = recExistingCity("prci_RatingUserId"); 
            fld = blkEntry.GetEntry("prci_SalesTerritory"); fld.DefaultValue = recExistingCity("prci_SalesTerritory"); 
            fld = blkEntry.GetEntry("prci_InsideSalesRepId"); fld.DefaultValue = recExistingCity("prci_InsideSalesRepId"); 
            fld = blkEntry.GetEntry("prci_FieldSalesRepId"); fld.DefaultValue = recExistingCity("prci_FieldSalesRepId"); 
            fld = blkEntry.GetEntry("prci_ListingSpecialistId"); fld.DefaultValue = recExistingCity("prci_ListingSpecialistId"); 
            fld = blkEntry.GetEntry("prci_CustomerServiceId"); fld.DefaultValue = recExistingCity("prci_CustomerServiceId"); 
            
            fld = blkEntry.GetEntry("prci_LumberRatingUserId"); fld.DefaultValue = recExistingCity("prci_LumberRatingUserId"); 
            fld = blkEntry.GetEntry("prci_LumberInsideSalesRepId"); fld.DefaultValue = recExistingCity("prci_LumberInsideSalesRepId"); 
            fld = blkEntry.GetEntry("prci_LumberFieldSalesRepId"); fld.DefaultValue = recExistingCity("prci_LumberFieldSalesRepId"); 
            fld = blkEntry.GetEntry("prci_LumberListingSpecialistId"); fld.DefaultValue = recExistingCity("prci_LumberListingSpecialistId"); 
            fld = blkEntry.GetEntry("prci_LumberCustomerServiceId"); fld.DefaultValue = recExistingCity("prci_LumberCustomerServiceId"); 
        }
        prci_cityid = -1;
        eWare.Mode = (eWare.Mode < Edit) ? Edit : eWare.Mode;
	} else {
		recCity = eWare.FindRecord("PRCity", "prci_CityId=" + prci_cityid);


        var recLocation = eWare.FindRecord("vPRLocation",  "prci_CityId=" + prci_cityid);
        if (recLocation("prcn_CountryID") > 3) {
            Response.Redirect(eWare.Url("PRCity/PRInternationalCity.asp")+ "&prci_CityId=" + prci_cityid);
            return;
        }
	}

	sListingAction = eWare.Url("PRCity/PRCityListing.asp");
	sSummaryAction = eWare.Url("PRCity/PRCity.asp")+ "&prci_CityId="+ prci_cityid;

	if (eWare.Mode == Edit || eWare.Mode == Save)
	{
		if (bNew)
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
		else
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

		if (isUserInGroup(sSecurityGroups))
		{
			//blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
			blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
		}
	}
	else if (eWare.Mode == PreDelete )
	{
		//Perform a physical delete of the record
		sql = "DELETE FROM PRCity WHERE prci_CityId="+ prci_cityid;
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
			var sNewCityUrl = eWare.Url(J);
			sNewCityUrl = changeKey(sNewCityUrl, "prci_CityID", prci_cityid);
			sNewCityUrl = changeKey(sNewCityUrl, "Action", "mirror");
			blkContainer.AddButton(eWare.Button("Mirror City", "edit.gif", "javascript:location.href='" + sNewCityUrl + "';"));
		}
	}
	blkContainer.CheckLocks = false;

	blkContainer.AddBlock(blkEntry);

	eWare.AddContent(blkContainer.Execute(recCity));
    
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
		Response.Write(eWare.GetPage('New'));
	}
	else
		Response.Write(eWare.GetPage());
}

doPage();
%>

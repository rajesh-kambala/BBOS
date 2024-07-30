<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
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

<%

    doPage();

function doPage()
{

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;


	var sSecurityGroups = "4,5,10";
	var prci_cityid = getIdValue("prci_CityId");

    var blkMain;
    var recCity;


	// indicate that this is new
	var bNew = false;
	if (prci_cityid == -1) {
		bNew = true;
		if (eWare.Mode < Edit)
			eWare.Mode = Edit;
    }


	sListingAction = eWare.Url("PRCity/PRCityListing.asp");
	sSummaryAction = eWare.Url("PRCity/PRInternationalCity.asp") + "&prci_CityId="+ prci_cityid;

   if (eWare.Mode == Save) {

        if (bNew) {
            recCity = eWare.CreateRecord("PRCity"); 

            var recSourceCountry = eWare.FindRecord("vPRLocation", "prcn_CountryID=" + getFormValue("prcn_countryid"));
            var recSourceCity = eWare.FindRecord("PRCity", "prci_CityID=" + recSourceCountry.prci_CityID);

            recCity.prci_StateId                   = recSourceCity.prci_StateId;
            recCity.prci_RatingTerritory           = recSourceCity.prci_RatingTerritory;
            recCity.prci_RatingUserId              = recSourceCity.prci_RatingUserId;
            recCity.prci_SalesTerritory            = recSourceCity.prci_SalesTerritory;
            recCity.prci_InsideSalesRepId          = recSourceCity.prci_InsideSalesRepId;
            recCity.prci_FieldSalesRepId           = recSourceCity.prci_FieldSalesRepId;
            recCity.prci_ListingSpecialistId       = recSourceCity.prci_ListingSpecialistId;
            recCity.prci_CustomerServiceId         = recSourceCity.prci_CustomerServiceId;
            recCity.prci_LumberRatingUserId        = recSourceCity.prci_LumberRatingUserId;
            recCity.prci_LumberInsideSalesRepId    = recSourceCity.prci_LumberInsideSalesRepId;
            recCity.prci_LumberFieldSalesRepId     = recSourceCity.prci_LumberFieldSalesRepId;
            recCity.prci_LumberListingSpecialistId = recSourceCity.prci_LumberListingSpecialistId;
            recCity.prci_LumberCustomerServiceId   = recSourceCity.prci_LumberCustomerServiceId;

        } else {
        
            recCity = eWare.FindRecord("PRCity", "prci_CityID=" + prci_cityid);
        }

        recCity.prci_City = getFormValue("prci_city");

        recCity.SaveChanges();


	    if (bNew)
	        Response.Redirect(eWare.Url("PRCity/PRInternationalCity.asp") + "&prci_CityId="+ recCity.prci_cityid);
	    else
            Response.Redirect(sListingAction);	

        return;
    }

    blkMain=eWare.GetBlock("PRCityInternational");
    blkMain.Title="International City";
    recCity = eWare.FindRecord("vPRLocation", "prci_CityID=" + prci_cityid);

    if (eWare.Mode == View) 
    {
		blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
		if (isUserInGroup(sSecurityGroups))
		{
			blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
		}
    }

    if (eWare.Mode == Edit) {

        eWare.AddContent("<script type=\"text/javascript\" src=\"PRInternationalCity.js\"></script>")

		if (bNew) {
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
             
            blkMain.GetEntry("prci_RatingTerritory").Hidden = true;
            blkMain.GetEntry("prci_RatingUserId").Hidden = true;
            blkMain.GetEntry("prci_SalesTerritory").Hidden = true;
            blkMain.GetEntry("prci_InsideSalesRepId").Hidden = true;
            blkMain.GetEntry("prci_FieldSalesRepId").Hidden = true;
            blkMain.GetEntry("prci_ListingSpecialistId").Hidden = true;
            blkMain.GetEntry("prci_CustomerServiceId").Hidden = true;
            blkMain.GetEntry("prci_LumberRatingUserId").Hidden = true;
            blkMain.GetEntry("prci_LumberInsideSalesRepId").Hidden = true;
            blkMain.GetEntry("prci_LumberFieldSalesRepId").Hidden = true;
            blkMain.GetEntry("prci_LumberListingSpecialistId").Hidden = true;
            blkMain.GetEntry("prci_LumberCustomerServiceId").Hidden = true;

		} else {
			blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));

            fldCountry = blkMain.GetEntry("prcn_CountryID");
            fldCountry.ReadOnly = true;
        }

		if (isUserInGroup(sSecurityGroups))
		{
			blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
		}              
    }
 

  	blkContainer.AddBlock(blkMain);
	eWare.AddContent(blkContainer.Execute(recCity));
    Response.Write(eWare.GetPage());

    if ((eWare.Mode == Edit) &&
		(bNew)) {
        Response.Write("\n<script type=text/javascript >");
        Response.Write("\n    document.body.onload=function() {");
        Response.Write("\n        document.getElementById('prci_city').value='';");
        Response.Write("\n    }");
        Response.Write("\n</script>");
    }
}
%>
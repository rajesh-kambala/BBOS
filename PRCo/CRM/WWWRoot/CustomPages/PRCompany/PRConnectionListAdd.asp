<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2020

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

	doPage();

function doPage()
{
	//bDebug=true;
    //DEBUG(sURL);
	
	if (eWare.Mode < Edit) {
		eWare.Mode = Edit;
	}

	var blkContainer = eWare.GetBlock("Container");
	blkContainer.DisplayButton(Button_Default) = false;

	sListingAction = eWare.Url("PRCompany/PRConnectionListListing.asp");
	//sSummaryAction = prcl2_ConnectionListID;

	var recConnectionList=eWare.CreateRecord("PRConnectionList");
	recConnectionList.prcl2_CompanyID = comp_companyid;
	
	blkMain=eWare.GetBlock("PRConnectionList");
	blkMain.GetEntry("prcl2_CompanyID").Hidden = true;
	blkMain.GetEntry("prcl2_CompanyID").DefaultValue = comp_companyid;
	blkMain.GetEntry("prcl2_ConnectionListDate").DefaultValue = getDateAsString(null);
	blkMain.GetEntry("prcl2_PersonID").Restrictor = "prcl2_CompanyID";
	blkMain.Title = "Add Reference List";
		
	blkMain.ArgObj = recConnectionList; 
	blkContainer.AddBlock(blkMain);

	if (eWare.Mode == Save) {
		blkContainer.Execute(); 

		var companyIDs = Request.Form.Item("cbCompany").item;
		if (!isEmpty(companyIDs)) {
			var sql = "INSERT INTO PRConnectionListCompany (prclc_ConnectionListID, prclc_RelatedCompanyID, prclc_CreatedBy, prclc_CreatedDate, prclc_UpdatedBy, prclc_UpdatedDate, prclc_Timestamp) " +
					  "SELECT DISTINCT " + recConnectionList("prcl2_ConnectionListID") + ", comp_CompanyID, " + user_userid + ", GetDate(), " + user_userid + ", GetDate(), GetDate() " +
					  "FROM Company WITH (NOLOCK) " +
					 "WHERE comp_CompanyID IN (" + companyIDs + ") ";

			//Response.Write(sql);
			var qry = eWare.CreateQueryObj(sql);
			qry.ExecSQL();

			arrCompanyIds = new String(companyIDs).split(",");
			for (ndx=0; ndx < arrCompanyIds.length; ndx++)
			{
				relatedCompanyID = new String(arrCompanyIds[ndx]).replace(/^\s*/, "").replace(/\s*$/, "");

				var RTNew = Request.Form.Item("RTNew" + relatedCompanyID).item;
				var RTCurrent = Request.Form.Item("RTCurrent" + relatedCompanyID).item;
	
				if(!isEmpty(RTNew))
				{
					sql = "EXEC usp_UpdateCompanyRelationship " + comp_companyid + ", " + relatedCompanyID + ", '" + RTNew + "'"; 
					var addNewQry = eWare.CreateQueryObj(sql);
					addNewQry.ExecSQL();
				}

                updateSQL = "UPDATE PRCompanyRelationship " +
					     "SET prcr_TimesReported = ISNULL(prcr_TimesReported, 1) + 1, " +
                             "prcr_LastReportedDate = GetDate(), " +
                             "prcr_UpdatedBy = " + user_userid + ", " +
                             "prcr_UpdatedDate = GetDate(), " +
                             "prcr_TimeStamp = GetDate() " +
                       "WHERE prcr_Type IN ('09','10','11','12','13','15') " +
                         "AND prcr_Active = 'Y' " +
					     "AND prcr_LeftCompanyId = " + comp_companyid + " " +
					     "AND prcr_RightCompanyId = " + relatedCompanyID;

                //Response.Write("<p>" + updateSQL);
                var updateQry = eWare.CreateQueryObj(updateSQL);
                updateQry.ExecSQL();
			}

			recCompany("comp_PRConnectionListDate") = recConnectionList("prcl2_ConnectionListDate");
			recCompany.SaveChanges();
		}

		if (getIdValue("ATR") != "-1") {
            var url = eWare.Url("PRCompany/PRConnectionListAddTradeReport.asp")+ "&prcl2_connectionlistid=" + recConnectionList("prcl2_ConnectionListID");
            url = changeKey(url, "key0", "1");
            url = changeKey(url, "key1", comp_companyid);
			Response.Redirect( eWare.Url("PRCompany/PRConnectionListAddTradeReport.asp")+ "&prcl2_connectionlistid=" + recConnectionList("prcl2_ConnectionListID"));
		} else {
			Response.Redirect( eWare.Url("PRCompany/PRConnectionList.asp")+ "&prcl2_connectionlistid=" + recConnectionList("prcl2_ConnectionListID"));
		}
		return;
	}

	blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"save(false);\""));

    if (recCompany("comp_PRIndustryType") != "S") {
	    blkContainer.AddButton(eWare.Button("Save & Add Trade Reports", "save.gif", "#\" onClick=\"save(true);\""));
    }

	var sql = "SELECT DISTINCT comp_CompanyID as CompanyID, comp_Name as CompanyName, CityStateCountryShort, CAST(capt_us as varchar(100)) As IndustryType, " +
				"	dbo.ufn_GetRelationshipTypeList2(prcr_LeftCompanyID, prcr_RightCompanyID) as RelationshipTypeList, " + 
				"	dbo.ufn_GetRelationshipTypeList2_Types(prcr_LeftCompanyID, prcr_RightCompanyID) as RelationshipTypes " +
				"FROM Company WITH (NOLOCK) " +
				"	INNER JOIN PRCompanyRelationship WITH (NOLOCK) ON comp_CompanyID = prcr_RightCompanyID " + 
				"	INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID " +
				"	INNER JOIN Custom_Captions ON comp_PRIndustryType = capt_code AND capt_family = 'comp_PRIndustryType'  " +
				"WHERE prcr_Type IN ('09','10','11','12','13','14','15','16') " +
				 "AND prcr_Active = 'Y' " +
				 "AND prcr_LeftCompanyID = " + comp_companyid + " " +
			"ORDER BY comp_Name"

	var recRelatedCompanies = eWare.CreateQueryObj(sql);
	recRelatedCompanies.SelectSQL();

	var lstRelatedCompanies = eWare.GetBlock("content");
	lstRelatedCompanies.Contents = buildRelationshipGrid(recRelatedCompanies, "RelatedCompanies", " Related Companies");
	blkContainer.AddBlock(lstRelatedCompanies);
   
	eWare.AddContent(blkContainer.Execute()); 
   
	Response.Write(eWare.GetPage("Company"));
}

function buildRelationshipGrid(recCompanyRelationships,
							   sGridName,
							   sGridTitle) {  

	var sWorkContent = "";
	var Content01 = "";
	var Content02 = "";
	var Content03 = "";
	var Content04 = "";
	var Content05 = "";
	var Content06 = "";
	var Content07 = "";
	var Content08 = "";
	var Content09 = "";
	var Content10 = "";
	var Content11 = "";
	var Content12 = "";
	var Content13 = "";
	var Content14 = "";
	var Content15 = "";
	var Content16 = "";
	var Content17 = "";
	var Content18 = "";
	var Content19 = "";
	var Content20 = "";    
	
//Response.Write("<br/>" + sGridName + " Start: " + new Date());
   
	var sContent;
	sContent = createAccpacBlockHeader(sGridName, recCompanyRelationships.RecordCount + sGridTitle);

	sContent += "\n\n<table class=\"CONTENT\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%' >" +
				"\n<thead>" +
				"\n<tr>";
	sContent += "\n<td class=\"GRIDHEAD\" align=\"center\">Add<br/><input type=\"checkbox\" id=\"cbAll\" onclick=\"CheckAll2('" + sGridName + "', 'cbCompany', this.checked);\"></TD> ";
	sContent += "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "BB ID", "CompanyID") + "</td> " +
				"<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Company", "CompanyName") + "</td> " +
				"<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Location", "CityStateCountryShort") + "</td> " +
				"<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Industry Type", "IndustryType") + "</td>"  +
				"<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Reference List Relationship Types", "RelationshipTypeList") + "</td>"  +
				"<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "New Relationship Type", "NewRelationship") + "</td>"; 
	sContent += "\n</tr>";
	sContent += "\n</thead>";

	// Get list of possible RL relationshiptypes for dropdown
	sql = "SELECT capt_code prcr_type, RTRIM(capt_us) capt_us FROM Custom_Captions WHERE capt_family='prcr_TypeFilter' " + 
			" AND capt_code IN ('09','10','11','12','13','14','15','16')"
	var recRLRelationshipTypes = eWare.CreateQueryObj(sql);
	recRLRelationshipTypes.SelectSQL();

	arrRLRelationshipTypes = new Array();
	arrRLRelationshipTypesDesc = new Array();
	var ndx = 0;
	while (!recRLRelationshipTypes.eof)
	{
		var prcr_type = recRLRelationshipTypes("prcr_type");
		var capt_us = recRLRelationshipTypes("capt_us");
		arrRLRelationshipTypes[ndx] = prcr_type;
		arrRLRelationshipTypesDesc[ndx] = capt_us;
		recRLRelationshipTypes.NextRecord();
		ndx += 1;
	}

	sClass = "ROW2";
	var iCount = 0;
	while (!recCompanyRelationships.eof)
	{
		if (sClass == "ROW2") {
			sClass = "ROW1";
		} else {
			sClass = "ROW2";
		}
	
		sWorkContent += "\n<tr class=\"" + sClass + "\">";
		sWorkContent += "<td align=\"center\" class=\"" + sClass + "\"><input type=\"checkbox\" name=\"cbCompany\" class=\"smallcheck\"  value=\"" + recCompanyRelationships("CompanyID") + "\" grid=\"" + sGridName + "\"></td>";

		sWorkContent += "<td class=" + sClass + " align=\"center\">" + getValue(recCompanyRelationships("CompanyID")) + "</td>";
		sWorkContent += "<td class=" + sClass + "><a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + recCompanyRelationships("CompanyID") + "\">" + recCompanyRelationships("CompanyName") + "</a></td>";
		sWorkContent += "<td class=" + sClass + ">" + getValue(recCompanyRelationships("CityStateCountryShort")) + "</td>";
		sWorkContent += "<td class=" + sClass + ">" + recCompanyRelationships("IndustryType") + "</td>";
        sWorkContent += "<td class=" + sClass + ">" + recCompanyRelationships("RelationshipTypeList")  + "</td>";
		sWorkContent += "<td class=" + sClass + ">" + AddRelationshipTypeDropdown(recCompanyRelationships("RelationshipTypes"), arrRLRelationshipTypes, arrRLRelationshipTypesDesc, recCompanyRelationships("CompanyID")) + "</td>";
		sWorkContent += "<input type='hidden' name='RTCurrent" + recCompanyRelationships("CompanyID") + "' value='" + recCompanyRelationships("RelationshipTypes") + "'>";
	
		sWorkContent += "</tr>";
		
		iCount++;
		
		// This is to deal with large numbers of records.  We keep appending to the same string, but since
		// string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
		// can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
		switch(iCount) {
			case 50: 
				Content01 = sWorkContent;
				sWorkContent = "";
				break;
			case 100: 
				Content02 = sWorkContent;
				sWorkContent = "";
				break;
			case 150: 
				Content03 = sWorkContent;
				sWorkContent = "";
				break;
			case 200: 
				Content04 = sWorkContent;
				sWorkContent = "";
				break;
			case 250: 
				Content05 = sWorkContent;
				sWorkContent = "";
				break;
			case 300: 
				Content06 = sWorkContent;
				sWorkContent = "";
				break;
			case 350: 
				Content07 = sWorkContent;
				sWorkContent = "";
				break;
			case 400: 
				Content08 = sWorkContent;
				sWorkContent = "";
				break;
			case 450: 
				Content09 = sWorkContent;
				sWorkContent = "";
				break;
			case 500: 
				Content10 = sWorkContent;
				sWorkContent = "";
				break;
			case 550: 
				Content11 = sWorkContent;
				sWorkContent = "";
				break;
			case 600: 
				Content12 = sWorkContent;
				sWorkContent = "";
				break;
			case 650: 
				Content13 = sWorkContent;
				sWorkContent = "";
				break;
			case 700: 
				Content14 = sWorkContent;
				sWorkContent = "";
				break;
			case 750: 
				Content15 = sWorkContent;
				sWorkContent = "";
				break;
			case 800: 
				Content16 = sWorkContent;
				sWorkContent = "";
				break;
		}        
		recCompanyRelationships.NextRecord();
	}      
	
	sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
				Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 + sWorkContent;
	
	sContent += "\n</table>";
	sContent += createAccpacBlockFooter();
	
//Response.Write("<br/>" + sGridName + " End: " + new Date());    
	return sContent;
}

function AddRelationshipTypeDropdown(szRelationshipTypes, arrRLRelationshipTypes, arrRLRelationshipTypesDesc, iCompanyID)
{
	var ddlRelationshipType = "<select name='RTNew" + iCompanyID + "' style='width:100%'>";
	ddlRelationshipType += "<option value='' selected></option>";

	var arrRelationshipTypesSplit = szRelationshipTypes.split(',');
	
	for (var i = 0; i<arrRLRelationshipTypes.length; i++)
	{
		szRLRelationshipType = arrRLRelationshipTypes[i];
		szRLRelationshipTypeDesc = arrRLRelationshipTypesDesc[i];
		if(!InArray(arrRelationshipTypesSplit, szRLRelationshipType))
		{
			ddlRelationshipType += "<option value='" + szRLRelationshipType + "'>" + szRLRelationshipTypeDesc + "</option>";
		}
	}
		
	ddlRelationshipType += "</select>";

	return ddlRelationshipType;
}

function InArray(arr, value)
{
	for (var i=0; i<arr.length; i++)
	{
		if(arr[i] == value)
			return true;
	}

	return false;
}

%>

	<script type="text/javascript">
		function save(addTradeReport) {

		    if (addTradeReport) {
				var input = document.createElement("input");
				input.type = "hidden";
				input.name = "ATR";
				input.value = "Y";
				document.EntryForm.appendChild(input);
			}

			document.EntryForm.submit();
		}

		document.EntryForm.prcl2_companyid.value = "<% =comp_companyid %>";
	</script>

<!-- #include file ="../PRCompany/CompanyFooters.asp" -->
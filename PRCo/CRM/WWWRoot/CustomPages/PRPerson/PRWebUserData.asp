<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2008-2011

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Produce Reporter Company.
 

***********************************************************************
***********************************************************************/

doPage();

%>

<script type="text/javascript" language="javascript" runat="server">
function doPage(){
	/*
		Get the action parameter. (its only value for now is "PersonList")
		if ="PersonList", then get return a list of persons associated with
		the parameter CompanyID.
	*/
	var action = (Request.QueryString("Action").Count > 0 ? String(Request.QueryString.Item("Action")) : "");
	
	switch (action) {
		case "PersonList":
			// Go get the data...
			var CompanyID = (Request.QueryString("CompanyID").Count > 0 ? Number(Request.QueryString.Item("CompanyID")) : -1);
			var WebUserID = (Request.QueryString("WebUserID").Count > 0 ? Number(Request.QueryString.Item("WebUserID")) : -1);
			if (CompanyID > 0) {
				var qryPersons = eWare.CreateQueryObj(
					"SELECT Case When prwu_WebUserID = " + WebUserID + " Then 1 Else 0 End As Selected, peli_PersonLinkId As PersonLinkID, Coalesce(RTrim(pers_LastName) + N', ', N'') + Coalesce(RTrim(pers_FirstName), N'') + Coalesce(N' (' + peli_PRTitle + N')', N'') As PersonName" +
					"  FROM Person_Link WITH (NOLOCK) Inner Join Person WITH (NOLOCK) On (pers_PersonId = peli_PersonId) Left Outer Join vPersonEmail ON elink_RecordID = pers_PersonID  Left Outer Join PRWebUser WITH (NOLOCK) On (prwu_PersonLinkID = peli_PersonLinkID)" +
					" WHERE	peli_CompanyID = " + CompanyID + " And peli_PRStatus In (1, 2) And emai_EmailAddress Is Not Null And (prwu_WebUserID Is Null Or prwu_WebUserID = " + WebUserID + ")" +
					"ORDER BY pers_LastName, pers_FirstName"
				);
				
				qryPersons.SelectSql();
				var person_list = "";
				while (! qryPersons.Eof) {
					person_list += qryPersons("Selected") + "\t" + qryPersons("PersonLinkID") + "\t" + qryPersons("PersonName") + "\n";
					qryPersons.NextRecord();
				}
				qryPersons = null;
				
				Response.Write(person_list);
			}
			break;

		default:
			Response.Write("Invalid Action:" + action);
			break;
	}
}
</script>

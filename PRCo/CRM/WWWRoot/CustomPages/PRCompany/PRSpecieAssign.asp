<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<%

function doPage() {

    // First build a list of our selected IDs in order to set the checkboxes
    // and also build the appropriate "Before" PRCo transaction value
    var szSQL_GetSelected = "SELECT prcspc_SpecieID FROM PRCompanySpecie WHERE prcspc_CompanyID = " + comp_companyid;
    recGetSelected = eWare.CreateQueryObj(szSQL_GetSelected);
    recGetSelected.SelectSQL();

    var szSelectedIDs = "";
    while (!recGetSelected.eof) {
    
        if (szSelectedIDs != "") {
            szSelectedIDs += ",";
        }
    
        szSelectedIDs += recGetSelected("prcspc_SpecieID");
        recGetSelected.NextRecord();
    }


    if (eWare.Mode == Save) {

        // First remove all of previously selected items
        qryDelete = eWare.CreateQueryObj("DELETE FROM PRCompanySpecie WHERE prcspc_CompanyID = " + comp_companyid);
        qryDelete.ExecSql();

        var szcbSpecie = new String(Request.Form("cbSpecie"));
        if (szcbSpecie == "undefined") {
            szcbSpecie = "";
        }
       
        //Response.Write(szcbSpecie);
       
        if (szcbSpecie.length > 0) {
            aszSpecieIDs = szcbSpecie.split(',');

            for (i=0; i<aszSpecieIDs.length; i++)  {
                recPRCompanySpecie = eWare.CreateRecord("PRCompanySpecie");
                recPRCompanySpecie.prcspc_SpecieID = aszSpecieIDs[i];
                recPRCompanySpecie.prcspc_CompanyID = comp_companyid;
                recPRCompanySpecie.SaveChanges();                
            }
        }
        
        szOldNames = "";
        if (szSelectedIDs != "") {
            szOldNames = GetNames(szSelectedIDs);
        }
        
        szNewNames = "";
        if (szcbSpecie != "") {
            szNewNames = GetNames(szcbSpecie);
        }
        
        // This condition should handle the case when the user clicks Save
        // without changing anything
        if (szOldNames != szNewNames) {
            qryTransDetail = eWare.CreateQueryObj("usp_CreateTransactionDetail " + recTrx.prtx_TransactionId + ", 'Specie', 'Update', 'prspc_Name', '" + szOldNames + "', '" + szNewNames + "'");
            qryTransDetail.ExecSql();
        }        
     
        Response.Redirect(eWare.Url("PRCompany/PRSpecieListing.asp")+ "&comp_CompanyId=" + comp_companyid);
        return;
    } 

    // Reset our mode to edit.
    eWare.Mode = Edit;

    // If we're here we're in view/edit mode
    var szSQL_GetSpecies = "SELECT prspc_SpecieID, prspc_Name, prspc_Level, prspc_ParentID FROM PRSpecie ORDER BY prspc_DisplayOrder";
    recGetSpecies = eWare.CreateQueryObj(szSQL_GetSpecies);
    recGetSpecies.SelectSQL();

    var bFirstTime = true;
    szSelectedIDs2 = "," + szSelectedIDs + ",";
    var szRowClass = "ROW1"
    var szHTMLTable = "<table border=\"0\"><tr><td valign=top>";
    while (!recGetSpecies.eof) {

        sChecked = "";
        if (szSelectedIDs2.indexOf("," + recGetSpecies("prspc_SpecieID") + ",") > -1) {
            sChecked = " CHECKED ";
        }            


        if (recGetSpecies("prspc_Level") == 1) {
            if (!bFirstTime) {
                szHTMLTable += "</table>"; 
                szHTMLTable += "</td><td valign=top>"; 
            }

            bFirstTime = false;        
            szRowClass = "ROW1";
            szHTMLTable += "<table><tr><th class=\"GRIDHEAD\" style=\"text-align:left;\"><span class=\"smallcheck\"><input name=\"cbSpecie\" id=\"cb" + recGetSpecies("prspc_SpecieID") + "\" type=\"checkbox\" value=\"" + recGetSpecies("prspc_SpecieID") + "\"" + sChecked + "/><label for=\"cb" + recGetSpecies("prspc_SpecieID") + "\">" + recGetSpecies("prspc_Name") + "</label></span></th></tr> ";
        } else {

            if (szRowClass == "ROW2") {
                szRowClass = "ROW1";
            } else {
                szRowClass = "ROW2";
            }
            
            sIndent = "";
            for (j=1; j<recGetSpecies("prspc_Level"); j++)  {
                sIndent += "&nbsp;&nbsp;&nbsp;&nbsp;";
            }

            szHTMLTable += "<tr class=" + szRowClass + "><td>" + sIndent + "<span class=\"smallcheck\"><input name=\"cbSpecie\" id=\"cb" + recGetSpecies("prspc_SpecieID") + "\" type=\"checkbox\" value=\"" + recGetSpecies("prspc_SpecieID") + "\"" + sChecked + "/><label for=\"cb" + recGetSpecies("prspc_SpecieID") + "\">" + recGetSpecies("prspc_Name") + "</label></span></td></tr>";
        }
        
        recGetSpecies.NextRecord();
    }
    szHTMLTable += "</table>";
    szHTMLTable += "</td></tr></table>"; 
    
    var sContent = createAccpacBlockHeader("SpeciesProvided", "Assign Species");
    sContent += szHTMLTable;
    sContent += createAccpacBlockFooter();

    blkListing = eWare.GetBlock("content");
    blkListing.Contents=sContent;

    blkContainer = eWare.GetBlock('container');
    blkContainer.AddBlock(blkTrxHeader)

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkListing)

    sSaveLink = "javascript:document.EntryForm.action='"+eWare.URL("PRCompany/PRSpecieAssign.asp") + "';document.EntryForm.submit();";
    blkContainer.AddButton(eWare.Button("Save", "save.gif", sSaveLink));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRSpecieListing.asp")));

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage());
    
    //Response.Write(szHTMLTable);
} 

function GetNames(szIDs) {
    sSQL = "SELECT prspc_Name FROM PRSpecie WHERE prspc_SpecieID IN (" + szIDs + ") ORDER BY prspc_DisplayOrder";
    recNames = eWare.CreateQueryObj(sSQL);
    recNames.SelectSQL();

    var sNames = "";
    while (!recNames.eof) {
	    if (sNames != "") {
            sNames += ", "
        }
        
        sNames += recNames("prspc_Name");
        recNames.NextRecord();
    }

	return sNames;
}


doPage();
%>
<!-- #include file ="..\PRCompany\CompanyFooters.asp" -->

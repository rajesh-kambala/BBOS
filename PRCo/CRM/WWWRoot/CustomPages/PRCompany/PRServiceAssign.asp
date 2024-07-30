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
    var szSQL_GetSelected = "SELECT prcserpr_ServiceProvidedID FROM PRCompanyServiceProvided WHERE prcserpr_CompanyID = " + comp_companyid;
    recGetSelected = eWare.CreateQueryObj(szSQL_GetSelected);
    recGetSelected.SelectSQL();

    var szSelectedIDs = "";
    while (!recGetSelected.eof) {
    
        if (szSelectedIDs != "") {
            szSelectedIDs += ",";
        }
    
        szSelectedIDs += recGetSelected("prcserpr_ServiceProvidedID");
        recGetSelected.NextRecord();
    }


    if (eWare.Mode == Save) {

        // First remove all of previously selected items
        qryDelete = eWare.CreateQueryObj("DELETE FROM PRCompanyServiceProvided WHERE prcserpr_CompanyID = " + comp_companyid);
        qryDelete.ExecSql();

        var szcbServiceProvided = new String(Request.Form("cbServiceProvided"));
        if (szcbServiceProvided == "undefined") {
            szcbServiceProvided = "";
        }
       
        //Response.Write(szcbServiceProvided);
       
        if (szcbServiceProvided.length > 0) {
            aszServiceIDs = szcbServiceProvided.split(',');

            for (i=0; i<aszServiceIDs.length; i++)  {
                recPRCompanyServiceProvided = eWare.CreateRecord("PRCompanyServiceProvided");
                recPRCompanyServiceProvided.prcserpr_ServiceProvidedID = aszServiceIDs[i];
                recPRCompanyServiceProvided.prcserpr_CompanyID = comp_companyid;
                recPRCompanyServiceProvided.SaveChanges();                
            }
        }
        
        szOldNames = "";
        if (szSelectedIDs != "") {
            szOldNames = GetNames(szSelectedIDs);
        }
        
        szNewNames = "";
        if (szcbServiceProvided != "") {
            szNewNames = GetNames(szcbServiceProvided);
        }
        
        // This condition should handle the case when the user clicks Save
        // without changing anything
        if (szOldNames != szNewNames) {
            qryTransDetail = eWare.CreateQueryObj("usp_CreateTransactionDetail " + recTrx.prtx_TransactionId + ", 'Services Provided', 'Update', 'prserpr_Name', '" + szOldNames + "', '" + szNewNames + "'");
            qryTransDetail.ExecSql();
        }        
     
        Response.Redirect(eWare.Url("PRCompany/PRServiceListing.asp")+ "&comp_CompanyId=" + comp_companyid);
        return;
    } 

    // Reset our mode to edit.
    eWare.Mode = Edit;

    // If we're here we're in view/edit mode
    var szSQL_GetServices = "SELECT prserpr_ServiceProvidedID, prserpr_Name, prserpr_Level, prserpr_ParentID FROM PRServiceProvided ORDER BY prserpr_DisplayOrder";
    recGetServices = eWare.CreateQueryObj(szSQL_GetServices);
    recGetServices.SelectSQL();

    var bFirstTime = true;
    szSelectedIDs2 = "," + szSelectedIDs + ",";
    var szRowClass = "ROW1"
    var szHTMLTable = "<table border=\"0\" style=\"width:100%;\"><tr><td valign=top>";
    while (!recGetServices.eof) {

        if (recGetServices("prserpr_Level") == 1) {
            if (!bFirstTime) {
                szHTMLTable += "</table>"; 
                szHTMLTable += "</td><td valign=top>"; 
            }

            bFirstTime = false;        
            szRowClass = "ROW1";
            szHTMLTable += "<table><tr><th class=\"GRIDHEAD\">" + recGetServices("prserpr_Name") + "</th></tr> ";
        } else {

            if (szRowClass == "ROW2") {
                szRowClass = "ROW1";
            } else {
                szRowClass = "ROW2";
            }
            
            sIndent = "";
            for (j=1; j<recGetServices("prserpr_Level"); j++)  {
                sIndent += "&nbsp;&nbsp;&nbsp;&nbsp;";
            }
            
            sChecked = "";
            if (szSelectedIDs2.indexOf("," + recGetServices("prserpr_ServiceProvidedID") + ",") > -1) {
                sChecked = " CHECKED ";
            }            

            szHTMLTable += "<tr class=" + szRowClass + "><td>" + sIndent + "<span class=\"smallcheck\"><input name=\"cbServiceProvided\" id=\"cb" + recGetServices("prserpr_ServiceProvidedID") + "\" type=\"checkbox\" value=\"" + recGetServices("prserpr_ServiceProvidedID") + "\"" + sChecked + "/><label for=\"cb" + recGetServices("prserpr_ServiceProvidedID") + "\">" + recGetServices("prserpr_Name") + "</label></span></td></tr>";
        }
        
        recGetServices.NextRecord();
    }
    szHTMLTable += "</table>";
    szHTMLTable += "</td></tr></table>"; 

    var sContent = createAccpacBlockHeader("ServicesProvided", "Assign Services Provided");
    sContent += szHTMLTable;
    sContent += createAccpacBlockFooter();

    blkListing = eWare.GetBlock("content");
    blkListing.Contents=sContent;

    blkContainer = eWare.GetBlock('container');
    blkContainer.AddBlock(blkTrxHeader)

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkListing)

    sSaveLink = "javascript:document.EntryForm.action='"+eWare.URL("PRCompany/PRServiceAssign.asp") + "';document.EntryForm.submit();";
    blkContainer.AddButton(eWare.Button("Save", "save.gif", sSaveLink));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRServiceListing.asp")));

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage());
    
    //Response.Write(szHTMLTable);
} 

function GetNames(szIDs) {
    sSQL = "SELECT prserpr_Name FROM PRServiceProvided WHERE prserpr_ServiceProvidedID IN (" + szIDs + ") ORDER BY prserpr_DisplayOrder";
    recNames = eWare.CreateQueryObj(sSQL);
    recNames.SelectSQL();

    var sNames = "";
    while (!recNames.eof) {
	    if (sNames != "") {
            sNames += ", "
        }
        
        sNames += recNames("prserpr_Name");
        recNames.NextRecord();
    }

	return sNames;
}


doPage();
%>
<!-- #include file ="..\PRCompany\CompanyFooters.asp" -->

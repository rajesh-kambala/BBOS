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
    var szSQL_GetSelected = "SELECT prcprpr_ProductProvidedID FROM PRCompanyProductProvided WHERE prcprpr_CompanyID = " + comp_companyid;
    recGetSelected = eWare.CreateQueryObj(szSQL_GetSelected);
    recGetSelected.SelectSQL();

    var szSelectedIDs = "";
    while (!recGetSelected.eof) {
    
        if (szSelectedIDs != "") {
            szSelectedIDs += ",";
        }
    
        szSelectedIDs += recGetSelected("prcprpr_ProductProvidedID");
        recGetSelected.NextRecord();
    }


    if (eWare.Mode == Save) {

        // First remove all of previously selected items
        qryDelete = eWare.CreateQueryObj("DELETE FROM PRCompanyProductProvided WHERE prcprpr_CompanyID = " + comp_companyid);
        qryDelete.ExecSql();

        var szcbProductProvided = new String(Request.Form("cbProductProvided"));
        if (szcbProductProvided == "undefined") {
            szcbProductProvided = "";
        }
       
        //Response.Write(szcbProductProvided);
       
        if (szcbProductProvided.length > 0) {
            aszProductIDs = szcbProductProvided.split(',');

            for (i=0; i<aszProductIDs.length; i++)  {
                recPRCompanyProductProvided = eWare.CreateRecord("PRCompanyProductProvided");
                recPRCompanyProductProvided.prcprpr_ProductProvidedID = aszProductIDs[i];
                recPRCompanyProductProvided.prcprpr_CompanyID = comp_companyid;
                recPRCompanyProductProvided.SaveChanges();                
            }
        }
        
        szOldNames = "";
        if (szSelectedIDs != "") {
            szOldNames = GetNames(szSelectedIDs);
        }
        
        szNewNames = "";
        if (szcbProductProvided != "") {
            szNewNames = GetNames(szcbProductProvided);
        }
        
        // This condition should handle the case when the user clicks Save
        // without changing anything
        if (szOldNames != szNewNames) {
            qryTransDetail = eWare.CreateQueryObj("usp_CreateTransactionDetail " + recTrx.prtx_TransactionId + ", 'Products Provided', 'Update', 'prprpr_Name', '" + szOldNames + "', '" + szNewNames + "'");
            qryTransDetail.ExecSql();
        }        
     
        Response.Redirect(eWare.Url("PRCompany/PRProductListing.asp")+ "&comp_CompanyId=" + comp_companyid);
        return;
    } 

    // Reset our mode to edit.
    eWare.Mode = Edit;

    // If we're here we're in view/edit mode
    var szSQL_GetProducts = "SELECT prprpr_ProductProvidedID, prprpr_Name, prprpr_Level, prprpr_ParentID FROM PRProductProvided ORDER BY prprpr_DisplayOrder";
    recGetProducts = eWare.CreateQueryObj(szSQL_GetProducts);
    recGetProducts.SelectSQL();

    szSelectedIDs2 = "," + szSelectedIDs + ",";
    var szRowClass = "ROW2"
    var iColCount = 5; // Set this higher than our desired count to trigger the row breaks
    var szHTMLTable = "<table border=\"0\" style=\"width:100%;\"><tr class=\"colHeader\"><th class=\"GRIDHEAD\" align=left colspan=4><span class=\"smallcheck\">Products Provided</span></th>";
    while (!recGetProducts.eof) {

        if (iColCount > 4) {
        
            if (szRowClass == "ROW2") {
                szRowClass = "ROW1";
            } else {
                szRowClass = "ROW2";
            }
        
            szHTMLTable += "</tr><tr class=" + szRowClass + ">";
            iColCount = 1;
        }

        sChecked = "";
        if (szSelectedIDs2.indexOf("," + recGetProducts("prprpr_ProductProvidedID") + ",") > -1) {
            sChecked = " CHECKED ";
        }            

        szHTMLTable += "<td><span class=\"smallcheck\"><input name=\"cbProductProvided\" id=\"cb" + recGetProducts("prprpr_ProductProvidedID") + "\" type=\"checkbox\" value=\"" + recGetProducts("prprpr_ProductProvidedID") + "\"" + sChecked + "/><label for=\"cb" + recGetProducts("prprpr_ProductProvidedID") + "\">" + recGetProducts("prprpr_Name") + "</label></span></td>";

        iColCount++;
        recGetProducts.NextRecord();
    }
    szHTMLTable += "</table>";


    var sContent = createAccpacBlockHeader("ProductsProvided", "Assign Products Provided");
    sContent += szHTMLTable;
    sContent += createAccpacBlockFooter();
    
    sContent += "<script type=\"text/javascript\" >";
    sContent += "var bSaveFlag = false;";
    sContent += "function save() {";
    sContent += "     if (bSaveFlag == true) {";
    sContent += "          return;";
    sContent += "     }";
    sContent += "     bSaveFlag = true;";
    sContent += "     document.EntryForm.action='"+eWare.URL("PRCompany/PRProductAssign.asp") + "';";
    sContent += "     document.EntryForm.submit();";
    sContent += "}";
    sContent += "</script>";

    blkListing = eWare.GetBlock("content");
    blkListing.Contents=sContent;

    blkContainer = eWare.GetBlock('container');
    blkContainer.AddBlock(blkTrxHeader)

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkListing)

    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRProductListing.asp")));

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage());
} 

function GetNames(szIDs) {
    sSQL = "SELECT prprpr_Name FROM PRPRoductProvided WHERE prprpr_ProductProvidedID IN (" + szIDs + ") ORDER BY prprpr_DisplayOrder";
    recNames = eWare.CreateQueryObj(sSQL);
    recNames.SelectSQL();

    var sNames = "";
    while (!recNames.eof) {
	    if (sNames != "") {
            sNames += ", "
        }
        
        sNames += recNames("prprpr_Name");
        recNames.NextRecord();
    }

	return sNames;
}


doPage();
%>
<!-- #include file ="..\PRCompany\CompanyFooters.asp" -->

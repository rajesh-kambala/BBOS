<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2021

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

    var prtx_transactionid = getIdValue("prtx_TransactionId");

    blkContainer = eWare.GetBlock("container");
    blkContainer.DisplayButton(Button_Default) = false;

    var sSQL = "SELECT prtx_TransactionID, " +
                      "pers_PersonID, " +
                      "dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)  AS Pers_FullName " +
                 "FROM PRTransaction WITH (NOLOCK) " + 
                      "INNER JOIN Person WITH (NOLOCK) ON prtx_PersonID = pers_PersonID " + 
                "WHERE prtx_Status = 'O' " + 
                  "AND prtx_ParentTransactionID = " + prtx_transactionid;


    recPersons = eWare.CreateQueryObj(sSQL);
    recPersons.SelectSQL();

    if (eWare.Mode == View) {

        // Create a block to hold the custom grid/table
        blkPersons = eWare.GetBlock("Content");
        sContent = "";
        sContent = createAccpacBlockHeader("PersonGrid", "Person Transactions");


        sContent = sContent + "\n<span class=\"VIEWBOXCAPTION\">";
        sContent = sContent + "\n<br/>This company transaction is associated with open transactions for the persons below.  Please indicate which person transactions should also be closed.";
        sContent = sContent + "\n</span>";

        sContent = sContent + "\n<table ID=\"tbl_PersonGrid\" width=\"100%\" cellpadding=1 cellspacing=1 border=0>";

        sContent = sContent + "\n<tr>";
        sContent = sContent + "\n<td class=\"GRIDHEAD\" align=\"center\">Close<br/><input type=\"checkbox\" id=\"cbAll\" onclick=\"TogglePersons();\" /></td>";
        sContent = sContent + "\n<td class=\"GRIDHEAD\" width=\"100%\">Person</td>";
        sContent = sContent + "\n</tr>";

        var sClass = "ROW1";
        var szDisabled = "";
        var szChecked = "";
        
        while (!recPersons.eof){
            var iPersonID = recPersons("pers_PersonID")
            sClassTag = " CLASS=" + sClass + " ";

            sContent = sContent + "\n<tr>";
            sContent = sContent + "\n<td align=\"center\" valign=\"middle\" " + sClassTag + "><input type=\"checkbox\" value=\"on\" id=\"cbPersonID_" + iPersonID + "\" name=\"cbPersonID_" + iPersonID + "\" /></TD>";
            sContent = sContent + "\n<td " + sClassTag + ">" + recPersons("pers_FullName") + "</TD> ";
            
            sContent = sContent + "\n</tr>";
            
            if (sClass=="ROW1")
                sClass = "ROW2";
            else
                sClass = "ROW1";

            recPersons.NextRecord();
        }
        sContent = sContent + "\n</TABLE>";

        sContent = sContent + createAccpacBlockFooter();
        blkPersons.Contents=sContent;
        blkContainer.AddBlock(blkPersons);
        
        Response.Write("<script type=\"text/javascript\" src=\"PRTransactionInclude.js\"></script>");
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", "javascript:self.close();"));
        
        sSaveUrl = changeKey(sURL, "em", Save);
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"document.EntryForm.action='" + sSaveUrl + "';document.EntryForm.submit();"));
        
        
        eWare.AddContent(blkContainer.Execute()); 
        Response.Write(eWare.GetPage("New"));           
    }            
    
    if (eWare.Mode == Save) {
    
        var sTransactionIDs = prtx_transactionid;
        while (!recPersons.eof) {
            var iPersonID = recPersons("pers_PersonID")

            if (getFormValue("cbPersonID_" + iPersonID ) == "on") {
                sTransactionIDs += ", " + recPersons("prtx_TransactionID");
            }
            
            recPersons.NextRecord();
        }

        sSQL = "UPDATE PRTransaction SET prtx_Status='C', prtx_CloseDate = GETDATE() WHERE prtx_TransactionID IN (" + sTransactionIDs + ")";
        qryUpdate = eWare.CreateQueryObj(sSQL);
        qryUpdate.ExecSql();
    
        var sRefreshAndClose = "<script type=\"text/javascript\">" +
                                    "opener.parent.location.reload();" + 
                                    "self.close()" +
                                "</script>";

        Response.Write(sRefreshAndClose);
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
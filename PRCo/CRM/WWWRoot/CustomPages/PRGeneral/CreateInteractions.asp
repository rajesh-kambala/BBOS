<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2014-2021

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

var message = null;
doPage();

function doPage() {

    if (eWare.Mode < Edit) {
        eWare.Mode = Edit;
    }

    if (eWare.Mode == Save) {

        var companyIDs = new String(Request.Form("txtCompanyIDS"));
        var companyIDs = companyIDs.replace(new RegExp("\r\n", "gi"), ",");


        var sql = "EXEC usp_CreateInteractions ";
            sql += "@CompanyIDList = '" + companyIDs + "', ";
            sql += "@Note = '" + Request.Form("comm_note") + "', ";
            sql += "@Date = '" + Request.Form("comm_datetime") + " " + Request.Form("comm_datetime_TIME") + "', ";
            sql += "@Action = '" + Request.Form("comm_Action") + "', ";
            sql += "@Type = 'Task', ";
            sql += "@Category = '" + Request.Form("comm_prcategory") + "', ";
            sql += "@SubCategory = '" + Request.Form("comm_prsubcategory") + "', ";
            sql += "@Status = '" + Request.Form("comm_status") + "', ";
            sql += "@Priority = '" + Request.Form("comm_priority") + "', ";
            sql += "@Subject = '" + Request.Form("comm_subject") + "', ";
            sql += "@CreatedByUser = " + user_userid + ", ";
            sql += "@Commit = 1";

            //Response.Write("<p>" + sql + "</p>");

            var recQuery = eWare.CreateQueryObj(sql);
            recQuery.ExecSql()

            eWare.Mode = Edit;
            message = "The interactions have been created.";
    }

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    blkMain=eWare.GetBlock("PRCreateInteraction");
    blkMain.Title="Create Interactions";


    blkContent = eWare.GetBlock("Content");
    blkContent.Contents = "<table><tr id=trCompanyIDs><td colspan=4><span class=\"VIEWBOXCAPTION\" >Company IDs:</span><br /><textarea name=txtCompanyIDS cols=90 rows=10></textarea></td></tr></table>";

    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);
    blkContainer.AddBlock(blkContent);
    blkContainer.AddButton(eWare.Button("Save", "Save.gif", "javascript:document.EntryForm.submit();"));

    eWare.AddContent(blkContainer.Execute());
    Response.Write("<script type='text/javascript' src='../PRCoGeneral.js'></script>")
    Response.Write(eWare.GetPage(""));
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
    <script type="text/javascript">
        AppendRow("_Captcomm_note", "trCompanyIDs", false);

<%       if (message != null) {  %>
            alert("<% =message %>");

<% } %>
    </script>
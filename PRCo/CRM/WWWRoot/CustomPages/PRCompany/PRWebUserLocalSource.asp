<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2016

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
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
    DEBUG(sURL);
    var sql;

    if (eWare.Mode == Edit) {
        eWare.Mode = Save;
    }

    if (eWare.Mode == Save) {

        var webuserID = getIdValue("hdnWebUserID");

        var sql = "DELETE FROM PRWebUserLocalSource WHERE prwuls_WebUserID ="+ webuserID;
        var qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        sql = "SELECT prod_code, prod_name " +
                 "FROM NewProduct WITH (NOLOCK) " +
                "WHERE prod_productfamilyid IN (15) " +
                  "AND prod_IndustryTypeCode LIKE '%" + recCompany("comp_PRIndustryType") + "%' " +
             "ORDER BY prod_PRSequence";
    
        var recServices = eWare.CreateQueryObj(sql);
        var checked = "";
        recServices.SelectSQL();
        while (!recServices.eof) {

            var serviceCode = recServices("prod_code");
            checked = getIdValue("cb" + serviceCode);
         
            if (checked == "on") {
                sql = "INSERT INTO PRWebUserLocalSource (prwuls_WebUserID, prwuls_ServiceCode, prwuls_CreatedBy, prwuls_CreatedDate, prwuls_UpdatedBy, prwuls_UpdatedDate, prwuls_Timestamp) " +
                      "VALUES (" + webuserID + ", '" + serviceCode + "', " + user_userid + ", GETDATE(), " + user_userid + ", GETDATE(), GETDATE())"; 

                //Response.Write("<br/>" + sql);
                var qryInsert = eWare.CreateQueryObj(sql);
                qryInsert.ExecSql();
            }

            //Response.Write("<br/>" + serviceCode + ": " + checked);
            recServices.NextRecord();
        }

        sql = "UPDATE PRWebUser SET prwu_LocalSourceSearch='ELS' WHERE prwu_WebUserID = " + webuserID + " AND prwu_LocalSourceSearch IS NULL;"; 
        var qryUpdate = eWare.CreateQueryObj(sql);
        qryUpdate.ExecSql();

        eWare.Mode = View;
    }


    if (eWare.Mode == View) {

        var sql = "SELECT prod_code, prod_name, ISNULL(SUM(QuantityOrdered), 0) As OrderedCount, ISNULL(AssignedCount, 0) As AssignedCount, prod_productfamilyid " +
                 "FROM NewProduct WITH (NOLOCK) " +
                      "LEFT OUTER JOIN PRService ON prod_code = prse_ServiceCode AND prse_HQID = " + recCompany("comp_PRHQID") + " " +
                      "LEFT OUTER JOIN (SELECT prwu_HQID, prwuls_ServiceCode, COUNT(1) As AssignedCount " +
						             "FROM PRWebUser WITH (NOLOCK) " +
									      "INNER JOIN PRWebUserLocalSource ON prwu_WebUserID = prwuls_WebUserID " +
						            "WHERE prwuls_ServiceCode IS NOT NULL " +
						           "GROUP BY prwu_HQID, prwuls_ServiceCode) T1 ON prod_code = prwuls_ServiceCode and prwu_HQID = " + recCompany("comp_PRHQID") + " " +
                "WHERE prod_productfamilyid IN (15) " +
                  "AND prod_IndustryTypeCode LIKE '%" + recCompany("comp_PRIndustryType") + "%' " +
             "GROUP BY prod_code, prod_name, AssignedCount, prod_PRSequence, prod_productfamilyid " +
             "ORDER BY prod_PRSequence";


        var sServiceCreation = "";


        var serviceDesc = new Array();
        var serviceQty = new Array();
        var serviceIndex = 0;

        var dialogLineItems = "";



        // 
        // Create the Company Web Access Settings Block
        //
        blkWebAccess = eWare.GetBlock("Content");

        sContent ="\n<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
        sContent +="<script type=\"text/javascript\" src=\"PRWebUserLocalSource.js\"></script>\n\n";
        sContent += createAccpacBlockHeader("WebAccess", "Company BBOS Local Data Access Services");
        sContent += "<table border=\"0\" \"width=100%\">" ;
        sContent += "<tr class=CONTENT >";

        var i = 0;
        var recServices = eWare.CreateQueryObj(sql);
        recServices.SelectSQL();
        while (!recServices.eof){

            sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">" + recServices("prod_name") + ":</span><br/><span class=\"VIEWBOX\">" + parseInt(recServices("OrderedCount")) + "</span></td>";
            if ((i+1)%3 == 0) {
                sContent += "</tr><tr>";
            }
            i++;

            disabled = "";
            if ((recServices("OrderedCount") - recServices("AssignedCount")) <= 0) {
                disabled = " disabled=true ";
            }
    
            dialogLineItems += "<tr><td class=\"ROW2\"><input type=\"checkbox\" name=\"cb" + recServices("prod_code") + "\" id=\"cb" + recServices("prod_code") + "\"" + disabled + " value=\"on\"><label for=\"cb" + recServices("prod_code") + "\"" + disabled + ">" + recServices("prod_name") + "</label></td></tr>\n";
            recServices.NextRecord();
        }


        sContent += "</tr>";
        sContent += "</table>";
        sContent += createAccpacBlockFooter();
        blkWebAccess.contents = sContent;
        blkContainer.AddBlock(blkWebAccess);





        // Get a list of person list recs to display
        sql = "SELECT * FROM vPRWebUserLocalSourceAccess WHERE comp_PRHQID = " + recCompany("comp_PRHQID");

        var sGridName = "WebSiteUsers";
        sql += GetSortClause(sGridName, "pers_FullName", "ASC");


        recWebSiteUsers = eWare.CreateQueryObj(sql);
        recWebSiteUsers.SelectSQL();
        sWebSiteUserRows = "";
        sClass = "ROW2";
    
        while (!recWebSiteUsers.EOF){
        
            if (sClass == "ROW2")
                sClass="ROW1"; 
            else
                sClass = "ROW2"

            if (sWebSiteUserRows != "")
                sWebSiteUserRows += "\n";

            sWebSiteUserRows += "<tr PersonID=\"" + recWebSiteUsers("peli_PersonID") + "\" >";
            //sWebSiteUserRows += "<tr PersonID=\"" + recWebSiteUsers("peli_PersonID") + "\" >"; 
            sName = "txt_peli_" + recWebSiteUsers("peli_personlinkid");
            sServiceCodeTag = "txt_prse_" + recWebSiteUsers("peli_personlinkid");

            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("pers_FullName"), "&nbsp;") + "</td>"; 
            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("location"), "&nbsp;") + "</td>"; 

            var email_address;
            if ((email_address = getEmpty(recWebSiteUsers("emai_emailAddress"), "&nbsp;")) != "&nbsp;") {
			    email_address = "<a href=\"mailto:" + email_address + "&body=" + recWebSiteUsers("pers_FullName") + "\">" + email_address + "</a>";
		    }
            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + email_address + "</td>"; 

            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("peli_PRTitle"), "&nbsp;") + "</td>"; 
            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("peli_Title"), "&nbsp;") + "</td>"; 
            sWebSiteUserRows += "<td class=\"" + sClass + "\" id=\"td_Access_Level_"+ recWebSiteUsers("peli_personlinkid")+"\">" + getEmpty(recWebSiteUsers("AccessLevelDesc"), "&nbsp;") + "</td>"; 
            sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + (Date.parse(recWebSiteUsers("prwu_LastLoginDateTime")) >= 0 ? formatDateTime(recWebSiteUsers("prwu_LastLoginDateTime")) : "&nbsp") + "</td>";  

            var editLink = "<a href=\"javascript:EditUser(" + recWebSiteUsers("prwu_WebUserID") + ", '" + getEmpty(recWebSiteUsers("LocalSourceDataAccess"), "") + "')\">";

            sWebSiteUserRows += "<td class=\"" + sClass + "\">" + editLink + getEmpty(recWebSiteUsers("LocalSourceDataAccess"), "Add Access") + "</a></td>";         
            sWebSiteUserRows += "</tr>" ;

            recWebSiteUsers.NextRecord();
        }



        //Create the Web Site Users Panel
        blkWebSiteUsers = eWare.GetBlock("Content");
        sContent = createAccpacBlockHeader(sGridName, "Enterprise BBOS Users");
        sContent += "<table id=\"tblWebSiteUsers\" class=\"CONTENT\"  cellspacing=\"0\" cellpadding=\"1\" width=\"100%\" >" ;
        sContent += "\n<tr>" +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Person", "pers_FullName") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Location", "location") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Email", "emai_emailAddress") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Published Title", "peli_PRTitle") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Role", "peli_Title") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Assigned Access", "AccessLevelDesc") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last Login", "prwu_LastLoginDateTime") + "</td> " +
                    "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Local Source Data Access", "LocalSourceDataAccess") + "</td> ";
        sContent += "\n</tr>";


        sContent += sWebSiteUserRows;
        sContent += "</table>";
        sContent += createAccpacBlockFooter();
        blkWebSiteUsers.contents = sContent;
        blkContainer.AddBlock(blkWebSiteUsers);
        blkContainer.CheckLocks = false;

        var blkDialog = eWare.GetBlock("Content");
        var sDialog = "\n\n<div id=\"pnlEdit\" class=\"Popup\" style=\"width:300px;display:none;\">\n";
        sDialog += "<input type=\"hidden\" id=\"hdnWebUserID\" name=\"hdnWebUserID\" value=\"\">\n";
        sDialog += "<table class=\"CONTENT\">\n";
        sDialog += dialogLineItems
        sDialog += "</table>\n";

    	var sSaveAction = changeKey(eWare.Url("PRCompany/PRWebUserLocalSource.asp")+ "&comp_CompanyID="+ comp_companyid, "em", Save);
        var sCancelAction = changeKey(eWare.Url("PRCompany/PRWebUserLocalSource.asp")+ "&comp_CompanyID="+ comp_companyid, "em", View)

        sDialog += "<input type=submit onclick=\"document.EntryForm.action='" + sSaveAction + "'\" value=Save> <button onclick=\"location.href='" + sCancelAction + "';return false;\">Cancel</button>\n";
        sDialog += "</div>\n\n";
        blkDialog.contents = sDialog;
        blkContainer.AddBlock(blkDialog);

    }

    blkContainer.AddButton(eWare.Button("Continue","continue.gif", eWare.Url("PRCompany/PRCompanyPeople.asp") + "&T=Company&Capt=Personnel"));


    eWare.AddContent(blkContainer.Execute());
    sResponse = eWare.GetPage('Company');
    Response.Write(sResponse);

}
%>

<!-- #include file ="../RedirectTopContent.asp" -->

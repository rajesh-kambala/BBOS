<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    var bContinue = false;
    var message = null;
	doPage();

function doPage()
{
	var praa_ARAgingId = getIdValue("praa_ARAgingId");
    var sCancelUrl = eWare.URL("PRCompany/PRCompanyARTranslationListing.asp") + "&T=Company&Capt=Trade+Activity";
    if (praa_ARAgingId > -1) {
        sCancelUrl += "&praa_ARAgingId="+praa_ARAgingId ;
    }

    

	if (eWare.Mode < Edit)
		eWare.Mode = Edit;

	if (eWare.Mode == Save) {

        var iCount = 0;
        var szSQL = "";
        var szWebUserID = "";
        var szWebUserIDs = Request.Form.Item("cbWebUserID").item;

        arrWebUserIds = new String(szWebUserIDs).split(",");

        for (ndx=0; ndx < arrWebUserIds.length; ndx++)
        {
            szWebUserID = arrWebUserIds[ndx];

            szSQL = "EXEC usp_UpdateAUSListFromARAging " + comp_companyid + ", " + szWebUserID + ", " + user_userid;
            if (praa_ARAgingId > -1) {
                szSQL += ", " + praa_ARAgingId
            }


            var recQuery = eWare.CreateQueryObj(szSQL);
            recQuery.ExecSql()

            iCount++;
        }
        
        message = "Updated the Alerts list for " + iCount + " person(s).";
        bContinue = true;
	}

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

	var blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;
	
    if (bContinue) {
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sCancelUrl));
    } else {
    	blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelUrl));
	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));	
    }


	var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
	sBannerMsg += "<table class=\"MessageContent\" align=\"center>\"\n";
	sBannerMsg += "<tr><td>Select the person Alerts lists to update with the AR subject companies.</td></tr>\n";
	sBannerMsg += "</table>\n";
	sBannerMsg += "</td></tr></table>\n\n";

    var blkBanners = eWare.GetBlock('content');
    blkBanners.contents = sBannerMsg;
	blkContainer.AddBlock(blkBanners);



	var sSQL = "SELECT prwu_WebUserID, Pers_FullName, location, peli_PRTitle, emai_EmailAddress, prwu_LastLoginDateTime " +
	  		     "FROM vPRWebSiteUsersListing " +
			    "WHERE comp_PRHQId = " + recCompany("comp_PRHQID")  +
			     " AND (prwu_AccessLevel >= 200 " + 
                 "      OR prwu_AccessLevel = 7) " + 
		     "ORDER BY Pers_FullName";

    recWebSiteUsers = eWare.CreateQueryObj(sSQL);
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

        sWebSiteUserRows += "\n<tr class=\"" + sClass + "\" >";
        sWebSiteUserRows += "\n<td style=\"text-align:center\"><input style=\"{height:14px;width:14px}\" type=\"checkbox\" value=\"" + recWebSiteUsers("prwu_WebUserID") + "\" name=\"cbWebUserID\" ></td>"; 
        sWebSiteUserRows += "<td>" + getEmpty(recWebSiteUsers("pers_FullName"), "&nbsp;") + "</td>"; 
        sWebSiteUserRows += "<td>" + getEmpty(recWebSiteUsers("location"), "&nbsp;") + "</td>"; 
		sWebSiteUserRows += "<td><a href=\"mailto:'" + recWebSiteUsers("emai_EmailAddress") +  "');\">" + recWebSiteUsers("emai_EmailAddress") + "</a></td>";
        sWebSiteUserRows += "<td>" + getEmpty(recWebSiteUsers("peli_PRTitle"), "&nbsp;") + "</td>"; 
        sWebSiteUserRows += "<td style=\"text-align:center\">" + (Date.parse(recWebSiteUsers("prwu_LastLoginDateTime")) >= 0 ? formatDateTime(recWebSiteUsers("prwu_LastLoginDateTime")) : "&nbsp") + "</td>";  
        sWebSiteUserRows += "\n</tr>" ;

        recWebSiteUsers.NextRecord();
    }

    //Create the Web Site Users Panel
    blkWebSiteUsers = eWare.GetBlock("Content");
    sContent = createAccpacBlockHeader("WebSiteUsers", "Company BBOS Users");
    sContent += "<table id=\"tblWebSiteUsers\" class=\"CONTENT\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\" width=\"100%\" >" ;
   
    sContent += "\n<tr>" +
                "\n<td class=\"GRIDHEAD\" align=\"center\">Select</td> " +
                "<td class=\"GRIDHEAD\">Person</td> " +
                "<td class=\"GRIDHEAD\">Location</td> " +
                "<td class=\"GRIDHEAD\">Email</td> " +
                "<td class=\"GRIDHEAD\">Published Title</td> " +
                "<td class=\"GRIDHEAD\" style=\"text-align:center\">Last Login</td> " +
                "\n</tr>";


    sContent += sWebSiteUserRows;
    sContent += "</table>";
    sContent += createAccpacBlockFooter();
    blkWebSiteUsers.contents = sContent;
    blkContainer.AddBlock(blkWebSiteUsers);


	eWare.AddContent(blkContainer.Execute());
	Response.Write(eWare.GetPage("Company"));
}
%>

       <script type="text/javascript">
           function initBBSI() {
<% if (message != null) { %>                
                alert("<% =message %>");
<% } %>                
            }

            function save() {

                var sAlertString = "";

                var oCheckboxes = document.body.getElementsByTagName("INPUT");

                var bChecked = false;
                for (var i = 0; i < oCheckboxes.length; i++) {
                    if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbWebUserID") == 0)) {

                        if (oCheckboxes[i].checked) {
                            bChecked = true;
                            break;
                        }
                    }
                }

                if (!bChecked) {
                    sAlertString = " - Please select a person's Alerts list.";
                }

                if (sAlertString != "") {
                    alert("To save this record, the following changes are required:\n\n" + sAlertString);
                    return;
                }

                document.EntryForm.submit();
            }

            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
       </script>
<!-- #include file ="../PRCompany/CompanyFooters.asp" -->
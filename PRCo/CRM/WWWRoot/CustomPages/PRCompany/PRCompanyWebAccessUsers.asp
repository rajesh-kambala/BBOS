<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2008-2021

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

    var sEmailMsg = "";
    if (eWare.Mode == "95") {

        var sPersonLinkIDList = "";
        var iPersonLinkCount = 0;
        var iWebUserCount = 0;


        // get a list of all the text controls to process
        for (x = 1; x <= Request.Form.count(); x++) {

            if (Request.Form.Key(x).substring(0, 9) == "txt_peli_") {
                 
                var nPersonLinkID = Request.Form.Key(x).substring(9);
                if (Request("chk_" + nPersonLinkID) == "on") {

                    if (sPersonLinkIDList.length > 0) {
                        sPersonLinkIDList += ",";
                    }
                    sPersonLinkIDList += nPersonLinkID;
                    iPersonLinkCount++;
                }
            }
        }


        // Have any users been selected?
        if (iPersonLinkCount > 0) {

            sSQL = "SELECT prwu_WebUserID FROM PRWebUser WITH (NOLOCK) WHERE prwu_PersonLinkID IN (" + sPersonLinkIDList + ")";
            recWebUsers = eWare.CreateQueryObj(sSQL);
            recWebUsers.SelectSQL();

            while (!recWebUsers.eof) {
                iWebUserCount++;

                var sSQL = "EXEC usp_SendBBOSPasswordChangeLink " + recWebUsers("prwu_WebUserID") + ", " + user_userid + ", 0";
    
                var recUpdatePRTESRequest = eWare.CreateQueryObj(sSQL);
                recUpdatePRTESRequest.ExecSql();
                
                recWebUsers.NextRecord();
            }

            sEmailMsg = "alert('Successfully sent password change emails to " + iWebUserCount.toString() + " BBOS users.');";
        }
    }
    
    
    // If we have a sort column specified, then we're
    // still in Edit mode.
    if (getFormValue("_hiddenSortColumn") != "") {
        eWare.Mode = Edit;
    }


    if (eWare.Mode == Save){
        // perform the save, redirect, and then exit.
        
        // get a list of all the text controls to process
        for (x = 1; x <= Request.Form.count(); x++) {
            if (Request.Form.Key(x).substring(0, 9) == "txt_peli_") {
                //sPeliValue represents the AccessLevel for this Person_link Id
                sAccessLevel = Request.Form.Item(x);
                if (sAccessLevel  != ""){
                    
                    nPeliID = Request.Form.Key(x).substring(9);
                    recPRWebUser = eWare.FindRecord("PRWebUser", "prwu_PersonLinkId=" + nPeliID);
                    sServiceCode = getFormValue("txt_prse_" + nPeliID ) ;

                    if (!recPRWebUser.eof) {

                        // if the access level or service code have changed
                        if ((IsNull(recPRWebUser.prwu_AccessLevel, "") != sAccessLevel) ||
                            (IsNull(recPRWebUser.prwu_ServiceCode, "") != sServiceCode)) {

                            // if the access level was empty and is now 0, don't consider that a change
                            if ( ((isEmpty(recPRWebUser("prwu_AccessLevel")) || recPRWebUser("prwu_AccessLevel") == 0) && sAccessLevel == "0") 
                               &&((isEmpty(recPRWebUser("prwu_ServiceCode")) || recPRWebUser("prwu_AccessLevel") == "") && sServiceCode == "")) {

                               DEBUG("<br>Unchanged: " + nPeliID + " ServiceCode: " + sServiceCode  + " AccessLevel: "  + sAccessLevel  );

                            } else {
                                sOldAccessLevel = recPRWebUser.prwu_AccessLevel;
                                
                                // We know the access level has changed, so if the old
                                // access was trial access, clear the trial exp date
                                if (IsTrialAccess(recPRWebUser.prwu_ServiceCode)) {
                                    // This date will be reset to NULL via a trigger
                                    recPRWebUser.prwu_TrialExpirationDate = new Date("1899", "11", "30").getVarDate();
                                }


                                // If the new access level is trial access, save off
                                // the old access level info
                                if (IsTrialAccess(sServiceCode)) {
                                     recPRWebUser.prwu_PreviousAccessLevel = recPRWebUser.prwu_AccessLevel;
                                     recPRWebUser.prwu_PreviousServiceCode = recPRWebUser.prwu_ServiceCode;

                                     var today = new Date();
                                     var tmpDate = new Date(today.getYear(), today.getMonth(), today.getDate() + 31);
                                     recPRWebUser.prwu_TrialExpirationDate = tmpDate.getVarDate();

                                     // If the previous access level was a registered
                                     // or restricted user, then allocate some units.
                                     if (sOldAccessLevel <= 10) {

                                        var recPerson = eWare.CreateQueryObj("SELECT peli_PersonID FROM Person_Link WITH (NOLOCK) WHERE peli_PersonLinkID = " + recPRWebUser.prwu_PersonLinkID);
                                        recPerson.SelectSQL();
                                        var iPersonID = recPerson("peli_PersonID");

                                        sSQL = "EXEC usp_AllocateServiceUnits " + recPRWebUser("prwu_BBID") + ", " + iPersonID + ", 60, 'C', 'A'"; 
                                        qryAllocateUnits = eWare.CreateQueryObj(sSQL);
                                        qryAllocateUnits.ExecSQL();
                                    }
                                }

                                if ((sServiceCode == "None") ||
                                    (sServiceCode == "None2")) {
                                    recPRWebUser.prwu_ServiceCode = "";
                                    recPRWebUser.prwu_Disabled = "Y";

                                    var sql = "DELETE FROM PRWebUserLocalSource WHERE prwuls_WebUserID ="+ recPRWebUser("prwu_WebUserId");
                                    var qryDelete = eWare.CreateQueryObj(sql);
                                    qryDelete.ExecSql();


                                } else {
                                    recPRWebUser.prwu_ServiceCode = sServiceCode;
                                    recPRWebUser.prwu_Disabled = "";
                                }
                                recPRWebUser.prwu_AccessLevel = sAccessLevel;
                                recPRWebUser.SaveChanges();


                                if ((sServiceCode != "None") &&
                                    (sServiceCode != "None2")) {

                                    // Make sure they are setup correctly.
                                    sSQL = "EXEC usp_ProcessNewMembeshipUser " + recPRWebUser("prwu_WebUserId"); 
                                    qryProcessNewMembershipUser = eWare.CreateQueryObj(sSQL);
                                    qryProcessNewMembershipUser.ExecSQL();
                                }

                                
                                DEBUG("<br>Updated: " + nPeliID + " ServiceCode: [" + sServiceCode  + "] AccessLevel: "  + sAccessLevel  );
                            }
                        }else{
                                DEBUG("<br>Unchanged: " + nPeliID + " ServiceCode: " + sServiceCode  + " AccessLevel: "  + sAccessLevel  );
                        }
                    } else {
                        if (sAccessLevel != "0") {

                            // call a stored proc to process this Person into a new PRWebUser record
                            DEBUG ("<br>Creating New " + nPeliID + "ServiceCode: " + sServiceCode  + " AccessLevel: "  + sAccessLevel  );

                            sSQL = "EXEC usp_CreateWebUserFromPersonLink " + nPeliID + ", " + user_userid + ", " + sServiceCode + ", " + sAccessLevel; 
                            qryNewWebUser = eWare.CreateQueryObj(sSQL);
                            qryNewWebUser.ExecSQL();
                        }
                    }
                }
            }
        }
        
        Response.Redirect(eWare.Url("PRCompany/PRCompanyPeople.asp")+"&Key1="+recCompany("comp_CompanyId") + "&T=Company&Capt=Personnel");    
        return;
    }
    
    eWare.Mode = Edit;
    
    var blkScript1 = eWare.GetBlock("Content");
    blkScript1.Contents = "\n<script type=\"text/javascript\">var arrServices = new Array();</script>\n" +
                          "<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>\n" +
	                      "<script type=\"text/javascript\" src=\"PRCompanyWebAccessUsers.js\"></script>\n";
    blkContainer.AddBlock(blkScript1);

    var blkCompany = eWare.GetBlock("Content");
    blkCompany.contents = "<input type=hidden id=hdnIndustryType value='"+ recCompany("comp_PRIndustryType") +"'>";
    blkContainer.AddBlock(blkCompany);
    
    var sPrimaryName = "&nbsp;";

    sSQL = "SELECT ItemCodeDesc FROM PRService WHERE prse_Primary = 'Y' AND prse_HQID=" + recCompany("comp_PRHQID"); 
    recPrimary = eWare.CreateQueryObj(sSQL);
    recPrimary.SelectSQL();
    if (!recPrimary.eof) {
        sPrimaryName = recPrimary("ItemCodeDesc");
    }


    sSQL = "SELECT prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)) AS WebAccessDescription, ISNULL(SUM(QuantityOrdered), 0) As OrderedCount, ISNULL(AssignedCount, 0) As AssignedCount, prod_productfamilyid " +
             "FROM NewProduct WITH (NOLOCK) " +
                  "INNER JOIN custom_captions WITH (NOLOCK) ON capt_family = 'prwu_AccessLevel' and capt_Code = prod_PRWebAccessLevel  " +
                  "LEFT OUTER JOIN PRService ON prod_code = prse_ServiceCode AND prse_HQID = " + recCompany("comp_PRHQID") + " " +
                  "LEFT OUTER JOIN (SELECT prwu_HQID, prwu_ServiceCode, COUNT(1) As AssignedCount " +
						             "FROM PRWebUser WITH (NOLOCK) " +
						            "WHERE prwu_ServiceCode IS NOT NULL " +
						           "GROUP BY prwu_HQID, prwu_ServiceCode) T1 ON prod_code = prwu_ServiceCode and prwu_HQID = " + recCompany("comp_PRHQID") + " " +
            "WHERE prod_productfamilyid IN (6,14) " +
              "AND prod_IndustryTypeCode LIKE '%" + recCompany("comp_PRIndustryType") + "%' " +
         "GROUP BY prod_code, prod_PRWebAccessLevel, cast(capt_US AS varchar(100)), AssignedCount, prod_PRSequence, prod_productfamilyid " +
           "ORDER BY prod_PRSequence";

    var sServiceCreation = "";
    sServiceCreation = "\toService = new Service(); oService.init('None', 0, 'Disabled Access', 9999, 0000, false); arrServices[arrServices.length] = oService;\n";

    if (recCompany("comp_PRHasITAAccess") == "Y") {
        sServiceCreation += "\toService = new Service(); oService.init('ITALIC', 100, '" + eWare.GetTrans("prwu_AccessLevel", "100") + "', 9999, 0000, false); arrServices[arrServices.length] = oService;\n";
    }

    var additionalLicensesDesc = new Array();
    var additionalLicenseAccessMax = new Array();
    var additionalLicenseIndex = 0;

    recServices = eWare.CreateQueryObj(sSQL);
    recServices.SelectSQL();
    while (!recServices.eof){

        var trialDesc = "";
        var isTrial = "false";
        if (recServices("prod_productfamilyid")  == 14) {
            trialDesc = "Trial ";
            var isTrial = "true";
        }

        sServiceCreation += "\toService = new Service(); oService.init('" + recServices("prod_code") + "', " + recServices("prod_PRWebAccessLevel") + ", '" + trialDesc + recServices("WebAccessDescription") + "', " + recServices("OrderedCount") + ", " + recServices("AssignedCount") + ", " + isTrial + "); arrServices[arrServices.length] = oService;\n";

        var nAccessLevel = parseInt(recServices("prod_PRWebAccessLevel"));
        var quantity = parseInt(recServices("OrderedCount"));

        additionalLicensesDesc[additionalLicenseIndex] = trialDesc + recServices("WebAccessDescription")
        additionalLicenseAccessMax[additionalLicenseIndex] = quantity;
        additionalLicenseIndex++;

        recServices.NextRecord();
    }


    // 
    // Create the Company Web Access Settings Block
    //
    blkWebAccess = eWare.GetBlock("Content");

    sContent = createAccpacBlockHeader("WebAccess", "Company BBOS Access Settings");
    sContent += "<table border=\"0\" \"width=100%\">" ;
    sContent += "<tr ID=\"tr_WebAccess\">";
    sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Primary Membership:</span><br/><span id=\"spanPrimary\" class=\"VIEWBOX\">"+sPrimaryName+"</span></td>";
    sContent += "</tr>";

    sContent += "<tr class=CONTENT >";
    for (var i=0; i<additionalLicensesDesc.length; i++) {
        sContent += "<td valign=\"top\" width=\"400px\"><span class=\"VIEWBOXCAPTION\">Maximum " + additionalLicensesDesc[i] + " Users:</span><br/><span class=\"VIEWBOX\">" + additionalLicenseAccessMax[i] + "</span></td>";

        if ((i+1)%3 == 0) {
            sContent += "</tr><tr>";
        }

    }
    sContent += "</tr>";


    //sContent += "</tr>";
    sContent += "</table>";
    sContent += createAccpacBlockFooter();
    blkWebAccess.contents = sContent;
    blkContainer.AddBlock(blkWebAccess);


    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=\"hidden\" name=\"_hiddenSortColumn\"><input type=\"hidden\" name=\"_hiddenSortGrid\">";

    var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
    var recSSRS = eWare.CreateQueryObj(sSQL);
    recSSRS.SelectSQL();                
    blkSorting.Contents += "<input type=\"hidden\" id=\"hidSSRSURL\" value=\"" + getValue(recSSRS("SSRSURL")) + "\">";
    blkSorting.Contents += "<input type=\"hidden\" id=\"hidHQID\" value=\"" + getValue(recCompany("comp_PRHQID")) + "\">";
    blkContainer.AddBlock(blkSorting);


    // Get a list of person list recs to display
    sSQL = "SELECT * " +
             "FROM vPRWebSiteUsersListing " +
            "WHERE comp_PRHQID = " + recCompany("comp_PRHQID");

    var sGridName = "WebSiteUsers";
    sSQL += GetSortClause(sGridName, "pers_FullName", "ASC");


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

        sWebSiteUserRows += "<tr PersonID=\"" + recWebSiteUsers("peli_PersonID") + "\" >";
        //sWebSiteUserRows += "<tr PersonID=\"" + recWebSiteUsers("peli_PersonID") + "\" >"; 
        sName = "txt_peli_" + recWebSiteUsers("peli_personlinkid");
        sServiceCodeTag = "txt_prse_" + recWebSiteUsers("peli_personlinkid");

        var bDisplayCheckbox = false;
        var bDisplayExisting = false;

        if (isEmpty(recWebSiteUsers("emai_EmailAddress"))) {
            // Even if the person does not have an email address, if they currently have
            // web access, we must allow the user to deselect them, thus we must display
            // the checkbox.
            if (recWebSiteUsers("prwu_AccessLevel") >= 100) {
                bDisplayCheckbox = true;
            }            
        } else {
			if (recWebSiteUsers("ExistingEmailAddressCount") > 0) {
				bDisplayExisting = true;
			} else {
	            bDisplayCheckbox = true;
			}
        }
        
        if (bDisplayCheckbox) {
            sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" +
                    "<input type=\"hidden\" id=\"" + sServiceCodeTag + "\" name=\"" + sServiceCodeTag + "\" value=\"" + getEmpty(recWebSiteUsers("prwu_ServiceCode") )+ "\" >" + 
                    "<input type=\"hidden\" id=\"" + sName + "\" name=\"" + sName + "\" value=\"" + getEmpty(recWebSiteUsers("prwu_AccessLevel") )+ "\" >" +
                    "<input style=\"{height:14px;width:14px}\" type=\"checkbox\" id=\"chk_" + recWebSiteUsers("peli_personlinkid") + "\" name=\"chk_" + recWebSiteUsers("peli_personlinkid") + "\" >" + 
                    "</td>"; 
                    

        } else if (bDisplayExisting) {
			//sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\"><a href=\"mailto:" + recWebSiteUsers("emai_EmailAddress") +  "');\">Existing</a></td>";
            sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\"><a href=\"javascript:CopyStringToClipboard('" + recWebSiteUsers("emai_EmailAddress") +  "');\">Existing</a></td>";
            
        } else {
            sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">&nbsp;</td>"; 
        }

        var tmpURL = eWare.Url("PRPerson/PRPersonSummary.asp");
        tmpURL = changeKey(tmpURL, "Key0", "2");
        tmpURL = changeKey(tmpURL, "Key2", recWebSiteUsers("PeLi_PersonId"));
        tmpURL = removeKey(tmpURL, "Key1");
        //sWebSiteUserRows += "<td class=\"" + sClass + "\"><a href=\"" + tmpURL + "\">" + getEmpty(recWebSiteUsers("pers_FullName"), "&nbsp;") + "</a></td>"; 
        sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("pers_FullName"), "&nbsp;") + "</td>"; 

        sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("location"), "&nbsp;") + "</td>"; 

        var email_address;
        if ((email_address = getEmpty(recWebSiteUsers("emai_emailAddress"), "&nbsp;")) != "&nbsp;") {
			email_address = "<a href=\"mailto:" + email_address + "&body=" + recWebSiteUsers("pers_FullName") + "\">" + email_address + "</a>";
		}
        sWebSiteUserRows += "<td class=\"" + sClass + "\">" + email_address + "</td>"; 

        sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("peli_PRTitle"), "&nbsp;") + "</td>"; 
        sWebSiteUserRows += "<td class=\"" + sClass + "\">" + getEmpty(recWebSiteUsers("peli_Title"), "&nbsp;") + "</td>"; 

        tmpDescription = getEmpty(recWebSiteUsers("AccessLevelDesc"), "&nbsp;");
        tmpURL = "";
        tmpURLEnd = "";
        if (recWebSiteUsers("prwu_WebUserID") != null) {
            tmpURL = eWare.Url("PRPerson/PRWebUser.asp") + "&prwu_WebUserID=" + recWebSiteUsers("prwu_WebUserID");
            tmpURL = changeKey(tmpURL, "Key0", "2");
            tmpURL = changeKey(tmpURL, "Key2", recWebSiteUsers("PeLi_PersonId"));
            tmpURL = removeKey(tmpURL, "Key1");

            tmpURL = "<a href=\"" + tmpURL + "\">";
            tmpURLEnd = "</a>";

            if (recWebSiteUsers("prwu_AccessLevel")  == 0) {
                tmpDescription = "Disabled Access"
            }
        }

        sWebSiteUserRows += "<td class=\"" + sClass + "\" id=\"td_Access_Level_"+ recWebSiteUsers("peli_personlinkid")+"\">" + tmpURL + tmpDescription + tmpURLEnd + "</td>"; 

        trialAccess = "";
        if (recWebSiteUsers("prod_ProductFamilyID") == 14) {
            trialAccess = "Y - " + getDateAsString(recWebSiteUsers("prwu_TrialExpirationDate"));
        } else {
            
        }
        sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\" id=\"td_Trial_"+ recWebSiteUsers("peli_personlinkid")+"\">" + trialAccess + "</td>";  


        sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + (Date.parse(recWebSiteUsers("prwu_LastLoginDateTime")) >= 0 ? formatDateTime(recWebSiteUsers("prwu_LastLoginDateTime")) : "&nbsp") + "</td>";  



        tmpURL = "";
        tmpURLEnd = "";
        if (recWebSiteUsers("AUSSubjectCount") != null) {
            tmpURL = eWare.Url("PRPerson/PRPersonAUSListing.asp");
            tmpURL = changeKey(tmpURL, "Key0", "2");
            tmpURL = changeKey(tmpURL, "Key2", recWebSiteUsers("PeLi_PersonId"));
            tmpURL = removeKey(tmpURL, "Key1");

            tmpURL = "<a href=\"" + tmpURL + "\">";
            tmpURLEnd = "</a>";
        }


        sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + tmpURL + getEmpty(recWebSiteUsers("AUSSubjectCount"), "&nbsp;") + tmpURLEnd + "</td>";  
        sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + getEmpty(recWebSiteUsers("AUSSentCount"), "&nbsp;") + "</td>";  
        sWebSiteUserRows += "<td class=\"" + sClass + "\" style=\"text-align:center\">" + (Date.parse(recWebSiteUsers("AUSLastReportDate")) >= 0 ? formatDateTime(recWebSiteUsers("AUSLastReportDate")) : "&nbsp") + "</td>";  


        sWebSiteUserRows += "</tr>" ;

        recWebSiteUsers.NextRecord();
    }


    //Create the Web Site Users Panel
    blkWebSiteUsers = eWare.GetBlock("Content");
    sContent = createAccpacBlockHeader(sGridName, "Enterprise BBOS Users");
    sContent += "<table id=\"tblWebSiteUsers\" class=\"CONTENT\"  cellspacing=\"0\" cellpadding=\"1\" width=\"100%\" >" ;
    
    sContent += "<tr><td colspan=\"8\">" ;

    sContent += "<div style=text-align:center>";
    sContent += "<span class=\"VIEWBOXCAPTION\">Service:&nbsp;</span>";
    sContent += "<span class=EDIT><select class=\"VIEWBOX\" id=\"cbo_AvailableServices\" onclick=\"AvailableServices_Click()\" style=\"width:150px;\">";
    sContent += "</select>&nbsp;&nbsp;&nbsp;</span>";

    sContent += "<span class=\"VIEWBOXCAPTION\">Access Level:&nbsp;</span>";
    sContent += "<span class=EDIT><select class=\"VIEWBOX\" id=\"cbo_AvailableAccessLevels\" style=\"width:150px;\" >";
    sContent += "</select>&nbsp;&nbsp;&nbsp;</span>";
    sContent += "<span class=\"viewbox\"><button style=\"font-size:9pt;\" onclick=\"return setWebSiteUserAcccess_Click();\">Set BBOS Access</button></span>";
    sContent += "</div>";

    sContent += "</td></tr>";
    
    //sContent += "<tr style=\"text-align:center\" valign=\"top\" class=GRIDHEAD><td>Select</td><td>Person</td><td>Location</td><td>Email</td><td>Published Title</td><td>Role</td><td>Assigned Access</td><td>Last Login</td></tr>";
    
    sContent += "\n<tr>" +
                //"\n<td class=\"GRIDHEAD\" align=\"center\">Select<br/><input type=checkbox id=cbAll onclick=\"CheckAll(this.checked);\"></td> " +
                "\n<td class=\"GRIDHEAD\" align=\"center\">Select</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Person", "pers_FullName") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Location", "location") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Email", "emai_emailAddress") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Published Title", "peli_PRTitle") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Role", "peli_Title") + "</td> " +
                "<td class=\"GRIDHEAD\">" + getColumnHeader(sGridName, "Assigned Access", "AccessLevelDesc") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">Trial</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last Login", "prwu_LastLoginDateTime") + "</td> "+
                "<td class=\"GRIDHEAD\" align=\"center\"># Companies<br/>on Alerts</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\"># Alerts Reports<br/>in 12 Months</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">Last<br/>Alerts Report</td> ";
    sContent += "\n</tr>";


    sContent += sWebSiteUserRows;
    sContent += "</table>";
    sContent += createAccpacBlockFooter();
    blkWebSiteUsers.contents = sContent;
    blkContainer.AddBlock(blkWebSiteUsers);

    blkContainer.CheckLocks = false;

    blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onclick=\"save();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyPeople.asp")+"&comp_companyid="+recCompany("comp_CompanyId") + "&T=Company&Capt=Personnel"));
    blkContainer.AddButton(eWare.Button("Send BBOS Password", "sendemail.gif", "javascript:sendEmail('" + changeKey(sURL, "em", "95") + "');"));
    blkContainer.AddButton(eWare.Button("BBOS User", "continue.gif", eWare.Url("PRPerson/PRWebUserListing.asp") + "&T=Company&Capt=Personnel"));
    blkContainer.AddButton( eWare.Button("Enterprise Users Report", "ComponentPreview.gif", "javascript:openEnterpriseUsersReport();"));


	var blkScript2 = eWare.GetBlock("Content");
	blkScript2.Contents = "\n<script type=\"text/javascript\">" +
                          "\nfunction initBBSI()" + 
                          "\n{" +
                          "\n" + sServiceCreation +
                          "\n\t" + sEmailMsg +
                          "\n\tinitialize();" + 
                          "\n}" +
                          "\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }" +
                          "\n</script>";

	blkContainer.AddBlock(blkScript2);
    eWare.AddContent(blkContainer.Execute());
    sResponse = eWare.GetPage('Company');
    Response.Write(sResponse);
}


function IsTrialAccess(serviceCode) {
    if (serviceCode == undefined) {
        return false;
    }

    if (serviceCode == "") {
        return false;
    }
    
    var bIsTrial = false;

    recService = eWare.CreateQueryObj("SELECT 'Y' As IsTrial FROM NewProduct WITH (NOLOCK) WHERE prod_productfamilyid=14 AND prod_Code = '" + serviceCode + "'");
    recService.SelectSQL();
    if (!recService.eof) {
        if (recService("IsTrial") == "Y") {
            bIsTrial = true;
        }
    }

    return bIsTrial
}


%>

<!-- #include file ="../RedirectTopContent.asp" -->

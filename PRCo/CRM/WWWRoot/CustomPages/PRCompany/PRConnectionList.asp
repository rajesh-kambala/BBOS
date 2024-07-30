<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->
<!-- #include file ="..\PRTES\PRTESCustomRequestFunctions.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2017

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

    var szMessage = null;
    var SSRSURL = "";
    doPage();

function doPage()
{
    var prcl2_ConnectionListID = getIdValue("prcl2_connectionlistid");


    var blkContainer = eWare.GetBlock("Container");
    blkContainer.CheckLocks = false;
    blkContainer.DisplayButton(Button_Default) = false;

    var sListingAction = eWare.Url("PRCompany/PRConnectionListListing.asp");
    var sSummaryAction = eWare.Url("PRCompany/PRConnectionList.asp")+ "&prcl2_connectionlistid="+ prcl2_ConnectionListID;

    var blkMain=eWare.GetBlock("PRConnectionList");
    blkMain.Title="Reference List";
    blkMain.GetEntry("prcl2_CompanyID").Hidden = true;
        
    var recConnectionList = eWare.FindRecord("PRConnectionList", "prcl2_connectionlistid=" + prcl2_ConnectionListID) ;    
    blkMain.ArgObj = recConnectionList; 
    blkContainer.AddBlock(blkMain);

    var companyIDs = Request.Form.Item("cbCompany").item;
    if (getFormValue("_hiddenCreateTES") == "Y") {

 
         if (getFormValue("_hiddenInvestigationType") == "M") {
            szMessage = createTES(comp_companyid, companyIDs, null, null, user_userid);
            eWare.Mode = View;
         } else {
            Session("ReturnURL") = sSummaryAction;
            Session("VICompanyIDs") = companyIDs;         
            Response.Redirect(eWare.Url("PRTES/PRVerbalInvestigationSelect.asp")+ "&comp_CompanyID="+ comp_companyid);
            return;
         }
    }


    if (eWare.Mode == Save) {
        blkContainer.Execute(); 
       
        if (!isEmpty(companyIDs)) {
            var sql = "DELETE FROM PRConnectionListCompany WHERE prclc_ConnectionListID = " + prcl2_ConnectionListID + " AND prclc_RelatedCompanyID IN (" + companyIDs + ")";
            var qry = eWare.CreateQueryObj(sql);
            qry.ExecSQL();
        }

        Response.Redirect(sSummaryAction);
        return;

    }

    if ((getFormValue("_hiddenSortColumn") != "") &&
        (eWare.Mode == Edit)) {
        eWare.Mode = View;
    }

    if (eWare.Mode == View) {
      
        blkOptions = eWare.GetBlock("content");
        blkOptions.Contents = "<input type=\"hidden\" name=\"_hiddenCreateTES\"><input type=\"hidden\" name=\"_hiddenInvestigationType\">";
        blkContainer.AddBlock(blkOptions);

        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));

        if (recCompany("comp_PRIndustryType") != "S") {
            blkContainer.AddButton(eWare.Button("Create TES Request","new.gif","javascript:confirmTES('M');"));
            blkContainer.AddButton(eWare.Button("Verbal Investigation","new.gif","javascript:confirmTES('V');"));
            blkContainer.AddButton(eWare.Button("Submit Trade Reports","save.gif", eWare.Url("PRCompany/PRConnectionListAddTradeReport.asp")+ "&prcl2_connectionlistid="+ prcl2_ConnectionListID));
        }

        Session("RelationshipReturnURL") = eWare.URL("PRCompany/PRConnectionList.asp") + "&prcl2_connectionlistid="+ prcl2_ConnectionListID;
        blkContainer.AddButton(eWare.Button("New Relationship", "New.gif", eWare.URL("PRCompany/PRCompanyRelationship.asp") + "&prcl2_connectionlistid="+ prcl2_ConnectionListID));

        if (recCompany("comp_PRIndustryType") != "S") {
            var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
            var recSSRS = eWare.CreateQueryObj(sSQL);
            recSSRS.SelectSQL();                
            SSRSURL = getValue(recSSRS("SSRSURL"));
            blkContainer.AddButton(eWare.Button("Reference List Report","componentpreview.gif", "javascript:openConnectionListReport(" + comp_companyid + ", " + prcl2_ConnectionListID + ", '" + recCompany("comp_PRIndustryType") + "')"));
        }
    }


    if (eWare.Mode == Edit) {
        blkMain.GetEntry("prcl2_PersonID").Restrictor = "prcl2_CompanyID";
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"save();\""));
    }


    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    var blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=\"hidden\" name=\"_hiddenSortColumn\" id=\"_hiddenSortColumn\" value=\"\"><input type=\"hidden\" name=\"_hiddenSortGrid\" id=\"_hiddenSortGrid\" value=\"RelatedCompanies\">"
    blkContainer.AddBlock(blkSorting);

    //var recRelatedCompanies = eWare.FindRecord("vPRConnectionListDetails", "prcl2_ConnectionListID=" + prcl2_ConnectionListID) ;    
    var sql = "SELECT * FROM vPRConnectionListDetails WHERE prcl2_ConnectionListID=" + prcl2_ConnectionListID;
    sql += GetSortClause("RelatedCompanies", "CompanyName", "ASC");
    var recRelatedCompanies = eWare.CreateQueryObj(sql);

    recRelatedCompanies.SelectSql();
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
    sContent = createAccpacBlockHeader("SCRGrid", recCompanyRelationships.RecordCount + sGridTitle);

    sContent += "\n\n<table class=\"CONTENT\" border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%' >" +
                "\n<THEAD>" +
                "\n<tr>";
                
 
    var szSelect = "Select";
    if (eWare.Mode == Edit) {
        szSelect = "Delete";  
    }
                 
    sContent += "\n<td class=\"GRIDHEAD\" align=\"center\">" + szSelect + "<br/><input type=\"checkbox\" id=\"cbAll\" onclick=\"CheckAll2('" + sGridName + "', 'cbCompany', this.checked);\"></td> ";                


    sContent += "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "BB ID", "CompanyID") + "</td> " +
                "<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Company", "CompanyName") + "</td> " +
                "<td class=\"GRIDHEAD\" >" + getColumnHeader(sGridName, "Location", "CityStateCountryShort") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Industry Type", "IndustryType") + "</td> "+
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last TES<br/>Form Sent", "LastFormSent") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Last Trade Report<br/>Received", "LastFormResponse") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Electronic<br/>TES", "TESEDisabled") + "</td> " +
                "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "Verbal<br/>TES", "TESVDisabled") + "</td> ";

    sContent += "\n</tr>";
    sContent += "\n</THEAD>";



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
        
        
        var sSelect = "";

        //if (eWare.Mode == Edit) {
            sSelect = "<td align=\"center\" class=\"" + sClass + "\"><input type=\"checkbox\" name=\"cbCompany\" class=\"smallcheck\"  value=" + recCompanyRelationships("CompanyID") + " grid=\"" + sGridName + "\"></td>";
        //}
        
        sWorkContent += sSelect;

        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + getValue(recCompanyRelationships("CompanyID")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\"><a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + recCompanyRelationships("CompanyID") + "\">" + recCompanyRelationships("CompanyName") + "</a></td>";
        sWorkContent += "<td class=\"" + sClass + "\">" + getValue(recCompanyRelationships("CityStateCountryShort")) + "</td>";
        sWorkContent += "<td align=\"center\"class=\"" + sClass + "\">" + recCompanyRelationships("IndustryType") + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getDateValue(recCompanyRelationships("LastFormSent")) + "</td>";
        sWorkContent += "<td align=\"center\" class=" + sClass + ">" + getDateValue(recCompanyRelationships("LastFormResponse")) + "</td>";

        // Electronic TES
        var work = "Y";
        if (recCompanyRelationships("TESEDisabled") == "Y") {
            work = "";
        }

        if ((recCompanyRelationships("comp_PRListingStatus") == "N3") ||
            (recCompanyRelationships("comp_PRListingStatus") == "N5") ||
            (recCompanyRelationships("comp_PRListingStatus") == "N6")) {
            work = "";
        } 
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + work + "</td>";
        sWorkContent += "<input type=\"hidden\" id=\"companyMTES" + getValue(recCompanyRelationships("CompanyID")) + "\"  value=\"" + work + "\">";


        // Verbal TES
        work = "Y";
        if (recCompanyRelationships("TESVDisabled") == "Y") {
            work = "";
        } 
        if ((recCompanyRelationships("comp_PRListingStatus") == "N3") ||
            (recCompanyRelationships("comp_PRListingStatus") == "N5") ||
            (recCompanyRelationships("comp_PRListingStatus") == "N6")) {
            work = "";
        }  
        sWorkContent += "<td class=\"" + sClass + "\" align=\"center\">" + work + "</td>";
        sWorkContent += "<input type=\"hidden\" id=\"companyVTES" + getValue(recCompanyRelationships("CompanyID")) + "\"  value=\"" + work + "\">";



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
    
    
    while (iCount < 10) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        sContent += "\n<tr class=\"" + sClass + "\"><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td></tr>";
    
        iCount ++;
    }
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
//Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}

%>

       <script type="text/javascript">
<% if (szMessage != null) { %>                
           alert("<% =szMessage %>");
<% } %>  

            function save() {

                var companySelected = isAnySelected();

                if (companySelected) {
                    if (!confirm("Deleting a related company from a reference list does NOT delete any corresponding company relationship records.  Company relationship records must be deleted via the company relationship page.  Do you want to continue?")) {
                        return false;
                    }
                }

                document.EntryForm.submit();
            }


            function openConnectionListReport(companyID, connectionListID, industryType) {
                var sReportURL = "<% =SSRSURL %>";

                switch (industryType) {
                    case "P":
                        sReportURL += "/Rating Metrics/Connection List - Produce";
                        break;
                    case "T":
                        sReportURL += "/Rating Metrics/Connection List - Transportation";
                        break;
                    case "L":
                        sReportURL += "/Rating Metrics/Connection List - Lumber";
                        break;
                }
                sReportURL += "&rc:Parameters=false";
                sReportURL += "&rs:Format=PDF";
                sReportURL += "&ConnectionListID=" + connectionListID;
                sReportURL += "&CompanyID=" + companyID;
                //sReportURL += "&x:dummy=" + getUniqueString();

                window.open(sReportURL,
				"Reports",
				"location=no,menubar=no,status=no,toolbar=no,scrollbars=yes,resizable=yes,width=1000,height=600", true);
            }

            // Determines if any checkboxes on the current
            // page with the specified name prefix are checked.
            function confirmTES(investigationType) {

                document.all._hiddenInvestigationType.value = investigationType;
                document.all._hiddenCreateTES.value = "";

                var bChecked = isAnySelected();
               
                if (!bChecked) {
                    alert("Please select a company to send a TES to.");
                    return;
                } else {

                    if (investigationType == "M") {
                        if (!confirm("Are you sure you want to send a TES to the selected companies?")) {
                            return;
                        }

                        var foundBadSelections = hasBadSelections("companyMTES");
                        if (foundBadSelections) {
                            if (!confirm("Some of the companies selected are not eligible for a Electronic TES.  These companies have been deselected.  Do you want to continue?")) {
                                return;
                            }
                        }
                    } else {

                        var foundBadSelections = hasBadSelections("companyVTES");
                        if (foundBadSelections) {
                            if (!confirm("Some of the companies selected are not eligible for a Verbal TES.  These companies have been deselected.  Do you want to continue?")) {
                                return;
                            }
                        }


                    }


                    bChecked = isAnySelected();
               
                    if (!bChecked) {
                        alert("Please select a company to send a TES to.");
                        return;
                    }

                    document.all._hiddenCreateTES.value = "Y";
                    document.EntryForm.submit();

                }
            }

            function hasBadSelections(controlName) {
                var foundBadSelections = false;

                var oCheckboxes = document.body.getElementsByTagName("INPUT");
                for (var i = 0; i < oCheckboxes.length; i++) {
                    if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbCompany") == 0)) {

                        if (oCheckboxes[i].checked) {
                                    
                            companyID = oCheckboxes[i].value;
                            tesFlag = document.getElementById(controlName + companyID).value;

                            if (tesFlag == "") {
                                oCheckboxes[i].checked = false;
                                foundBadSelections = true;
                            }
                        }
                    }
                }

                return foundBadSelections;
            }

            function isAnySelected() {

                var oCheckboxes = document.body.getElementsByTagName("INPUT");
                var bChecked = false;
                for (var i = 0; i < oCheckboxes.length; i++) {
                    if ((oCheckboxes[i].type == "checkbox") &&
		                (oCheckboxes[i].name.indexOf("cbCompany") == 0)) {

                        if (oCheckboxes[i].checked) {
                            return true;
                        }
                    }
                }

                return false;
            }
        </script>

<!-- #include file ="../PRCompany/CompanyFooters.asp" -->
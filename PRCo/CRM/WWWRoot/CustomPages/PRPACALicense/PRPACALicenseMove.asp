<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2011-2021

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

    var Step1=Edit, Step2=95, Step3=96;
    if (eWare.Mode == 0) {
        eWare.Mode = Step1;
    }

    var blkContainer = eWare.GetBlock("container");
    recPACALicenseMove = eWare.CreateRecord("PRPACALicenseMoveAuditLog");

    var msg = "";
    
    if (eWare.Mode == Step1) {
        var blkNew=eWare.GetBlock("PRPACALicenseMoveAuditLogNew");
        blkNew.Title = "Move PACA License"

        blkContainer.AddBlock(blkNew);
        blkContainer.DisplayButton(Button_Default) = false;
    
        sNextUrl = changeKey(sURL, "em", Step2);
        blkContainer.AddButton(eWare.Button("Next","continue.gif","javascript:document.EntryForm.action='" + sNextUrl + "';step1Click();"));
    }
    
    if (eWare.Mode == Step2) {
        var szSourceCompanyID = getIdValue("prplmal_SourceCompanyID");
        var szTargetCompanyID = getIdValue("prplmal_TargetCompanyID");
        
        Session("szSourceCompanyID") = szSourceCompanyID;
        Session("szTargetCompanyID") = szTargetCompanyID;
        
        sSQL = "SELECT DISTINCT prpa_LicenseNumber FROM PRPACALicense WITH (NOLOCK) WHERE prpa_CompanyID = " + szSourceCompanyID + " ORDER BY prpa_LicenseNumber"
        recLicenses = eWare.CreateQueryObj(sSQL);
        recLicenses.SelectSQL();

     
        var bFound = true;
        if (recLicenses.eof) {
            bFound = false;
        }

        var sLicensesContent = "\n <select class=\"EDIT\" name=\"_Licenses\" id=\"_Licenses\" style=\"width:150px\">";

        while (!recLicenses.eof)
        {
            sLicensesContent += "\n      <option value=\"" + recLicenses("prpa_LicenseNumber") + "\" >" + recLicenses("prpa_LicenseNumber") + "</option>";
            recLicenses.NextRecord();
        }
        sLicensesContent += "\n</select>";

        var sBannerMsg = "Please select the PACA License to move.";
        if (!bFound) {
            sBannerMsg = "Unable to find any PACA Licenses for the selected company.";
        }

        var sHTML = createAccpacBlockHeader("Step2", "Move PACA License"); 
        sHTML += "<table class=\"CONTENT\" WIDTH=\"100%\"><tr>" + 
                 "<td colspan=\"3\">" +
                    "<span class=\"VIEWBOXCAPTION\">" +
                        "<p><strong>" + sBannerMsg + "</span></strong></p>" +
                    "</span>" +
                    "<p></p>" +
                  "</td></tr>";
                  
        sHTML += "<tr><td  valign=\"top\" width=\"30%\"><span class=\"VIEWBOXCAPTION\">Source Company:</span><br/><span class=\"VIEWBOX\">";
        sHTML += GetCompanyInfo(szSourceCompanyID);
        sHTML += "</span></td>";
        
        sHTML += "<td valign=\"top\" width=\"30%\"><span class=\"VIEWBOXCAPTION\">Target Company:</span><br/><span class=\"VIEWBOX\">";
        sHTML += GetCompanyInfo(szTargetCompanyID);                     
        sHTML += "</span></td>";            

        sHTML += "<td valign=\"top\"><span class=\"VIEWBOXCAPTION\">License Number:</span><br/>";
        sHTML += sLicensesContent;
        sHTML += "</td>";
        
        sHTML += "</tr></table>";            

        sHTML += createAccpacBlockFooter(); 

        blkStep2=eWare.GetBlock("content");
        blkStep2.contents = sHTML;   
        blkContainer.AddBlock(blkStep2);    
        
        if (bFound) {
            sNextUrl = changeKey(sURL, "em", Step3);
            blkContainer.AddButton(eWare.Button("Move","continue.gif","javascript:document.EntryForm.action='" + sNextUrl + "';step2Click();"));
        } else {
            sNextUrl = changeKey(sURL, "em", Step1);
            blkContainer.AddButton(eWare.Button("Back","continue.gif","javascript:document.EntryForm.action='" + sNextUrl + "';document.EntryForm.submit();"));
        }
    }

    if (eWare.Mode == Step3) {

        var szSourceCompanyID = Session("szSourceCompanyID");
        var szTargetCompanyID = Session("szTargetCompanyID");
        var szLicense = getIdValue("_licenses")


        var sSQL = "SELECT COUNT(1) As Cnt FROM PRPACALicense WITH (NOLOCK) WHERE prpa_CompanyID = " + szTargetCompanyID + " AND prpa_LicenseNumber <> '" + szLicense + "'";
        var recLicenseCount = eWare.CreateQueryObj(sSQL);
        recLicenseCount.SelectSQL();
        if (recLicenseCount("Cnt") > 0) {
            msg = "Target company " + szTargetCompanyID  + " now has more than one license number associated with it.  Please verify the current/publish flags.";
        }

        sSQL = "SELECT COUNT(1) As Cnt FROM PRCompanyLicense WITH (NOLOCK) WHERE prli_CompanyID = " + szTargetCompanyID + " AND prli_Type = 'PACA'";
        recLicenseCount = eWare.CreateQueryObj(sSQL);
        recLicenseCount.SelectSQL();
        if (recLicenseCount("Cnt") > 0) {
            if (msg.length > 0) {
                msg + "  ";
            }
            msg += "Please verify the unconfirmed license information for target Company ID" + szTargetCompanyID + ".";
        }

	    sSQL = "UPDATE PRPACALicense " +
	              "SET prpa_CompanyID = " + szTargetCompanyID + ", " +
		              "prpa_UpdatedDate = GETDATE(), " +
		              "prpa_UpdatedBy = " + user_userid +", " +
		              "prpa_Timestamp = GETDATE() " +
	            "WHERE prpa_LicenseNumber = " + szLicense + " " +
	              "AND prpa_CompanyID = " + szSourceCompanyID;
	   
        qryMove = eWare.CreateQueryObj(sSQL);
        qryMove.ExecSql();

        recPACALicenseMove.prplmal_SourceCompanyID = szSourceCompanyID;
        recPACALicenseMove.prplmal_TargetCompanyID = szTargetCompanyID;
        recPACALicenseMove.prplmal_LicenseNumber = szLicense;
        
        if (msg != "") {
            recPACALicenseMove.prplmal_Notes = msg;
        }
        
        recPACALicenseMove.SaveChanges();
        
        var sHTML = createAccpacBlockHeader("Step2", "Move PACA License"); 
        sHTML += "<table class=CONTENT WIDTH=\"100%\"><tr>" + 
                 "<td colspan=2>" +
                    "<span class=VIEWBOXCAPTION>" +
                        "<p><strong>The PACA License was successfully moved.</span></strong></p>" +
                    "</span>" +
                    "<p></p>" +
                  "</td></tr>";
                  
        sHTML += "<tr><td  valign=top width=30% ><span class=VIEWBOXCAPTION>Source Company:</span><br/><span class=VIEWBOX >";
        sHTML += GetCompanyInfo(szSourceCompanyID);
        sHTML += "</span></td>";
        
        sHTML += "<td valign=top width=30% ><span class=VIEWBOXCAPTION>Target Company:</span><br/><span class=VIEWBOX >";
        sHTML += GetCompanyInfo(szTargetCompanyID);                     
        sHTML += "</span></td>";            

        sHTML += "<td valign=top width=30% ><span class=VIEWBOXCAPTION>License Number:</span><br/><span class=VIEWBOX >";
        sHTML += szLicense;
        sHTML += "</span></td>";

        sHTML += "</tr></table>";

        sHTML += createAccpacBlockFooter(); 

        blkStep3=eWare.GetBlock("content");
        blkStep3.contents = sHTML;   
        blkContainer.AddBlock(blkStep3);    
        
        sPendingUrl = eWare.Url("PRPACALicense/PRImportPACALicenseFind.asp")
        blkContainer.AddButton(eWare.Button("Pending PACA Licenses","continue.gif", sPendingUrl));

        sNextUrl = changeKey(sURL, "em", Step1);
        blkContainer.AddButton(eWare.Button("Move Another License","continue.gif", "javascript:document.EntryForm.action='" + sNextUrl + "';document.EntryForm.submit();"));
    }

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRPACALicenseMove.js\"></script>");

    eWare.AddContent(blkContainer.Execute(recPACALicenseMove)); 
    Response.Write(eWare.GetPage("New"));

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
   <script type="text/javascript" >
        function initBBSI() 
        {   
        <% if (msg.length > 0) { %>
            alert("<% =msg %>");
        <% } %>
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
    </script>
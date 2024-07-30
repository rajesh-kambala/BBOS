<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2021

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

    // We are defining our own mode codes to avoid having EWare
    // do things we don't want it to do.
    var Step1=94, Step2=95, Step3=96;
    if (eWare.Mode == 0) {
        eWare.Mode = Step1;
    }

    var blkContainer = eWare.GetBlock("container");

    recCompanyMerge = eWare.CreateRecord("PRCompanyMergeAuditLog");
    var szErrorMessage = null;


    if (!isUserInGroup(",5,10,16,")) {
        eWare.Mode = -10;
        szErrorMessage = "You do not have the appropriate security access for this functionality."
    }
        
    // Step 1        
    if ( eWare.Mode == Step1 ) {
 
        blkStep1=eWare.GetBlock("PRCompanyBranchMergeStep1");
        blkStep1.Title = "Convert Company to Branch"
  
        blkContainer.AddBlock(blkStep1);
        blkContainer.DisplayButton(Button_Default) = false;

        sAddInfoUrl = changeKey(sURL, "em", Step2);
        blkContainer.AddButton(eWare.Button("Next","continue.gif","javascript:document.EntryForm.action='" + sAddInfoUrl + "';document.EntryForm.submit();"));

    } else if ( eWare.Mode == Step2 ) {
        ExecuteStep2();
    } else if ( eWare.Mode == Step3 ) {
        ExecuteStep3();
    }
    
    if (szErrorMessage != null) {
        sErrorHTML = createAccpacBlockHeader("Error", "Convert Company to Branch - Error"); 
        sErrorHTML += "<span class=VIEWBOXCAPTION><p>&nbsp;</p><div style=\"font-weight:bold;\">" + szErrorMessage + "</div><p>&nbsp;</p></span>";
        sErrorHTML += createAccpacBlockFooter(); 
        
        blkError=eWare.GetBlock("content");
        blkError.contents = sErrorHTML;   
        
        blkContainer.AddBlock(blkError);    
        
        sAddInfoUrl = changeKey(sURL, "em", "95");
        blkContainer.AddButton(eWare.Button("Continue", "continue.gif", eWareUrl("PRCompany/PRCompanyBranchMerge.asp")));
    } 

    Response.Write("<script type=\"text/javascript\" language=\"javascript\" src=\"../PRCoGeneral.js\"></script>");
    eWare.AddContent(blkContainer.Execute(recCompanyMerge)); 
    Response.Write(eWare.GetPage("New"));


/*
 * Helper method that returns an HTML formatted string containing basic information
 * about the specified company.
 */
function GetCompanyInfo(iCompanyID) {
    
    var sSQL = "SELECT comp_CompanyID, comp_Name, CityStateCountryShort, dbo.ufn_GetCustomCaptionValue('comp_PRListingStatus', comp_PRListingStatus, DEFAULT) As comp_PRListingStatus, dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, DEFAULT) As comp_PRType, dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, DEFAULT) As comp_PRIndustryType, comp_CreatedDate " +
                 "FROM Company " +
                      "INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID " +
                "WHERE comp_CompanyID=" + iCompanyID;

    recCompanyInfo = eWare.CreateQueryObj(sSQL);
    recCompanyInfo.SelectSQL();
    
    var szCompanyInfo = "";
    if (!recCompanyInfo.eof)  {
        szCompanyInfo += "BB #: " + recCompanyInfo("comp_CompanyID") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_Name") + "<br/>";
        szCompanyInfo += recCompanyInfo("CityStateCountryShort") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRListingStatus") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRType") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRIndustryType") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_CreatedDate") + "<br/>";
    }     
    
    return szCompanyInfo;
}

/* 
 * Step 2 validates the source company is eligible for merge and deletion.  It also
 * displays an "Are you sure" message including data from both companies.
 */
function ExecuteStep2() {

        var szSourceCompanyID = getIdValue('prcmal_sourcecompanyid');
        var szTargetCompanyID = getIdValue('prcmal_targetcompanyid');
        
        if ((szSourceCompanyID == "-1") || (szTargetCompanyID == "-1")) {
            szErrorMessage = "Both a source company and a target company must be specified.";
            return;
        } 
        
       
        var szSourceCompanyURL = GetCompanyURL(szSourceCompanyID);
        var szTargetCompanyURL = GetCompanyURL(szTargetCompanyID);
        
        var sHTML = createAccpacBlockHeader("Step2", "Convert Company to Branch"); 
        sHTML += "<table class=CONTENT WIDTH=\"100%\"><tr>" + 
                 "<td colspan=2>" +
                    "<span class=VIEWBOXCAPTION>" +
                        "<p><strong><span style=\"color:red;\">Are you sure you want to merge " + szSourceCompanyURL + " into a branch for " + szTargetCompanyURL + "?</span></strong>  &nbsp;" +
                        "Clicking the Next button will execute the Branch Merge operation.</p>" +
                    "</span>" +
                    "<p></p>" +
                  "</td></tr>";
                  
                  
        sHTML += "<tr><td  VALIGN=TOP width=30% ><span class=VIEWBOXCAPTION>Source Company:</span><br/><span class=VIEWBOX >";
        sHTML += GetCompanyInfo(szSourceCompanyID);
        sHTML += "</span></td><td VALIGN=TOP width=70% ><span class=VIEWBOXCAPTION>Target Company:</span><br/><span class=VIEWBOX >";
        sHTML += GetCompanyInfo(szTargetCompanyID);                     
        sHTML += "</span></td></tr></table>";            

        sHTML += createAccpacBlockFooter(); 

        blkStep2=eWare.GetBlock("content");
        blkStep2.contents = sHTML;   
        blkContainer.AddBlock(blkStep2);    


        sNextUrl = changeKey(sURL, "em", Step3);
        blkContainer.AddButton(eWare.Button("Next","continue.gif","javascript:document.EntryForm.action='" + sNextUrl + "';document.EntryForm.submit();"));

        sCancelUrl = changeKey(sURL, "em", Step1);
        blkContainer.AddButton(eWare.Button("Cancel","cancel.gif","javascript:document.EntryForm.action='" + sCancelUrl + "';document.EntryForm.submit();"));
        
        Session("szSourceCompanyID") = szSourceCompanyID;
        Session("szTargetCompanyID") = szTargetCompanyID;
        Session("szReasonCode") = "BM";
}

/*
 * This step actually executes the Merge stored proc and then the delete stored proc.
 * The audit log is manually saved.
 */
function ExecuteStep3() {

        var szSourceCompanyID = Session("szSourceCompanyID");
        var szTargetCompanyID = Session("szTargetCompanyID");
        
        if ((szSourceCompanyID == "-1") || (szTargetCompanyID == "-1")) {
            szErrorMessage = "Both a source company and a target company must be specified.";
            return;
        } 

        qryMerge = eWare.CreateQueryObj("EXEC usp_ConvertToBranch " + szSourceCompanyID + ", " + szTargetCompanyID);
        qryMerge.ExecSql();


        var sHTML = createAccpacBlockHeader("Step3", "Convert Company to Branch"); 
        sHTML += "The merge operation was successful.  Please review the company " + GetCompanyURL(szTargetCompanyID) + " to ensure the company is setup correctly."
        sHTML += createAccpacBlockFooter();
        
        blkStep3=eWare.GetBlock("content");
        blkStep3.contents = sHTML;   
        blkContainer.AddBlock(blkStep3);      
        
        recCompanyMerge.prcmal_SourceCompanyID = szSourceCompanyID;
        recCompanyMerge.prcmal_TargetCompanyID = szTargetCompanyID;
        recCompanyMerge.prcmal_ReasonCode = Session("szReasonCode");
        recCompanyMerge.SaveChanges();
        
        Session("szSourceCompanyID") = null;
        Session("szTargetCompanyID") = null;
        Session("szReasonCode") = null;
}        

/* 
 * Helper function to return a formatted <A> tage for the specified company ID.
 */
function GetCompanyURL(szCompanyID) {
    recCompany = eWare.CreateQueryObj("SELECT comp_Name FROM Company WHERE comp_CompanyID=" + szCompanyID);
    recCompany.SelectSQL();
    
    var szCompanyName = "Unknown";
    if (!recCompany.eof)  {
        szCompanyName = recCompany("comp_Name");
    }    

    return "<a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&comp_CompanyID=" + szCompanyID + "\">" + szCompanyName + "</a>";
}       
    
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
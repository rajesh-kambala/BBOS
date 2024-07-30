<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Produce Report Company  is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company .
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<HTML>
<script> 
	var isBranchOwnership = false;
</script>
<BODY>
	<SPAN >Processing Business Report Request... </SPAN>
</BODY>
</HTML>
<%
        var sErrorContent = null;
        var bError = false;
        var sReturnString = "";
        
        // get the requested company
        sRegardingCompanyID = getIdValue("prbr_requestedcompanyid");

        recRequestedCompany = eWare.FindRecord("Company","comp_Companyid="+sRegardingCompanyID);
        if (!recRequestedCompany.eof){
            sStatus = recRequestedCompany("comp_PRListingStatus");
            if ("L,H,N3".indexOf(sStatus) == -1){
                sErrorContent = "Business reports can only be generated for companies with a status of Listed, Hold, or Not Listed (Previously Listed-Reported Closed/Inactive/Not A Factor).";
                bError = true;
            }
        } else {
            sErrorContent = "Requested Company could not be retrieved.";
            bError = true;
        }
        if (bError)
            sReturnString = "0";
        else    
            sReturnString = "1";
        
        // if we can generate the report, determine if we need a balance sheet and a survey
        if (!bError){
            // determine "Include Balance Sheet"
            if ( recRequestedCompany("comp_PRConfidentialFS") == "" &&
                 recCompany("comp_PRIndustryType") == "S" )
                sReturnString += ",1";
            else
                sReturnString += ",0";   
                
                
            // determine "Include Survey"
            var sSurveySQL = "Select dbo.ufn_IsEligibleForBRSurvey("+ comp_companyid + ") as bEligible ";
            recQuery = eWare.CreateQueryObj(sSurveySQL);
            recQuery.SelectSql();
            sReturnString += "," + recQuery("bEligible");
        }
        
        
        // We have a branch relationship
        Response.Write("<SCRIPT>");
        if (sErrorContent == null)
            Response.Write("var szErrorContent=null;\n");
        else    
            Response.Write("var szErrorContent='" + sErrorContent + "';\n");
        Response.Write("var szReturnString='" + sReturnString + "';\n");
        Response.Write("</SCRIPT>");
	    
	    
%>
<script type="text/javascript">
	    function initBBSI() {
            if (szErrorContent != null) {
				alert(szErrorContent);
			}
			window.returnValue = szReturnString;				
			window.close();
        }

        if (window.addEventListener) { 
            window.addEventListener("load", initBBSI); 
        } else {
            window.attachEvent("onload", initBBSI); 
        }
</script>

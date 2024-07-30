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
<!-- #include file ="..\PRCoGeneral.asp" -->
<HTML>
<script> 
	var isBranchOwnership = false;
</script>
<BODY>
	<SPAN >Processing... </SPAN>
</BODY>
</HTML>
<%
        // get the comp_Name from the form values
        sLeftCompanyID = getIdValue("prcr_leftcompanyid");
        sRightCompanyID = getIdValue("prcr_rightcompanyid");

        Response.Write("<br>sLeftCompanyID:" + sLeftCompanyID + " <br>");
        Response.Write("sRightCompanyID:" + sRightCompanyID + " <br>");
       
	    // try to find a match
	    recLeft = eWare.FindRecord("Company", "comp_CompanyID='" + sLeftCompanyID+ "'");
	    if (recLeft.eof) {
	        Response.Write("Left Company Not Found<br>");
	    }
	    
        Response.Write("comp_Name:" + recLeft.comp_Name + "<br>");
	    Response.Write("comp_PRHQId:" + recLeft.comp_PRHQId + "<br>");
	    
	    if (recLeft.comp_PRHQId == sRightCompanyID) {
	        recRight = eWare.FindRecord("Company", "comp_CompanyID=" + sRightCompanyID);
	    
	        // We have a branch relationship
	        Response.Write("\n<script type=\"text/javascript\">\n");
	        Response.Write("isBranchOwnership = true;\n");
	        Response.Write("szLeftCompanyID='" + sLeftCompanyID + "';\n");
	        Response.Write("szRightCompanyID='" + sRightCompanyID + "';\n");
	        Response.Write("szLeftCompanyName='" + recLeft.comp_Name + "';\n");
	        Response.Write("szRightCompanyName='" + recRight.comp_Name + "';\n");
	        Response.Write("</script>");
	    }
	    
%>
        <script type="text/javascript">
            function initBBSI()
            {
                var bReturnValue = true;
                if (isBranchOwnership) {
					alert(szLeftCompanyName + " (" + szLeftCompanyID + ") is a branch of " + szRightCompanyName  + " (" + szRightCompanyID + ") and thus cannot have an ownership relationship.");
					bReturnValue = false;
				}
				window.returnValue = bReturnValue;				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>

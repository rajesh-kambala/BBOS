<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2009

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
<html>
<script type="text/javascript"> 
	var isOwnershipValid = true;
	var dPercentage = 0;
</script>
<body>
	<span>Processing... </span><br/>
<%
        // get the comp_Name from the form values
        var sCompanyID = Request("companyid");
       
        sSQL = "SELECT dbo.ufn_GetOwnershipPercentage(" + sCompanyID + ") As CurrentPercentage";
        recCurrentPercentage = eWare.CreateQueryObj(sSQL,"");
        recCurrentPercentage.SelectSQL();
        var dCurrentPercentage = recCurrentPercentage("CurrentPercentage"); 
       
        //Response.Write("dCurrentPercentage = " + dCurrentPercentage + "<br/>");         
        //Response.Write("sCompanyID = " + sCompanyID + "<br>");

        Response.Write("<script type=\"text/javascript\">\n");
        Response.Write("dPercentage = " + dCurrentPercentage + ";\n");
        
        if (dCurrentPercentage > 100) {
            recCompany = eWare.FindRecord("Company", "comp_CompanyID=" + sCompanyID);
            Response.Write("isOwnershipValid = false;\n");
            Response.Write("szCompanyName='" + recCompany.comp_Name + "';\n");
        }
        Response.Write("</script>\n");              
	    
	    
%>
        <script type="text/javascript">
            function initBBSI()
            {
                var bReturnValue = true;
                
                //pass the percentage back if the caller was smart enough to know how to look for it
				var opener = window.dialogArguments;
				if (opener.document){
				    var fld = opener.document.all["hdn_CompanyOwnershipPercent"];
				    if (fld)
				        fld.value = dPercentage;
                }
                
                if (!isOwnershipValid) {
					// if the caller specified a field for the total percentage, do not show the alert
					// the caller will handle it
					if (!fld)
					    alert("Warning: The total ownership of " + szCompanyName + " is " + dPercentage + "% which exceeds 100%.");
					bReturnValue = false;
				}
				window.returnValue = bReturnValue;				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
</body>
</html>

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
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
<HTML>
<script> 
	var bDuplicateExists = false;
	
</script>
<BODY>
	<SPAN>Processing... </SPAN>
</BODY>
</HTML>
<%
 
	
        // if we are saving, we need to make sure that there is not a duplicate company name;
        // if there is a duplicate, do not stop the user, just warn them and let them cancel
        
        // get the comp_Name from the form values
        //sCompanyName = getIdValue("companyname");
        sPersonID = new String(Request.Querystring("peli_PersonID"));
        sCompanyID = new String(Request.Querystring("peli_CompanyID"));
        sPersonLinkID = new String(Request.Querystring("peli_PersonLinkID"));

        // First, check for missing company id (we cannot search CRM if it's not there
        var re = /^\-?[0-9]+$/;
        if (re.test(sCompanyID))
        {
	        // try to find a match
	        recDup = eWare.FindRecord("Person_Link", "peli_PersonID=" + sPersonID + " AND peli_CompanyID=" + sCompanyID + "AND peli_PersonLinkID <>" + sPersonLinkID + " AND peli_PRStatus=1");
	        if (!recDup.eof)
	        {
	            // there is a duplicate
	            Response.Write("<SCRIPT>bDuplicateExists = true;</SCRIPT>");
	        }
	    }
	    
%>
        <script type="text/javascript">
            function initBBSI()
            {
                var bReturnValue = true;
                if (bDuplicateExists)
                {
					bReturnValue = confirm("An active history record already exists for this person and company.  Do you want to save this record anyway?");
				}
				window.returnValue = bReturnValue;				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>

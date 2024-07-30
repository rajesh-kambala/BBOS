<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<HTML>
<script> 
	var bActiveExists = false;
	
</script>
<BODY>
	<SPAN >Processing... </SPAN>
<%
/* ****************************************************************************
 *    Filename: PRImportPACAActiveCheck.asp
 * Description: This screen checks a passed prpa_companyid to see if the company
                already has an active license
 *      Author: Copied from Richard Otruba 
 *****************************************************************************/
 
	
        // Check to see if the company already has an active license
        
        // get the the company ID from the form values
        sCompanyID = getIdValue("prpa_companyid");

	    // try to find a match
	    recDup = eWare.FindRecord("PRPACALicense", "prpa_CompanyID=" + sCompanyID + " AND prpa_Current='Y'");
	    if (!recDup.eof)
	    {
	        // there is an active record
	        Response.Write("<SCRIPT>");
	        Response.Write("bActiveExists = true;\n");
	        Response.Write("</SCRIPT>");
	    } else {
	    }
	    
%>
        <script type="text/javascript">
            function initBBSI()
            {
                var bReturnValue = true;
                if (bActiveExists)
                {
                    bReturnValue = confirm("The specified company already has an active PACA license number.  Do you want to save this record anyway?");
				}
				window.returnValue = bReturnValue;				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
</BODY>
</HTML>

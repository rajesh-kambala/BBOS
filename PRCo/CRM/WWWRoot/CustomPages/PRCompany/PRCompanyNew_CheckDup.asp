<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<HTML>
<head>
<script type="text/javascript"> 
	var bDuplicateExists = false;
	
</script>
</head>
<BODY>
	<SPAN >Processing... </SPAN>
</BODY>
</HTML>
<%
/* ****************************************************************************
 *    Filename: PRCompanyNew_CheckDup.asp
 * Description: This screen checks a passed comp_name to see if it already exists
 *      Author: Richard Otruba 
 *****************************************************************************/
 
	
        // if we are saving, we need to make sure that there is not a duplicate company name;
        // if there is a duplicate, do not stop the user, just warn them and let them cancel
        
        // get the comp_Name from the form values
        sCompanyName = new String(Request.Querystring("companyname"));

        var regexp = new RegExp( "%26", "gi");
        sCompanyName = sCompanyName.replace(regexp, "&");

        // This is to escape single ticks
        var regexp = new RegExp( "'", "gi");        
        sCompanyName = sCompanyName.replace(regexp, "''");
        
	    // try to find a match
	    recDup = eWare.FindRecord("PRCompanySearch", "prcse_NameAlphaOnly=dbo.ufn_GetLowerAlpha('" + sCompanyName+ "')");
	    
	    if (!recDup.eof)
	    {
	        // there is a duplicate
	        Response.Write("<script type=\"text/javascript\">bDuplicateExists = true;</script>");
	    }
	    
%>
        <script type="text/javascript">
            function initBBSI()
            {
                var bReturnValue = true;
                if (bDuplicateExists)
                {
					bReturnValue = confirm("A company with an identical tradestyle name exists.  Do you want to save this record anyway?");
				}
				window.returnValue = bReturnValue;				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
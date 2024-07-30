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
	var isOwnershipValid = true;
</script>
<BODY>
	<SPAN >Processing... </SPAN><br>
<%
    var sRoles = "";
    //bDebug = true;
    var sAction = Request("action");
    // get the comp_Name from the form values
    var sCompanyId = String(Request("companyid"));
    DEBUG("sCompanyID = " + sCompanyId );
    var sPeliId = String(Request("peliid"));
    DEBUG("sPeliID = " + sPeliId );

    if (sAction == "retrieveroles")
    {
        sSQL = "SELECT DISTINCT peli_PRRole FROM Person_link " + 
               "WHERE peli_PRRole is not null and peli_deleted is null and peli_PRStatus != 3 " + 
               "  AND peli_CompanyId = " + sCompanyId ;
        if (sPeliId != "undefined" && sPeliId != "")
               sSQL += " AND peli_PersonLinkId != " + sPeliId ;

        recQuery = eWare.CreateQueryObj(sSQL,"");
        recQuery.SelectSQL();
        
        while (!recQuery.eof)
        {
            sRoles += recQuery("peli_PRRole");
            recQuery.NextRecord();
        }
    } else if (sAction == "retrieverecipients")
    {
        sSQL = "SELECT DISTINCT peli_PRRecipientRole FROM Person_link " + 
               "WHERE peli_PRRecipientRole is not null and peli_deleted is null and peli_PRStatus != 3 " + 
               "  AND peli_CompanyId = " + sCompanyId ;
        if (sPeliId != "undefined" && sPeliId != "")
               sSQL += " AND peli_PersonLinkId != " + sPeliId ;

        recQuery = eWare.CreateQueryObj(sSQL,"");
        recQuery.SelectSQL();
        
        while (!recQuery.eof)
        {
            sRoles += recQuery("peli_PRRecipientRole");
            recQuery.NextRecord();
        }
    }
    
    DEBUG("Roles = " + sRoles);         
    
%>
        <script type="text/javascript">
            function initBBSI()
            {
				window.returnValue = '<%= sRoles %>';				
				window.close();
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>

</BODY>
</HTML>

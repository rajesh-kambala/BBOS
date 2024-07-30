<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2008-2018

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
<!-- #include file ="CompanyIDInclude.asp" -->


<%
	    // clear the current DL lines
        sSQL ="SELECT dbo.ufn_GetListingFromCompany(" + comp_companyid + ", 2, 0) As Listing"; 
        qryListing = eWare.CreateQueryObj(sSQL);
        qryListing.SelectSQL();
        
        szListing = qryListing("Listing");



 %>

<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>Company Listing</title>
    <LINK REL="stylesheet" HREF="/<% =sInstallName %>/prco.css">
    <link href="/crm/Themes/Kendo/kendo.default.min.css" rel="stylesheet">
    <link href="/crm/Themes/Kendo/kendo.common.min.css" rel="stylesheet">
    <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet">
</head>

<body class=dialog style="margin:0;">

    <div>
        <h3>Company Listing</h3>
    </div>

    <table style="width:100%;">
    <tr><td>
	    <div style="height:545px;overflow:auto;border: 1px solid gray;">
    	    <pre><% =szListing %></pre>
	    </div>
    </td><td style="vertical-align:top;">
        <table>
        <tr><td>
            <a class="er_buttonItem" HREF="#" onClick="window.close();">Close</a>
        </td></tr>
        </table>
	</td></tr>
    </table>
</body>
</html>

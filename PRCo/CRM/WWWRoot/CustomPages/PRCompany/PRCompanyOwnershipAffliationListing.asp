<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009-2023

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

    recFilter = eWare.FindRecord("vPRCompanyAffiliations", "comp_CompanyId=" + comp_companyid);
    blkListing = eWare.GetBlock("PRSubjectCompanyAffiliations");
    blkListing.RowsPerScreen=0;
    var sContent = blkListing.Execute(recFilter);
%>
<HTML>
    <HEAD>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8">
        <TITLE>CRM</TITLE>
        <link rel="stylesheet" href="/CRM/prco.css" />
        <link href="/crm/Themes/Kendo/kendo.default.min.css" rel="stylesheet">
        <link href="/crm/Themes/Kendo/kendo.common.min.css" rel="stylesheet">
        <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet">

        <script type="text/javascript">
            function setTarget() {
                var oATags = document.body.getElementsByTagName("A");
                for (var i = 0; i < oATags.length; i++) {
                    if ((oATags[i].className != "GRIDHEAD") &&
                        (oATags[i].className != "ButtonItem")) {
                        oATags[i].target = "_parent";
                    }                        
                }
            }
        </script>
        
        
    </HEAD>
    <BODY onload="setTarget();">
    <% =sContent %>
    </BODY>
</HTML>
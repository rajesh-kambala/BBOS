<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2014-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission ofBlue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

    blkListing = eWare.GetBlock("PRCompanyLicenseGrid");
    recFilter = eWare.FindRecord("PRCompanyLicense", "prli_CompanyId=" + comp_companyid);
    var sContent = blkListing.Execute(recFilter);

%>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <title>CRM</title>
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
        
        
    </head>
    <body class="MAINBODY" link="#003B72" vlink="#003B72" topmargin="0" leftmargin=0 onload="setTarget();">
    <% =sContent %>
    </body>
</html>
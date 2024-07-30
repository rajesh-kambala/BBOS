<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
function doPage(){
    //bDebug = true;
    DEBUG(sURL);
    var recClosed = eWare.FindRecord('vPRCompanyExceptionQueue', "preq_DateClosed is not null AND preq_CompanyId = "+ comp_companyid);
    var blkList = null;
    if (recClosed.RecordCount == 0 ){
        blkList = eWare.GetBlock("Content");
        blkList.contents = createAccpacEmptyGridBlock("PRCompanyExceptionGrid_Closed", 
                            "No Closed Exceptions", "No Closed Exceptions Exist");
        Response.Write(blkList.Execute());
    } else {
        blkList = eWare.GetBlock("PRCompanyExceptionGrid_Closed");
        blkList.prevURL = sURL;
        blkList.PadBottom = false;
        // get the content for the block
        var sContent = blkList.Execute(recClosed);            
        // we are assuming this is being shown in an IFrame as the child block in 
        // PRCompanyExceptionListing.asp.  Therfore, every link to 
        // PRExceptionQueueRedirect.asp must be set to open in the parent window, 
        // not the iframe. 
        var regexp = new RegExp('<A HREF="([^>]*)PRExceptionQueueRedirect.asp([^>]*)>([^<]*)</A>', 'gi');
        sContent = sContent.replace(regexp, '<A TARGET=_parent HREF="$1PRExceptionQueueRedirect.asp$2>$3</A>');
        Response.Write(sContent );
    }

}
%>
<HTML>
    <HEAD>
        <META http-equiv="Content-Type" content="text/html; charset=utf-8">
        <TITLE>CRM</TITLE>
        <link rel="stylesheet" href="/CRM/Themes/color1.css" />
        <link rel="stylesheet" href="../../prco.css" />
    </HEAD>
    <BODY>
<%
doPage();
%>
    </BODY>
</HTML>
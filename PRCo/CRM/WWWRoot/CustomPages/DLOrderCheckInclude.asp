<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2012
  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property o Blue Book Services, Inc..
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/

function hasDLService(companyID) {

    var qry = eWare.CreateQueryObj("SELECT 'Y' as Result FROM PRService WHERE prse_ServiceCode = 'DL' AND prse_CompanyID=" + companyID);
    qry.SelectSQL();
        
    if (qry.eof) {
        return false;
    }
    return true;
}

function hasDLServiceOrdered(companyID) {

    var qry = eWare.CreateQueryObj("SELECT 'Y' as Result FROM PRChangeDetection WHERE prchngd_CompanyID=" + companyID);
    qry.SelectSQL();
        
    if (qry.eof) {
        return false;
    }
    return true;
}

function getDLMsgBanner() {
    return getDLMsg("This company does not have the Descriptive Lines service.");
}

function getDLOrderedMsgBanner() {
    return getDLMsg("An order for the Descriptive Line service is being processed.");
}

function getDLMsg(message) {

    sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=center>\n";
    sBannerMsg += "<table class=\"MessageContent\" align=center>\n";
    sBannerMsg += "<tr><td>" + message + "</td></tr>"
    sBannerMsg += "</table>";
    sBannerMsg += "</td></tr></table>";

    return sBannerMsg;
}

function triggerDLOrder(companyID, userID) {

    var qry = eWare.CreateQueryObj("INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_CreatedBy, prchngd_UpdatedBy) VALUES (" + companyID + ", 'DL Order', " + userID + ", " + userID + ")");
    qry.ExecSql();
}
%>
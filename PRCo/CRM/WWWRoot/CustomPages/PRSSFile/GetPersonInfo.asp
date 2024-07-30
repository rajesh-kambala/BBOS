<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2023

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

    doPage();

function doPage()
{
    Response.Expires=0 
    Response.ExpiresAbsolute="July 9,1998 17:30:00"

    var personid = Request("PersonID");
    var companyid = Request("CompanyID");
    var sBuffer = "";

    sql = "SELECT RTRIM(emai_EmailAddress) as emai_EmailAddress " +
            "FROM vPersonEmail WITH (NOLOCK) " +
           "WHERE elink_Type = 'E' AND elink_RecordID = " + personid + " AND emai_CompanyID = " + companyid + " AND emai_PRPreferredInternal='Y'";

    qryEmail = eWare.CreateQueryObj(sql);
    qryEmail.SelectSql();
    if (!qryEmail.eof)
    {
		email = new String(qryEmail("emai_EmailAddress"));
		if (isEmpty(email)) email = "";
		sBuffer += "document.EntryForm.prssc_email.value = '" + email + "';\n" ;
    }
   
	Response.Write(sBuffer);
}
%>
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2009

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
function getARAgingHeader() {

    var recARAgingHeader = eWare.FindRecord("PRCompanyInfoProfile", "prc5_CompanyId = " + comp_companyid + " AND prc5_ARSubmitter='Y'");
    var sARAgingHeader = recARAgingHeader.prc5_ARSubmitter;
    var sARAgingHeaderMsg = "";

    if (!isEmpty(sARAgingHeader)) {
        sARAgingHeaderMsg = "<tr><td>This company is an AR Aging Submitter.</td></tr>";    }
    
    return sARAgingHeaderMsg;
}    
%>
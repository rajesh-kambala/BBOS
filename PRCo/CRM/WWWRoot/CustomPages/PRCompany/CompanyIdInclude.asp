<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2019

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

    // including this defintion in here because all company pages will include this
    // this is not true of CompanyHeaders.asp
    var sTopContentUrl = "CompanyTopContent.asp"; 


    //Establish Context and retrieve records from tables
    var recCompany = null;

    var comp_companyid = String(Request.Querystring("comp_companyid"));

    if (comp_companyid == "null")
        comp_companyid = null;

    // check other possible sources of the company link 
    if (isEmpty(comp_companyid))
        comp_companyid = String(Request.Querystring("peli_companyid"));
    // the SSFile workflow listing uses prfi_Company1Id and prfi_Company2Id to access company summary
    if (isEmpty(comp_companyid))
        comp_companyid = String(Request.Querystring("prfi_company1id"));
    if (isEmpty(comp_companyid))
        comp_companyid = String(Request.Querystring("prfi_company2id"));
    // key1 can have this value from multiple places including native accpac
    if (isEmpty(comp_companyid))
        comp_companyid = String(Request.Querystring("Key1"));
    if (isEmpty(comp_companyid))
        comp_companyid = String(Request.Form.Item("comp_companyid"));
    if (isEmpty(comp_companyid))
        comp_companyid = String(eWare.GetContextInfo("company","comp_companyid"));
    // this is a one-off added for handling PACA search; selecting a PACA License
    // indirectly selects the company
    if (isEmpty(comp_companyid)){
        pacaId = String(Request.Querystring("prpa_PacaLicenseId"));
        if (!isEmpty(pacaId)){
            // look up the paca license and get the company id
            var recPACA = eWare.FindRecord("PRPACALicense", "prpa_PACALicenseId="+pacaId);
            if (!recPACA.eof)
                comp_companyid = recPACA("prpa_CompanyId");
            recPACA = null;
        }
    }

    if (isEmpty(comp_companyid)){
        var interactionID = String(Request.Querystring("Key6"));
        if (!isEmpty(interactionID)) {

            // We are seeing in somecases, due to the F and J keys, that Key6 can appear multiple
            // times in the query string.  This code detects mutliple Key6 values and grabs the
            // first one.  Each time we have seen this scenario, all the values were the same.
            if (interactionID.indexOf(",") > -1)    {
		        var sSplit = interactionID.split(",");
                interactionID = sSplit[0];
            }

            // look up the interaction and get the company id
            var recInteraction = eWare.FindRecord("Comm_Link", "CmLi_Comm_CommunicationId="+interactionID);
            if (!recInteraction.eof)
                comp_companyid = recInteraction("CmLi_Comm_CompanyId");
            recInteraction = null;
        }
    }


    // No Luck!
    if (isEmpty(comp_companyid))
    {
        comp_companyid = String("-1");
    }

    if (!isEmpty(comp_companyid)) 
    {
        var arr = comp_companyid.split(",");
        comp_companyid = arr[0].valueOf();
        recCompany = eWare.FindRecord("company","comp_companyid=" + comp_companyid);
        sTopContentUrl += "&comp_companyid=" + comp_companyid;
    }
%>
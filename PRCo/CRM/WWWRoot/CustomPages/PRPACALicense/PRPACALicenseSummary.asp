<!-- #include file ="../accpaccrm.js" -->
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
<!-- #include file ="../PRCompany/CompanyHeaders.asp" -->
<%

function doPage()
{
    // it is possible to get here from places like PACA License Listing
    // where we do not yet have a companyid on the url; this will cause the 
    // continue button to fail. if we do not have key1 or comp_companyid on 
    // the url, add key1 and redirect to ourself
    if (sURL.indexOf("key1=") == -1 && sURL.indexOf("comp_companyid=") == -1){
        var sNewURL = changeKey(sURL, "key1", comp_companyid);
        Response.Redirect(sNewURL);
        return;
    }

    
    var sEntityName="PRPACALicense";
    var sEntityTitle="PACA License";
    var sEntityIdField="prpa_PACALicenseId";

    if (comp_companyid != "-1")
        sContinueUrl = eWare.URL("PRCompany/PRCompanyLicenseListing.asp");
    else
        sContinueUrl = eWare.URL("PRPACALicense/PRPACALicenseFind.asp");
    // Determine the key id for this entity type
    var prpa_PACALicenseId = new String(eWare.GetContextInfo('PRPACALicense','prpa_PACALicenseId'));
    if (isEmpty(prpa_PACALicenseId)) 
    {
        prpa_PACALicenseId = new String(Request.Querystring(sEntityIdField));
    }
    if (isEmpty(prpa_PACALicenseId)) 
    {
        // Last chance
        prpa_PACALicenseId = new String(Request.Querystring("Key58"));
    }

    if (isEmpty(prpa_PACALicenseId)) 
    {
        Response.Redirect(sContinueUrl);    
        return;
    }

    // find the record based upon the ID
    prpa_record = eWare.FindRecord(sEntityName, sEntityIdField+"="+prpa_PACALicenseId);

    // check for two custom actions for publishing and unpublishing the License
    if (eWare.Mode == 51 || eWare.Mode == 52)
    {
        var sPublishValue = "'Y'"
        if (eWare.Mode == 52)
            sPublishValue = "null"
        // new requirement... when the license is set to publish
        // remove the publish flag on all other licenses with the same companyid 
        // only one license for the company should be marked published
        if (sPublishValue == "'Y'")
        {
            var sql = "UPDATE PRPACALicense SET prpa_Publish = NULL"  
                    + ",prpa_UpdatedDate=getDate(), prpa_Timestamp=getDate(), prpa_UpdatedBy=" + user_userid  
                    + " WHERE prpa_CompanyId='"+ prpa_record("prpa_CompanyId") + "' and prpa_Publish is not null";
            qry = eWare.CreateQueryObj(sql);
            qry.ExecSql();
        }
        
        var sql = "UPDATE PRPACALicense SET prpa_Publish = " + sPublishValue 
                    + ",prpa_UpdatedDate=getDate(), prpa_Timestamp=getDate(), prpa_UpdatedBy=" + user_userid  
                    + " WHERE prpa_PACALicenseId="+ prpa_PACALicenseId;
        qry = eWare.CreateQueryObj(sql);
        qry.ExecSql();
	    sURL = removeKey(sURL, "em");
	    Response.Redirect(sURL);
        return;
    }
    // check for custom action for stealing the current flag and setting it to this License
    else if (eWare.Mode == 65 || eWare.Mode == 75)
    {
        sSetValue_OFF = "prpa_Current = NULL";
        sSetValue_ON = "prpa_Current='Y'";
        sWhereValue = "prpa_Current is not NULL";
        if (eWare.Mode == 75) {
            sSetValue_ON += ", prpa_Publish='Y'";
            sSetValue_OFF += ", prpa_Publish = NULL ";
            sWhereValue += " or prpa_Publish is not NULL";
        }
        var sql = "UPDATE PRPACALicense SET " + sSetValue_OFF
                + ",prpa_UpdatedDate=getDate(), prpa_Timestamp=getDate(), prpa_UpdatedBy=" + user_userid  
                + " WHERE prpa_CompanyId="+ prpa_record("prpa_CompanyId") + " AND (" + sWhereValue + ") ";
        qry = eWare.CreateQueryObj(sql);
        qry.ExecSql();
        
        sql = "UPDATE PRPACALicense SET " + sSetValue_ON 
                + ",prpa_UpdatedDate=getDate(), prpa_Timestamp=getDate(), prpa_UpdatedBy=" + user_userid  
                + " WHERE prpa_PACALicenseId="+ prpa_PACALicenseId;
        qry = eWare.CreateQueryObj(sql);
        qry.ExecSql();
	    sURL = removeKey(sURL, "em");
	    Response.Redirect(sURL);
        return;
    }            
                
    
    // This screen should always present as view
    eWare.Mode = View;
    MainContainer=blkContainer;

    MainContainer.DisplayButton(Button_Default) = false;
    TopContainer=eWare.GetBlock("container");

    MainContainer.DisplayButton(Button_Default) = false;
    MainContainer.AddButton(eWare.Button("Continue","continue.gif", sContinueUrl)); 

    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        var sPublishCaption = "";
        var sPublishUrl = sURL; //removeKey(sURL, "PrevCustomURL") ;
        if (prpa_record("prpa_Publish") == "Y")
        {
            sPublishCaption = "Unpublish";
            sPublishUrl = changeKey(sPublishUrl, "em", "52");
        }
        else
        {
            sPublishCaption = "Publish";
            sPublishUrl = changeKey(sPublishUrl, "em", "51");
        }
        MainContainer.AddButton(eWare.Button(sPublishCaption, "edit.gif", "javascript:location.href='"+sPublishUrl+"';"));

        if (prpa_record("prpa_Current") != "Y")
        {
            sCurrentCaption = "Make&nbsp;Current";
            sCurrentUrl = changeKey(sPublishUrl, "em", "65");
            MainContainer.AddButton(eWare.Button(sCurrentCaption, "edit.gif", "javascript:location.href='"+sCurrentUrl+"';"));

            sCurrentCaption = "Make&nbsp;Current & Published";
            sCurrentUrl = changeKey(sPublishUrl, "em", "75");
            MainContainer.AddButton(eWare.Button(sCurrentCaption, "edit.gif", "javascript:location.href='"+sCurrentUrl+"';"));
        }
    }

    blkSummaryContent=eWare.GetBlock("PRPACALicenseSummary");
    blkSummaryContent.ArgObj = prpa_record;
    blkSummaryContent.Title = sEntityTitle;
    TopContainer.AddBlock(blkSummaryContent);

    // add the Principal and Trade grids 
    BottomContainer=eWare.GetBlock("container");

    blkPrincipalGrid=eWare.GetBlock("PRPACAPrincipalGrid");
    blkPrincipalGrid.DisplayForm = false;

    blkTradeGrid=eWare.GetBlock("PRPACATradeGrid");
    blkTradeGrid.DisplayForm = false;
    blkTradeGrid.NewLine = false;

    blkPrincipalInner = eWare.GetBlock("Content");
    blkTradeInner = eWare.GetBlock("Content");
    blkTradeInner.NewLine = false;
    blkPrincipalInner.contents = blkPrincipalGrid.Execute("prpp_PACALicenseId="+prpa_PACALicenseId);
    blkTradeInner.contents = blkTradeGrid.Execute("ptrd_PACALicenseId="+prpa_PACALicenseId);

    BottomContainer.AddBlock(blkPrincipalInner);
    BottomContainer.AddBlock(blkTradeInner);
        
    MainContainer.AddBlock(TopContainer);
    MainContainer.AddBlock(BottomContainer);
    
    MainContainer.Checklocks = false;
    eWare.AddContent(MainContainer.Execute());
    //eWare.AddContent(MainContainer.Execute("prpa_PACALicenseId="+prpa_PACALicenseId));

    Response.Write(eWare.GetPage("Company"));

}
doPage();
if (comp_companyid != "-1")
{
%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->
<%
}
%>
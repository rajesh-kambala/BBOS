<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
%>
<!-- #include file ="../PRCoGeneral.asp" -->
<%
function doPage()
{
    // note that we do not have a view mode for this entity; that is the purpose of SSAddressInfo.asp
    if (eWare.Mode < Edit)
        eWare.Mode = Edit;

    sCompanySelect = "";
    
    var sSecurityGroups = "1,2,3,4,5,6,7,8,9,10,11";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkMain=eWare.GetBlock("PRSSContactInfo");
    blkMain.Title="Contact Info";
    
    var prss_ssfileid = getIdValue("prss_ssfileid");
    recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);

    sListingAction = eWare.Url("PRSSFile/PRSSAddressInfo.asp")+ "&prss_ssfileid="+ prss_ssfileid;
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
    // Determine if this is new or edit
    var prssc_sscontactid = getIdValue("prssc_sscontactid");
    // indicate that this is new
    if (prssc_sscontactid == "-1")
    {
        var bNew = true;
        recSSContact=eWare.CreateRecord("PRSSContact");
        recSSContact.prssc_SSFileId = prss_ssfileid;
        fldSSFileId=blkMain.GetEntry("prssc_SSFileId");
        fldSSFileId.DefaultValue = prss_ssfileid;
        sSelectedCompanyId = -1;

        // determine the possible companies
        sCompanySelect = "<div style=\"display:none\"><table><tr id=\"_trCompanySelect\"><td  VALIGN=TOP ><SPAN ID=_Captprssc_companyid class=VIEWBOXCAPTION>Company:</SPAN><br>"+
            "<SPAN ID=_Dataprssc_companyid class=VIEWBOXCAPTION >"+
            "<SELECT class=EDIT size=1 name=\"prssc_companyid\"  id=\"prssc_companyid\"  onchange=\"prssc_companyid_change();\" >";
        sql = "SELECT prcse_CompanyId, prcse_FullName FROM PRSSFile "
             + " INNER JOIN PRCompanySearch ON (prcse_CompanyId = prss_ClaimantCompanyId OR prcse_CompanyId = prss_RespondentCompanyId OR prcse_CompanyId = prss_3rdPartyCompanyId )" 
             + " WHERE prss_ssfileid = " + prss_ssfileid;
        qryCompanies = eWare.CreateQueryObj(sql);
        qryCompanies.SelectSql();
        var nFirstCompany = -1;
        while (!qryCompanies.eof)
        {
            sSelected = "";
            if (qryCompanies("prcse_CompanyId") == sSelectedCompanyId)
                sSelected = " SELECTED ";
            sCompanySelect += "<OPTION " + sSelected  + " Value=\"" + qryCompanies("prcse_CompanyId") + "\">" + qryCompanies("prcse_FullName") + "</OPTION>";
            qryCompanies.NextRecord();
        }
        sCompanySelect += "</SELECT></td>"+
            "<td  VALIGN=TOP ><SPAN ID=_Captprssc_personid class=VIEWBOXCAPTION>Person:</SPAN><br>"+
            "<SPAN ID=_Dataprssc_personid class=VIEWBOXCAPTION >"+
            "<SELECT class=EDIT size=1 name=\"prssc_personid\" onchange=\"prssc_personid_change();\" >";
        sCompanySelect += "</SELECT></tr></table></div>";
    } else {
        recSSContact = eWare.FindRecord("PRSSContact", "prssc_sscontactid=" + prssc_sscontactid);
        sSummaryAction = eWare.Url("PRSSFile/PRSSContact.asp")+ "&prssc_sscontactid="+ prssc_sscontactid;
        sSelectedCompanyId = recSSContact("prssc_CompanyId");
    }
            
    Response.Write("<script type=\"text/javascript\" src=\"../ajax.js\"></script>");  
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");  
    Response.Write("<script type=\"text/javascript\" src=\"PRSSContact.js\"></script>");  

    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (eWare.Mode == Edit ){
            if (bNew){
                blkMain.DeleteEntry("prssc_CompanyId");
                blkMain.DeleteEntry("prssc_PersonId");
            } else {
                fldCompanyId=blkMain.GetEntry("prssc_CompanyId");
                fldCompanyId.ReadOnly = true;
                fldPersonId=blkMain.GetEntry("prssc_PersonId");
                fldPersonId.ReadOnly = true;
            }
        }
        
        if (isUserInGroup(sSecurityGroups ))
	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();\""));
        
	}
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRSSContact WHERE prssc_SSContactId="+ prssc_sscontactid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
	    return;
    }

    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recSSContact));
//    DumpFormValues();
    
    if (eWare.Mode == Save) 
    {
        Response.Redirect(sListingAction);
        return;
    }
   
    if (eWare.Mode == Edit) 
    {
        Response.Write(sCompanySelect);
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));
        
        //Response.Write(sCompanySelect);
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        sFileId = " + prss_ssfileid + "; ");
        Response.Write("\n        sCompanyInfoUrl = \"" + eWare.URL("PRSSFile/GetCompanyInfo.asp") + "\";");
        Response.Write("\n        sPersonInfoUrl = \"" + eWare.URL("PRSSFile/GetPersonInfo.asp") + "\";");
        if (!bNew){
            Response.Write("\n        sSSContactId = " + prssc_sscontactid + "; ");
        }else{
            Response.Write("\n        InsertRow(\"_Captprssc_contactattn\", \"_trCompanySelect\"); " ); 
            Response.Write("\n        prssc_companyid_change();");
        }
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }
    else
    {
        Response.Write(eWare.GetPage());
    }        

}
doPage();
%>

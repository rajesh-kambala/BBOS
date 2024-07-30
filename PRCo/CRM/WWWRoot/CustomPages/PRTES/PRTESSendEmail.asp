<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2018

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
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
var _sDefaultEmail
var _sDefaultPersonID

function doPage()
{
    Response.Write("<script type=text/javascript src=\"PRTESSendEmail.js\"></script>")
    var sURL=new String(Request.ServerVariables("URL")() + "?" + Request.QueryString );
    sURL = removeKey(sURL, "em");

    var szTESIDList = getIdValue("TESIDList");

    DEBUG("URL: " + sURL); 
    DEBUG("<br>Mode: " + eWare.Mode); 

	var blkContainer = eWare.GetBlock('container');

    var sSecurityGroups = "1,2,3,4,5,6,8,9,10";
   
	var blkEntry=eWare.GetBlock("PRTESSendFaxNewEntry");
	blkEntry.Title="Send Email";
	blkContainer.CheckLocks = false;
    
    // create a new TES record
    recTESRequest = eWare.CreateRecord("PRTESRequest");
    if (eWare.Mode < Edit)
	    eWare.Mode = Edit;
    
	var sSaveAndSendAction = Request("ReturnURL");
	if (isEmpty(sSaveAndSendAction)) {
	    sSaveAndSendAction = eWare.Url(Request.QueryString("F"));
	}

    // ****  
    if (eWare.Mode == Edit) // Edit
    {
        // DumpFormValues();
        
        // Show the current company (Read-only)
        var entryCompanyId = blkEntry.GetEntry("prtesr_ResponderCompanyId");
        //entryCompanyId.Size = 40;
        entryCompanyId.DefaultType = 1;
        entryCompanyId.DefaultValue = comp_companyid;
        entryCompanyId.ReadOnly = 'true';
        
        // Resize the other company
        entryCompanyId = blkEntry.GetEntry("prtesr_SubjectCompanyId");
        entryCompanyId.Size = 50;
        
        if (szTESIDList != "-1") {
            entryCompanyId.Hidden = 'true';
            Response.Write("<input type=hidden id=hidTESIDList value=Y />");
        } else {
            Response.Write("<input type=hidden id=hidTESIDList value=N />");
        }
        
        getDefaults();
        
        entryAddress = blkEntry.GetEntry("prtesr_OverrideAddress");
        entryAddress.DefaultValue = _sDefaultEmail;
        
        entryPersonId = blkEntry.GetEntry("prtesr_OverridePersonID");
        entryPersonId.Restrictor = "prtesr_ResponderCompanyId";
        if (!isEmpty(_sDefaultPersonID)) {
            entryPersonId.DefaultValue = _sDefaultPersonID;
        }
        
        
    	blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Send Email", "sendletter.gif", "#\" onClick=\"if (validate()) save();\""));
	    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSaveAndSendAction));
    	
	    blkContainer.AddBlock(blkEntry);
	    recTESRequest.prtesr_ResponderCompanyId = comp_companyid;

	    eWare.AddContent(blkContainer.Execute(recTESRequest));
	    Response.Write(eWare.GetPage('New'));
    }
    else if (eWare.Mode == Save) // saving the records
    {
        // DumpFormValues();
        var sResponderCompanyId = String(Request.Form("prtesr_ResponderCompanyId"));
        var sSubjectCompanyId = String(Request.Form("prtesr_SubjectCompanyId"));
        var sEmailAddress = String(Request.Form("prtesr_OverrideAddress")).replace(/^\s*/, '').replace(/\s*$/, '');
        
        var sOverridePersonID = String(Request.Form("prtesr_OverridePersonID"));
        var sOverrideAttention = String(Request.Form("prtesr_OverrideCustomAttention"));
        
	    var dtDate = new Date();
	    var sDate = (dtDate.getMonth() + 1) + "/" + dtDate.getDate() + "/" + dtDate.getYear();
	    sDate = getDBDate(sDate);

        getDefaults();

        var sSQL = "";
        if (szTESIDList != "-1") {
           
            sSQL = "UPDATE PRTESRequest " + 
                         "SET prtesr_SentMethod='E', " + 
                             "prtesr_OverrideAddress= '" + sEmailAddress + "'";

            if (sOverrideAttention != "") {
                sSQL += ", prtesr_OverrideCustomAttention = '" +  padQuotes(sOverrideAttention) + "'";
                sSQL += ", prtesr_OverridePersonID = NULL";
            } else {                        
                sSQL += ", prtesr_OverrideCustomAttention = NULL";
                if (sOverridePersonID != _sDefaultPersonID) {
                    sSQL += ", prtesr_OverridePersonID = " + sOverridePersonID;
                } else {
                    sSQL += ", prtesr_OverridePersonID = NULL";
                }
           } 
                                        
           
           sSQL += " WHERE prtesr_TESRequestID IN (" + szTESIDList + ")";
           
        } else {
            sSQL = "EXECUTE usp_CreateTES " + 
                            "@ResponderCompanyID = " + sResponderCompanyId + ", " +
                            "@SubjectCompanyID = " + sSubjectCompanyId + ", " +
                            "@SentMethod = 'E', " +
                            "@UserId = " + user_userid + ", " +
                            "@CreatedDate = '" + sDate + "', " +
                            "@OverrideAddress = '" + sEmailAddress + "'";

            if (sOverrideAttention != "") {
                sSQL += ", @OverrideCustomAttention = '" + padQuotes(sOverrideAttention) + "'";
            } else {
                if ((sOverridePersonID != "") &&
                    (sOverridePersonID != _sDefaultPersonID)) {
                    sSQL += ", @OverridePersonID = " + sOverridePersonID;
                }                        
            }                      
        }
        
       var recQuery = eWare.CreateQueryObj(sSQL);
       recQuery.ExecSql()           
        
        // The TES ID List only comes from the Verbal Investigations
        // Execute this to send the TES emails now
        if (szTESIDList != "-1") {
            sSQL = "EXEC usp_SendVITESEmail '" + szTESIDList + "'";
            var recQuery = eWare.CreateQueryObj(sSQL);
            recQuery.ExecSql()           
        }

       Response.Redirect(sSaveAndSendAction);
    }
}



function getDefaultEmail()
{
    var sDefaultEmail = "";
    var qryEmail = eWare.CreateQueryObj("SELECT RTRIM(Emai_EmailAddress) As Email FROM vCompanyEmail WITH (NOLOCK) WHERE emai_PRPreferredInternal='Y' AND elink_RecordID=" + String(comp_companyid), "");
    qryEmail.SelectSQL();
    if (!qryEmail.EOF) {
        sDefaultEmail= String(qryEmail("Email"));
    }
    return sDefaultEmail;
}

function getDefaults() {
    var sqlDefaults = "SELECT prattn_PersonID, prattn_EmailID, DeliveryAddress " +
                        "FROM vPRCompanyAttentionLine " +
                       "WHERE prattn_CompanyID=" + comp_companyid + " " +
                         "AND prattn_ItemCode = 'TES-E' " +
                         "AND prattn_EmailID IS NOT NULL " +
                         "AND DeliveryAddress LIKE '%@%'";                         

    var qryDefaults = eWare.CreateQueryObj(sqlDefaults);
    qryDefaults.SelectSQL();

    if (qryDefaults.eof) {
        _sDefaultEmail = getDefaultEmail();
        _sDefaultPersonID = String(Request.Form("prtesr_OverridePersonID"));
    } else  {
        _sDefaultEmail = String(qryDefaults("DeliveryAddress"));
        _sDefaultPersonID = String(qryDefaults("prattn_PersonID"));
    }        
}

doPage();
%>
<!-- #include file ="..\PRCompany\CompanyFooters.asp" -->

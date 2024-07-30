<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

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

doPage();

function doPage(){
    var prwu_webuserid = getIdValue("prwu_WebUserId");
    if (prwu_webuserid == "-1") {
        Response.Redirect(sListingAction);
        return;
    }
    
	var blkScript = eWare.GetBlock("Content");
	blkScript.Contents =
		"<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>" +
		"<script type=\"text/javascript\" src=\"../ajax.js\"></script>" +
		"<script type=\"text/javascript\" src=\"PRWebUser.js\"></script>";
	
    blkContainer = eWare.GetBlock('Container');
    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkScript);

    var email_sent = false;
    switch (eWare.Mode) {
		case View:
			ViewUser(prwu_webuserid, email_sent);
			break;
			
		case Edit:
			EditUser(prwu_webuserid);
			break;
			
		case Save:
			SaveUser(prwu_webuserid);
			eWare.Mode = View;
			ViewUser(prwu_webuserid, email_sent);
			break;

        case 97:
            EnableRegisteredUser(prwu_webuserid);
            eWare.Mode = View;
            ViewUser(prwu_webuserid, email_sent);
            break;

        case 98:
            DisableRegisteredUser(prwu_webuserid);
            eWare.Mode = View;
            ViewUser(prwu_webuserid, email_sent);
            break;
		
		case 99:
			email_sent = EmailUser(prwu_webuserid);
			eWare.Mode = View;
			ViewUser(prwu_webuserid, email_sent);
			break;
			
		default:
			eWare.Mode = View;
			ViewUser(prwu_webuserid, email_sent);
			break;
    }


    Response.Write(eWare.GetPage('Find'));
}

function DisableRegisteredUser(prwu_webuserid) {

    var sSQL = "UPDATE PRWebUser SET prwu_Disabled = 'Y' WHERE prwu_WebUserID=" + prwu_webuserid;
    var qryDisableUser = eWare.CreateQueryObj(sSQL);
    qryDisableUser.ExecSQL();

    return true;
}

function EnableRegisteredUser(prwu_webuserid) {

    var sSQL = "UPDATE PRWebUser SET prwu_Disabled = NULL WHERE prwu_WebUserID=" + prwu_webuserid;
    var qryEnableUser = eWare.CreateQueryObj(sSQL);
    qryEnableUser.ExecSQL();

    return true;
} 
    
function EmailUser(prwu_webuserid) {
    // sending email
    sSQL = "exec usp_SndBBOSPassword " + prwu_webuserid + ", 1" ;
    qryEmailPassword = eWare.CreateQueryObj(sSQL);
    qryEmailPassword.ExecSQL();

    return true;
}

function ViewUser(prwu_webuserid, email_sent) {
	var blkFields = eWare.GetBlock("Content");
	blkFields.Contents = "<input type=\"hidden\" id=\"hdnEmailSent\" name=\"hdnEmailSent\" value=\"" + (email_sent ? "1" : "0") + "\">";
	blkContainer.AddBlock(blkFields);

    var sSecurityGroups = "";
    sListingAction = eWare.Url("PRPerson/PRWebUserListing.asp");

    var sDisplayError = null;
    
    blkContainer.DisplayButton(Button_Default) = false;
    
    recWebUser = eWare.FindRecord("vPRWebUser", "prwu_WebUserId=" + prwu_webuserid);
    bPIKSPerson = false;
    if (recWebUser("prwu_PersonLinkID") > 0){
        bPIKSPerson = true;
    }
    
    sListingAction = eWare.Url("PRPerson/PRWebUserListing.asp");
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
    blkContainer.AddButton(eWare.Button("Change", "edit.gif", "javascript:document.EntryForm.submit();"));

    if (bPIKSPerson) {
        blkMain=eWare.GetBlock("PRWebUserInfo_PIKS");
        if (recWebUser("IsTrial") == "N"){
            entry = blkMain.GetEntry("prwu_TrialExpirationDate");
            if (entry){
                entry.Hidden = true;
            }
        }
        // also need to pass the PersonId or tab links will fail
        recPELI = eWare.FindRecord("Person_Link", "peli_PersonLinkId=" + recWebUser("prwu_PersonLinkID")); 
        sPELIUrl = eWare.Url("PRPerson/PRPersonLink.asp")+ "&Key0=2&Key2=" + recPELI("peli_PersonId") + "&peli_personlinkid=" + recWebUser("prwu_PersonLinkID");
        blkContainer.AddButton(eWare.Button("View Person","continue.gif", sPELIUrl));
        
        var sWebAccessURL = eWare.Url("PRCompany/PRCompanyWebAccessUsers.asp") + "&Key0=1&Key1=" + recPELI("peli_CompanyID");
		blkContainer.AddButton(eWare.Button("Web Access", "continue.gif", sWebAccessURL));
        
        blkContainer.AddBlock(blkMain);
        
    } else {
        blkMain=eWare.GetBlock("PRWebUserInfo");
        blkContainer.AddBlock(blkMain);

        if (recWebUser("prwu_IndustryTypeCode") == "L") {
            blkMain.GetEntry("prwu_HowLearned").LookupFamily = "prwu_HowLearnedL";
        }

        if (recWebUser("prwu_Disabled")) {
            blkContainer.AddButton(eWare.Button("Enable Registered User", "edit.gif", "javascript:document.EntryForm.em.value='97';document.EntryForm.submit();"));
        } else {
            blkContainer.AddButton(eWare.Button("Disable Registered User", "edit.gif", "javascript:document.EntryForm.em.value='98';document.EntryForm.submit();"));
        }
        
        recPurchases = eWare.FindRecord("vPRWebUserPurchase", "prreq_WebUserId=" + prwu_webuserid);
        blkList = eWare.GetBlock("PRWebUserPurchasesGrid");
        blkList.ArgObj = recPurchases;
        blkContainer.AddBlock(blkList);
    }
    blkMain.Title="Web User";

    if (! isEmpty(recWebUser("prwu_Email"))){
        blkContainer.AddButton(eWare.Button("Email Password", "sendemail.gif", "javascript:document.EntryForm.em.value='99';document.EntryForm.submit();"));
    }

    entry = blkMain.GetEntry("prwu_Culture");
    if (entry)
        entry.Caption = "Selected Language:";
        
    eWare.Mode = View;

    eWare.AddContent(blkContainer.Execute(recWebUser)); 
}

function EditUser(prwu_webuserid) {
	var blkFields = eWare.GetBlock("Content");
	
	// Build the URL of the data page, only interested in the page & sid info
	var a1 = eWare.URL("PRPerson/PRWebUserData.asp").split(/[?&]/);
	var url = a1.shift();
	while (a1.length > 0) {
		var s1 = a1.shift();
		if (s1.match(/^\s*SID\s*=/i)) {
			url += "?" + s1;
			break;
		}
	}
	url += "&WebUserID=" + prwu_webuserid;
	blkFields.Contents = "<input type=\"hidden\" id=\"hdnWebUserDataURL\" value=\"" + url + "\" /><span style=\"display:none\" id=\"_ddlPersonLink\"><span id=\"_CaptddlPersonLink\" class=\"VIEWBOXCAPTION\">Company Person:</span><br /><select id=\"ddlPersonLink\" name=\"ddlPersonLink\"><option value=\"1\">one</option><option value=\"2\">two</option></select></span>";

    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
    blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", changeKey(eWare.url("PRPerson/PRWebUser.asp"), "prwu_webuserid", prwu_webuserid)));

	var recWebUser = eWare.FindRecord("PRWebUser", "prwu_WebUserID=" + prwu_webuserid);
	var blkEntry = eWare.GetBlock("PRWebUserEntry");
	blkEntry.Title = "Web User";
	

	var blkBBID = blkEntry.GetEntry("prwu_BBID");
	blkBBID.OnChangeScript = "BBID_Changed();";

	blkContainer.AddBlock(blkFields);
	blkContainer.AddBlock(blkEntry);
	eWare.AddContent(blkContainer.Execute(recWebUser));
}

function SaveUser(prwu_WebUserID) {
	var recWebUser = eWare.FindRecord("PRWebUser", "prwu_WebUserID=" + prwu_WebUserID);
	var blkEntry = eWare.GetBlock("PRWebUserEntry");
	blkEntry.Execute(recWebUser)

}
%>
<!-- #include file ="..\accpaccrm.js" -->

<%

// Need to set mode to edit automatically
if (eWare.Mode < Edit) {
   eWare.Mode = Edit;
}

// Create the new record and add it into workflow
var recMain = eWare.CreateRecord("PRInvestigation");
recMain.SetWorkFlowInfo("PRInvestigation", "Initial");

// Build the screen from CRM blocks
var blkEntry1 = eWare.GetBlock("PRInvestigationNewEntry");
blkEntry1.Title = "Details";

var cntMain = eWare.GetBlock("container");
cntMain.AddBlock(blkEntry1);
cntMain.DisplayButton(Button_Default) = false;
cntMain.CheckLocks = false;
cntMain.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';document.EntryForm.action=x;document.EntryForm.submit();", "PRInvestigation", "EDIT"));
cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.Url("PRCompany/PRCompanyInvestigation.asp")));

eWare.SetContext("New");

// Initialize screen fields based on current record and user
lTeamId = eWare.GetContextInfo('user','user_primarychannelid');
lUserId = eWare.GetContextInfo('user','user_userid');
lCompId = eWare.GetContextInfo("company", "comp_companyid");

// Set company to current user
fldMain = blkEntry1.GetEntry("priv_CompanyId");
fldMain.DefaultValue = lCompId;

// Set assigned user to current user
fldMain = blkEntry1.GetEntry("priv_InvestigationManagerId");
fldMain.DefaultValue = lUserId;

eWare.AddContent(cntMain.Execute(recMain));

if (eWare.Mode == Save) {
   Response.Redirect("PRInvestigationSummary.asp?J=PRInvestigation/PRInvestigationSummary.asp&E=PRInvestigation&priv_InvestigationId=" + recMain("priv_InvestigationId") + "&" + Request.QueryString);
} else {
   sRefreshTabs = Request.QueryString("RefreshTabs");

   if (sRefreshTabs == 'Y') {
      Response.Write(eWare.GetPage('New'));
   } else {
      Response.Write(eWare.GetPage());
   }
}

%>


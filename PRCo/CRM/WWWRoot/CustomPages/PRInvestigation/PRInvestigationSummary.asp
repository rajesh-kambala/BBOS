<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

if (eWare.Mode != Save) {
   F = Request.QueryString("F");

   if (F == "PRInvestigationNew.asp") {
      eWare.Mode = Edit;
   }
}

// If a valid Id is present, display the page.
var lId = 0

// First check for the key
lId = pcg_GetId("priv_InvestigationId");

// If the key is not found, check for the communication record key
if (lId.toString() == 'undefined') {
	lId = pcg_GetId("comm_PRInvestigationId");
}

if (lId != 0) {
	// Set Context correctly
   eWare.SetContext("PRInvestigation", lId);

   recMain = eWare.FindRecord("PRInvestigation", "priv_InvestigationId=" + lId);

	blkEntry1 = eWare.GetBlock("PRInvestigationNewEntry");
	blkEntry1.Title = "Details";

	cntMain = eWare.GetBlock("container");
	cntMain.AddBlock(blkEntry1);
	cntMain.DisplayButton(1) = false;
	cntMain.CheckLocks = false;

   // If we are deleting the record, execute delete function and save changes
   if (eWare.Mode == PreDelete) {
      recMain.DeleteRecord = true;
      recMain.SaveChanges();

      // need to redirect back to the place where we got to the summary from
      // -- but we cant refresh the top frame easily so just go back to find
      PrevCustomURL = new String(Request.QueryString("F"));
      URLarr = PrevCustomURL.split(",");
      if (URLarr[0].toUpperCase() != "PRInvestigationNew.asp") {
         Response.Redirect(eWare.URL("PRInvestigation/PRInvestigationFind.asp?J=PRInvestigation/PRInvestigationFind.asp&E=PRInvestigation"));
      } else {
         Response.Redirect(eWare.URL("PRInvestigationNew.asp?J=PRInvestigationNew.asp&E=PRInvestigation"));
      }
   } else {
	   // otherwise add the appropriate buttons if in edit mode -- continue and save, or continue and change
      if (eWare.Mode == Edit) {
         cntMain.DisplayButton(Button_Continue) = true;
         cntMain.AddButton(eWare.Button("Save", "save.gif", "javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='priv_InvestigationId=" + lId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRInvestigation", "SAVE"));
      } else {
         cntMain.DisplayButton(Button_Continue) = true;
         cntMain.AddButton(eWare.Button("Change","edit.gif","javascript:x=location.href;if (x.charAt(x.length-1)!='&')if (x.indexOf('?')>=0) x+='&'; else x+='?';x+='priv_InvestigationId=" + lId + "';document.EntryForm.action=x;document.EntryForm.submit();", "PRInvestigation", "EDIT"));
      }
      
      cntMain.ShowWorkflowButtons = true;
      cntMain.WorkflowTable = 'PRInvestigation';

      eWare.AddContent(cntMain.Execute(recMain));
   }

   Response.Write(eWare.GetPage());
}

%>

<!-- #include file="topcontent.asp" -->

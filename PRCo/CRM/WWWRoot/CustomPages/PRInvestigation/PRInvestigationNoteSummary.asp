<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PCGLibrary.asp" -->

<%

var lId = new String(Request.Querystring('lbbo_buyingopid'));
var lNoteId = new String(Request.Querystring('note_NoteId'));
var txtNote;
var lBuyingOpId = new String(Request.Querystring('Key37'));
var SID = Request.QueryString('SID');

// the Mode is less than edit, change to edit mode, split the note id, and to set the text field to current data

if (eWare.Mode != Save) {
	F = Request.Querystring("F");
	if (F == "PRInvestigation/PRInvestigationNoteNew.asp") {
		eWare.Mode = Save;
	}
}

if (eWare.Mode == Edit) {
	// Split the lId string
	if (lNoteId.toString() == 'undefined') {
	   lNoteId = new String(Request.Querystring('Key58'));
	}
	
	var lUseId = 0;

	if (lNoteId.indexOf(',') > 0) {
	   var Idarr = lNoteId.split(",");
	   lUseId = Idarr[0];
	} else if (lNoteId != '') {
	   lUseId = lNoteId;
	}

	eWare.Mode = Edit;
	
	x = eWare.FindRecord("Notes","Note_NoteId=" + lUseId);
	txtNote = x.note_note;
} else {
	if (lNoteId.toString() == 'undefined') {
	   lNoteId = new String(Request.Querystring('Key58'));
	}
	
	var lUseId = 0;

	if (lNoteId.indexOf(',') > 0) {
	   var Idarr = lNoteId.split(",");
	   lUseId = Idarr[0];
	} else if (lNoteId != '') {
	   lUseId = lNoteId;
	}
	
	x = eWare.FindRecord("Notes","Note_NoteId=" + lUseId);

//       x = eWare.FindRecord("Notes","note_NoteId=" + lUseId);
}

cntMain = eWare.GetBlock("container");
blkEntry1 = eWare.GetBlock("PRNoteBox");
blkEntry1.Title = "Note";
blkEntry1.Checklocks = false;

   if (eWare.Mode == PreDelete) {
      record.DeleteRecord = true;
      record.SaveChanges();

      // need to redirect back to the place where we got to the summary from
      // -- but we cant refresh the top frame easily so just go back to find
      PrevCustomURL = new String(Request.QueryString("F"));
      URLarr = PrevCustomURL.split(",");

      if (URLarr[0].toUpperCase() != "PRInvestigationNoteNew.asp") {
         Response.Redirect(eWare.URL("PRInvestigation/PRInvestigationNote.asp?J=PRInvestigation/PRInvestigationNote.asp&E=PRInvestigation"));
      } else {
         Response.Redirect(eWare.URL("PRInvestigationNoteNew.asp?J=PRInvestigationNoteNew.asp&E=PRInvestigation"));
      }
   } else {
      if (eWare.Mode == Edit) {
         cntMain.DisplayButton(Button_Default) = true;
      } else {
        cntMain.addbutton(eWare.Button("Continue","Continue.gif",eWare.URL("PRInvestigation/PRInvestigationNote.asp?F=PRInvestigation/PRInvestigationNoteSummary.asp&J=PRInvestigation/PRInvestigationNote.asp&priv_InvestigationId=" + lId + ""))); 

      }
   }

cntMain.AddBlock(blkEntry1);   

eWare.AddContent(cntMain.Execute(x));

Response.Write(eWare.GetPage());

%>
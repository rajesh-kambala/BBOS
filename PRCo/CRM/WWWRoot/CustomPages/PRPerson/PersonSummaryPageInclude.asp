<%
	var sEntityName = "PR" + sAbbrEntityName;
    var sListingPage = "PRPerson/PR" + sAbbrEntityName + "Listing.asp";
    var sSummaryPage = "PRPerson/PR" + sAbbrEntityName + ".asp";
    var sEntityIdName = sEntityPrefix + "_" + sAbbrEntityName + "Id";
    var sNewEntryBlockName = "PR" + sAbbrEntityName + "NewEntry";

    blkEntry=eWare.GetBlock(sNewEntryBlockName);
    blkEntry.Title=sNewEntryBlockTitle;
    Entry = blkEntry.GetEntry(sEntityPersonIdName);
    Entry.DefaultValue = pers_personid;
    Entry.Hidden = true;
    blkContainer.CheckLocks = false; 
    blkContainer.AddBlock(blkEntry);

    var Id = getIdValue(sEntityIdName);
   
    // indicate that this is new
    if (Id == -1 )
    {
	    rec = eWare.CreateRecord(sEntityName);
		rec.item(sEntityPersonIdName) = pers_personid;

        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    else
    {
        rec = eWare.FindRecord(sEntityName, sEntityIdName + "=" + Id);
    }
    sListingAction = eWare.Url(sListingPage)+ "&" + sEntityPersonIdName + "=" + pers_personid + tabContext;
    sSummaryAction = eWare.Url(sSummaryPage)+ "&" + sEntityIdName + "="+ Id + tabContext;

    bValidationError = false;
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Save)
    {
        if (blkContainer.Validate())
        {
            blkContainer.Execute(rec); 
            
            //Debugging Lines...
            //eWare.AddContent(blkContainer.Execute(rec)); 
            //eWare.Mode = View;
            //Response.Write(eWare.GetPage('New'));
    	    
	        if (Id == -1 )
	            Response.Redirect(sListingAction);
	        else
	            Response.Redirect(sSummaryAction);
        }
        else
        {
            bValidationError = true;
        }
        
    }
    
    if (eWare.Mode == Edit || bValidationError)
    {
        
        if (Id == -1 )
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        else
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
        eWare.AddContent(blkContainer.Execute(rec)); 
        eWare.Mode = Edit;        
        Response.Write(eWare.GetPage('Person'));
        
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        document.getElementById('" + sEntityPersonIdName + "').value='" + pers_personid + "';");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");        

    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE " + sEntityIdName + "="+ Id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup(sSecurityGroups))
	        {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
    	}
        eWare.AddContent(blkContainer.Execute(rec)); 
        Response.Write(eWare.GetPage('Person'));

    }

%>
<!-- #include file ="../RedirectTopContent.asp" -->

<%
	var sEntityName = "PR" + sAbbrEntityName;
    var sListingPage = "PRCompany/PR" + sAbbrEntityName + "Listing.asp";
    var sSummaryPage = "PRCompany/PR" + sAbbrEntityName + ".asp";
    var sEntityCompanyIdName = sEntityPrefix + "_CompanyId";
    var sEntityIdName = sEntityPrefix + "_" + sAbbrEntityName + "Id";
    var sNewEntryBlockName = "PR" + sAbbrEntityName + "NewEntry";

    blkMain=eWare.GetBlock(sNewEntryBlockName);
    blkMain.Title=sNewEntryBlockTitle;

    entryCompany = blkMain.GetEntry(sEntityCompanyIdName);
    if (entryCompany != null && entryCompany != "undefined")
        entryCompany.Hidden = true;
        
    var Id = getIdValue(sEntityIdName);
    // indicate that this is new
    if (Id == "-1" )
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    
    sListingAction = eWare.Url(sListingPage)+ "&" + sEntityCompanyIdName + "=" + comp_companyid;
    sSummaryAction = eWare.Url(sSummaryPage)+ "&" + sEntityIdName + "="+ Id;

    rec = eWare.FindRecord(sEntityName, sEntityIdName + "=" + Id);
    
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
	        rec = eWare.CreateRecord(sEntityName);
			
			rec.item(sEntityCompanyIdName) = comp_companyid;
            
            Entry = blkMain.GetEntry(sEntityCompanyIdName);
            Entry.DefaultValue = comp_companyid;
            Entry.Hidden = true;

            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }

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

    }
    blkContainer.CheckLocks = false; 

    blkContainer.AddBlock(blkMain);
    //eWare.AddContent(blkContainer.Execute());
    eWare.AddContent(blkContainer.Execute(rec)); // generates HTML content that gets seen

    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));

        Response.Write("\n<script type=text/javascript >");
        Response.Write("\n    initBBSI() {");
        Response.Write("\n        document.getElementById('" + sEntityPrefix + "_companyid').value='" + comp_companyid + "';");
        //Response.Write("\n        LoadComplete('');");
        Response.Write("\n    }");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");        
    }
    else
        Response.Write(eWare.GetPage());

%>

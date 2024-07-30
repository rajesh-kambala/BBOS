<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%
        
    DEBUG(sURL);
    var sSecurityGroups = "1,2,3,4,5,6,10";

    // Create the form
	blkDRC = eWare.GetBlock("PRDRCLicenseNewEntry");
	blkDRC.Title = "DRC Information";
    Entry = blkDRC.GetEntry("prdr_CompanyId");
    Entry.Hidden = true;

    recDRCLicense = eWare.FindRecord("PRDRCLicense", "prdr_CompanyId=" + comp_companyid);
    if (recDRCLicense.eof) {
        recDRCLicense = eWare.CreateRecord("PRDRCLicense");
    }
        
    sCancelAction = eWare.Url("PRCompany/PRCompanyLicenseListing.asp")+ "&comp_CompanyId=" + comp_companyid;
    // based upon the mode determine the buttons and actions
    if (eWare.Mode == '99' || eWare.Mode == Save)
    {
        if (eWare.Mode == '99')
            eWare.Mode = Edit;
        if (recDRCLicense.eof)
        {
	        recDRCLicense = eWare.CreateRecord("PRDRCLicense");
            recDRCLicense.prdr_CompanyId = comp_companyid;
            Entry.DefaultValue = comp_companyid;
	    }
                
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sCancelAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
	    blkContainer.AddBlock(blkDRC);
	    blkContainer.CheckLocks = false;
    }
    else 
    {
        eWare.Mode = View;
        sContinueAction = eWare.Url("PRCompany/PRCompanyProfile.asp") + "&T=Company&Capt=Profile";
        blkContainer.AddButton(eWare.Button("Continue","continue.gif",sContinueAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
            {
    	        blkContainer.AddButton(eWare.Button("Change DRC","edit.gif","javascript:document.EntryForm.em.value='99';document.EntryForm.submit();"));
	            //blkContainer.AddButton(eWare.Button("New PACA License", "new.gif", eWare.URL("PRPACALicense/PRPACALicenseNew.asp") ));
	            blkContainer.AddButton(eWare.Button("New License", "new.gif", eWare.URL("PRCompany/PRCompanyLicense.asp") ));
            }
    	}
	    // only show these if the page is in view mode

        //
        // We are putting these grids in an IFrame in order to allow them to sort.  Accpac has
        // trouble natively sorting when multiple grids are on a single page.
        //


        var sHeight = "750";
        var sURL = eWare.URL("PRCompany/PRCompanyLicensePACAListing.asp")+"&comp_companyid=" + comp_companyid;;;
        var grdPACA = eWare.GetBlock('Content');
        grdPACA.contents = '<iframe ID="ifrmPACALicense" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sURL +'"></iframe>';


        var sHeight = "750";
        var sURL = eWare.URL("PRCompany/PRCompanyLicenseGeneralListing.asp")+"&comp_companyid=" + comp_companyid;;;
        var grdLicense = eWare.GetBlock('Content');
        grdLicense.contents = '<iframe ID="ifrmGeneralLicense" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sURL +'"></iframe>';


	    blkContainer.AddBlock(grdPACA);
        blkContainer.AddBlock(blkDRC);
  	    blkContainer.AddBlock(grdLicense);
    }
    
	eWare.AddContent(blkContainer.Execute(recDRCLicense));

    if (eWare.Mode == Save) 
    {
	    Response.Redirect(eWare.Url("PRCompany/PRCompanyLicenseListing.asp")+ "&comp_CompanyId=" + comp_companyid);
    }
    else if (eWare.Mode == Edit) 
    {
	    Response.Write(eWare.GetPage('Company'));
	    
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        Response.Write("\n        document.getElementById('prdr_companyid').value='" + comp_companyid + "';");
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");        
	    
    }
    else
	    Response.Write(eWare.GetPage('Company'));


%>
<!-- #include file="CompanyFooters.asp" -->

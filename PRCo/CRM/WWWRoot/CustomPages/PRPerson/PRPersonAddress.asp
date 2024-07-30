<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = sDefaultPersonSecurity;

    function setAddressLinkCheckbox(recAddrLink, formfield)
    {
    
        sChk = Request.Form.Item(formfield);
	    if (sChk == "on")
	        sChk = "Y"
	    else
	        sChk = "";

        recAddrLink(formfield) = sChk;
        // turn off all other defaults for this company
        if (sChk == "Y")
        {
            sSQL = "Update Address_link set " + formfield+ "=NULL Where adli_PersonId = " + pers_personid;
            qrySQL = eWare.CreateQueryObj(sSQL);
            qrySQL.ExecSQL();
        }        
    }

    //DumpFormValues();
    var addr_AddressId = getIdValue("addr_AddressId");

    sListingAction = eWare.Url("PRPerson/PRPersonContactInfoListing.asp")+ "&pers_personId=" + pers_personid + "&T=Person&Capt=Contact+Info";
    sSummaryAction = eWare.Url("PRPerson/PRPersonAddress.asp")+ "&addr_AddressId=" + addr_AddressId + "&T=Person&Capt=Contact+Info";

	// handle saves before anything else, because we'll redirect away upon completion
	if (eWare.Mode == Save) 
    {
        bNew = false;
        if (addr_AddressId == -1 )
        {
    	    bNew = true;
    	    recAddress = eWare.CreateRecord("Address");
        }
        else
            recAddress = eWare.FindRecord("Address", "addr_AddressId="+ addr_AddressId);
        
	    // we are using a view to populate the screen; therefore the fields have to 
	    // be saved manually.
	    recAddress.addr_Address1 = Request.Form.Item("addr_address1");
	    recAddress.addr_Address2 = Request.Form.Item("addr_address2");
	    recAddress.addr_Address3 = Request.Form.Item("addr_address3");
	    recAddress.addr_Address4 = Request.Form.Item("addr_address4");
	    recAddress.addr_PRCityId = Request.Form.Item("addr_prcityid");
	    recAddress.addr_PostCode = Request.Form.Item("addr_postcode");
	    recAddress.addr_PRCounty = Request.Form.Item("addr_prcounty");
	    recAddress.addr_PRDescription = Request.Form.Item("addr_prdescription");
	    // fill in the remaining address fields used by accpac
	    recCity = eWare.FindRecord("PRCity", "prci_CityId="+ recAddress.addr_PRCityId);
	    if (!recCity.eof)
	    {
	        recAddress.addr_City = recCity.prci_City;
	        recState = eWare.FindRecord("PRState", "prst_StateId=" + recCity.prci_StateId);
	        if (!recState.eof)
	        {
	            recAddress.addr_State = recState.prst_State;
	            recCountry = eWare.FindRecord("PRCountry", "prcn_CountryId=" + recState.prst_CountryId);
	            if (!recCountry.eof)
	            {
    	            recAddress.addr_Country = recCountry.prcn_Country;
	            }
	        }
	    }
	    //recAddress.addr_PRZone = Request.Form.Item("addr_przone");
        recAddress.SaveChanges();
        addr_AddressId = recAddress.addr_AddressId;
        
        recAddressLink = eWare.FindRecord("Address_Link", "adli_AddressId="+addr_AddressId);
        if (recAddressLink.eof)
        {
            recAddressLink = eWare.CreateRecord("Address_Link");
            recAddressLink.adli_PersonId = pers_personid;
            recAddressLink.adli_AddressId = addr_AddressId;
	    }
	    recAddressLink.adli_Type = Request.Form.Item("adli_type");
	    setAddressLinkCheckbox(recAddressLink,'adli_prdefaultmailing');
        recAddressLink.SaveChanges();

        if (bNew )
            Response.Redirect(sListingAction);
        else
            Response.Redirect(sSummaryAction);
    }
    
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete on the address_link records but a logical delete on address
        sql = "DELETE FROM Address_Link WHERE adli_AddressId="+ addr_AddressId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();

        recAddress = eWare.FindRecord("Address", "addr_AddressId="+ addr_AddressId);
	    recAddress.DeleteRecord = true;
	    recAddress.SaveChanges();
	    Response.Redirect(sListingAction);
    }
    else
    {
        if (addr_AddressId == -1 )
        {
    	    recAddress = eWare.CreateRecord("Address");
            if (eWare.Mode < Edit)
                eWare.Mode = Edit;
        }
        else
        {
            recAddress = eWare.FindRecord("vPRAddress", "addr_AddressId="+ addr_AddressId);
        }

	    Response.Write("<script language=javascript src=\"../PRCoGeneral.js\"></script>");
	    Response.Write("<LINK REL=\"stylesheet\" HREF=\"../../prco.css\">");
    
        blkAddress=eWare.GetBlock("PRPersonAddressNewEntry");
        blkAddress.Title="Person Address";
        entry = blkAddress.GetEntry("adli_Type");
        entry.LookUpFamily = "adli_TypePerson";
        entry.AllowBlank = false;
        entry.DefaultValue = "B";

        blkAddress.ArgObj = recAddress;
        blkContainer.CheckLocks = false;
        blkContainer.AddBlock(blkAddress);

        // based upon the mode determine the buttons and actions
        sPageAction = "";
        if (eWare.Mode == Edit)
        {
            sPageAction = "New";
            if (addr_AddressId == -1 )
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            else
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
            
            if (iTrxStatus == TRX_STATUS_EDIT)
                if (isUserInGroup(sSecurityGroups))
    	            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

        }
        else 
        {
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
            if (iTrxStatus == TRX_STATUS_EDIT)
            {
                if (isUserInGroup(sSecurityGroups))
                {
                    //sDeleteUrl = changeKey(sURL, "em", "3");
                    var sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";

                    blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                    blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
    	        }
    	    }
        }

        if (eWare.Mode == Edit)
        {
            //Create the Perfect Address Verification Block
            blkPerfectAddress = eWare.GetBlock("Content");//style={display:none}
            sContent = createAccpacBlockHeader("PerfectAddress", "Address Verification");
            sContent  += "<table \"width=100%\" ><tr ID=\"tr_PerfectAddress\"><td width=\"100%\">";
            
            sContent += "<IFRAME border=0 width=100% ID=\"embed_PerfectAddress\" ></IFRAME> ";
            sContent += "</td><td valign=\"top\"><input id=\"btnVerify\" type=\"button\" value=\"Refresh\" onclick=\"refreshPerfectAddress()\"/></td></tr></table>";
            sContent += createAccpacBlockFooter();
            blkPerfectAddress.contents = sContent;
            blkContainer.AddBlock(blkPerfectAddress);
        }
            
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage(sPageAction));

        Response.Write("<script type=\"text/javascript\" src=\"../PRAddressInclude.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"../PRAddressPA.js\"></script>");

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        if (eWare.Mode == Edit)
        {
            Response.Write("\n        refreshPerfectAddress(); " );
            Response.Write("\n        initPerfectAddressAutoRefresh(); " );
        }
        Response.Write("\n    }");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");

        //Special handling for ENTER key because other methods didn't permit suppression of the default form submit and was bypassing validation
        //Prevent default but call save()
        Response.Write("\n    window.addEventListener(\"keydown\", function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){e.preventDefault();save();return false;}},true);");

        Response.Write("\n</script>");
    }
%>
<!-- #include file ="../RedirectTopContent.asp" -->
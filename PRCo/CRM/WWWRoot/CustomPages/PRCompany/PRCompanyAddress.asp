<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->

<%
    var sSecurityGroups = "1,2,3,4,5,6,10";
    var sInnerMsg = "";
    var bAttentionLine = false;
    
    //Response.Write(sURL);
    var sAddressDefaultsString = "";
    var blkAddress=eWare.GetBlock("PRAddressNewEntry");

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
            sSQL = "UPDATE Address_link SET " + formfield+ "=NULL WHERE adli_CompanyId = " + recCompany("comp_CompanyId");
            qrySQL = eWare.CreateQueryObj(sSQL);
            qrySQL.ExecSQL();
        }        
    }

    function removeExistingAddressLinkPublishFlags()
    {
        // Only happens for mailing address
    
        sSQL = "UPDATE Address SET addr_PRPublish = NULL FROM Address_Link "
               + " WHERE addr_AddressId = adli_AddressId AND adli_Type = 'M' AND addr_PRPublish = 'Y' AND adli_CompanyId = " + comp_companyid;
        qrySQL = eWare.CreateQueryObj(sSQL);
        qrySQL.ExecSQL();
    }

    var addr_AddressId = getIdValue("addr_AddressId");

//    DumpFormValues();
    sListingAction = eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + "&T=Company&Capt=Contact+Info";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyAddress.asp")+ "&addr_AddressId=" + addr_AddressId + "&T=Company&Capt=Contact+Info";

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

	    var addr_prpublish = Request.Form.Item("addr_prpublish");
	    if (addr_prpublish == "on")
	        addr_prpublish = "Y";
	    recAddress.addr_PRPublish = addr_prpublish;
    
  	    var adli_Type = Request.Form.Item("adli_type");
  	    if (adli_Type == "M" && addr_prpublish == "Y")
  	    {
            // Update all addresslink records to remove other mailing and publishing flags.
            removeExistingAddressLinkPublishFlags();
  	    }

        recAddress.SaveChanges();
        addr_AddressId = recAddress.addr_AddressId;
        
        // these should be one-to-one
        recAddressLink = eWare.FindRecord("Address_Link", "adli_AddressId="+addr_AddressId);
        if (recAddressLink.eof)
        {
            recAddressLink = eWare.CreateRecord("Address_Link");
            recAddressLink.adli_CompanyId = comp_companyid;
            recAddressLink.adli_AddressId = addr_AddressId;
	    }
	    recAddressLink.adli_Type = adli_Type;
	    
	    setAddressLinkCheckbox(recAddressLink,'adli_prdefaultmailing');
	    setAddressLinkCheckbox(recAddressLink,'adli_prdefaulttax');
        recAddressLink.SaveChanges();
   	    
    	// Go back to the listing page
        if (bNew )
            Response.Redirect(sListingAction);
        else
            Response.Redirect(sSummaryAction);
            //Response.Write("Saving the Address");

    }
    else if (eWare.Mode == PreDelete )
    {
        recAddress = eWare.FindRecord("Address", "addr_AddressId="+ addr_AddressId);
        //Perform a physical delete on the address_link records but a logical delete on address
        sql = "DELETE FROM Address_Link WHERE adli_AddressId="+ addr_AddressId;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    recAddress.DeleteRecord = true;
	    recAddress.SaveChanges();
	    Response.Redirect(sListingAction);
    }
    else 
    {	
        // indicate that this is new
        if (addr_AddressId == -1 )
        {
    	    recAddress = eWare.CreateRecord("Address");
    	    if (eWare.Mode < Edit)
    	        eWare.Mode = Edit;
    	    // determine which default flags are already set
    	    rec = eWare.FindRecord("Address_Link", "adli_PRDefaultMailing='Y' and adli_CompanyId=" + comp_companyid);
    	    if (rec.eof) recAddress.adli_PRDefaultMailing = "Y";

    	    rec = eWare.FindRecord("Address_Link", "adli_PRDefaultTax='Y' and adli_CompanyId=" + comp_companyid);
    	    if (rec.eof) recAddress.adli_PRDefaultTax = "Y";

        }
        else
        {
            recAddress = eWare.FindRecord("vPRAddress", "addr_AddressId="+ addr_AddressId);
            recAttnLine = eWare.FindRecord("PRAttentionLine", "prattn_AddressID="+ addr_AddressId);
            if (!recAttnLine.eof) {
                bAttentionLine = true;
                var sAttnLineURL = eWare.Url("PRCompany/PRCompanyAttentionLine.asp")+ "&comp_CompanyId=" + comp_companyid;
                sInnerMsg += "<tr><td>This address is associated with an <a href=\"" + sAttnLineURL + "\">attention line</a>.</td></tr>";
            }
        }
        
        Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
	    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        
        blkAddress.Title="Company Address";
        entry = blkAddress.GetEntry("adli_Type");

        if(recCompany("comp_PRIndustryType") == "L")
        {
            entry.LookUpFamily = "adli_TypeCompany";
        }
        else
        {
            entry.LookUpFamily = "adli_TypeCompanyNotL"; //new for MadisonLumber
        }

        entry.AllowBlank = false;
        entry.DefaultValue = "M";
        entry.OnChangeScript = "selectAddressType();";

        // set checked defaults to readonly; if this is a new address, all checkboxes that 
        // have not previously been set should get checked
        var bHasDefaults = false;
        if (recAddress("adli_PRDefaultMailing") == "Y") {
            sAddressDefaultsString += "document.EntryForm.adli_prdefaultmailing.checked = true; document.EntryForm.adli_prdefaultmailing.disabled =true;";
            bHasDefaults = true;
        }
        if (recAddress("adli_PRDefaultTax") == "Y") {
            sAddressDefaultsString += "document.EntryForm.adli_prdefaulttax.checked = true; document.EntryForm.adli_prdefaulttax.disabled =true;";
            bHasDefaults = true;
        }

        blkAddress.ArgObj = recAddress;

        // based upon the mode determine the buttons and actions
        if (eWare.Mode == Edit)
        {
            if (addr_AddressId == -1 )
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            else
                blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
            
            if (iTrxStatus == TRX_STATUS_EDIT)
    	        if (isUserInGroup(sSecurityGroups)) {
        	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        	        blkContainer.AddButton(eWare.Button("Select All Defaults", "selectall.gif", "javascript:selectAllDefaults();"));
        	    }

        }
        else 
        {
            if (sInnerMsg != "")
            {
                
                sBannerMsg = "<table width=\"100%\" cellspacing=0 class=\"MessageContent\">" + sInnerMsg + "</table> ";
                var blkBanners = eWare.GetBlock('content');
                blkBanners.contents = sBannerMsg;
                blkContainer.AddBlock(blkBanners);
            }          
        
            blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
            if (iTrxStatus == TRX_STATUS_EDIT)
            {
    	        if (isUserInGroup(sSecurityGroups))
                {
                    if ((bHasDefaults) || (bAttentionLine)) {
                        sDeleteUrl="javascript:alert('Please reassign the default address settings, or reassign the attention line, to another address prior to removing this record.');";
                    } else {
                        sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
                    }
                
                    blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));
                    sReplicateAction = eWare.Url("PRCompany/PRCompanyReplicate.asp")+ "&RepType=2&RepId=" + addr_AddressId + "&comp_CompanyId=" + comp_companyid;
                    blkContainer.AddButton(eWare.Button("Replicate", "includeall.gif", "javascript:location.href='"+sReplicateAction+"';"));
                    blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
                }
    	    }

        }


        blkContainer.AddBlock(blkAddress);
        blkContainer.CheckLocks = false;

       
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

            //Add the usage message
            sMsg = "If this address has a special building or market description, place the value in the 'Address 1' field.";
            Response.Write("<table style=\"display:none;\"><tr ID=\"_trUsage\"><td colspan=\"4\" class=\"GRAYEDTEXT\">"+ sMsg +"</td></tr></table>");
        }
        
        if (eWare.Mode == View)
        {
            var sSQL = " SELECT dbo.ufn_GetCustomCaptionValue('SSRS', 'URL', 'en-us') as SSRSURL ";
            var recSSRS = eWare.CreateQueryObj(sSQL);
            recSSRS.SelectSQL();                
            var sReportURL = recSSRS("SSRSURL") +  "/Accounting/AddressPreview&rc:Parameters=false&rs:embed=true&CompanyID=" + comp_companyid + "&AddressID=" + addr_AddressId;


            //Create the Perfect Address Verification Block
            blkAddressPreview = eWare.GetBlock("Content");
            sContent = createAccpacBlockHeader("AddressPreview", "Address Preview");
            sContent  += "<table style=\"width:100%;\" ><tr ID=\"tr_AddressPreview\"><td width=\"100%\">";
            
            sContent += "<IFRAME border=0 style=\"width:900px;height:300px;\" ID=\"embed_AddressPreview\" src=\"" + sReportURL + "\"></IFRAME> ";
            sContent += "</td></tr></table>";
            sContent += createAccpacBlockFooter();
            blkAddressPreview.contents = sContent;
            blkContainer.AddBlock(blkAddressPreview);


        }      


        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage("Company"));

        var sReplicateString = "";
        if (!isEmpty(recAddress("addr_PRReplicatedFromId")) )
        {
            recLink = eWare.FindRecord("Address_Link", "adli_addressId="+recAddress("addr_PRReplicatedFromId"));
            sMsg = "This address was replicated"
            if (!recLink.eof)
                sMsg = sMsg + " from BBID " + recLink("adli_CompanyId");
            Response.Write("<table><tr ID=_trReplicated><td colspan=4 class=InfoContent>"+ sMsg +"</td></tr></table>");
            sReplicateString = "InsertRow(\"_Captaddr_address1\", \"_trReplicated\");"; 
        }

        Response.Write("<script type=\"text/javascript\" src=\"../PRAddressInclude.js\"></script>");
        Response.Write("<script type=\"text/javascript\" src=\"../PRAddressPA.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI() {");
        if (sReplicateString != "")
            Response.Write("\n        " + sReplicateString );
        if (eWare.Mode == Edit)
        {
            Response.Write("\n" + sAddressDefaultsString );
            Response.Write("\n        InsertRow(\"_Captaddr_address1\", \"_trUsage\"); " ); 
            
            Response.Write("\n        initPerfectAddressAutoRefresh(); " );
            Response.Write("\n        var oPublish = document.getElementById('addr_prpublish'); ");
            Response.Write("\n        if (oPublish) oPublish.onclick = onClickAddrPRPublish");
        }
        Response.Write("\n    }");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");

        //Special handling for ENTER key because other methods didn't permit suppression of the default form submit and was bypassing validation
        //Prevent default but call save()
        Response.Write("\n    window.addEventListener(\"keydown\", function(e){if(e.keyIdentifier=='U+000A'||e.keyIdentifier=='Enter'||e.keyCode==13){e.preventDefault();save();return false;}},true);");

        Response.Write("\n</script>");
    }
%>
<!-- #include file="CompanyFooters.asp" -->

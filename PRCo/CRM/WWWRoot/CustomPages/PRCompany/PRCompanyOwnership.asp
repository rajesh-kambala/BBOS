<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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
    var sSecurityGroups = "1,2,3,4,5,6,10,11";
    var dCurrentPercentage = 0; 

    // check the current percentage of ownership
    sSQL = "SELECT dbo.ufn_GetOwnershipPercentage(" + comp_companyid + ") As CurrentPercentage";
    recCurrentPercentage = eWare.CreateQueryObj(sSQL,"");
    recCurrentPercentage.SelectSQL();
    dCurrentPercentage = recCurrentPercentage("CurrentPercentage"); 
    
    if (dCurrentPercentage > 100) {
        var blkBanners = eWare.GetBlock('content');

        var sBanner = "<table id=\"tbl_PctWarning\" width=\"100%\" cellspacing=0 class=\"MessageContent\">" +
                      "<tr class=\"ErrorContent\"><td>" +
                            //"Warning: The total ownership of " + recCompany("comp_name") + " is " + dCurrentPercentage + "% which exceeds 100%." + 
                            "Total Ownership Percentage for all company personnel equals " +
                            "<span id=\"spnTotalPct\"> " + dCurrentPercentage + "</span>%. This value should not exceed 100%." +
                       "</td></tr>" + 
                       "</table> ";

        blkBanners.contents = sBanner;
        blkContainer.AddBlock(blkBanners);
    } 
    
        
    if (eWare.Mode == View)
    {
        Session("RelationshipReturnURL") = eWare.URL("PRCompany/PRCompanyOwnership.asp") + "&comp_CompanyID=" + comp_companyid + "&T=Company&Capt=Relationships";
    
        //
        // We are putting these grids in an IFrame in order to allow them to sort.  Accpac has
        // trouble natively sorting when multiple grids are on a single page.
        //
        var sHeight = "500";
        var sURL = eWare.URL("PRCompany/PRCompanyOwnershipOwnedByListing.asp")+"&comp_companyid=" + comp_companyid;;;
        var blkOwnedBy = eWare.GetBlock('Content');
        blkOwnedBy.contents = '<IFRAME ID="ifrmOwnedBy" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sURL +'"></IFrame>';
        blkContainer.AddBlock(blkOwnedBy);
        
        sURL = eWare.URL("PRCompany/PRCompanyOwnershipHasOwnershipListing.asp")+"&comp_companyid=" + comp_companyid;;;
        var blkHasOwnership = eWare.GetBlock('Content');
        blkHasOwnership.contents = '<IFRAME ID="ifrmHasOwnership" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sURL +'"></IFrame>';
        blkContainer.AddBlock(blkHasOwnership);
        
        sURL = eWare.URL("PRCompany/PRCompanyOwnershipAffliationListing.asp")+"&comp_companyid=" + comp_companyid;;;
        var blkAffiliations = eWare.GetBlock('Content');
        blkAffiliations .contents = '<IFRAME ID="ifrmAffiliations" FRAMEBORDER="0" MARGINHEIGHT="0" ' +
            'MARGINWIDTH="0" NORESIZE WIDTH=100% SCROLLING="NO" HEIGHT="' + sHeight + '" src="'+sURL +'"></IFrame>';
        blkContainer.AddBlock(blkAffiliations );
    
        blkByPerson = eWare.GetBlock("PROwnershipByPersonGrid");
        recByPerson = eWare.FindRecord("vPROwnershipByPerson","peli_CompanyId=" + comp_companyid);
        blkByPerson.ArgObj = recByPerson;
        //blkByPerson.Title = "Individual Ownership";
        blkContainer.AddBlock(blkByPerson);
    }
    
    blkUnattributedOwner = eWare.GetBlock("PRCompanyRelationshipUnattributedOwner");
    recUnattributedOwner = eWare.FindRecord("Company","comp_CompanyId=" + comp_companyid);
    blkUnattributedOwner.ArgObj = recUnattributedOwner;
    blkUnattributedOwner.Title = "Unattributed Ownership";
    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkUnattributedOwner);
    
    
    sListingAction = eWare.Url("PRCompany/PRCompanyRelationshipListing.asp")+ "&prcr_LeftCompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyOwnership.asp")+ "&comp_comapnyid=" + comp_companyid;
    
    Response.Write("<script type=\"text/javascript\" src=\"PRCompanyOwnershipCheck.js\"></script>");
    
    var szResizeJS = "";
    var bRedirect = false;
    if (eWare.Mode == View)
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        
        if (iTrxStatus == TRX_STATUS_EDIT) {
            if (isUserInGroup(sSecurityGroups))
	            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.submit();"));
	    }

        szResizeJS += "resizeFrame(document.getElementById('ifrmOwnedBy'));\n";
        szResizeJS += "resizeFrame(document.getElementById('ifrmHasOwnership'));\n";
        szResizeJS += "resizeFrame(document.getElementById('ifrmAffiliations'));\n";
    }
    else if (eWare.Mode == Edit)
    {
        blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        if (isUserInGroup(sSecurityGroups))
	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "#\" onClick=\"save();\""));
    }
    else if (eWare.Mode == Save)
    {
        blkContainer.Execute();
        Response.Redirect(sSummaryAction);
        bRedirect = true;
    }
    
    
    if (bRedirect == false)
    {
        eWare.AddContent(blkContainer.Execute());

        if (eWare.Mode == Edit)
            Response.Write(eWare.GetPage('Company'));
        else
            Response.Write(eWare.GetPage());
    }    

    Response.Write("\n<script type=\"text/javascript\">"); 
    Response.Write("\n    function initBBSI() {");
    
	//var sOwnwershipCheckURL = "checkCompanyOwnershipByID('" + eWare.URL("PRCompany/PRCompanyOwnershipCheck.asp") + "', '" + comp_companyid + "');";
	//Response.Write("\n   " + sOwnwershipCheckURL);
    Response.Write("\n" + szResizeJS);
    
    Response.Write("\n    }");
    Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
    Response.Write("\n</script>");
%>

<script type="text/javascript">
    function resizeFrame(f) {
        f.style.height = f.contentWindow.document.body.scrollHeight + "px";
    }
    
    function save() {

        var nTotalPct = <% =dCurrentPercentage %>;

        var nOrigPct = 0;
        var _HIDDENcomp_prunattributedownerpct = document.getElementById("_HIDDENcomp_prunattributedownerpct");
        if (_HIDDENcomp_prunattributedownerpct)
            nOrigPct = parseFloat(_HIDDENcomp_prunattributedownerpct.value);

        var nPct = 0;
        var comp_prunattributedownerpct = document.EntryForm.comp_prunattributedownerpct;
        if (comp_prunattributedownerpct )
            nPct = parseFloat(comp_prunattributedownerpct.value);

        var nNewTotal = nTotalPct - nOrigPct + nPct;
        if (!isNaN(nNewTotal) && nNewTotal > 100) {
            alert("Total Ownership Percentage for all company personnel equals " + nNewTotal + "%. This value should not exceed 100%.");
            //return false;
        }

        document.forms[0].submit();
    }
</script>

<!-- #include file="CompanyFooters.asp" -->

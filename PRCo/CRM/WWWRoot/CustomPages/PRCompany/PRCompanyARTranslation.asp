<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

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
    doPage();

function doPage()
{
    var sSecurityGroups = "2,3,4,10";

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
	
	var sAbbrEntityName = "ARTranslation";
	var sEntityPrefix = "prar";
	var sNewEntryBlockTitle = "A/R Translation";
	
	var sEntityName = "PR" + sAbbrEntityName;
    var sListingPage = "PRCompany/PRCompany" + sAbbrEntityName + "Listing.asp";
    var sSummaryPage = "PRCompany/PRCompany" + sAbbrEntityName + ".asp";
    var sEntityCompanyIdName = sEntityPrefix + "_CompanyId";
    var sEntityIdName = sEntityPrefix + "_" + sAbbrEntityName + "Id";
    var sNewEntryBlockName = "PR" + sAbbrEntityName + "NewEntry";
    
    var sInsertString = "";
    var sCompanyName = new String(Request("CompanyName"));
    var sCompanyCity = new String(Request("CompanyCity"));
    var sCompanyState = new String(Request("CompanyState"));
    
    if (sCompanyCity == null || sCompanyCity == "undefined") {
        sCompanyCity = "";
    }

    if (sCompanyState == null || sCompanyState == "undefined") {
        sCompanyState = "";
    }
    
    blkEntry=eWare.GetBlock(sNewEntryBlockName);
    blkEntry.Title=sNewEntryBlockTitle;

    var Id = getIdValue(sEntityIdName);
    // indicate that this is new
    if (Id == "-1" )
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;

        //Defect 7038
        var responderId = new String(Request.Form.Item("prar_prcocompanyid"));
        var szIndustryCheck = doIndustryCheck(recCompany("comp_PRIndustryType"), responderId);
        if(szIndustryCheck != "")
        {
            Session("sUserMsg") = szIndustryCheck;
            eWare.Mode = Edit;
        }
    }
    
    sListingAction = eWare.Url(sListingPage) + "&T=Company&Capt=Trade+Activity";

    // if the praa_ARAgingId value was passed, assume that we'll return to a single 
    // ARAGing Report File listing instead of teh ALL listing
    var praa_ARAgingid = getIdValue("praa_ARAgingId");
    if (praa_ARAgingid == -1)
        sListingAction += "&prar_CompanyId=" + comp_companyid;
    else {
        sListingAction += "&praa_ARAgingId=" + praa_ARAgingid;
    }
    sSummaryAction = eWare.Url(sSummaryPage)+ "&" + sEntityIdName + "="+ Id + "&T=Company&Capt=Trade+Activity";

    rec = eWare.FindRecord(sEntityName, sEntityIdName + "=" + Id);
    
    try
    {
        Entry = blkEntry.GetEntry(sEntityCompanyIdName);
        Entry.DefaultValue = comp_companyid;
        Entry.Hidden = true;

    } catch (e)
    {
        // the field must not exist; just eat the error
    }            
    
    // this value may be passed if this is a new translation but the cusotmer number is
    // already known.  It's a shortcut so the user doesn't have to enter it.
    var prar_customernumber = getIdValue("prar_CustomerNumber");
    if (prar_customernumber != -1)
    {
        Entry = blkEntry.GetEntry("prar_CustomerNumber");
        Entry.DefaultValue = prar_customernumber;
    }

    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (bNew)
        {
	        rec = eWare.CreateRecord(sEntityName);
			
			rec.item(sEntityCompanyIdName) = comp_companyid;
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
        }
        
        if (isUserInGroup(sSecurityGroups ))
        	blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));

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

        if (isUserInGroup(sSecurityGroups ))
        {
            sDeleteUrl = changeKey(sURL, "em", "3");
            blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
        }
    }
    blkContainer.CheckLocks = false; 

    blkContainer.AddBlock(blkEntry);
    
    
    if (sCompanyName != null && sCompanyName != "undefined") {
        Response.Write("<table><TR id=_trCustomerLocation><TD><SPAN class=VIEWBOXCAPTION>Customer Name:</SPAN><br/><span class=VIEWBOX>" + sCompanyName + "</span></TD><TD><SPAN class=VIEWBOXCAPTION>Customer Location:</SPAN><br/><span class=VIEWBOX>" + sCompanyCity + ", " + sCompanyState + "</span></TD></TR></table>");
        sInsertString = "InsertRow(\"prar_companyid\", \"_trCustomerLocation\");"; 
    }
    
    
    eWare.AddContent(blkContainer.Execute(rec)); 

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
    }
    else
        Response.Write(eWare.GetPage('Company'));


    if (eWare.Mode==Edit || eWare.Mode==View)
    {


        Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\" src=\"PRCompanyARTranslation.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\" >");
        Response.Write("\nfunction initBBSI()"); 
        Response.Write("\n{ ");
        
        if (sInsertString.length > 0) {
            Response.Write("\n    " + sInsertString);
        }
        
        if (eWare.Mode==Edit)
        {
            Response.Write("\n    document.getElementById('prar_companyid').value='" + comp_companyid + "';");
        }

        Response.Write("\n}");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");

    displayUserMsg();
}

function doIndustryCheck (compIndustry, responderId)
{
    if (eWare.Mode == Save)
    {
        // If one is “L” and the other is not “L”, display a user message "Unable to save this AR translation record due to industry type mismatch."
        {
            var recResponder = eWare.FindRecord("company","comp_companyid=" + responderId);

            if ( (compIndustry == "L" && recResponder("comp_PRIndustryType") != "L") ||
                 (compIndustry != "L" && recResponder("comp_PRIndustryType") == "L")       )
            {
                var errorMsg = "Unable to save this AR translation record due to industry type mismatch.";
                return errorMsg;
            }
        }
    }
    
    return "";
}

%>
<!-- #include file="CompanyFooters.asp" -->

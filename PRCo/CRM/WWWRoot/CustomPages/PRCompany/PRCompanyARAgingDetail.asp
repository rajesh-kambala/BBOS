<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
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
%>
<%
    var sSecurityGroups = "3,4,10";
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

	var sEntityName = "PRARAgingDetail";

    blkEntry=eWare.GetBlock("PRARAgingDetailNewEntry");
    blkEntry.Title="A/R Aging Detail";
    
    nOriginalMode = eWare.Mode;
    if (eWare.Mode == 95)
        eWare.Mode = Save;
        
    // get the AR Aging Id
    var praa_id = getIdValue("praa_ARAgingId");
    
    // find the ar aging record
    // get the AR Aging Header record
    recHeader =  eWare.FindRecord("PRARAging", "praa_ARAgingId=" + praa_id);
    var isLumber = ((recCompany != null) ? (recCompany("comp_PRIndustryType") == "L") : false );

    var hiddenFields;
    if (isLumber) {
        // Hide produce fields
        hiddenFields = [ "praad_Amount0to29", "praad_Amount30to44", "praad_Amount45to60", "praad_Amount61Plus" ];
    } else {
        // Hide lumber fields
        hiddenFields = [ "praad_Amount1to30", "praad_Amount31to60", "praad_Amount61to90", "praad_Amount91Plus", "praad_AmountCurrent" ];
    }
    for (var i in hiddenFields) {
        blkEntry.GetBlock(hiddenFields[i]).Hidden = true;
    }

    var praad_id = getIdValue("praad_ARAgingDetailId");

    // indicate that this is new
    if (praad_id == "-1" )
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }

    var bManuallyEntered = true;
    
    rec = eWare.FindRecord(sEntityName, "praad_ARAgingDetailId=" + praad_id);
    if (!rec.eof && praa_id == -1) {
        praa_id = rec("praad_ARAgingId");
        recHeader =  eWare.FindRecord("PRARAging", "praa_ARAgingId=" + praa_id);
        if (recHeader("praa_ManualEntry") != "Y") {
            bManuallyEntered = false;
        }
    }

    sListingAction = eWare.Url("PRCompany/PRCompanyARAgingDetailListing.asp") + "&praa_ARAgingId=" + praa_id + "&T=Company&Capt=Trade+Activity";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyARAgingDetail.asp") + "&T=Company&Capt=Trade+Activity";

    // based upon the mode determine the buttons and actions
    if (eWare.Mode == Edit || eWare.Mode == Save )
    {
        if (bNew)
        {
	        rec = eWare.CreateRecord(sEntityName);
			
			rec.item("praad_ARAgingId") = praa_id;
            
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
            if (isUserInGroup(sSecurityGroups ))
            {
    	        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
                sSaveAndAddUrl = changeKey(sURL, "em", "95");
                blkContainer.AddButton(eWare.Button("Save & Add Another", "save.gif", 
                    "javascript:document.EntryForm.action='"+sSaveAndAddUrl+"';document.EntryForm.submit();"));
            }
        }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction+ "&praad_ARAgingDetailId=" + praad_id ));
            if (isUserInGroup(sSecurityGroups ))
        	    blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
        
    }
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM " + sEntityName + " WHERE praad_ARAgingDetailId ="+ praad_id;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else // view mode
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

        if (isUserInGroup(sSecurityGroups ))
        {
            sDeleteUrl = "javascript:if (confirm('Are you sure you want to delete this record?')) { location.href='" + changeKey(sURL, "em", "3") + "';}";
			blkContainer.AddButton(eWare.Button("Delete", "delete.gif", sDeleteUrl));

            blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "&praad_ARAgingDetailId=" + praad_id + "';document.EntryForm.submit();"));
        }
    }

    blkContainer.CheckLocks = false; 
    blkContainer.AddBlock(blkEntry);

    if (eWare.Mode == Edit) {
        // Set up the Pay Rating dropdown
        sCaption = eWare.GetTrans("ColNames","prra_PayRatingId");
        sSQL = "SELECT prpy_PayRatingId, prpy_Name " +
                 "FROM PRPayRating WITH (NOLOCK) WHERE prpy_TradeReportDescription is not NULL AND prpy_Deleted IS NULL " +
             "ORDER BY prpy_Order";
        recPay = eWare.CreateQueryObj(sSQL,"");
        recPay.SelectSQL();
        sPayRating = "<table><tr id=\"tr_payrating\"><td valign=\"top\"><span class=\"VIEWBOXCAPTION\">"+sCaption+":</span><br/><span>" +
                "<input type=\"HIDDEN\" name=\"_HIDDENprra_payratingid\">" + 
                "<select class=\"EDIT\" size=\"1\" name=\"prra_payratingid\">" + 
                "<option value=\"\" selected=\"true\">--None--</option> ";
        while (!recPay.eof)
        {
            sPayRating += "<option value=\""+ recPay("prpy_PayRatingId") + "\" >" + recPay("prpy_Name") + "</option> ";
            recPay.NextRecord();
        }
        sPayRating += "</select></span></td></tr></table>";
        blkPay = eWare.GetBlock("content");
        blkPay.Contents = sPayRating;

        // add our custom block for pay description
        blkContainer.AddBlock(blkPay);


        if (!bManuallyEntered) {
            blkEntry.GetBlock("praad_SubjectCompanyID").ReadOnly = true;
        }
    }
    

    
    eWare.AddContent(blkContainer.Execute(rec)); 

    if (eWare.Mode == Save ) 
    {
	    //DumpFormValues();
	    // check if a pay description was also submitted
        sPayRatingId = String(Request.Form.Item("prra_payratingid"));
	    DEBUG("<br>sPayRaingId: " + sPayRatingId);
	    if (!isEmpty(sPayRatingId))
	    {
	        
	        // Need to create aTrade Report with just the pay rating filled in 
	        recPayRating = eWare.CreateRecord("PRTradeReport");
	        recPayRating.prtr_ResponderId = recHeader("praa_CompanyId");
	        recPayRating.prtr_SubjectId = rec("praad_ManualCompanyId");
	        dtDate = new Date();
	        sDate = (dtDate.getMonth() + 1) + "/" + dtDate.getDate() + "/" + dtDate.getYear();
	        recPayRating.prtr_Date = getDBDate(sDate);
	        recPayRating.prtr_PayRatingId = sPayRatingId;
	        recPayRating.prtr_ResponseSource = 'A';
	    }
	    
        qryUpdateTotals = eWare.CreateQueryObj("EXEC usp_UpdateARAgingTotals " + praa_id);
        qryUpdateTotals.ExecSql();
	    
	    // redirect to the appropriate page
	    // if this is the "Add And Another" (mode=95) redirect to a new detail page
	    if (bNew)
	        if (nOriginalMode == 95)
                Response.Redirect(sSummaryAction+ "&praa_ARAgingId=" + praa_id);
            else
	            Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction + "&praad_ARAgingDetailId=" + praad_id );
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Companyh'));

        Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
        //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI()"); 
        Response.Write("\n    {");
        Response.Write("\n        AppendRow(\"_Captpraad_subjectcompanyid\", \"tr_payrating\");");
        Response.Write("\n    }");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");

    }
    else
        Response.Write(eWare.GetPage());

%>
<!-- #include file="CompanyFooters.asp" -->

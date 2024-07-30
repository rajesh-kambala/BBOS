<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2013-2014

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written  permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 

***********************************************************************
***********************************************************************/
%>

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->

<%

    var errorMsg = "";
    var warningMsg = "";
	doPage();

function doPage()
{
	var action = getIdValue("Action");

	if (eWare.Mode < Edit)
		eWare.Mode = Edit;

	if (eWare.Mode == Save) {

		if (action == "C2H") {
			recCompany.comp_PRType = "H";
			recCompany.comp_PRHQID = recCompany.comp_CompanyID;
			recCompany.SaveChanges();

			var sRedirect = eWare.URL("PRCompany/PRCompanySummary.asp");
			Response.Redirect(sRedirect);
			return;                        
		}

		if (action == "C2B") {

            if (getFormValue("prpbarc_companyid") == "") {
                eWare.Mode = Edit;

            } else {

                var targetCompanyID = getFormValue("prpbarc_companyid");
                recTargetCompany = eWare.FindRecord("Company", "comp_CompanyId=" + targetCompanyID);


                //Response.Write("<br/>targetCompanyID: " + targetCompanyID);
                //Response.Write("<br/>recTargetCompany.comp_PRType: " + recTargetCompany.comp_PRType);
                //Response.Write("<br/>recTargetCompany.comp_PRIndustryType: " + recTargetCompany.comp_PRIndustryType);

                if (recTargetCompany.comp_PRType != "H") {
                    errorMsg += " - The selected target company must be a headquarters.";
                }

                //if (recTargetCompany.comp_PRIndustryType != "L") {
                //    errorMsg += " - The selected target company must be a lumber company.";
                //}

                if (errorMsg == "") {
			        recCompany.comp_PRType = "B";
			        recCompany.comp_PRHQID = getFormValue("prpbarc_companyid");
			        recCompany.SaveChanges();

			        var sRedirect = eWare.URL("PRCompany/PRCompanySummary.asp");
			        Response.Redirect(sRedirect);
			        return;  
                }

                eWare.Mode = Edit;
            }
		}
	}

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

	var blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;
	
	blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", eWare.URL("PRCompany/PRCompanySummary.asp")));
	
    var hasBranches = false;
    var blkEntry = null;
    var sInnerMsg = "";

	if (action == "C2H") {
        sInnerMsg = "Are you sure you want to convert this branch to a headquarters?";
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
    }

	if (action == "C2B") {

        sInnerMsg = "Are you sure you want to convert this headquarters to a branch?";

        // We're going to resuse this block
        // since we only need a company ID.
        blkEntry = eWare.GetBlock("PRPublicationArticleCompanyEntry");
        blkEntry.Title = "Select Headquarters";
        blkEntry.GetEntry("prpbarc_PublicationArticleID").Hidden = true;
        blkEntry.GetEntry("prpbarc_CompanyID").Caption = "Headquarters";


        var sSQL = "SELECT COUNT(1) as Cnt FROM PRARAging WITH (NOLOCK) WHERE praa_CompanyID=" + recCompany.comp_CompanyID;
        var qry = eWare.CreateQueryObj(sSQL);
        qry.SelectSQL();
        var cnt = qry("Cnt");
        if (cnt > 0) {
           warningMsg = "WARNING: This record has aging data assigned.";
        }    

        var sSQL = "SELECT COUNT(1) as Cnt FROM Company WITH (NOLOCK) WHERE comp_PRType='B' AND comp_PRHQID=" + recCompany.comp_CompanyID;
        var qry = eWare.CreateQueryObj(sSQL);
        qry.SelectSQL();
        var cnt = qry("Cnt");
        if (cnt > 0) {
            hasBranches = true;
            warningMsg = "WARNING: This headquarters has branches.";
        }    


        if (!hasBranches) {
            blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
        }

    }


	var sBannerMsg = "\n\n<table width=\"100%\"><tr><td width=\"100%\" align=\"center\">\n";
	sBannerMsg += "<table class=\"MessageContent2\" align=\"center>\"\n";
	sBannerMsg += "<tr><td>" + sInnerMsg + "</td></tr>\n";
	sBannerMsg += "</table>\n";
	sBannerMsg += "</td></tr></table>\n\n";

    // Needed to prevent <enter> from submitting the form.
    sBannerMsg += "<div style=display:none;><input type=text id=dummy /></div>";


    var blkBanners = eWare.GetBlock('content');
    blkBanners.contents = sBannerMsg;
	blkContainer.AddBlock(blkBanners);

    if (blkEntry != null) {
        blkContainer.AddBlock(blkEntry);
    }

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("Company"));
}
%>
<script type="text/javascript">
    function save() {

        var sAlertString = "";
        var prpbarc_companyid = document.getElementById("prpbarc_companyid").value;
        if (prpbarc_companyid == "") {
            sAlertString = " - Please select a new headquarters company.";
        }

        if (sAlertString != "") {
            alert("To save this record, the following changes are required:\n\n" + sAlertString);
            return;
        }

        document.EntryForm.submit();
    }

<% if (errorMsg != "") { %>
    alert("To save this record, the following changes are required:\n\n<% =errorMsg %>");
<% } %>

<% if (warningMsg != "") { %>
    alert("<% =warningMsg %>");
<% } %>



</script>
<!-- #include file ="../PRCompany/CompanyFooters.asp" -->
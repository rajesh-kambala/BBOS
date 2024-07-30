<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->

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

    var sSecurityGroups = "1,2,10";

    var blkCW = eWare.GetBlock("PRCreditWorthCap");
    blkCW.Title = "Credit Worth Cap";
    blkCW.Mode = View;
    blkCW.ArgObj = recCompany;

    // Build our CreditWorthCap field
    var sInsertString = "<table><tr><td id=\"tdCreditWorthCap\" valign=\"top\">"
    sInsertString = sInsertString + "<span id=\"_Captcomp_prcreditworthcap\" class=\"VIEWBOXCAPTION\">Credit Worth Cap:</span><br/>"

    if ((recCompany.comp_PRCreditWorthCap == null) || (recCompany.comp_PRCreditWorthCap == 0)) {
        szCreditWorth = "-None Selected-";
    } else {
        recCRM = eWare.FindRecord("PRCreditWorthRating","prcw_CreditWorthRatingId=" + recCompany.comp_PRCreditWorthCap);
        szCreditWorth = recCRM.prcw_Name;
    }

    sInsertString = sInsertString + "<span id=\"_Datacomp_prcreditworthcapreason\" class=\"VIEWBOX\">" + szCreditWorth + "</span>";
    sInsertString = sInsertString + "</td></tr></table>";
    Response.Write(sInsertString);

    sInsertString = "AppendCell(\"_Captcomp_prcreditworthcapreason\", \"tdCreditWorthCap\", true);"; 


    var recRating = eWare.FindRecord('PRRating','prra_CompanyId=' + comp_companyid);
    grdRating = eWare.GetBlock("PRRatingGrid");
    grdRating.prevURL = sURL;
    grdRating.ArgObj = recRating;

    //container = eWare.GetBlock('container');
    blkContainer.AddBlock(blkCW);
    blkContainer.AddBlock(grdRating);
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", eWare.URL("PRCompany/PRCompanyRatingListing.asp") + "&T=Company&Capt=Rating"));

    if (recCompany.comp_PRIndustryType != "S") {
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            if (isUserInGroup("1,2,10,4,5,6,8"))
            {
                blkContainer.AddButton(eWare.Button("New Rating", "new.gif", eWare.URL("PRRating/PRRating.asp") + "&T=Company&Capt=Rating"));
            }
        }
    }

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));

    Response.Write("\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("\n<script type=\"text/javascript\">");
    Response.Write("\n    function initBBSI()"); 
    Response.Write("\n    { ");
    
    if (sInsertString.length > 0) {
        Response.Write("\n    " + sInsertString);
    }

    Response.Write("\n    }");
    Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
    Response.Write("\n</script>");

%>
<!-- #include file="CompanyFooters.asp" -->

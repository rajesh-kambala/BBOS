<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2014

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Blue Book Services, Inc. is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Blue Book Services, Inc.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/

    var message = null;
    doPage();

function doPage() {

	blkContainer = eWare.GetBlock('container');
	blkContainer.DisplayButton(Button_Default) = false;

    var sSecurityGroups = "1,2,3,4,5,6,10";

    blkMain=eWare.GetBlock("PRBusinessReportPurchase");
    blkMain.Title="Business Report Purchase";

    // Determine if this is new or edit
    var prbrp_BusinessReportPurchaseID = getIdValue("prbrp_BusinessReportPurchaseID");
    sListingAction = eWare.Url("PRGeneral/BusinessReportPurchaseListing.asp");
    sSummaryAction = eWare.Url("PRGeneral/BusinessReportPurchase.asp") + "&prbrp_BusinessReportPurchaseID="+ prbrp_BusinessReportPurchaseID;

    recBRPurchase = eWare.FindRecord("vPRBusinessReportPurchase", "prbrp_BusinessReportPurchaseID=" + prbrp_BusinessReportPurchaseID);

    
    if (getIdValue("BRSent") == "Y") {
        message = "Business Report sucessfully sent.";    
    }


    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
    var btnBusinessReport = eWare.Button("Send Business Report","componentpreview.gif", eWare.Url("PRGeneral/BusinessReportPurchaseSend.aspx") + "&prbrp_BusinessReportPurchaseID="+ prbrp_BusinessReportPurchaseID);
    blkContainer.AddButton(btnBusinessReport);



    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recBRPurchase));
    Response.Write(eWare.GetPage("PRBusinessReportPurchase"));
}
%>

       <script type="text/javascript">
            document.body.onload = function() {
<% if (message != null) { %>                
                alert("<% =message %>");
<% } %>                
            }
        </script>
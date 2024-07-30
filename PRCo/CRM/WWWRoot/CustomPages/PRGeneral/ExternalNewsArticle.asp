<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Blue Book Services, Inc. 2015

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

doPage();
    

function doPage()
{

    var pren_ExternalNewsID = getIdValue("pren_ExternalNewsID");
    var sListingAction = eWare.Url("PRGeneral/ExternalNewsListing.asp");

    if (eWare.Mode == PreDelete) {
        if (pren_ExternalNewsID > 0) {
            sql = "DELETE FROM PRExternalNews WHERE pren_ExternalNewsID = " + pren_ExternalNewsID;
            qry = eWare.CreateQueryObj(sql);
            qry.ExecSql();
        }
        Response.Redirect(sListingAction);
        return;
    }


    var recExternalNews = eWare.FindRecord("PRExternalNews", "pren_ExternalNewsID=" + pren_ExternalNewsID);

    var blkMain=eWare.GetBlock("ExternalNewsArticle");
    blkMain.Title="External News Article";

    var blkContainer = eWare.GetBlock("container");
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));

    var sDeleteAction = changeKey(eWare.URL("PRGeneral/ExternalNewsArticle.asp"), "em", "3");
    sDeleteAction = changeKey(sDeleteAction, "pren_ExternalNewsID", pren_ExternalNewsID);
    blkContainer.AddButton(eWare.Button("Delete","delete.gif", "javascript:if (confirm('Are you sure you want to delete this article?')) { location.href='" + sDeleteAction + "'; }"));


    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute(recExternalNews));

    Response.Write(eWare.GetPage());

    if (eWare.Mode == View) {
%>

<script type="text/javascript">

    var eURL = document.getElementById("_Datapren_url");
    var url = eURL.innerText;
    eURL.innerHTML = "<a href='" + url + "' target=_blank>" + url + "</a>"

</script>


<%
    }
}
%>
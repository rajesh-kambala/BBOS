<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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

<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRGeneral/DocumentDropInclude.asp" -->

<%
function doPage()
{
    var key58Redirect = handleKey58();
    if (key58Redirect != null) {
        Response.Redirect(Request.ServerVariables("URL")+ "?" + key58Redirect);
    }

	//bDebug = true;
	DEBUG(sURL);
	DEBUG("Mode:" + eWare.Mode);
	//DumpFormValues();
	//if (eWare.Mode < 2)
	//    eWare.Mode = 2;
	DEBUG("Mode:" + eWare.Mode);
	
	if (eWare.Mode == View) {
	    eWare.Mode = Edit;
	}	
	
    sKey0 = Request.QueryString("Key0");
    
	var prss_ssfileid = getIdValue("prss_SSFileId");
	if (prss_ssfileid == "-1" && sKey0 == "58")
	    prss_ssfileid = getIdValue("Key58");
	
    prss_claimantcompanyid = "";
    recFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);
    if (!recFile.eof)
        prss_claimantcompanyid = recFile("prss_ClaimantCompanyId");
    
    var blkFilter  = eWare.GetBlock("CommunicationFilterBox");
    blkFilter.NewLine = false;
	blkFilter.DisplayButton(Button_Default) = false;
    
   
    var sListingAction = "";
    sListingAction = eWare.URL(F);

    var blkContainer = eWare.GetBlock("Container");
	blkContainer.DisplayButton(Button_Default) = false;

	var lstMain = eWare.GetBlock("CommunicationList");
	lstMain.AddGridCol('comp_Name', 5, true);
	lstMain.prevURL = sURL;
    lstMain.ArgObj = blkFilter;
	lstMain.DisplayButton(Button_Default) = false;

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"../PRGeneral/PRInteraction.js\"></script>");
    Response.Write("<table style=\"display:none;\"><tr id=\"_tr_ApplyFilter\"><td colspan=\"2\">" + 
                    eWare.Button("Apply Filter","search.gif", "javascript:document.EntryForm.submit();") +
                   "</td></tr></table>");
    blkFilter.AddButton("</TD></TR><TR><TD>");
    
    var sNewTaskLink = eWare.URL("PRGeneral/PRInteraction.asp");
    // cannot have key6 on the url or an existing interaction will load
    sNewTaskLink = removeKey(sNewTaskLink, "Key6");
    sNewTaskLink += "&E=PRSSFile&prss_SSFileId=" + prss_ssfileid;
    if (prss_claimantcompanyid != "")
    {
        sNewTaskLink = removeKey(sNewTaskLink, "Key1");
        sNewTaskLink += "&Key1="+prss_claimantcompanyid;
    }
    
    
    blkFilter.AddButton("</TD></TR><TR><TD>" + eWare.Button("New Interaction","newtask.gif", sNewTaskLink));
    blkFilter.AddButton(getDocDropButton(prss_ssfileid));
    blkFilter.ButtonLocation = Bottom;

    // As of CRM 6.2, the native CommunciationFilter box isn't rendered by the normal
    // container execute method below.  So to get around this, we manually execute the
    // block to generate the HTML, and include that HTML in the page by adding it to
    // a temporary block.
    var blkTemp = eWare.GetBlock('content');
    blkTemp.Contents = blkFilter.Execute();


    // DON'T remove this seemingly needless spacer block; it is reqd for proper display
    //blkSpacer = eWare.GetBlock("content");
	//blkContainer.AddBlock(blkSpacer)
	blkContainer.AddBlock(blkTemp);
	blkContainer.AddBlock(lstMain);

    eWare.AddContent(blkContainer.Execute("comm_PRFileId=" + prss_ssfileid));
	Response.Write(eWare.GetPage("PRSSFile"));
    Response.Write("<link rel=\"stylesheet\" href=\"/" + sInstallName + "/prco_compat.css\">");  
}
doPage();
%>
    <script type="text/javascript" >
        function initBBSI() {

            AppendRow("_HIDDENcomm_nonsystemgenerated", "_tr_ApplyFilter");

            // This is a cheat to allow the filter to be to the right of the listing.
            // accpac will function properly if the listing is AddBlock'ed before the 
            // filter. this helps correct the display.
            var capt = document.all("_Captcomm_action");
            var parent = capt.parentElement;
            // find the td 3 levels up
            var level = 0;
            while ((parent != null) && ((parent.tagName != "TD") || level != 2))
            {
                if (parent.tagName == "TD")
                    level++;
                parent = parent.parentElement;
            }
            if (parent != null)
                parent.rowSpan = 2;

            InitializeListing();
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
    </script>
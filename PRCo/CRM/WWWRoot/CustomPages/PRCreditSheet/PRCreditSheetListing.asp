<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2022

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

<%
    //bDebug=true;
    DEBUG(sURL);
	DEBUG("Mode:" + eWare.Mode);

    // This fixes an issue with changing the team name 
    // for the Team CRM Credit Sheet Items context
    var metaString = "%3Cmeta%20name=";
    var sURLNew = sURL.replace(metaString, "");
    if (sURLNew != sURL)
        Response.Redirect(sURLNew);

    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

    var blkProcessingFlags = eWare.GetBlock('content');
    blkProcessingFlags.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkContainer.AddBlock(blkProcessingFlags);    



    if (isUserInGroup("4,5,10"))
    {
        blkContainer.AddButton(eWare.Button("Credit Sheet Publish", "continue.gif", eWare.URL("PRCreditSheet/PRCreditSheetPublish.asp")));
    }

%>
<!-- #include file ="PRCreditSheetFilter.asp" --> 
<%
    var keyValue = "-1";    
	var keyField = "";
	var keyEntity = "";
	var keyFilter = "";
	
    var key0 = Request.QueryString("Key0");
    if ((key0 == 1) || (key0 == 58)) {
%>
        <!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->
        <!-- #include file ="../PRCompany/CompanyTrxInclude.asp" -->
<%
		keyEntity = "Company";
		keyValue = comp_companyid;
		keyField = "prcs_CompanyId";
		keyFilter =  keyField + "=" + keyValue;
        if (isUserInGroup("1,2,4,5,6,8,10"))
        {
			if (iTrxStatus == TRX_STATUS_EDIT)
			{
                // Add the New CS button
    	        var sNewCSUrl = eWare.Url("PRCreditSheet/PRCreditSheet.asp") + "&T=Company&Capt=Transactions";
		        sNewCSUrl += "&prevCustomURL=" + sURL; 
		        blkContainer.AddButton(eWare.Button("New C/S Item", "new.gif", sNewCSUrl));
            }
        }

    } else if (key0 == 4){
		keyEntity = "User";
		keyValue = Request.QueryString("Key4");
		keyField = "prcs_authorid";
		keyFilter =  " (prcs_AuthorId=" + keyValue + 
		             " OR prci_ListingSpecialistId=" + keyValue + 
		             " OR prcs_ApproverId=" + keyValue + ") "  ;
    } else if (key0 == 5){
		keyEntity = "Channel";
		keyValue = Request.QueryString("Key5");
		keyField = "prcs_ChannelId";
		keyFilter =  keyField + "=" +  keyValue ;
    }

	grid=eWare.GetBlock("PRCRMCSListing");
    grid.ArgObj = blkFilter;

    blkContainer.AddBlock(blkStatusDisplay);    
    blkContainer.AddBlock(blkFilter);    
    blkContainer.AddBlock(grid);
    
    DEBUG("<br>keyValue: " + keyValue);
    if (!isEmpty(keyValue) && keyValue != "-1")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") + keyFilter;
    DEBUG("<BR>Filter: " + sGridFilterWhereClause);
    eWare.AddContent(blkContainer.Execute(sGridFilterWhereClause)); 
    Response.Write(eWare.GetPage(keyEntity));
%>
   <script type="text/javascript" >
       function initBBSI() 
        {
            <%= sFormLoadCommands %>
        }
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
    </script>
<%    
    if (key0 == 1 ) {
%>
	<!-- #include file ="../RedirectTopContent.asp" -->
<%
	}	
%>
<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
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


	//DumpFormValues();

	// By default the eWare mode is View.
	// We want it to be Edit so that when the
	// user click's Find, it is incremented to 
	// Find.
	if (eWare.Mode == View) {
	    eWare.Mode = Edit;
	}
	
    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
	
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    blkSearchBox = eWare.GetBlock("PRWebUserSearchBox");
	blkSearchBox.Title = "Find";

    blkContainer.AddButton(eWare.Button("Search", "search.gif", "javascript:document.EntryForm.submit();" ));
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

	blkContainer.AddBlock(blkSearchBox);

    sDB_IsMember = "";
    sDB_IsTrial = "";
    sDB_IsDisabled = "";
    
    if (eWare.Mode != Clear) {
        sForm_IsMember = String(Request.Form.Item("_IsMember"));
        if (sForm_IsMember != 'undefined')
            sDB_IsMember = sForm_IsMember;
        sForm_IsTrial = String(Request.Form.Item("_IsTrial"));
        if (sForm_IsTrial != 'undefined')
            sDB_IsTrial = sForm_IsTrial;
        sForm_IsDisabled = String(Request.Form.Item("_IsDisabled"));
        if (sForm_IsDisabled != 'undefined')
            sDB_IsDisabled = sForm_IsDisabled;
    }            
        
    szSelectTags = "\n<TABLE ID='tblIsMemberOptions' style='{display:none}' CELLPADDING=0 BORDER=0 align=left><TR>";
    szSelectTags += "\n <TD ID=td_IsMemberSelect><SPAN CLASS=VIEWBOXCAPTION ALIGN=LEFT >Is Member:</SPAN><BR>";
    szSelectTags += "\n <SELECT class=EDIT name=_IsMember>";
    sSelected = "";
    if (sDB_IsMember == "Y") {
        sSelected=  " SELECTED ";
    } 
    szSelectTags += "\n      <OPTION value=\"Y\" " + sSelected + ">Yes</OPTION>";
    sSelected = "";
    if (sDB_IsMember == "N") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"N\" " + sSelected + ">No</OPTION>";
    sSelected = "";
    if (sDB_IsMember == "") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"\" " + sSelected + ">--All--</OPTION>";
    szSelectTags += "\n</SELECT></TD>";

    // Process IsTrial 
    szSelectTags += "\n <TD ID=td_IsTrialSelect><SPAN CLASS=VIEWBOXCAPTION ALIGN=LEFT >Is Trial:</SPAN><BR>";
    szSelectTags += "\n <SELECT class=EDIT name=_IsTrial>";
    sSelected = "";
    if (sDB_IsTrial == "Y") {
        sSelected=  " SELECTED ";
    } 
    szSelectTags += "\n      <OPTION value=\"Y\" " + sSelected + ">Yes</OPTION>";
    sSelected = "";
    if (sDB_IsTrial == "N") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"N\" " + sSelected + ">No</OPTION>";
    sSelected = "";
    if (sDB_IsTrial == "") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"\" " + sSelected + ">--All--</OPTION>";
    szSelectTags += "\n</SELECT></TD>";


    // Process IsDisabled
    szSelectTags += "\n <TD ID=td_IsDisabledSelect><SPAN CLASS=VIEWBOXCAPTION ALIGN=LEFT >Is Disabled:</SPAN><BR>";
    szSelectTags += "\n <SELECT class=EDIT name=_IsDisabled>";
    sSelected = "";
    if (sDB_IsDisabled == "Y") {
        sSelected=  " SELECTED ";
    } 
    szSelectTags += "\n      <OPTION value=\"Y\" " + sSelected + ">Yes</OPTION>";
    sSelected = "";
    if (sDB_IsDisabled == "N") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"N\" " + sSelected + ">No</OPTION>";
    sSelected = "";
    if (sDB_IsDisabled == "") {
        sSelected=  " SELECTED ";
    }
    szSelectTags += "\n      <OPTION value=\"\" " + sSelected + ">--All--</OPTION>";
    szSelectTags += "\n</SELECT></TD>";


    szSelectTags += "\n</TR></TABLE>";
    Response.Write(szSelectTags);
        




    blkSearchResults = eWare.GetBlock("PRWebUserGrid");
    blkSearchResults.ArgObj = blkSearchBox;
    blkContainer.AddBlock(blkSearchResults);
	
	sWhere = "";
	if (sDB_IsMember != "")
	    sWhere = "IsMember='" + sDB_IsMember + "' ";

	if (sDB_IsTrial != "") {
	    if (sWhere != "")
	        sWhere += " AND ";
	    sWhere += "IsTrial='" + sDB_IsTrial + "' ";
    }
    
	if (sDB_IsDisabled != "") {
	    if (sWhere != "")
	        sWhere += " AND ";
	        
        if (sDB_IsDisabled == "Y") {	        
    	    sWhere += "prwu_Disabled='" + sDB_IsDisabled + "' ";
    	} else {
    	    sWhere += "prwu_Disabled IS NULL ";
    	}

	}
	eWare.AddContent(blkContainer.Execute(sWhere));
	Response.Write(eWare.GetPage('Find'));
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
    %>


        <script type="text/javascript">
            function initBBSI()
            {
                AppendCell("_Captprwu_companyname", "td_IsDisabledSelect");
                AppendCell("_Captprwu_companyname", "td_IsTrialSelect");
                AppendCell("_Captprwu_companyname", "td_IsMemberSelect");
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
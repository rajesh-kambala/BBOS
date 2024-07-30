<!-- #include file ="../accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2018

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

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%

    doPage();

function doPage()
{
    //bDebug = true;
    DEBUG("Mode: " + eWare.Mode); 
    DEBUG("URL: " + sURL); 
    var sOriginalMode = eWare.Mode;
    
    var sRedirectUrl = "";
    var key1 = Request.QueryString("Key1");
    var key2 = Request.QueryString("Key2");
    if (!isEmpty(key1) || !isEmpty(key2)){
        // removing and resetting these values will hopefully prevent accpac 
        // navigation issues when jumping to the company and coming back to MY CRM
        sRedirectUrl = removeKey(sURL, "Key1");
        sRedirectUrl = removeKey(sRedirectUrl, "Key2");
        Response.Redirect(sRedirectUrl);
        return;
    }

    //Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    var blkContainer = eWare.GetBlock("Container");
    blkContainer.ButtonTitle="Search";
    blkContainer.ButtonImage="Search.gif";
    blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));
   
    var blkScript = eWare.GetBlock('content');
    blkScript.contents = "\n<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>";
    blkContainer.AddBlock(blkScript);
   
    var keyValue = "-1";
	var keyField = "";
	var keyEntity = "";
	
    var key0 = Request.QueryString("Key0");

%>
<!-- #include file ="PRExceptionQueueFilter.asp" --> 

<%
    DEBUG("Key Entity: " + keyEntity); 
    if (key0 == 4){
		keyEntity = "User";
		keyValue = Request.QueryString("Key4");
		keyField = "preq_assigneduserid";
    } else if (key0 == 5){
		keyEntity = "Channel";
		keyValue = Request.QueryString("Key5");
		keyField = "preq_ChannelId";
    }

	entry = blkFilter.GetEntry(keyField);
	if (!isEmpty(entry))
		entry.Hidden = true;

    setBlockCaptionAlignment(blkFilter, 6);
    blkContainer.AddBlock(blkStatusDisplay);
    blkContainer.AddBlock(blkFilter);    

    var sWhere = "";
 
    var sSQL = 
        "SELECT comp_CompanyId, company.comp_Name, preq_Date, preq_AssignedUserId, RTRIM(user_logon) As AnalystName, " +
               "comp_PRType, " +
               "preq_status = case when preq_status = 'C' then 'Closed' else 'Open' end, " +
               "prra_RatingLine = ISNULL(dbo.ufn_getCurrentRatingLine(comp_companyid), ''), " +
               "preq_BluebookScore = ISNULL(dbo.ufn_getCurrentBBScore(comp_companyid), ''), " +
               "TotalExcpCount, " +
               "BBS_Count, BBS_Days15Count, BBS_Days30Count, BBS_Days45Count, BBS_Days60Count, BBS_Days90Count, " +
	           "AR_Count, AR_Days15Count, AR_Days30Count, AR_Days45Count, AR_Days60Count, AR_Days90Count, " +
	           "TES_Count, TES_Days15Count, TES_Days30Count, TES_Days45Count, TES_Days60Count, TES_Days90Count " +
          "FROM PRExceptionQueue preq WITH (NOLOCK) " +
               "INNER JOIN Company WITH (NOLOCK) ON preq_CompanyId = comp_CompanyId " +
               "LEFT OUTER JOIN dbo.ufn_getCompanyExceptionCounts(" + sDBExceptionType + ", " + sDBStatus + ") tblExcCounts ON tblExcCounts.CompanyID =  preq_CompanyId " + 
               "LEFT OUTER JOIN Users WITH (NOLOCK) ON preq_AssignedUserId = user_UserId " +
               "INNER JOIN (SELECT preq_ExceptionQueueId, Rank() Over (PARTITION BY preq_CompanyId order by preq_ExceptionQueueId DESC) as Rank " +
                             "FROM PRExceptionQueue WITH (NOLOCK) " +
                                  "INNER JOIN Company WITH (NOLOCK) ON preq_CompanyId = comp_CompanyId " +
                             sGridFilterInnerWhereClause +") preq2 ON Rank = 1 and preq.preq_ExceptionQueueId = preq2.preq_ExceptionQueueId " ;

    if (sGridFilterWhereClause != "") {
        sWhere += " WHERE " + sGridFilterWhereClause;
    } else {
        sWhere += " WHERE 1=0";
    }
    
    sSQL += sWhere + GetSortClause("gridExcp", "TotalExcpCount", "DESC");   
    
//Response.Write("<p>" +  GetSortClause("gridExcp", "TotalExcpCount", "DESC") + "</p>");   
//Response.Write("<p>" +  sSQL + "</p>");   
    
    recExceptions = eWare.CreateQueryObj(sSQL);
    recExceptions.SelectSQL();
            
    var grid = eWare.GetBlock("content");
    grid.Contents = buildExceptionsGrid(recExceptions, "gridExcp", "Companies with Exceptions", sDBExceptionType);
    blkContainer.AddBlock(grid);

    /*
     * This is a special block just used to get our 
     * hidden sort fields on the form
     */
    blkSorting = eWare.GetBlock("content");
    blkSorting.Contents = "<input type=hidden name=\"_hiddenSortColumn\"><input type=\"hidden\" name=\"_hiddenSortGrid\">"
    blkContainer.AddBlock(blkSorting);     

    eWare.AddContent(blkContainer.Execute()); 
    Response.Write(eWare.GetPage(keyEntity));
    DEBUG("Mode after execute:" + eWare.Mode);

    %>
        <script type="text/javascript">
            function initBBSI() 
            {
                <%= sFormLoadCommands %>
                // remove this option in lieu of the existing Date Range: option which users really like
                RemoveDropdownItemByName('DateTimeModespreq_date', 'Relative');
                removeBRInTD('preq_date');
                forceTableCellsToLeftAlign("preq_status", "30%");
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
        </script>
    <%
}


function buildExceptionsGrid(recExceptions,
                             sGridName,
                             sGridTitle,
                             sTypeCode) {  

    var sWorkContent = "";
    var Content01 = "";
    var Content02 = "";
    var Content03 = "";
    var Content04 = "";
    var Content05 = "";
    var Content06 = "";
    var Content07 = "";
    var Content08 = "";
    var Content09 = "";
    var Content10 = "";
    var Content11 = "";
    var Content12 = "";
    var Content13 = "";
    var Content14 = "";
    var Content15 = "";
    var Content16 = "";
    var Content17 = "";
    var Content18 = "";
    var Content19 = "";
    var Content20 = "";    
    
  
    var sContent;
    sContent = createAccpacBlockHeader(sGridName, recExceptions.RecordCount + " " + sGridTitle);

    sContent += "\n\n<table class=\"CONTENT\" border=\"1px\" cellspacing=\"0\" cellpadding=\"1\" bordercolordark=\"#ffffff\" bordercolorlight=\"#ffffff\" width=\"100%\">" +
                "\n<thead>" +
                "\n<tr>\n" +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\" >" + getColumnHeader(sGridName, "Date", "preq_Date") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\">" + getColumnHeader(sGridName, "Company Name", "Comp_Name") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\">" + getColumnHeader(sGridName, "Type", "comp_PRType") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"left\">" + getColumnHeader(sGridName, "Rating", "prra_RatingLine") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\">" + getColumnHeader(sGridName, "BB Score", "preq_BluebookScore") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\">" + getColumnHeader(sGridName, "Exp Count", "TotalExcpCount") + "</td> ";

    if ((sTypeCode == "'AR'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" colspan=\"6\" align=\"center\">AR Exception(s)</td> ";
    }

    if ((sTypeCode == "'TES'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" colspan=\"6\" align=\"center\">TES Exception(s)</td> ";
    }

    if ((sTypeCode == "'BBScore'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" colspan=\"6\" align=\"center\">BBScore Exception(s)</td> ";
    }
     
    sContent += "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\">" + getColumnHeader(sGridName, "Status", "preq_Status") + "</td> " +
                "<td class=\"GRIDHEAD\" rowspan=\"2\" align=\"center\">" + getColumnHeader(sGridName, "Analyst", "user_Logon") + "</td> " +
                "\n</tr>" +
                "\n<tr>";


    if ((sTypeCode == "'AR'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" align=\"center\" valign=\"bottom\">" + getColumnHeader(sGridName, "Total", "AR_Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "15 Days", "AR_Days15Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "30 Days", "AR_Days30Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "45 Days", "AR_Days45Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "60 Days", "AR_Days60Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "90 Days", "AR_Days90Count") + "</td> ";
    }

    if ((sTypeCode == "'TES'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" align=\"center\" valign=\"bottom\">" + getColumnHeader(sGridName, "Total", "TES_Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "15 Days", "TES_Days15Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "30 Days", "TES_Days30Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "45 Days", "TES_Days45Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "60 Days", "TES_Days60Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "90 Days", "TES_Days90Count") + "</td> ";
    }

    if ((sTypeCode == "'BBScore'") || (sTypeCode == "NULL")) {
        sContent += "<td class=\"GRIDHEAD\" align=\"center\" valign=\"bottom\">" + getColumnHeader(sGridName, "Total", "BBS_Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "15 Days", "BBS_Days15Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "30 Days", "BBS_Days30Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "45 Days", "BBS_Days45Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "60 Days", "BBS_Days60Count") + "</td> " +
                    "<td class=\"GRIDHEAD\" align=\"center\">" + getColumnHeader(sGridName, "90 Days", "BBS_Days90Count") + "</td> ";
    }
    
    sContent +="\n</tr>\n</thead>";

    sClass = "ROW2";
    var iCount = 0;
    while (!recExceptions.eof)
    {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }
    
        sWorkContent += "\n<tr class=\"" + sClass + "\">\n";
        sWorkContent += "<td align=center class=\"" + sClass + "\">" + getDateValue(recExceptions("preq_Date")) + "</td>";
        sWorkContent += "<td class=\"" + sClass + "\"><a href=\"" + eWareUrl("PRCompany/PRCompanytradeActivityListing.asp") + "&comp_CompanyID=" + recExceptions("comp_CompanyId") + "\">" + recExceptions("comp_Name") + "</a></td>";
        sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("comp_PRType")) + "</td>";
        sWorkContent += "<td align=\"left\" class=\"" + sClass + "\">" + getValue(recExceptions("prra_RatingLine")) + "</td>";

        bbScore = getValue(recExceptions("preq_BluebookScore"));
        if (bbScore != "") {
            bbScore = Math.round(bbScore);
        }
        sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + bbScore.toString() + "</td>";
        
        sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TotalExcpCount")) + "</td>";

        if ((sTypeCode == "'AR'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Days15Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Days30Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Days45Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Days60Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AR_Days90Count")) + "</td>";
        }

        if ((sTypeCode == "'TES'") || (sTypeCode == "'TESAR'") || (sTypeCode == "NULL")) {
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Days15Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Days30Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Days45Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Days60Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("TES_Days90Count")) + "</td>";
        }

        if ((sTypeCode == "'BBScore'") || (sTypeCode == "NULL")) {
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Days15Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Days30Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Days45Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Days60Count")) + "</td>";
            sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("BBS_Days90Count")) + "</td>";
        }

        sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("preq_status")) + "</td>";
        sWorkContent += "<td align=\"center\" class=\"" + sClass + "\">" + getValue(recExceptions("AnalystName")) + "</td>";
        sWorkContent += "\n</tr>";
        
        iCount++;
        
        // This is to deal with large numbers of records.  We keep appending to the same string, but since
        // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
        // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.
        switch(iCount) {
            case 25: 
                Content01 = sWorkContent;
                sWorkContent = "";
                break;
        	case 50: 
            	Content02 = sWorkContent;
                sWorkContent = "";
                break;
        	case 75: 
            	Content03 = sWorkContent;
                sWorkContent = "";
                break;
        	case 100: 
            	Content04 = sWorkContent;
                sWorkContent = "";
                break;
        	case 150: 
            	Content05 = sWorkContent;
                sWorkContent = "";
                break;
        	case 200: 
            	Content06 = sWorkContent;
                sWorkContent = "";
                break;
        	case 250: 
            	Content07 = sWorkContent;
                sWorkContent = "";
                break;
        	case 300: 
            	Content08 = sWorkContent;
                sWorkContent = "";
                break;
        	case 350: 
            	Content09 = sWorkContent;
                sWorkContent = "";
                break;
        	case 400: 
            	Content10 = sWorkContent;
                sWorkContent = "";
                break;
        	case 450: 
            	Content11 = sWorkContent;
                sWorkContent = "";
                break;
        	case 500: 
            	Content12 = sWorkContent;
                sWorkContent = "";
                break;
        	case 550: 
            	Content13 = sWorkContent;
                sWorkContent = "";
                break;
        	case 600: 
            	Content14 = sWorkContent;
                sWorkContent = "";
                break;
        	case 650: 
            	Content15 = sWorkContent;
                sWorkContent = "";
                break;
        	case 700: 
            	Content16 = sWorkContent;
                sWorkContent = "";
                break;
        }        
        recExceptions.NextRecord();
    }      
    
    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 + sWorkContent;
    
    
    while (iCount < 10) {

        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        sContent += "\n<tr class=\"" + sClass + "\"><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td><td class=\"" + sClass + "\">&nbsp;</td></tr>";
    
        iCount ++;
    }
    
    sContent += "\n</table>";
    sContent += createAccpacBlockFooter();
    
//Response.Write("<br/>" + sGridName + " End: " + new Date());    
    return sContent;
}
%>

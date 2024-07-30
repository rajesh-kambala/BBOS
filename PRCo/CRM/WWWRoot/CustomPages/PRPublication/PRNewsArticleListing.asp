<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2018

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

<%
/////////////////////////////////////////////////////////
//Filename: PRnewsArticleListing.asp
//Author:           Tad M. Eness */
//////////////////////////////////////////////////
function doPage()
{
    //    bDebug = true;
    var blkContainer = eWare.GetBlock("container");

    // Search Box
    var blkSearch = eWare.GetBlock("PPRNewsArticleSearchBox");
    blkSearch.Title = "Find News Articles";
    blkSearch.GetBlock("prpbar_IndustryTypeCode").Size = 6;
    blkSearch.AddButton(eWare.Button("Search", "search.gif", "javascript:document.EntryForm.submit();"));
    blkSearch.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));


    var lstNewsArticle = eWare.GetBlock("PRNewsArticleGrid");
    lstNewsArticle.GetGridCol("prpbar_PublishDate").OrderByDesc = true;
    lstNewsArticle.ArgObj = blkSearch;

    blkFlags = eWare.GetBlock("content");
    blkFlags.Contents = "<input type=hidden name=_hiddenFirstTime value=\"N\">"
    blkContainer.AddBlock(blkFlags);

    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(lstNewsArticle);
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddButton(eWare.Button("New", "new.gif", eWare.URL("PRPublication/PRNewsArticle.asp")));
    

    var jsLoadString = "";
    var selectCondition = "";
    if (getFormValue("_hiddenFirstTime") != "N") {
        selectCondition = " AND prpbar_ExpirationDate BETWEEN GETDATE() AND DATEADD(year, 1, GETDATE())";

        var today = new Date();
        var endRange = new Date();
        endRange.setDate(endRange.getDate() + 365);
        jsLoadString += "\tdocument.getElementById('prpbar_expirationdate_start').value = '" + getDateAsString(today) + "';\n";
        jsLoadString += "\tdocument.getElementById('prpbar_expirationdate_end').value = '" + getDateAsString(endRange) + "';\n";
    }

    eWare.AddContent(blkContainer.Execute("prpbar_PublicationCode = 'BBN'" + selectCondition));
    Response.Write(eWare.GetPage("New"));
%>

    <script type="text/javascript">
    function clear() {
        document.EntryForm.em.value = '6';
        document.EntryForm.submit();
    }
<%

    if (jsLoadString.length > 0) {
        Response.Write(jsLoadString);
    }
%>
    </script>
<%
}

doPage();
%>

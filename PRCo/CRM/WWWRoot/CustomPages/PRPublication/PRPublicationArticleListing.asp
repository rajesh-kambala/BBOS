<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="..\PRCoGeneral.asp" -->

<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2007-2021

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

doPage();


/////////////////////////////////////////////////////////
//Filename: PRPublicationArticleListing.asp
//Author:           Tad M. Eness */
//////////////////////////////////////////////////
function doPage()
{
    Response.Write("<script type=text/javascript src=\"PRPublicationArticleListing.js\"></script>");

    var blkContainer = eWare.GetBlock("container");

    // Search Box
    var blkSearch = eWare.GetBlock("PRPublicationArticleSearchBox");
    blkSearch.Title = "Find";
    fld = blkSearch.GetEntry("prpbar_PublicationCode");
    fld.LookupFamily = "GeneralPublicationCode";


    // Grid
    var blkArticleList = eWare.GetBlock("PRPublicationArticleListingGrid");
    blkArticleList.ArgObj = blkSearch;

    if (Request.Form.Item("prpbar_publicationcode") != "BBS") {
        blkArticleList.DeleteGridCol("prpbar_IndustryTypeCode");
    }

    blkArticleList.DeleteGridCol("prpbar_CategoryCode");


    blkSearch.AddButton(eWare.Button("Search", "search.gif", "javascript:document.EntryForm.submit();"));
    blkSearch.AddButton(eWare.Button("Clear", "clear.gif", "javascript:clear();"));
    
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkSearch);
    blkContainer.AddBlock(blkArticleList);

    blkContainer.AddButton(eWare.Button("New Article", "new.gif", eWare.URL("PRPublication/PRPublicationArticle.asp")));

    // Create buttons for each of the publication code values
    var sql = "SELECT RTrim(Capt_Code) As \"Capt_Code\", Capt_US FROM Custom_Captions WITH (NOLOCK) WHERE Capt_Family = 'GeneralPublicationCode' Order By Capt_Order";
    var qry = eWare.CreateQueryObj(sql);

    var capt_code = "";
    var caption = "";
    var SequenceAction = "";
    
    qry.SelectSQL();
    while (! qry.eof) {

        capt_code = String(qry("Capt_Code"));
        
        if ((capt_code != "BBN") &&
            (capt_code != "KYCGFB") &&
            (capt_code != "TTGFB") &&
            (capt_code != "KYCG")) {
            caption = String(qry("Capt_US"));
            SequenceAction = eWare.URL("PRPublication/PRPublicationArticleSequence.asp");
            SequenceAction = changeKey(SequenceAction, "prpbar_PublicationCode", Server.URLEncode(capt_code));
            blkContainer.AddButton(eWare.Button("Sequence \"" + caption + "\"", "forecastrefresh.gif", SequenceAction));
        }            
        qry.NextRecord();        
    }

    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage("New"));
}
Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
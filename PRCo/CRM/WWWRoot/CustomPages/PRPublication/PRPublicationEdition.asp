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
//Filename: PRPublicationEdition.asp
//Author:           Tad M. Eness */
//////////////////////////////////////////////////
function doPage() {

   
    /*
     This is the only screen I'm aware of that has both an grid listing and can edit the
     entity.  By default, sorting the grid put the page into edit mode.  So I added a 
     btnEdit flag to the Edit link so that we know when we are truly in edit mode.
     If we don't find that flag, reset the mode to View.
    */
    if ((eWare.Mode == Edit) && 
        (getIdValue("btnEdit") == -1)) {
        eWare.Mode = View;
    }

    // Declare the blocks to be added to the screen
    var blkArticleList;
    var blkEntry;
    var blkError;
    var blkCoverArt;

    var sListingAction = eWare.URL("PRPublication/BluePrintsEditionListing.asp");

    //bDebug = true;

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type=\"text/javascript\" src=\"PRPublicationEdition.js\"></script>");

    var qry;
    var blkContainer = eWare.GetBlock("container");
    blkContainer.CheckLocks = false;    
    
    var prpbed_publicationeditionid = getIdValue("prpbed_PublicationEditionID");
    var recPublicationEdition;
    if (prpbed_publicationeditionid != -1 && prpbed_publicationeditionid != "undefined") {
        recPublicationEdition = eWare.FindRecord("PRPublicationEdition", "prpbed_PublicationEditionID=" + String(prpbed_publicationeditionid));
    } else {
        recPublicationEdition = eWare.CreateRecord("PRPublicationEdition");
        if (eWare.Mode < Edit) {
            eWare.Mode = Edit;
        }
    }

    // Add Block to Container to build screen.
    blkEntry = eWare.GetBlock("PRPublicationEditionEntry");
    blkEntry.Title = "Publication Edition";

    if ( eWare.Mode == Save ) {
        var bError = false;
        var sErrMsg = "";

        // Validate the name to be unique within the publication type.
        // If type == Blueprints, then must be unique within the edition as well
        var sEditionName = String(Request.Form("prpbed_Name"));
        sEditionName = (sEditionName != "undefined") ? trim(sEditionName) : "";

        qry = eWare.CreateQueryObj("SELECT Count(*) As Cnt FROM PRPublicationEdition WITH (NOLOCK) WHERE prpbed_PublicationCode = 'BP' AND prpbed_Name = '" + sEditionName.replace(/'/g, "''") + "' And prpbed_PublicationEditionID != " + String(prpbed_publicationeditionid));
        qry.SelectSQL();
        var cnt = Number(qry("Cnt"));
        
        if (cnt > 0) {
            bError = true;
            sErrMsg = getErrorHeader("Name must be unique within the publication type");
        }
        
        // Check the Cover art file name for uniquness. must be unique Accross Publication type and edition (if edition == blueprints)
        var sCoverArtFileName = String(Request.Form("prpbed_CoverArtFileName"));
        sCoverArtFileName = (sCoverArtFileName != "undefined") ? trim(sCoverArtFileName) : "";
        var sql = "SELECT Count(*) As Cnt FROM PRPublicationEdition WITH (NOLOCK) WHERE prpbed_CoverArtFileName = '" + sCoverArtFileName + "' And prpbed_PublicationCode = 'BP' AND prpbed_PublicationEditionID != " + String(prpbed_publicationeditionid) + " AND prpbed_Name = '" + sEditionName.replace(/'/g, "''") + "'"
        
        qry.SelectSQL();
        cnt = qry("Cnt");
        if (cnt > 0) {
            bError = true;
            sErrMsg += getErrorHeader(Server.HTMLEncode("Cover Art Filename must be unique within the Blueprints Edition.)"));
        }

        if (! bError) {
            blkEntry.Execute(recPublicationEdition);
            var id = String(recPublicationEdition("prpbed_PublicationEditionID"));
            var url= changeKey(eWare.URL(J), "prpbed_PublicationEditionID", id)
            Response.Redirect(url);
        } else {
            blkError = eWare.GetBlock('content');
            blkError.Contents = sErrMsg;
            eWare.Mode = Edit;
        }


    }

    if (eWare.Mode == Edit) {

        fld = blkEntry.GetEntry("prpbed_PublicationCode");
        fld.DefaultValue = "BP";

        blkContainer.DisplayButton(Button_Default) = false;
        blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:save();"));
                        
        if (prpbed_publicationeditionid != -1) {
            blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", sSummaryAction(prpbed_publicationeditionid)));
        } else {
            blkContainer.AddButton(eWare.Button("Cancel", "Cancel.gif", sListingAction));
        }    
        
    } else if ( eWare.Mode == View ) {
        blkContainer.DisplayButton(Button_Default) = false;
        // blkContainer.AddButton(eWare.Button("Continue","continue.gif", ((F.length > 0) ? eWare.URL(F) : eWare.URL("PRPublication/PRPublicationArticleListing.asp"))));
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", (eWare.URL("PRPublication/BlueprintsEditionListing.asp"))));

        var qry = eWare.CreateQueryObj("SELECT RTrim(Cast(Capt_US As nvarchar(max))) As Capt_US FROM Custom_Captions WHERE Capt_Family = 'BBOS' And Capt_Code = 'URL'");
        qry.SelectSQL();
        if (!qry.Eof) {
            bbos_url = String(qry("Capt_US"));
        }
        var sPreviewAction = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "BlueprintsEdition.aspx?EditionID=" + prpbed_publicationeditionid;

        blkContainer.AddButton(eWare.Button("Preview ","componentpreview.gif", sPreviewAction + "\" target=\"_blank"));
        blkContainer.AddButton(eWare.Button("Change","edit.gif", "javascript:document.EntryForm.action='" + sSummaryAction(prpbed_publicationeditionid) + "&btnEdit=1'; document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("New Article", "new.gif", changeKey(eWare.URL("PRPublication/PRPublicationArticle.asp"), "prpbed_PublicationEditionID", String(prpbed_publicationeditionid))));
        blkContainer.AddButton(eWare.Button("Sequence", "forecastrefresh.gif", eWare.URL("PRPublication/PRPublicationArticleSequence.asp") + "&prpbar_PublicationCode=BP&prpbed_PublicationEditionID=" + String(prpbed_publicationeditionid)));


        if (recPublicationEdition.ItemAsString("prpbed_CoverArtFileName").length > 0) {
            blkCoverArt = eWare.GetBlock("Content");
            blkCoverArt.NewLine = false;
            blkCoverArt.Width = "220px";
            blkCoverArt.Contents = createAccpacBlockHeader("CoverArt", "Cover Art", "220px");
            blkCoverArt.Contents += "<table><tr>";

            var sImgURL = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "LearningCenter/" + recPublicationEdition("prpbed_CoverArtFileName")
            blkCoverArt.Contents += "<td><img src = \"" + sImgURL + "\" /></td>";

            sImgURL = bbos_url + (bbos_url.search("/$") >= 0 ? "" : "/") + "LearningCenter/" + recPublicationEdition("prpbed_CoverArtThumbFileName")
            blkCoverArt.Contents += "<td><img src = \"" + sImgURL + "\" /></td>";

            blkCoverArt.Contents += "</tr></table>";
            blkCoverArt.Contents += createAccpacBlockFooter();
        }


        // Grid
        blkArticleList = eWare.GetBlock("PRPublicationEditionListingGrid");
        //blkArticleList.Title = "Publication Edition Articles";
    }

    if (blkError) {
        blkContainer.AddBlock(blkError);
    }
    blkContainer.AddBlock(blkEntry);

    if (blkCoverArt) {
        blkContainer.AddBlock(blkCoverArt);
    }
    

    if (blkArticleList) {
        blkContainer.AddBlock(blkArticleList);
    }
    
    eWare.AddContent(blkContainer.Execute(recPublicationEdition));
    Response.Write(eWare.GetPage("New"));
    
    if (eWare.Mode == Edit) {
        Response.Write("<table>");
        Response.Write("<tr id='_tr_publication_upload'><td><span id='_DataPublication_Upload'><iframe id='_frmPublication_Upload' style='width:75%; height:150px' frameborder='0' marginwidth='0' src='PRPublicationUpload.aspx?IsPublicationEdition=Y'></iframe></span></td></tr>");
        Response.Write("</table>");

        Response.Write("\n<script type=\"text/javascript\">");
        Response.Write("\n    function initBBSI()"); 
        Response.Write("\n    { ");
        Response.Write("\n        PublicationEditionFormUpdates(); "); 
        Response.Write("\n    } ");
        Response.Write("\n    document.forms['EntryForm'].onsubmit=Form_OnSubmit;");
        Response.Write("\n    if (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
        Response.Write("\n</script>");
    }


}

function sSummaryAction(PublicationEditionId)
{
    var sResult = eWare.URL("PRPublication/PRPublicationEdition.asp");
    if (PublicationEditionId != -1) {
        var sPublicationEditionId = String(PublicationEditionId);
        if (sPublicationEditionId.length > 0)
            sResult = changeKey(sResult, "prpbed_PublicationEditionID", sPublicationEditionId);
    }
    return sResult;
}

Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>

<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var blkEntry = null;
    var prbs_bbscoreid = getIdValue("prbs_bbscoreid");
    if (prbs_bbscoreid == -1)
    {
        blkEntry = eWare.getBlock("content");
        blkEntry.contents = "<span class=\"WarningContent\">A valid BB ID was not availabe to allow retrieval of BB Score records.</span>";
    }
    else
    {
        recBBScore = eWare.FindRecord("PRBBScore", "prbs_bbscoreid="+prbs_bbscoreid);    
    }


    //DumpFormValues();
    eWare.Mode = View;

    if (recBBScore("prbs_Model") == "blendedV2")
        blkEntry=eWare.GetBlock("PRBBScoreSummary");
    else
        blkEntry=eWare.GetBlock("PRBBScoreNewEntry");
    

    blkEntry.Title="BB Score";
    blkEntry.ArgObj = recBBScore;
    
    sListingAction = eWare.Url("PRCompany/PRCompanyRatingListing.asp")+ "&comp_CompanyId=" + comp_companyid;
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sListingAction));
    blkContainer.AddBlock(blkEntry);
    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage());

    if (recBBScore("prbs_Model") == "blendedV2") {
        Response.Write("\n<script type='text/javascript'>");
	    Response.Write("\nfunction initBBSI()"); 
	    Response.Write("\n{ ");

        Response.Write("\n setFieldValue('_Dataprbs_surveyweight', '" + getValue(recBBScore("prbs_SurveyWeight")) + "'); ");
        Response.Write("\n setFieldValue('_Dataprbs_arweight', '" + getValue(recBBScore("prbs_arweight")) + "'); ");
        Response.Write("\n setFieldValue('_Dataprbs_surveynagepercentile', '" + getValue(recBBScore("prbs_surveynagepercentile")) + "'); ");
        Response.Write("\n setFieldValue('_Dataprbs_arnagepercentile', '" + getValue(recBBScore("prbs_arnagepercentile")) + "'); ");
   
        Response.Write("\n} ");
        Response.Write("\nif (window.addEventListener) { window.addEventListener(\"load\", initBBSI); } else {window.attachEvent(\"onload\", initBBSI); }");
	    Response.Write("\n</script>");
    }

%>
<!-- #include file="CompanyFooters.asp" -->
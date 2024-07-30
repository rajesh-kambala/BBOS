<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<!-- #include file ="PRBBScoreGridInclude.asp" -->
<!-- #include file ="CompanyHeaders.asp" -->
<%
    var blkCompanyInfo = eWare.GetBlock("Company1");
    blkCompanyInfo.Title = "Company";
    blkCompanyInfo.Mode = View;
    blkCompanyInfo.ArgObj = recCompany;

    if (recCompany.comp_PRIndustryType == "L") {
        lstMain = eWare.GetBlock("PRBBScoreLumberGrid");
        lstMain.prevURL = eWare.URL(f_value);    
        entry=lstMain.GetGridCol("prbs_Date").OrderByDesc = true;
    } else {
        var recBBScores = eWare.CreateQueryObj("SELECT * FROM PRBBScore WITH (NOLOCK) WHERE prbs_CompanyID=" + comp_companyid + " ORDER BY prbs_Date DESC");
        recBBScores.SelectSQL();

        lstMain = eWare.GetBlock("content");
        lstMain.Contents = buildProduceBBScoreGrid(recBBScores, "BBScoreGrid", " BB Score Record");
    }
    
    blkContainer.AddBlock(blkCompanyInfo);
    blkContainer.AddBlock(lstMain);

    sContinueAction = "PRCompany/PRCompanyRatingListing.asp";
    blkContainer.AddButton(eWare.Button("Continue","continue.gif",eWare.Url(sContinueAction) + "&T=Company&Capt=Rating"));
    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute("prbs_CompanyId=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));

%>
<!-- #include file="CompanyFooters.asp" -->


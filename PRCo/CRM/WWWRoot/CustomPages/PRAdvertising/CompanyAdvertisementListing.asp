<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<% doPage(); %>

<script type="text/javascript" language="javascript" runat="server">
function doPage()
{
    var blkContainer = eWare.GetBlock("Container");
    var blkContent;

    try {
        var blkIncludes = eWare.GetBlock('content');
        blkIncludes.contents = "\n<meta http-equiv=\"Page-Enter\" content=\"RevealTrans(Duration=0,Transition=0)\" />\n";
        blkIncludes.contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";

        blkContainer.AddBlock(blkIncludes);

        // determine if any of the addtional banners should show
        var sBannerMsg = "";
        var blkBanners = eWare.GetBlock('content');
        if (eWare.Mode == View) {
            var sInnerMsg = "";
            var cols = 3;
            var i = 0

            //ONLY INCLUDE year-round blueprints advertiser message
            var qry = eWare.CreateQueryObj("SELECT * FROM dbo.ufn_GetCompanyMessages(" + comp_companyid + ", '" + recCompany("comp_PRIndustryType") + "') WHERE Message LIKE ('%year-round Blueprints%')");
            qry.SelectSQL();

            while (!qry.eof) {
                if (i % cols == 0) {
                    sInnerMsg += "<tr>\n";
                }

                var msg = qry("Message");

                if (msg.substr(0, 10) == "lightblue:") {
                    msg = msg.replace("lightblue:", "");
                    sInnerMsg += "\t<td width=\"33%\" align=\"center\" class=\"MessageContent3\">" + msg + "</td>\n";
                }
                else
                    sInnerMsg += "\t<td width=\"33%\" align=\"center\">" + msg + "</td>\n";


                if ((i + 1) % cols == 0) {
                    sInnerMsg += "</tr>\n";
                }

                i++;
                qry.NextRecord();
            }

            if (sInnerMsg != "") {
                if (i % cols != 0) {
                    sInnerMsg += "</tr>\n";
                }

                sBannerMsg = "\n\n<table width='100%' style='padding-left:10px !important; padding-right:10px !important'><tr><td width='100%' align='center'>\n";
                sBannerMsg += "<table class='MessageContent' align='center>'\n";
                sBannerMsg += sInnerMsg;
                sBannerMsg += "</table>\n";
                sBannerMsg += "</td></tr></table>\n\n";

                blkBanners.contents = sBannerMsg;
            }
        }

        // we only need to show this in view mode
        if (eWare.Mode == View) {
            if (sBannerMsg != "")
                blkContainer.AddBlock(blkBanners);
        }

        //Search filter and results blocks
        blkSearch = eWare.GetBlock("PRAdCampaignHeaderGridFilter");
        blkSearch.Title = "Search";

        var blkList = eWare.GetBlock("PRAdCampaignHeaderGrid");
        blkList.GetGridCol("pradch_CreatedDate").OrderByDesc = true;
        blkList.CaptionFamily = "PRAdCampaignCaptions";
        blkList.prevURL = sURL;
        blkList.ArgObj = blkSearch;

        blkContainer.AddBlock(blkSearch);

        var blkTitle = eWare.GetBlock('Content');
        blkTitle.Contents = "<div class='PANEREPEAT' style='padding-left:15px' nowrap='true'>Ad Campaigns</div>";
        blkContainer.AddBlock(blkTitle);

        blkContainer.AddBlock(blkList);
        
        blkContainer.DisplayButton(Button_Default) = true;
        blkContainer.ButtonTitle="Search";
        blkContainer.ButtonImage="Search.gif";
        blkContainer.AddButton(eWare.Button("Clear", "clear.gif", "javascript:document.EntryForm.em.value='6';document.EntryForm.submit();"));

        blkContainer.AddButton(eWare.Button("New Ad Campaign", "new.gif", eWare.URL("PRAdvertising/AdCampaignHeader.asp")));

        eWare.AddContent(blkContainer.Execute("pradch_CompanyID = " + comp_companyid));
        Response.Write(eWare.GetPage());
    } catch (e) {
        blkContent = eWare.GetBlock("Content");
        blkContent.Contents = "Unexpected Event:<table border='0'><tr><td>name:</td><td>" + e.name + "</td><tr><td>number:</td><td>" + e.number + "</td><tr><td>description:</td><td>" + e.description + "</td><tr><td>message:</td><td>" + e.message + "</td></table>"
        blkContainer.AddBlock(blkContent);
        
        eWare.AddContent(blkContainer.Execute());
        Response.Write(eWare.GetPage())
    }
}
</script>
<!-- #include file="..\PRCompany\CompanyFooters.asp" -->

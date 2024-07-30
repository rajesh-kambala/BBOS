<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%
    doPage();

function doPage() {

    var blkCustomCSS = eWare.GetBlock('Content');
    blkCustomCSS.contents = "\n\n<style>.myframe {height:600px;width:100%;overflow:auto;border:none;}</style>\n";

    var sURL = Request.QueryString("FrameURL") + "&SID=" + Request.QueryString("SID") + "&user_userid=" + user_userid;
    var blkCustom = eWare.GetBlock('Content');
    blkCustom.contents = '<iframe ID="ifrmCustom" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE scrolling="yes" class="myframe" src="'+sURL +'"></iframe>\n\n';

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkCustomCSS);
    blkContainer.AddBlock(blkCustom);
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
}
%>
<!-- #include file="CompanyFooters.asp" -->
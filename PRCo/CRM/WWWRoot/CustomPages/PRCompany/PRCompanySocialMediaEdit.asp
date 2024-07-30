<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<%

    doPage();


function doPage() {

    var sURL = "PRCompanySocialMediaEdit.aspx?CompanyID=" + Request.QueryString("Key1") + "&SID=" + Request.QueryString("SID") + "&user_userid=" + user_userid;
    var blkCustom = eWare.GetBlock('Content');
    blkCustom.contents = '<iframe ID="ifrmCustom" FRAMEBORDER="0" MARGINHEIGHT="0" NORESIZE SCROLLING="AUTO" style="height:500px;width:100%;border:none;" src="'+sURL +'"></iframe>';

    var blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    blkContainer.AddBlock(blkCustom);
    eWare.AddContent(blkContainer.Execute());
    Response.Write(eWare.GetPage('Company'));
}
%>
<!-- #include file="CompanyFooters.asp" -->
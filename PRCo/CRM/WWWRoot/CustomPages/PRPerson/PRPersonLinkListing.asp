<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="PersonHeaders.asp" -->
<%
    var blkGeneralContent = eWare.GetBlock("content");
    blkGeneralContent.Contents += "<link rel=\"stylesheet\" href=\"../../prco.css\">\n";
    blkContainer.AddBlock(blkGeneralContent);

    var sSecurityGroups = sDefaultPersonSecurity;
    var sGridName = "PRPerson_LinkGrid";
    var sAddNewPage = "PRPerson/PRPersonLink.asp";
    var sEntityPersonIdName = "peli_PersonId";
    var sNewCaption = "New Company Link";
    tabContext = "&T=Person&Capt=History";
%>
<!-- #include file ="PersonListingPageInclude.asp" -->

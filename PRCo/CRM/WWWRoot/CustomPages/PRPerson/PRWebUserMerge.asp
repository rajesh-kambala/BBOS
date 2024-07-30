<!-- #include file ="../accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->

<%
function doPage(){

    DumpFormValues();
    bDebug = true;
    var prwu_webuserid;
    
    if (eWare.Mode == Save) {
        // determine what needs to happen for this merge.
        prwu_webuserid = getIdValue("prwu_WebUserId");
        sUSP = "exec usp_MergeWebUserToCRM " + prwu_webuserid + ", " + user_userid; 
        var prwu_mergedpersonid = getIdValue("prwu_mergedpersonid");
        var prwu_mergedcompanyid = getIdValue("prwu_mergedcompanyid");
        if (!isEmpty(prwu_mergedpersonid) && prwu_mergedpersonid != -1)
            sUSP += ", " + prwu_mergedpersonid;
        else
            sUSP += ", NULL";
        if (!isEmpty(prwu_mergedcompanyid) && prwu_mergedcompanyid != -1)
            sUSP += ", " + prwu_mergedcompanyid;
        else
            sUSP += ", NULL";
        // call the usp_MergeWebUserToCRM function to do the merge
        DEBUG("Executing: [" + sUSP + "]");
        recQuery = eWare.CreateQueryObj(sUSP);
        recQuery.ExecSql();
        DEBUG("Stored procedure executed.");
        
    }
    //bDebug = true;
    var sSecurityGroups = "";

    Response.Write("<script type==\"text/javascript=\" language==\"javascript=\" src=\"../PRCoGeneral.js\"></script>");
    Response.Write("<script type==\"text/javascript=\" language==\"javascript=\" src=\"PRWebUserMerge.js\"></script>");

    var sDisplayError = null;
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    sListingAction = eWare.Url("PRPerson/PRWebUserListing.asp");
    prwu_webuserid = getIdValue("prwu_WebUserId");
    if (prwu_webuserid == "-1"){
        Response.Redirect(sListingAction);
        return;
    }
    
    recWebUser = eWare.FindRecord("PRWebUser", "prwu_WebUserId=" + prwu_webuserid);
    
    sCancelAction = eWare.Url("PRPerson/PRWebUser.asp");
    blkContainer.AddButton(eWare.Button("Cancel","cancel.gif", sCancelAction));
    
    blkMain=eWare.GetBlock("PRWebUserMerge");
    setBlockCaptionAlignment(blkMain, 2);
    blkMain.ArgObj = recWebUser;        
    blkMain.Title="Merge Web User to CRM";
    blkContainer.CheckLocks = false;
    blkContainer.AddBlock(blkMain);
    blkContainer.AddButton(eWare.Button("Merge","new.gif", "javascript:save();"));
    
    eWare.Mode = Edit;

    eWare.AddContent(blkContainer.Execute()); 
    Response.Write(eWare.GetPage('Find'));
%>
    <script type="text/javascript">
        function initBBSI() {
<%  if (eWare.Mode == Edit) { %>
            initEditScreen();
<% } %>
            
        if (window.addEventListener) { window.addEventListener("load", initBBSI); } else {window.attachEvent("onload", initBBSI); }
    </script>
<%
}
doPage();
%>
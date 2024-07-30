<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    DEBUG("URL: " + sURL); 
    DEBUG("Mode: " + eWare.Mode);
    
    if (eWare.Mode != View || eWare.Mode != Find)
        eWare.Mode = View;
    
%>
<!-- #include file ="ExceptionQueueFilterInclude.asp" --> 

<%
    // build the where cluase based upon the current user, the user's security, and the filter criteria
    var sGridFilterWhereClause = "";
    if (sDBAssignedUserId != "NULL")
        sGridFilterWhereClause = "preq_AssignedUserId =" + sDBAssignedUserId;
    if (!isEmpty(sFormStartDate))
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"preq_Date >= " + sDBStartDate;
    if (!isEmpty(sFormEndDate))
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"preq_Date <= " + sDBEndDate;
    if (sDBStatus != "NULL")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"preq_status = " + sDBStatus;
    if (sDBType != "NULL")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"preq_Type = " + sDBType;
    if (sDBCompanyId != "NULL")
        sGridFilterWhereClause += (sGridFilterWhereClause == ""?"":" AND ") +"preq_CompanyId = " + sDBCompanyId;

    DEBUG("SQL: " + sGridFilterWhereClause);
    
    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    if (eWare.Mode == View || eWare.Mode == Find)
    {
        Response.Write("<LINK REL=\"stylesheet\" HREF=\"../../prco.css\">");
        Response.Write("<script language=javascript src=\"../PRCoGeneral.js\"></script>");

        //blkFilter is created in ExceptionQueueFilterInclude.asp
        blkFilter.Width = "95%";
        blkContainer.AddBlock(blkFilter);    
        
        blkListing = eWare.GetBlock("PRExceptionQueueGrid");
        blkListing.DisplayButton(Button_Default) = false;
        recListing = eWare.FindRecord("vExceptionQueue", sGridFilterWhereClause);
        blkContainer.AddBlock(blkListing);
                
        eWare.AddContent(blkContainer.Execute(recListing));
        Response.Write(eWare.GetPage());
    %>
        <script type="text/javascript" >
            function initBBSI()
            {
                document.all("_startdate").value = '<%= sFormStartDate %>';
                document.all("_enddate").value = '<%= sFormEndDate %>';

                RemoveDropdownItemByName("preq_type", "--None--");
                SelectDropdownItemByValue("preq_type", "<%= preq_type %>");

                RemoveDropdownItemByName("preq_status", "--None--");
                SelectDropdownItemByValue("preq_status", "<%= preq_status %>");

                RemoveDropdownItemByName("preq_assigneduserid", "--None--");
                SelectDropdownItemByValue("preq_assigneduserid", "<%= sUserIdToSelect %>");
            }
            if (window.addEventListener) { window.addEventListener("load", initBBSI); } else { window.attachEvent("onload", initBBSI); }
        </script>
    <%
    }
    %>

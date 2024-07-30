<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="CompanyHeaders.asp" -->
<!-- #include file ="..\DLOrderCheckInclude.asp" -->
<%

    doPage();

function doPage() {
    var sSecurityGroups = "1,2,3,4,5,6,10";

    blkMain=eWare.GetBlock("PRCompanyBrandNewEntry");
    blkMain.Title="Brand";

    // Determine if this is new or edit
    var prc3_companybrandid = getIdValue("prc3_CompanyBrandId");
    // indicate that this is new
    if (prc3_companybrandid == "-1")
    {
        var bNew = true;
        if (eWare.Mode < Edit)
            eWare.Mode = Edit;
    }
    sListingAction = eWare.Url("PRCompany/PRCompanyDLView.asp") + "&T=Company&Capt=Profile";
    sSummaryAction = eWare.Url("PRCompany/PRCompanyBrand.asp")+ "&prc3_CompanyBrandId="+ prc3_companybrandid;

    recCompanyBrand = eWare.FindRecord("PRCompanyBrand", "prc3_CompanyBrandId=" + prc3_companybrandid);

    if (eWare.Mode == 99)
    {
        triggerDLOrder(comp_companyid, user_userid);
        var blkOrderedBanner = eWare.GetBlock('content');
        eWare.Mode = Edit;
    }


    if (eWare.Mode == Edit || eWare.Mode == Save)
    {
        if (!hasDLService(comp_companyid)) {

            Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");
            var blkBanners = eWare.GetBlock('content');
            //blkBanners.contents = getDLMsgBanner();
            
            //if (hasDLServiceOrdered(comp_companyid)) {
            //    blkBanners.contents += getDLOrderedMsgBanner();
            //}

            //blkContainer.AddBlock(blkBanners);
            //blkContainer.AddButton(eWare.Button("Create DL Order", "save.gif", changeKey(sURL, "em", "99"))) ;
        } 

        if (bNew)
        {
            if (!isEmpty(comp_companyid)) 
            {
                recCompanyBrand=eWare.CreateRecord("PRCompanyBrand");
                recCompanyBrand.prc3_CompanyId = comp_companyid;
            }
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sListingAction));
	    }
        else
        {
            blkContainer.AddButton(eWare.Button("Cancel", "cancel.gif", sSummaryAction));
	    }
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
                blkContainer.AddButton(eWare.Button("Save", "save.gif", "javascript:document.EntryForm.submit();"));
        }
	}
    else if (eWare.Mode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyBrand WHERE prc3_CompanyBrandId="+ prc3_companybrandid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
	    Response.Redirect(sListingAction);
    }
    else 
    {
        blkContainer.AddButton(eWare.Button("Continue","continue.gif", sListingAction));
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    if (isUserInGroup(sSecurityGroups))
            {
                sDeleteUrl = changeKey(sURL, "em", "3");
                blkContainer.AddButton(eWare.Button("Delete", "delete.gif", "javascript:location.href='"+sDeleteUrl+"';"));
                blkContainer.AddButton(eWare.Button("Change","edit.gif","javascript:document.EntryForm.action='" + sSummaryAction + "';document.EntryForm.submit();"));
            }
    	}

    }
    blkContainer.CheckLocks = false;

    blkContainer.AddBlock(blkMain);
    if (bNew)
    {
        var script = "\n\n<script type=\"text/javascript\">\n";
        script += "     function convertToUpper() {\n";
        script += "          document.getElementById('prc3_brand').value = document.getElementById('prc3_brand').value.toUpperCase(); \n";
        script += "     }\n";
        script += "     document.getElementById('prc3_brand').addEventListener(\"keyup\", convertToUpper); \n";
        script += "</script>\n\n";
        var blkScript = eWare.GetBlock('content');
        blkScript.contents = script;
        blkContainer.AddBlock(blkScript);
    } 

    var script2 = "\n\n<script type=\"text/javascript\">\n";
    script2 += "     $('form').keypress(function (event) {";
    script2 += "         var keycode = (event.keyCode ? event.keyCode : event.which);";
    script2 += "         if (keycode == '13') {";
    script2 += "             event.preventDefault();";
    script2 += "             event.cancelBubble = true;";
    script2 += "             event.returnValue = false;";
    script2 += "             return false;";
    script2 += "         }";
    script2 += "     }); \n";
    script2 += "     document.getElementById('prc3_brand').focus();";
    script2 += "</script>\n\n";
    var blkScript2 = eWare.GetBlock('content');
    blkScript2.contents = script2;
    blkContainer.AddBlock(blkScript2);
    






    eWare.AddContent(blkContainer.Execute(recCompanyBrand));
    
    if (eWare.Mode == Save) 
    {
	    if (bNew)
	        Response.Redirect(sListingAction);
	    else
	        Response.Redirect(sSummaryAction);
    }
    else if (eWare.Mode == Edit) 
    {
        // hide the tabs
        Response.Write(eWare.GetPage('Company'));
    }
    else
        Response.Write(eWare.GetPage());
}
%>
<!-- #include file="CompanyFooters.asp" -->

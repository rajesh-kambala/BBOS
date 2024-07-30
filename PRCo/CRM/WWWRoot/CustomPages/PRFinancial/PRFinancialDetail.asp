<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006

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
%>
<!-- #include file ="..\PRCoFunctions.asp" -->

<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="..\PRCompany\CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->

<%
    var sURL=new String( Request.ServerVariables("URL")() + "?" + Request.QueryString );
//Response.Write("URL: " + sURL); 
//Response.Write("<br>CompanyId: " + comp_companyid); 

    bRedirect = false;
    var sSID = Request.Querystring("SID");
    var sField = Request.Querystring("sField");

    // I don't think this is submitted with the "prfd_" value anymore but leaving this
    // in just in case.  I assume most submissions will fall through to the "prfs_" check
    var prfd_financialid = Request.Querystring("prfd_FinancialId");
    if (isEmpty(prfd_financialid))
        prfd_financialid = Request.Querystring("prfs_FinancialId");

    var sBlock = Request.Querystring("sBlock");
    //var sURL = Request.Form();
    var sAdd = String(Request.Form("Add"));
    var sSave = String(Request.Form("Save"));
    var sTotal = String(Request.Form("Total"));
    var sForm = String(Request.Form);
    var sForm = sForm.split("&");
    var arr = sForm;
    var arrValues = null;

    // Start handling actions
    if (eWare.Mode == 95) // custom cancel action
    {
        // check if the arrTemp_<fieldname> exists and delete it; then redirect back to the FS
        arrValues = Session("arrTemp_" + sField);
        if (arrValues != null)
            Session.Contents.Remove("arrTemp_" + sField);
        Response.Redirect(eWare.Url("PRFinancial/PRFinancialSummary.asp")+ "&em=1&prfs_FinancialId="+ prfd_financialid);    
        bRedirect = true;
    }
    else if (eWare.Mode == 96) // new entry action
    {
            // move the submitted values to the temp array
            arrValues = new Array();
            ndx = 0;
            txtRowNdx = String(Request.Form.Item("_txtFDId_"+ ndx));
            while (txtRowNdx != "undefined")
            {
                // get the FinancialDetailId, Description, and Amount
                sDescription = String(Request.Form.Item("_txtDescription_"+ndx));
                sAmount = String(Request.Form.Item("_txtAmount_"+ndx));
                arrValues[ndx] = String(txtRowNdx) + "~" + sDescription + "~" + sAmount;
                // look for another row
                ndx = ndx + 1;
                txtRowNdx = String(Request.Form.Item("_txtFDId_"+ ndx));
            }
            Session("arrTemp_"+sField) = arrValues;
    }
    else if (eWare.Mode == 97) // apply changes action
    {
        Session.Contents.Remove("arrTemp_" + sField);
        // move the submitted values to the real array
        arrValues = new Array();
        ndx = 0;
        nTotalAmount = 0;
        txtRowNdx = String(Request.Form.Item("_txtFDId_"+ ndx));
        while (txtRowNdx != "undefined" )
        {
//Response.Write("<br>"+ndx+ " [" + txtRowNdx + "]");
            // get the FinancialDetailId, Description, and Amount
            sDescription = String(Request.Form.Item("_txtDescription_"+ndx));
            sAmount = String(Request.Form.Item("_txtAmount_"+ndx));
            if ((sDescription != "" && sAmount != "") || (txtRowNdx != "0") )
                arrValues[ndx] = String(txtRowNdx) + "~" + sDescription + "~" + sAmount;
            nAmount = parseInt(sAmount);
            if (!isNaN(nAmount))
                nTotalAmount += nAmount;
            // look for another row
            ndx = ndx + 1;
            txtRowNdx = String(Request.Form.Item("_txtFDId_"+ ndx));
        }
        Session("arr_"+sField) = arrValues;
        // before returning, we have to set the new value in the session
        // variable; these session values will be loaded unconditionally when we return
		var recFinancial = Session("recFinancial");
        recFinancial(sField) = nTotalAmount;
        Session("recFinancial") = recFinancial;
        
        Response.Redirect(eWare.Url("PRFinancial/PRFinancialSummary.asp")+ "&em=1&prfs_FinancialId="+ prfd_financialid);    
        bRedirect = true;
    }
    
    //  If we do not redirect, DRAW THE PAGE
    if (!bRedirect)
    {
        Response.Write("<script language=JavaScript src=\"PRFinancialDetail.js\"></script>");
        Response.Write("<script language=JavaScript>");
        Response.Write("    var prfd_financialid = \"" + prfd_financialid+ "\";");
        sNewEntryUrl = changeKey(sURL, "em", "96");
        Response.Write("    var sNewEntryUrl = \"" + sNewEntryUrl+ "\";");
        sSaveUrl = changeKey(sURL, "em", "97");
        Response.Write("    var sSaveUrl = \"" + sSaveUrl+ "\";");
        Response.Write("</script>");
        cntMain = eWare.GetBlock("container");
        sPanelName = eWare.GetTrans('ColNames', sField);
        sPanelNamePlural = "";
        blkContent = eWare.GetBlock("content");

        // check the session to see if a temp array for this field is available
        arrValues = Session("arrTemp_" + sField);
        if (arrValues == null)
        {
//Response.Write("<br>arrTemp_... could not be found.");
            // Check for the array already retrieved from the DB; this 
            // array may have already been modified since retrieval from the DB
            var arrValues = Session("arr_" + sField);
            if (arrValues != null)
            {
//Response.Write("<br>arr_" + sField + " was found.  " + arrValues.length + " items.");
                // copy the values into a new array otherwise any chnages will be added immediately
                // to the arr stored on the session (such as arrValues[<ndx>] = "0~~";)
                arrTempValues = new Array();
                for (ndx=0; ndx<arrValues.length; ndx++)    
                {
                    arrTempValues[ndx] = arrValues[ndx] 
                }
                arrValues = arrTempValues;
                Session("arrTemp_" + sField) = arrValues;
            }
            else
            { 
//Response.Write("<br>Loading from database.");
                // try the database for values
                arrValues = new Array();
                // look to the database
                sSQLSelect = "SELECT ";
                sSQLSelectFields = "prfd_FinancialDetailId, prfd_Description, prfd_Amount";
                sSQLFrom = " FROM PRFinancialDetail ";
                sSQLWhere = "WHERE prfd_FinancialId = " + prfd_financialid + " AND prfd_FieldName='" + sField + "' AND prfd_Deleted IS NULL";
                sSQL = sSQLSelect + sSQLSelectFields + sSQLFrom + sSQLWhere;
                recMain = eWare.CreateQueryObj(sSQL)
                recMain.SelectSql();
                
                var ndx = 0
                while(!recMain.eof)
                {
                    arrValues[ndx] = recMain("prfd_FinancialDetailId")+ "~" + recMain("prfd_Description")+ "~" + recMain("prfd_Amount")
                    recMain.NextRecord();
                    ndx = ndx + 1;
                }
                Session("arrTemp_" + sField) = arrValues;
            }
        }
//Response.Write("<br>arrTemp...length: " + arrValues.length);
        var sContent = "<TABLE ID='_tblValues' WIDTH=100% CELLPADDING=0 BORDER=0>";
        sContent += "<tr><td CLASS=ButtonItem colspan=4>&nbsp;To have an entry removed, clear the Amount field. </td></tr>";
        var nTotal = 0;
        var sDescriptionCaption = eWare.GetTrans('ColNames', 'prfd_Description');
        var sAmountCaption = eWare.GetTrans('ColNames', 'prfd_Amount');
        // add an extra entry for the empty row
        if (arrValues.length == 0)
        {
            arrValues[0] = "0~~";
        }
        else
        {
            // check the last value to see if it is blank.  If it is not, add another
            detailValues = arrValues[arrValues.length-1].split("~");
	        sFinancialDetailId = detailValues[0];
	        sDescription = detailValues[1];
	        sAmount = detailValues[2];
	        if (sDescription != "" || sAmount != "")
                arrValues[arrValues.length] = "0~~";
        }

        for (ndx=0; ndx<arrValues.length; ndx++)    
        { 
	        sContent += "<tr>";
            detailValues = arrValues[ndx].split("~");
	        sFinancialDetailId = detailValues[0];
	        sDescription = detailValues[1];
	        sAmount = detailValues[2];
        	nAmount = parseInt(sAmount);

	        sContent += "<input type=hidden name=_txtFDId_" + ndx + " type=text value=" + sFinancialDetailId + ">";
	        sContent += "<td class=VIEWBOXCAPTION align=left width=50>" + sDescriptionCaption + ": </td>";
	        sContent += "<td class=VIEWBOXCAPTION width='50%' align=left>";
	        sContent += "    <input name=_txtDescription_" + ndx + " type=text CLASS=EDIT align=left value='" + sDescription + "'></td>";

	        sContent += "<td class=VIEWBOXCAPTION align=left width=50>" + sAmountCaption + ": </td>";
	        sContent += "<td class=VIEWBOXCAPTION width='50%' align=left>";
	        sContent += "    <input name=_txtAmount_" + ndx + " type=text CLASS=EDIT align=left onchange='onAmountChange();' onkeypress='return onAmountKeyPress();' value=" + sAmount + ">";
	        sContent += "</td>";
	        sContent += "</tr>";
	        if ( !isNaN(nAmount))
	            nTotal = nTotal + nAmount;
        }

        sContent += "<input type=hidden name=SubmitAction value=>";

        //sContent += "<tr><td colspan=4>&nbsp;</td></tr>";
        sContent += "<tr><td colspan=2>&nbsp;</td><td ALIGN=RIGHT CLASS=VIEWBOXCAPTION>Total: </td>";
        sContent += "<td CLASS=VIEWBOX>";
        sContent += "    <input type=hidden name=_txtTotal value=" + nTotal + ">" 
        sContent += "    <span ID=_spnTotal>"+ nTotal + "</span>";
        sContent += "</td>";
        sContent += "</tr>";
	    sContent += "</table>";


        sPanel = createAccpacBlockHeader(sPanelName, sPanelName, 400);
        sPanel += sContent;
        sPanel += createAccpacBlockFooter(); 
        blkContent.contents = sPanel;

        cntMain.AddBlock(blkContent);
        cntMain.CheckLocks = false;
        cntMain.DisplayButton(1) = false;

        // Add Buttons
	    cntMain.AddButton(eWare.Button("Apply Changes", "saveandnew.gif", "javascript:apply();"));
	    cntMain.AddButton(eWare.Button("New Entry", "new.gif", "javascript:newEntry()"));
        sCancelUrl = changeKey(sURL, "em", "95");
        cntMain.AddButton(eWare.Button("Cancel", "cancel.gif", "javascript:location.href='"+sCancelUrl+"';"));
	    eWare.AddContent(cntMain.Execute());

        Response.Write(eWare.GetPage());
    }
%>
<!-- #include file="../PRCompany/CompanyFooters.asp" -->

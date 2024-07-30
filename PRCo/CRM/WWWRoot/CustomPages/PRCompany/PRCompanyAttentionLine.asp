<!-- #include file ="..\accpaccrm.js" -->
<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2010-2022

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
<!-- #include file ="CompanyHeaders.asp" -->
<%

    if (eWare.Mode == 99) {
        addCompanyChangeRecord(comp_companyid, user_userid);
        eWare.Mode = View;
        Response.Write("<script>alert('This company\\'s data will be sent to MAS shortly.');</script>");
    }

    Response.Write("<link rel=\"stylesheet\" href=\"../../prco.css\">");

    sClass = "ROW2";
    var buffer = "";
    var sql = "SELECT Capt_US, OrderedCount, AttnLineCount FROM dbo.ufn_OrderAttentionLineCounts({0}) INNER Join Custom_Captions ON Item = Capt_Code and Capt_Family = 'prattn_ItemCode' WHERE OrderedCount <> AttnLineCount";
    var qry = eWare.CreateQueryObj(sql.replace("{0}", comp_companyid));
    qry.SelectSQL();
    while (!qry.eof) {
        if (sClass == "ROW2") {
            sClass = "ROW1";
        } else {
            sClass = "ROW2";
        }

        buffer += "<tr class=" + sClass + "><td>";
        buffer += qry("Capt_US");
        buffer += "</td><td align=right>"
        buffer += qry("OrderedCount");
        buffer += "</td><td align=right>"
        buffer += qry("AttnLineCount");
        buffer += "</td></tr>"
        qry.NextRecord();
    }

    if (buffer != "") {
        blkContent = eWare.GetBlock("Content");
        blkContent.Contents += "<table width=100% ><tr><td>";
        blkContent.Contents += "<div style=text-align:center class=MessageContent>The following attention line codes are not in sync with the ordered services.</div>";
        blkContent.Contents += "<table class=CONTENT align=center style=margin-left:auto;margin-right:auto;margin-top:10px; border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff>";
        blkContent.Contents += "<tr><td class=GRIDHEAD>Item Type</td><td class=GRIDHEAD>Ordered Count</td><td class=GRIDHEAD>Attn Line Count</td></tr>"
        blkContent.Contents += buffer + "</table>";
        blkContent.Contents += "</td></tr></table>";
        blkContainer.AddBlock(blkContent);
    }

    var lstCorrespondenceAttnLines = eWare.GetBlock("PRCompanyAttentionLineGrid");
    lstCorrespondenceAttnLines.Title = "Correspondence Attention Lines";
    lstCorrespondenceAttnLines.prevURL = eWare.URL(f_value);
    lstCorrespondenceAttnLines.PadBottom = false;
    var recCorrespondenceAttnLines = eWare.FindRecord("vPRCompanyAttentionLine", "prattn_CompanyID=" + comp_companyid + " AND prattn_ItemCode IN ('BILL', 'JEP-E', 'JEP-M', 'LRL', 'TES-E', 'TES-M', 'TES-V', 'ARD', 'BBSICC', 'ADVBILL')") ;
    lstCorrespondenceAttnLines.ArgObj = recCorrespondenceAttnLines;    
    blkContainer.AddBlock(lstCorrespondenceAttnLines);

    var lstServiceAttnLines = eWare.GetBlock("PRCompanyAttentionLineGrid");
    lstServiceAttnLines.Title = "Service Attention Lines";
    lstServiceAttnLines.prevURL = eWare.URL(f_value);
    lstServiceAttnLines.PadBottom = false;
    var recServiceAttnLines = eWare.FindRecord("vPRCompanyAttentionLine", "prattn_CompanyID=" + comp_companyid + " AND prattn_ItemCode IN ('BOOK-APR', 'BOOK-OCT', 'BOOK-UNV', 'BOOK-F', 'BPRINT', 'KYCG')") ;    
    lstServiceAttnLines.ArgObj = recServiceAttnLines;    
    blkContainer.AddBlock(lstServiceAttnLines);

    tabContext = "&T=Company&Capt=Contact+Info";
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", eWare.Url("PRCompany/PRCompanyContactInfoListing.asp") + tabContext));
    //blkContainer.AddButton(eWare.Button("Create Manual Shipment", "new.gif", eWare.Url("PRCompany/PRCompanyManualShipment.aspx") + "&user_userid=" + eWare.getContextInfo('User', 'User_UserId')));
    blkContainer.AddButton(eWare.Button("Create Manual Shipment", "edit.gif", eWare.URL("PRCompany/PRCompanyIFrame.asp") + tabContext + "&FrameURL=" + Server.URLEncode("PRCompanyManualShipment.aspx?Key1=" + Request.QueryString("Key1"))));
    blkContainer.AddButton(eWare.Button("Send to MAS", "continue.gif", changeKey(sURL, "em", "99")));

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage('Company'));
%>
<!-- #include file="CompanyFooters.asp" -->
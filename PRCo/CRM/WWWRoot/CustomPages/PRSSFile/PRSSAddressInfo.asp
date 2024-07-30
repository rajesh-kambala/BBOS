<!-- #include file ="..\accpaccrm.js" -->
<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2012

  The use, disclosure, reproduction, modification, transfer, or  
  transmittal of  this work for any purpose in any form or by any 
  means without the written permission of Produce Report Company is 
  strictly prohibited.
 
  Confidential, Unpublished Property of Produce Report Company.
  Use and distribution limited solely to authorized personnel.
 
  All Rights Reserved.
 
  Notice:  This file was created by Travant Solutions, Inc.  Contact
  by e-mail at info@travant.com.
 
***********************************************************************
***********************************************************************/
%>
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../AccpacScreenObjects.asp" -->
<%
var SID = getIdValue("SID");
var prss_ssfileid = getIdValue("prss_ssfileid");
var nContactsPerLine = 4;
doPage();

function doPage()
{
    eWare.Mode = View;

    Response.Write("<script type=\"text/javascript\" src=\"../PRCoGeneral.js\"></script>"); 

    recSSFile = eWare.FindRecord("PRSSFile", "prss_ssfileid="+ prss_ssfileid);

    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;
    
    blkMain=eWare.GetBlock("Content");
    sAddressContent = createAccpacBlockHeader("AddressInfo", "Address Info"); 
    
    // CLAIMANT INFO
    prss_claimantcompanyid = recSSFile("prss_ClaimantCompanyId");
    sAddressContent += getAddressBlock(prss_claimantcompanyid , "Claimant");

    // RESPONDENT INFO
    prss_respondentcompanyid = recSSFile("prss_RespondentCompanyId");
    sAddressContent += getAddressBlock(prss_respondentcompanyid , "Respondent");
    // 3RD PARTY INFO
    prss_3rdpartycompanyid = recSSFile("prss_3rdPartyCompanyId");
    sAddressContent += getAddressBlock(prss_3rdpartycompanyid, "3rd Party");

    sAddressContent += createAccpacBlockFooter(); 
    blkMain.contents = sAddressContent;

    sListingAction = eWare.Url("PRSSFile/PRSSFile.asp")+ "&prss_ssfileid="+ prss_ssfileid;
    blkContainer.AddButton(eWare.Button("Continue", "continue.gif", sListingAction));

    sContactAction = eWare.Url("PRSSFile/PRSSContact.asp") + "&prss_ssfileid="+ recSSFile("prss_ssfileid");
    blkContainer.AddButton(eWare.Button("Add Contact", "new.gif", sContactAction));


    blkContainer.AddBlock(blkMain);

    eWare.AddContent(blkContainer.Execute());

    Response.Write(eWare.GetPage());
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
}

function getAddressBlock(sCompanyId, sCaption){
    var sReturnContent = "<table width=\"100%\" style=\"margin-top:15px;\"><TR class=InfoContent>" +
                "<TD COLSPAN=10 ALIGN=LEFT > " + sCaption + " Addresses </TD></TR></table>";
    if (isEmpty(sCompanyId))
    {
        sReturnContent += "<table><TR class=VIEWBOX>"+
                    "<TD COLSPAN=10 ALIGN=LEFT > -- No " + sCaption + " Company Selected -- </TD></TR></table>"
    }
    else
    {
        sql = "select prssc_SSContactId, prssc_IsPrimary, dbo.ufn_getSSContactMailingLabel(prssc_SSContactId, '<br/>') as MailingLabel, dbo.ufn_getSSContactMailingLabel(prssc_SSContactId, '_NEWLINE_') as ClipboardLabel" 
             + " FROM PRSSContact WITH (NOLOCK) " 
             + " WHERE prssc_ssfileid = " + prss_ssfileid + " and prssc_CompanyId = " + sCompanyId 
             + " order by prssc_IsPrimary Desc ";
        qryPersons = eWare.CreateQueryObj(sql);
        qryPersons.SelectSql();

        nCount = 0;
        if (qryPersons.eof){
            sReturnContent += "<table><TR class=VIEWBOX>"+
                    "<TD COLSPAN=10 ALIGN=LEFT > -- No " + sCaption + " Contacts Selected -- </TD></TR></table>"
        } else {
            sReturnContent += "\n<table><tr>\n";
            while (!qryPersons.eof)
            {
                sMailingLabel = "<A CLASS=ButtonItem HREF=\"/"+ sInstallName + "/CustomPages/PRSSFile/PRSSContact.asp?SID="+ SID + 
                        "&F=PRSSFile/PRSSAddressInfo.asp&prss_ssfileid="+prss_ssfileid+"&prssc_sscontactid="+qryPersons("prssc_SSContactId")+"\">" +
                        "<IMG SRC=\"/"+ sInstallName + "/img/Buttons/smallupdate.gif\" BORDER=0 ALIGN=MIDDLE></A>";

                sDeleteUrl = "/"+ sInstallName + "/CustomPages/PRSSFile/PRSSContact.asp?SID="+ SID + 
                        "&F=PRSSFile/PRSSAddressInfo.asp&em=3&prss_ssfileid="+prss_ssfileid+"&prssc_sscontactid="+qryPersons("prssc_SSContactId");

                sDeleteAction = "javascript:if (confirm('Are you sure you want to permanently delete this contact?')) {location.href='" + sDeleteUrl + "';}";

                sMailingLabel += "&nbsp;&nbsp;<A CLASS=ButtonItem HREF=\"" + sDeleteAction +"\">" +
                        "<IMG SRC=\"/"+ sInstallName + "/img/Buttons/smalldelete.gif\" BORDER=0 ALIGN=MIDDLE></A>";
                if (qryPersons("prssc_IsPrimary") == 'Y')
                    sMailingLabel += "&nbsp;&nbsp;&nbsp;<b>Primary</b>" ; 

                var address = qryPersons("ClipboardLabel").replace(/'/g, "\\'");
                var clipboard = "&nbsp;&nbsp;&nbsp;<a style=\"font-size:9pt\" href=\"javascript:CopyStringToClipboard('" + address + "')\" title=\"This copies the address to the clipboard.\">(Copy to Clipboard)</a>";
                sMailingLabel += clipboard;

                sMailingLabel += "<br/>" + qryPersons("MailingLabel");


               
                sReturnContent += "<td VALIGN=TOP style=\"padding-right:25px;\" ><SPAN class=VIEWBOX>" + sMailingLabel + "\</td>\n";
                if (nCount%nContactsPerLine == (nContactsPerLine-1))
                {
                    sReturnContent += "</tr><tr>\n"
                }
                nCount = nCount+1;
                qryPersons.NextRecord();
            }
            sReturnContent += "</tr></table>\n";
        }
    }
    return sReturnContent;
}

%>

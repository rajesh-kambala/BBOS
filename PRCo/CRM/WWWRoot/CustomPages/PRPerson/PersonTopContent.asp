<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2018

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


function GeneratePersonTopContent() {
   
    var sSID = new String(Request.Querystring("SID"));
    var sUniqueQueryParams = new String("&" + Request.Querystring);

    // remove known keys
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "SID");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "F");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "J");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key0");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key1");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key2");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "comp_companyid");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "pers_personid");

    if (pers_personid != -1)
    {
%>
    <!-- #include file ="PersonTrxInclude.asp" -->
<%

        //sSQL = "SELECT * FROM vPRListPerson WHERE peli_PRStatus IN (1,2) pers_personid = " + pers_personid;
        sSQL = "SELECT TOP 3 prcse_FullName, dbo.ufn_FormatPerson(Pers_FirstName, Pers_LastName, Pers_MiddleName, Pers_PRNickname1, Pers_Suffix)  AS Pers_FullName, peli_CompanyID, pers_personid, comp_PRLocalSource, pers_PRMMWID " +
                 "FROM Person WITH (NOLOCK) " + 
                      "LEFT OUTER JOIN Person_Link WITH (NOLOCK) on pers_PersonID = peli_PersonID AND peli_PRStatus IN (1,2) " +
                      "LEFT OUTER JOIN Company WITH (NOLOCK) on comp_CompanyID = peli_CompanyID " +
                      "LEFT OUTER JOIN PRCompanySearch WITH (NOLOCK) on prcse_CompanyID = peli_CompanyID  " +
                "WHERE pers_PersonID = " + pers_personid;
        
        qryPerson = eWare.CreateQueryObj(sSQL);
        qryPerson.SelectSQL();
        
        var sPersonFullName = ""; 
        var sLocalSource = ""
        var sCompany1Link = "-"; 
        var sCompany2Link = ""; 
        var sCompany3Link = ""; 
        if (!qryPerson.eof)
        {
            sPersonFullName = qryPerson("pers_FullName");
        }
        while (!qryPerson.eof)
        {
            sCompanyId = qryPerson("peli_CompanyID");
            if (!isEmpty(sCompanyId))
            {
                
                sCompanyName = qryPerson("prcse_FullName");

                // Remove the Key0 and Key2 if we're going
                // back to the company page.  This removes our
                // person context.                
                //var sURL = eWare.URL("PRCompany/PRCompanySummary.asp") + "&comp_companyid=" + sCompanyId;
                var sURL = eWare.URL("PRCompany/PRCompanySummary.asp");
                sURL = changeKey(sURL, "Key0", "1");
                sURL = changeKey(sURL, "Key1", sCompanyId);
                sURL = removeKey(sURL, "Key2");
                sURL = removeKey(sURL, "Key58");
                
                if (eWare.Mode == Edit)
                    szLink = sCompanyName + "&nbsp;("+ sCompanyId + ")";
                else
                    szLink = "<a href=\"" + sURL + "\" onclick=\"this.disabled=true;\" >" + sCompanyName + "</a>";
                
                if (qryPerson("comp_PRLocalSource") == "Y") {
                    szLink += " - <span style='color:red;'>Local Source</span>";
                    sLocalSource = " - <span style='color:red;'>Local Source</span>";
                }

                if (sCompany1Link == "-") {
                    sCompany1Link = szLink;
                } else if (sCompany2Link == "") {
                    sCompany2Link = szLink;
                } else if (sCompany3Link == "") {
                    sCompany3Link = szLink;
                    break;
                }
            }
            qryPerson.NextRecord();
        }

        //determine the appropriate transaction link
        var sTransactionLink = "&nbsp;";


        //var sCurrPage = new String(Request.QueryString("F"));
        var sCurrPage = String(Request.ServerVariables("URL"));
        // hide the transaction links if we are on the transaction page
        nTrxPage = sCurrPage.indexOf("PRTransaction.asp");
        if (nTrxPage == -1 && eWare.Mode != Edit)
        {
            var sTrxAction = null;
            var sFValue = Request.QueryString("F");
            if (!Defined(sFValue) || sFValue == null || sFValue == "undefined" ) {
                sFValue = "";
            }

            if (iTrxStatus == TRX_STATUS_NONE)
            {
                sUniqueQueryParams = removeKey(sUniqueQueryParams, "em");
                sTransactionLink = "<a href=\"" + eWare.URL("PRTransaction/PRTransaction.asp")+"&pers_personid="+pers_personid + "&PrevCustomUrl=" + sFValue + sUniqueQueryParams +
                                "\" onclick=\"this.disabled=true;\" >Open Transaction</a>";
                
            }
            else if (iTrxStatus == TRX_STATUS_EDIT)
            {
                sTransactionLink = "<a href=\"javascript:parent.location.reload();\" onclick=\"this.disabled=true;confirmCloseTransaction('" +
                        eWare.URL("PRTransaction/PRTransaction.asp") + "&em=51&prtx_TransactionId=" + recTrx("prtx_TransactionId") + "');\"" +
                        ">Close Transaction</a>";
            }
        }
    }
%>
    <script type="text/javascript" src="../PRTransaction/PRTransactionClose.js"></script>
<%
    var topContent = "";

    topContent += "<table style=\"width:100%;padding-right:50px !important;\" cellpadding=0 cellspacing=0 border=0>\n";
    topContent += "<tr>\n";
    topContent += "\t<td style=\"width:50px;text-align:left;\">\n";
    topContent += "\t\t<img src=\"/" + sInstallName + "/Themes/img/color/Icons/Person.png\" hspace=\"0\" border=\"0\" align=\"top\" />\n";
    topContent += "\t</td>\n";

    topContent += "<td class=\"TOPHEADING FavIcon\"><img title=\"Add to favourites\" align=\"TOP\" id=\"FavouritesRecordIcon\" onclick=\"SageCRM.ErgonomicTheme.updateFavourites();\" alt=\"Add to favourites\" src=\"/crm/Themes/img/ergonomic/Icons/favourites-addto.png\" border=\"0\" hspace=\"0\"></td>\n";
    topContent += "<td id=\"FavEntityId\" style=\"display: none;\">13</td>\n";
    topContent += "<td id=\"FavRecordId\" style=\"display: none;\">" + pers_personid + "</td>\n";


    topContent += "\t<td align=\"left\" valign=\"middle\" style=\"100% !important\" width=100% >\n";
    topContent += "\t<div>\n";

    topContent += "\t\t<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" style=\"100% !important\" width=100% >\n";

    if (pers_personid == -1)
    {
        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td width=\"250px\" rowspan=\"4\" align=\"left\" class=\"topheading\">New Person:</td>\n";
        topContent += "\t\t</tr>\n";

    } else {

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td align=\"right\" width=\"100px\" class=\"TOPCAPTION\">Person&nbsp;Name:</td>\n";
        topContent += "\t\t\t<td align=\"left\" width=\"100%\" class=\"TOPSUBHEADING\">&nbsp; " + sPersonFullName + " (" + pers_personid + ")" + sLocalSource + "</td>\n";
        topContent += "\t\t</tr>\n";

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td align=\"right\" width=\"100px\" class=\"TOPCAPTION\">Company:</td>\n";
        topContent += "\t\t\t<td align=\"left\" class=\"TOPSUBHEADING\">&nbsp;" + sCompany1Link + "</td>\n";
        topContent += "\t\t</tr>\n";

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td align=\"right\" width=\"100px\" class=\"TOPCAPTION\">Company 2:</td>\n";
        topContent += "\t\t\t<td align=\"left\" class=\"TOPSUBHEADING\">&nbsp;" + sCompany2Link + "</td>\n";
        topContent += "\t\t</tr>\n";

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td align=\"right\" width=\"100px\" class=\"TOPCAPTION\">Company 3:</td>\n";
        topContent += "\t\t\t<td align=\"left\" class=\"TOPSUBHEADING\">&nbsp;" + sCompany3Link + "</td>\n";
        topContent += "\t\t\t<td style=\"white-space: nowrap;padding-right:10px;\" class=\"TOPCAPTION\">" + sTransactionLink + "</td>\n";
        topContent += "\t\t</tr>\n";

        topContent += "\t\t</table>\n";
        topContent += "\t</td>\n";
        topContent += "\t</tr>\n";
    }

    topContent += "</table>\n";
    topContent += "\t</div>\n";
    return topContent;
}
%>



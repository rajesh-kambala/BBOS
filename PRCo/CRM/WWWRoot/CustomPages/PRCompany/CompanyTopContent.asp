<%
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2021

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

function GenerateCompanyTopContent() {

    var sSID = String(Request.Querystring("SID"));
    var sUniqueQueryParams = String("&" + Request.Querystring);
    // remove known keys
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "SID");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "F");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "J");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key0");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key1");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "Key2");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "comp_companyid");
    sUniqueQueryParams = removeKey(sUniqueQueryParams, "pers_personid");
    DEBUG(sUniqueQueryParams);

    var sFullName = "";
    var isMember = false;
    var hasWarnings = false;

    if (comp_companyid != -1)
    {
        vPRCompany = eWare.FindRecord("vPRCompany", "comp_companyid="+comp_companyid);
        sFullName = new String(vPRCompany.prcse_FullName).replace(/'/g, "\\'");

        var bShowCompanyPhone = Session("bShowCompanyPhone");
        Session("bShowCompanyPhone") = null;
        
        if (bShowCompanyPhone == "1") {
            qryPhone = eWare.CreateQueryObj("SELECT dbo.ufn_FormatPhone(phon_CountryCode, phon_AreaCode, phon_Number, phon_PRExtension) As Phone FROM vPRCompanyPhone WITH(NOLOCK) WHERE plink_recordid=" + comp_companyid + " AND phon_PRIsPhone='Y' AND phon_PRPreferredInternal='Y'"); 
            qryPhone.SelectSQL();
            sCompanyPhone = "";
            if(!qryPhone.eof)
            {
                sCompanyPhone = qryPhone("Phone");
            }
        } 
        
        sRating = vPRCompany.prra_RatingLine;
        if (isEmpty(sRating))
            sRating = "-";
        sCompanyName = vPRCompany.comp_Name;
        if (isEmpty(sCompanyName))
            sCompanyName = "-";
        else
        { 
            // need to escape apostrophes or the write to the new frame will fail.
            if (sCompanyName.indexOf("'") > 0) 
                sCompanyName = sCompanyName.replace("'","&#39;");
        }
            
        sBlueBookScore = vPRCompany.prbs_BBScore;
        if (isEmpty(sBlueBookScore))
            sBlueBookScore = "-";

        sPublishBBScore = vPRCompany.comp_PRPublishBBScore;
        if (isEmpty(sPublishBBScore))
            sBlueBookScore = 'N/A';

        sListing = "";
        sListingCity = vPRCompany.prci_City;
        sListingState = vPRCompany.prst_State;
        if (isEmpty(sListingCity) && isEmpty(sListingState))
            sListingCity = "-";
        else
        {
            if (isEmpty(sListingCity) )
                sListing = sListingState;
            else if (isEmpty(sListingState) )
                sListing = sListingCity;
            else
                sListing = sListingCity + ",&nbsp;" + sListingState             
        }
                
        sType = vPRCompany.comp_PRType;
        if (isEmpty(sType))
            sType = "-";
        else if (sType == "H")
            sType = "Headquarter";    
        else if (sType == "B" )
            sType = "Branch";
        else
            sType = "";
        // Per Defect 746: adding the industry type to the Type display
        sIndustryType = vPRCompany("comp_PRIndustryType");
        var sIndustryTypeDesc = "";
        if (!isEmpty(sIndustryType))
            sIndustryTypeDesc = eWare.GetTrans("comp_PRIndustryType", sIndustryType);

        sType += " - " + sIndustryTypeDesc;
            

        if (vPRCompany("comp_PROnlineOnly") == "Y") {
            sType += " - Online Only";
        }


        if (vPRCompany("comp_PRLocalSource") == "Y") {
            sType += " - <span style='color:red;'>Local Source</span>";
        }

        sTMAward = vPRCompany.comp_PRTMFMAward;
        sTMDate = vPRCompany.comp_PRTMFMAwardDate;
        if (isEmpty(sTMAward) || sTMAward == "N")
            sTMDate = "-";
        else
        {
            if (isEmpty(sTMDate))
                sTMDate = "-";
            else
                sTMDate = getDateAsString(sTMDate);
        }
        
        sListingStatusDesc = vPRCompany.capt_ListingStatusDesc;
        if (isEmpty(sListingStatusDesc))
            sListingStatusDesc = "-";

        sViewListingAction = eWare.URL("PRCompany/PRCompanyListingView.asp")+ "&comp_companyid="+comp_companyid;
        sViewListingAction = removeKey(sViewListingAction, "F");
        sViewListingAction = removeKey(sViewListingAction, "J");

        sSendListingAction = eWare.URL("PRCompany/PRCompanyListing.asp")+ "&comp_companyid="+comp_companyid;
        sSendListingAction = removeKey(sSendListingAction, "F");
        sSendListingAction = removeKey(sSendListingAction, "J");

        sSendLRLAction = eWare.URL("PRCompany/PRCompanyLRL.asp")+ "&comp_companyid="+comp_companyid;
        sSendLRLAction = removeKey(sSendLRLAction, "F");
        sSendLRLAction = removeKey(sSendLRLAction, "J");

        
        var qry = eWare.CreateQueryObj("SELECT 'X' FROM PRService WHERE prse_Primary='Y' AND prse_HQID=" + vPRCompany.comp_PRHQID);
        qry.SelectSQL();
        if (!qry.eof) {
            isMember = true;
        }

        var qry = eWare.CreateQueryObj("SELECT COUNT(1) As WarningCount FROM dbo.ufn_GetCompanyMessages(" + comp_companyid +  ", '" + vPRCompany.comp_PRIndustryType + "')");
        qry.SelectSQL();
        if (!qry.eof) {
            if (qry("WarningCount") > 0) {
                hasWarnings = true;
            }
        }
    }   


%>
<!-- #include file ="CompanyTrxInclude.asp" -->
<%

    var sTransactionLink = "";

    // Field reps (7) get browse only
    if (!isUserInGroup("7"))
    {

        if (comp_companyid != -1)
        {

            // F value has PRTransaction.asp when this is the active page
            //var sCurrPage = String(Request.QueryString("F"));
            var sCurrPage = String(Request.ServerVariables("URL"));
            nTrxPage = sCurrPage.indexOf("PRTransaction.asp");

            if ((nTrxPage == -1) && (eWare.Mode != Edit))
            {

                var sTrxAction = null;
                sTrxLink = eWare.URL("PRTransaction/PRTransaction.asp");
                //changeKey(sTrxLink, "F", "F="+sCurrPage);
                if (iTrxStatus == TRX_STATUS_NONE)
                {
                    sUniqueQueryParams = removeKey(sUniqueQueryParams, "em");
                    sTransactionLink = "<a href=\"" + sTrxLink+"&comp_companyid="+comp_companyid+ "&PrevCustomUrl=" + sCurrPage + sUniqueQueryParams +
                                          "\" onclick=\"this.disabled=true;\" >Open Transaction</a>";
                }
                else if (iTrxStatus == TRX_STATUS_EDIT)
                {
                	var sSQL = "SELECT COUNT(1) cnt FROM PRAttentionLine WITH (NOLOCK) WHERE prattn_CompanyID = " + comp_companyid +  " AND prattn_ItemCode <> 'ARD' AND ISNULL(prattn_AddressID, 0) = 0 AND ISNULL(prattn_PhoneID, 0) = 0 AND ISNULL(prattn_EmailID, 0) = 0 AND prattn_Disabled IS NULL";
                    recAttnLines = eWare.CreateQueryObj(sSQL);
                    recAttnLines.SelectSQL()
                    var iBadAttnLineCount = recAttnLines("Cnt");
                    
                    // If we have child transactions, build a link
                    // to display a dialog window.
                    var sSQL = "SELECT COUNT(1) As Cnt " +
                                 "FROM PRTransaction WITH (NOLOCK) " +
                                "WHERE prtx_Status = 'O' " +
                                  "AND prtx_ParentTransactionID =  " + sTxnStatus;

                    recChildTrx = eWare.CreateQueryObj(sSQL);
                    recChildTrx.SelectSQL()
                    var iCount = recChildTrx("Cnt");

                    var popupMsg = "";
                    if (iBadAttnLineCount > 0) {
                        popupMsg = " onclick=\"alert('This company has attention line(s) with missing delivery methods.  Attention lines MUST be assigned before the transaction can be closed.');return true;\"";
                    }

                    if (iCount == 0) {

                        var jsMethod = "confirmCloseTransaction";
                        if (iBadAttnLineCount > 0) {
                            jsMethod = "confirmCloseTransaction2";
                        }
                        
                        sTransactionLink = "<a href=\"javascript:delayRedirect(location);\" onclick=\"this.disabled=true;" + jsMethod + "('" + sTrxLink + "&em=51&prtx_TransactionId=" + sTxnStatus + "');\"" + popupMsg + ">Close Transaction</a>";
                    } else {

                        var sCloseTranastionAction = eWare.URL("PRTransaction/PRTransactionClose.asp") + "&prtx_TransactionId=" + sTxnStatus;
                        sTransactionLink = "<a href=\"javascript:openCloseTranWindow('" + sCloseTranastionAction + "');\"" + popupMsg + ">Close Transaction</a>";
                    }                                
                }
            }
            sCurrPage = null;
        }
    }        
%>
<script type="text/javascript" src="../PRCoGeneral.js"></script>
<script type="text/javascript" src="../PRCompany/ViewReport.js"></script>
<script type="text/javascript" src="../PRTransaction/PRTransactionClose.js"></script>
<script type="text/javascript">
    function openViewListingWindow(szURL) {
        window.open(szURL,
            "winViewListing",
            "location=no,menubar=no,status=no,toolbar=no,scrollbars=no,resizable=no,width=475,height=600", true);
    }

    function openCloseTranWindow(szURL) {
        window.open(szURL,
            "winViewListing",
            "location=no,menubar=no,status=no,toolbar=no,scrollbars=no,resizable=yes,width=600,height=600", true);
    }
    </script>
<style type="text/css">
    .copyLink {
        font-size: 8pt;
        text-decoration: underline
    }
</style>

<% 
    var topContent = "";

    // **Note: sBRRootUrl is defined in ViewReport.js
    var sViewBRAction = eWare.URL("PRCompany/PRCompanyBRReport.aspx");
    var sBRFileVersion = (Request.Form.Item("hdn_brfileversion").Count > 0 ? String(Request.Form.Item("hdn_brfileversion")) : (new Date()).valueOf());
    sViewBRAction = changeKey(sViewBRAction, "BRFileVersion", sBRFileVersion);
    topContent += "<script type=\"text/javascript\">sBRRootUrl = \"" +  sViewBRAction + "\";</script>\n";

    topContent += "<table style=\"width:100%;padding-right:50px !important;\" cellpadding=0 cellspacing=0 border=0>\n";
    topContent += "<tr>\n";
    topContent += "\t<td style=\"text-align:left;\" class=\"TOPHEADING TitleIcon\">\n";

    if (comp_companyid == -1) {
        topContent += "\t\t<img style=\"margin:0;border:0;\" alt=\"\" src=\"/" + sInstallName + "/img/Icons/Company.gif\" align=\"top\" />\n";
    } else { 
        var companyIcon = "";
        if (vPRCompany.comp_PRHasITAAccess == "Y") {
            if (hasWarnings)  
                companyIcon = "Limitado_Icon_Warning.png";
            else 
                companyIcon = "Limitado_Icon.png";

        } else {

            if (isMember) {               
                if (hasWarnings)  
                    companyIcon = "Member_Icon_Warning.png";
                else 
                    companyIcon = "Member_Icon.png";
            } else { 
                if (hasWarnings) 
                    companyIcon = "non_Member_Icon_Warning.png";
                else
                    companyIcon = "non_Member_Icon.png";
            }
        }     

        topContent += "\t\t<a href=\"" + eWareUrl("PRCompany/PRCompanySummary.asp") + "&Key0=1&Key1=" + comp_companyid + "\"><img style=\"margin:0;border:0;width:68px;height:64px;\" alt=\"\" src=\"/" +  sInstallName + "/img/PRCO/" + companyIcon + "\" align=\"top\" /></a>\n";
        //topContent += "\t\t<img style=\"margin:0;border:0;width:68px;height:64px;\" alt=\"\" src=\"/" +  sInstallName + "/img/PRCO/" + companyIcon + "\" align=\"top\" />\n";
    }

    topContent += "\t</td>\n";

    topContent += "<td class=\"TOPHEADING FavIcon\" style=\"vertical-align:top;\"><img title=\"Add to favourites\" align=\"TOP\" id=\"FavouritesRecordIcon\" onclick=\"SageCRM.ErgonomicTheme.updateFavourites();\" alt=\"Add to favourites\" src=\"/crm/Themes/img/ergonomic/Icons/favourites-addto.png\" border=\"0\" hspace=\"0\"></td>\n";
    topContent += "<td id=\"FavEntityId\" style=\"display: none;\">5</td>\n";
    topContent += "<td id=\"FavRecordId\" style=\"display: none;\">" + comp_companyid + "</td>\n";

    topContent += "\t<td align=\"left\" class=\"TOPCONTENTVALUE\" valign=\"middle\" style=\"width:100%;\">\n";
    topContent += "\t<div>\n";
    topContent += "\t\t<table border=\"0\"  cellpadding=\"0\" cellspacing=\"0\" style=\"width:100% !important;\" width=100% >\n";
    if (comp_companyid == -1)
    {
        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td style=\"width:250px\" rowspan=4 align=left class=\"topheading\">New Company</td>\n";
        topContent += "\t\t</tr>";
    } else {
        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\">BB ID#: </td>\n";
        topContent += "\t\t\t<td style=\"text-align:left;width:70%\" class=\"TOPHEADING\">&nbsp;" + comp_companyid + "&nbsp;&nbsp;&nbsp;<a class=\"copyLink\" href=\"javascript:CopyStringToClipboard('" +  sFullName + "')\" title='This copies the company full name, including type and listing location, to the clipboard.'>(Copy to Clipboard)</a></td>\n";
        topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\">Rating: </td>\n";
        topContent += "\t\t\t<td style=\"text-align:left;width:35%\" class=\"TOPHEADING\">&nbsp;" + sRating + "</td>\n";

        if (eWare.Mode == Edit) {
			topContent += "\t\t\t<td class=\"TOPCAPTION\">&nbsp;</td>\n";
		} else {
			topContent += "\t\t\t<td class=\"TOPCAPTION\"><a href=\"javascript:openViewListingWindow('" + sViewListingAction + "');\">View Listing</a></td>\n";
		} 
        topContent += "\t\t</tr>\n";

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\">Name: </td>\n";
        topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sCompanyName + "</td>\n";
        topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\">Blue Book Score: </td>\n";
        topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sBlueBookScore + "</td>\n";

        if ((eWare.Mode == Edit) ||
            (recCompany.comp_PRLocalSource ==  "Y")) {
			topContent += "\t\t\t<td class=\"TOPCAPTION\">&nbsp;</td>\n";
		} else {
			topContent += "\t\t\t<td class=\"TOPCAPTION\" nowrap><a href=\"javascript:viewListing('" + comp_companyid + "', '" + sSendListingAction + "', 'resizable=yes,scrollbars=yes,width=1200');\">Send Listing</a></td>\n"; 
		} 
        topContent += "\t\t</tr>\n";

        if (bShowCompanyPhone == 1)
        {
            topContent += "\t\t<tr>\n";
            topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\">Phone: </td>\n";
            topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sCompanyPhone + "</td>\n";
            topContent += "\t\t\t<td style=\"text-align:right;white-space:nowrap;\"class=\"TOPCAPTION\"></td>\n";
            topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + "" + "</td>\n";

            topContent += "\t\t</tr>\n";
        }

        topContent += "\t\t<tr>\n";
        topContent += "\t\t\t<td class=\"TOPCAPTION\" style=text-align:right;>Listing: </td>\n";
        topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sListing + "</td>\n";
        topContent += "\t\t\t<td class=\"TOPCAPTION\" style=\"text-align:right;white-space:nowrap;\">T/M Since Date: </td>\n";
        topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sTMDate + "</td>\n";

        if ((eWare.Mode == Edit) ||
            (recCompany.comp_PRLocalSource ==  "Y")) {
			topContent += "\t\t\t<td class=\"TOPCAPTION\">&nbsp;</td>\n";
        } else { 
			topContent += "\t\t\t<td class=\"TOPCAPTION\" nowrap><a href=\"javascript:viewListing('" + comp_companyid + "', '" + sSendLRLAction + "', 'resizable=yes,scrollbars=yes,width=1200');\">Send LRL</a></td>\n";
        } 

        topContent += "\t\t</tr>\n";

		topContent += "\t\t<tr>\n";
			topContent += "\t\t\t<td class=\"TOPCAPTION\" style=text-align:right;>Type: </td>\n";
			topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sType + "</td>\n";
			topContent += "\t\t\t<td class=\"TOPCAPTION\" style=\"text-align:right;white-space:nowrap;\">Listing Status: </td>\n";
			topContent += "\t\t\t<td class=\"TOPHEADING\">&nbsp;" + sListingStatusDesc + "</td>\n";
			topContent += "\t\t\t<td class=\"TOPCAPTION\" style=\"white-space:nowrap;padding-right:10px;\">" + sTransactionLink + "</td>\n";
		topContent += "\t\t</tr>\n";
    }

    topContent += "\t\t</table>\n";   
    topContent += "\t</div>\n";
    
	topContent += "\t</td>\n";
	topContent += "</tr>\n";
    topContent += "</table>\n";

    // clean up anything we created in this page
    sSID = null;
    sUniqueQueryParams = null;
    // clean up anything that may possile be open
    vPRCompany = null;

    return topContent;
}
%>



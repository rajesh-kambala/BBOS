<!-- #include file ="../accpaccrm.js" -->
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
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCompany/CompanyIdInclude.asp" -->

<%
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
    DEBUG(sUniqueQueryParams);


    if (comp_companyid != -1)
    {
        vPRCompany = eWare.FindRecord("vPRCompany", "comp_companyid="+comp_companyid);
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
            
        sTMDate = vPRCompany.comp_PRTMFMAwardDate;
        if (isEmpty(sTMDate))
            sTMDate = "-";
        else
            sTMDate = getDateAsString(sTMDate);

        sListingStatusDesc = vPRCompany.capt_ListingStatusDesc;
        if (isEmpty(sListingStatusDesc))
            sListingStatusDesc = "-";


        sViewListingAction = eWare.URL("PRCompany/PRCompanyListing.asp")+ "&comp_companyid="+comp_companyid;
    
        var sCompanyLinkURL = eWare.URL("PRCompany/PRCompanySummary.asp") + "&comp_companyid=" + comp_companyid;
        sCompanyLinkURL = changeKey(sCompanyLinkURL, "Key0", "1");
        sCompanyLinkURL = changeKey(sCompanyLinkURL, "Key1", comp_companyid);
        
        szCompanyLink = "<a target=\"EWARE_MID\" href=\"" + sCompanyLinkURL +
                 "\" class=\"topheading\" onclick=\"this.disabled=true;\" >" + sCompanyName + "</a>";
    
    }
    
%>

<HTML>
<HEAD>
    <LINK REL="stylesheet" HREF="/<%= sInstallName %>/eware.css">
    <SCRIPT language=javascript src="../PRCompany/ViewReport.js"></SCRIPT>
</HEAD>

<BODY CLASS="TOPBODY" VLINK=#003B72 LINK=#003B72 LEFTMARGIN="5" TOPMARGIN="0" >
    <TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0 HEIGHT=99% WIDTH=100%>
    <TR>
        <TD ALIGN=LEFT WIDTH=50><IMG SRC="/<%= sInstallName %>/img/Icons/CreditSheet.gif" HSPACE=0 BORDER=0 ALIGN=TOP></TD>
        <TD ALIGN=LEFT VALIGN=MIDDLE>    
            <TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
<%
    if (comp_companyid == -1)
    {
%>
            <tr>
                <td width="250" rowspan="4" align="left" class="topheading">New Credit Sheet</td>	
            </tr>
<%
    } else {
%>

       <tr>

          <td align="right" width="50" class="topcaption">BB ID#: </td>
          <td align="left" width="300" class="topsubheading">&nbsp;<%= comp_companyid %></td>
          <td align="right" width="125" class="topcaption">Rating: </td>
          <td align="left" width="40%" class="topheading">&nbsp;<%= sRating %></td>

          <td width="100" rowspan="2" class="topcaption"><a href="javascript:viewListing('<%= comp_companyid %>', '<%=sViewListingAction %>');">View Listing</td> 
       </tr>

       <tr>
          <td align="right" width="50" class="topcaption">Name: </td>
          <td align="left" width="300" class="topheading">&nbsp;<%=szCompanyLink %></td>

          <td align="right" width="125" class="topcaption">Blue Book Score: </td>
          <td align="left" width="40%" class="topheading">&nbsp;<%=sBlueBookScore%></td>

       </tr>

       <tr>
          <td align="right" width="50" class="topcaption">Listing: </td>
          <td align="left" width="300" class="topheading">&nbsp;<%=sListing %></td>

          <td align="right" width="125" class="topcaption">T/M Since Date: </td>
          <td align="left" width="40%" class="topheading">&nbsp;<%=sTMDate %></td>
          <td width="100" rowspan="2" class="topcaption">&nbsp;</td>

       </tr>

       <tr>
          <td align="right" width="50" class="topcaption">Type: </td>
          <td align="left" width="300" class="topheading">&nbsp;<%=sType%></td>
          <td align="right" width="125" class="topcaption">Listing Status: </td>
          <td align="left" width="40%" class="topheading">&nbsp;<%=sListingStatusDesc%></td>
       </tr>
<%
    }
%>
    </TABLE>
</BODY>
</HTML>
 
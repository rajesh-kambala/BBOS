<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="..\PRCoGeneral.asp" -->
<!-- #include file ="CompanyIdInclude.asp" -->
<!-- #include file ="..\AccpacScreenObjects.asp" -->
<%
    Server.ScriptTimeout = 1800;
    var iCount = 0;
    var iMaxCount = 10000;
    var bBreak = false;


    var sWorkContent = "";

    var Content01 = "";
    var Content02 = "";
    var Content03 = "";
    var Content04 = "";
    var Content05 = "";
    var Content06 = "";
    var Content07 = "";
    var Content08 = "";
    var Content09 = "";
    var Content10 = "";
    var Content11 = "";
    var Content12 = "";
    var Content13 = "";
    var Content14 = "";
    var Content15 = "";
    var Content16 = "";
    var Content17 = "";
    var Content18 = "";
    var Content19 = "";
    var Content20 = "";

    var sSecurityGroups = "2,3,4,10";


    blkContainer = eWare.GetBlock('container');
    blkContainer.DisplayButton(Button_Default) = false;

    // Need to control the listing better than what accpac provides; therefore 
    // we comment out the get block and use the listing code below
    //lstMain = eWare.GetBlock(sGridName);
    //lstMain.prevURL = eWare.URL(f_value);;

    var sGridName = "PRARTranslationGrid";
    var sAddNewPage = "PRCompany/PRCompanyARTranslation.asp";
    var sEntityCompanyIdName = "prar_CompanyId";
    var sNewCaption = "New";
    var AUSLinkParmaters = "";
    


    // override the default continue location
    praa_ARAgingid = getIdValue("praa_ARAgingId");
    if (praa_ARAgingid == -1)
    {
        sContinueUrl = eWare.URL("PRCompany/PRCompanyARAgingByListing.asp") + "&T=Company&Capt=Trade+Activity";
        sHiddenOrderBy = "prar_CustomerNumber";
    }
    else
    {
        sContinueUrl = eWare.URL("PRCompany/PRCompanyARAgingDetailListing.asp") + "&praa_ARAgingId="+praa_ARAgingid + "&T=Company&Capt=Trade+Activity";
        sHiddenOrderBy = "praad_ARCustomerId";
        AUSLinkParmaters = "&praa_ARAgingId="+praa_ARAgingid;
    }
    
    sHiddenOrderByDesc = "FALSE";
    sPrefixForListing = "prar";
    // sHiddenOrderBy, sHiddenOrderByDesc, and sPrefixForListing need to be defined before using this include
%>
<!-- #include file ="..\SortableTableInclude.asp" -->
<%

    var reportParams = "";

    if (praa_ARAgingid == -1)
    {
        recViewResults = eWare.FindRecord("vPRARTranslation", "prar_CompanyId="+ comp_companyid);
        recViewResults.OrderBy = sOrderByClause;

        reportParams = "CompanyID=" + comp_companyid
    }
    else
    {
        sSQL = "SELECT praad_ARCustomerId, praad_FileCompanyName, praad_FileCityName, praad_FileStateName, " +
                      "prar_ARTranslationId, prar_CompanyId, prar_CustomerNumber, prar_PRCoCompanyId, " +
                      "prar_PRCoCompanyName, ISNULL(FirstLeadID, FirstLeadID2) as FirstLeadID, ListingStatus, Type " +
                 "FROM PRARAgingDetail WITH (NOLOCK)  " +
  	                  "INNER JOIN PRARAging ON praa_ARAgingID = praad_ARAgingId " +
                      "LEFT OUTER JOIN vPRARTranslation vPR ON praad_ARCustomerId = prar_CustomerNumber AND prar_CompanyID=" + comp_companyid +
		                  "LEFT OUTER JOIN (SELECT AssociatedCompanyID, CustomerNumber, MIN(LeadID) as FirstLeadID2 " +
							                           "FROM LumberLeads.dbo.Lead  " +
 						                            "WHERE Status = 'Closed: Non-Factor' " +
							                            "AND Source = 'Unmatched AR' " +
						                         "GROUP BY AssociatedCompanyID, CustomerNumber) T1 ON praa_CompanyId = AssociatedCompanyID " +
																		                                                 "AND praad_ARCustomerID = CustomerNumber " +
		           "WHERE praad_ARAgingId = " + praa_ARAgingid + 
			          "AND praad_ARCustomerId IS NOT NULL " +
              " ORDER BY " + sOrderByClause;

        //Response.Write("<p>" + sSQL + "</p>");    
        //Response.End();

        recViewResults = eWare.CreateQueryObj(sSQL);
        recViewResults.SelectSQL();

        reportParams = "ARAgingID=" + praa_ARAgingid
    }
    blkContainer.AddBlock(blkSort);    
    

    Response.Write("<script type=\"text/javascript\" src=\"ViewReport.js\"></script>")

    sClass="ROW1";
    lstMain = eWare.GetBlock("content");
    sContent = createAccpacBlockHeader("Translations", recViewResults.RecordCount+ " A/R Translations");
    sContent = sContent + "\n    <TABLE CLASS=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff width='100%'>";

    sContent = sContent + "\n        <tr>";
    if (praa_ARAgingid == -1)
        sContent += addSortableGridHeader("prar_CustomerNumber", "Customer Number", "100", "align=\"left\"");  
    else {
        sContent += addSortableGridHeader("praad_ARCustomerId", "Customer Number", "100", "align=\"left\"");  
        sContent += addSortableGridHeader("praad_FileCompanyName", "Company Name", "200", "align=\"left\"");  
        sContent += addSortableGridHeader("praad_FileCityName", "City", "100", "align=\"left\"");  
        sContent += addSortableGridHeader("praad_FileStateName", "State", "50", "align=\"left\"T");  
    }
    
    sContent += addSortableGridHeader("prar_PRCoCompanyId", "BBSi<br/>Company ID", "100", "align=\"left\"");  
    if (praa_ARAgingid != -1)
    {
        sContent += addSortableGridHeader("prar_PRCoCompanyName", "BBSi Company Name", "200", "align=\"left\"");  
        sContent += addSortableGridHeader("ListingStatus", "Listing Status", "200", "");  
        sContent += addSortableGridHeader("Type", "Type", "100", "");  
        sContent += "\n<td  class=\"GRIDHEAD\" align=\"center\">Assign</td>";
        sContent += "\n<td  class=\"GRIDHEAD\" align=\"center\">Non-Factor</td>";
    }
    else
    {
        sContent += addSortableGridHeader("prar_PRCoCompanyName", "BBSi Company Name", "200", "ALIGN=LEFT COLSPAN=2");  
        sContent += addSortableGridHeader("ListingStatus", "Listing Status", "200", "");
        sContent += addSortableGridHeader("Type", "Type", "100", "");  
    }
    sContent = sContent + "\n        </tr>";
    
    if (recViewResults.RecordCount == 0)
    {
        sContent = sContent + "\n        <tr>";
        sContent = sContent + "\n            <td colspan=\"8\" align=\"CENTER\" class=" + sClass + " >" +
                        "No A/R Translations were found." + "</td>";
        sContent = sContent + "\n        </tr>";
    }
    else
    {
        sEditUrl = eWare.URL("PRCompany/PRCompanyARTranslation.asp") + "&T=Company&Capt=Trade+Activity";
        while (!recViewResults.eof)
        {
            sWorkContent += "\n        <TR>";
            sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" 
            if (praa_ARAgingid == -1)
            {
                sWorkContent += "<a HREF=\""+ sEditUrl+"&prar_ARTranslationId="+ recViewResults("prar_ARTranslationId") + "\">" 
                         + recViewResults("prar_CustomerNumber") + "</a>";
            }
            else
            {
                if (isEmpty(recViewResults("prar_PRCoCompanyId")) )
                    sWorkContent += recViewResults("praad_ARCustomerId");
                else
                    sWorkContent += "<a HREF=\""+ sEditUrl
                             +"&prar_ARTranslationId="+ recViewResults("prar_ARTranslationId") 
                             +"&praa_ARAgingId="+ praa_ARAgingid
                             + "\">" + recViewResults("praad_ARCustomerId") + "</a>";
            }
            sWorkContent += "</td> ";
            
            
            if (praa_ARAgingid != -1) {
                sWorkContent += "\n<td align=\"left\" class=" + sClass + " >"  + recViewResults("praad_FileCompanyName") + "</td>";
                sWorkContent += "\n<td align=\"left\" class=" + sClass + " >"  + recViewResults("praad_FileCityName") + "</td>";
                sWorkContent += "\n<td align=\"left\" class=" + sClass + " >"  + recViewResults("praad_FileStateName") + "</td>";
            }
            
            
            sTemp = recViewResults("prar_PRCoCompanyId");
            sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";
            sTemp = recViewResults("prar_PRCoCompanyName");
            if (praa_ARAgingid == -1)
            {
                sWorkContent += "\n            <td colspan=2 align=LEFT class=" + sClass + " >" +(isEmpty(String(sTemp))?"":sTemp) + "</td> ";
                sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" + (isEmpty(String(recViewResults("ListingStatus"))) ? "": recViewResults("ListingStatus")) + "</td>";
                sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" + (isEmpty(String(recViewResults("Type"))) ? "": recViewResults("Type")) + "</td>";
            }
            else
            {
                sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" + (isEmpty(String(sTemp))?"":sTemp) + "</td> ";
                sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" + (isEmpty(String(recViewResults("ListingStatus"))) ? "": recViewResults("ListingStatus")) + "</td>";
                sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >" + (isEmpty(String(recViewResults("Type"))) ? "": recViewResults("Type")) + "</td>";
                if (isEmpty(recViewResults("prar_PRCoCompanyId")))
                {
                    sWorkContent += "\n            <td align=CENTER class=" + sClass + " >" 
                            + "<a href=\""+ sEditUrl+"&prar_CustomerNumber="+ Server.URLEncode(recViewResults("praad_ARCustomerId"))
                            +"&praa_ARAgingId=" + praa_ARAgingid  
                            +"&CompanyName=" + Server.URLEncode(recViewResults("praad_FileCompanyName"))
                            +"&CompanyCity=" + Server.URLEncode(recViewResults("praad_FileCityName"))
                            +"&CompanyState=" + Server.URLEncode(recViewResults("praad_FileStateName")) + "\">" 
                            + "Assign</a></td> ";
                }
                else
                    sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >&nbsp;</td> ";

               
                if (isEmpty(recViewResults("FirstLeadID")))
                {
                    sWorkContent += "\n            <td align=\"left\" class=" + sClass + " >&nbsp;</td> ";
                } else {
                    sWorkContent += "\n            <TD ALIGN=CENTER CLASS=" + sClass + " >" + recViewResults("FirstLeadID") + "</td> ";
                }
            }
            sWorkContent = sWorkContent + "\n        </TR>";
            recViewResults.NextRecord();
            if (sClass == "ROW1")
                sClass="ROW2";
            else
                sClass="ROW1";

            iCount++;
            if (iCount >= iMaxCount) {
                bBreak = true
    	    	break;
	        }


            // This is to deal with large numbers of records.  We keep appending to the same string, but since
            // string are immutable, we are allocating memory at an exponential pace, thus the last 500 records
            // can take 10 times as long to process as the first 500 records.  This is purposely not in an array.

	        switch(iCount) {
            	case 500: 
                	Content01 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1000: 
                	Content02 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 1500: 
                	Content03 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2000: 
                	Content04 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 2500: 
                	Content05 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3000: 
                	Content06 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 3500: 
                	Content07 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4000: 
                	Content08 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 4500: 
                	Content09 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 5000: 
                	Content10 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 5500: 
                	Content11 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 6000: 
                	Content12 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 6500: 
                	Content13 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 7000: 
                	Content14 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 7500: 
                	Content15 = sWorkContent;
                        sWorkContent = "";
                        break;
            	case 8000: 
                	Content16 = sWorkContent;
                        sWorkContent = "";
                        break;
	        }

        }
    }
    sContent += Content01 + Content02 + Content03 + Content04 + Content05 + Content06 + Content07 + Content08 + Content09 + Content10 + 
                Content11 +  Content12 +  Content13 +  Content14 +  Content15 +  Content16 + sWorkContent+ "\n</TABLE>";
    if (bBreak) {
	sContent = sContent + "<script>alert('The number of rows exceeds the maximum allowed.  Only " + iMaxCount.toString() + " have been displayed');</script>";
    }

    sContent = sContent + createAccpacBlockFooter();

    lstMain.Contents=sContent;
    blkContainer.AddBlock(lstMain);    

    blkContainer.AddButton(eWare.Button("Continue","continue.gif", sContinueUrl));
    if (isUserInGroup(sSecurityGroups )) {
        blkContainer.AddButton( eWare.Button(sNewCaption,"New.gif", eWare.URL(sAddNewPage)) );

        blkContainer.AddButton( eWare.Button("Add Subject Companies to AUS", "New.gif", eWare.URL("PRCompany/PRCompanyARAgingAUS.asp") + AUSLinkParmaters) );

    }

    var reportURL = getReportServerURL() + "?/Lumber Reports/Unmatched AR Potential Matches&rc:Parameters=false&" + reportParams;
    var btnReport = eWare.Button("Potential Matches Report","componentpreview.gif", "javascript:viewReport('" + reportURL + "');");
    blkContainer.AddButton(btnReport);


    if (!isEmpty(comp_companyid)) 
    {
        eWare.AddContent(blkContainer.Execute(sEntityCompanyIdName + "=" + comp_companyid));
    }

    Response.Write(eWare.GetPage('Company'));
    Response.Write("<link rel=\"stylesheet\" href=\"../../prco_compat.css\">");
%>
<!-- #include file="CompanyFooters.asp" -->

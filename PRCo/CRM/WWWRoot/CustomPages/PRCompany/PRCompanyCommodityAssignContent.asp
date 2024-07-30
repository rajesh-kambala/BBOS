<!--#include file ="../accpaccrm.js"-->
<!--#include file ="../PRCOGeneral.asp"-->
<!--#include file ="../AccpacScreenObjects.asp"-->
<!--#include file ="CompanyIdInclude.asp"-->
<%
    var sHiddenSubmitFields = ""; 

	sCancelAction = eWare.Url("PRCompany/PRCompanyCommodityListing.asp");
	DEBUG("URL:" + sURL);
	sAction = Request.Form.Item("hdn_Action");
	DEBUG("<br>Action:" + sAction);

    // create a list of all the commodities currently assigned to this company
    // get a list of all the "selected" commodities
    sSQL = "SELECT * FROM dbo.ufn_GetAllCompanyCommodities(" + comp_companyid + ") ORDER BY ISNULL(SequenceNumber, 99999)" ;
    var recCCs = eWare.CreateQueryObj(sSQL);
    recCCs.SelectSQL();
	if (!isEmpty(sAction) && sAction == "save")
    {
%>
<!--#include file ="PRCompanyCommodityAssign_SaveAction.asp"-->
<%
    }
    else
    {
        eWare.Mode = Edit;
        while (!recCCs.eof) 
        {
	        var nCommodityId = recCCs("CommodityId");
	        var nGrowingMethodId = recCCs("GrowingMethodId");
	        var nAttributeId = recCCs("AttributeId");
	        var nSequence = recCCs("SequenceNumber");
            if (isEmpty(nSequence))
                nSequence = "-1";
	        var sPublishWithGM = recCCs("PublishWithGM");
            if (isEmpty(sPublishWithGM))
                sPublishWithGM = "";
	        var sPublishedDisplay = recCCs("PublishedDisplay");
            if (isEmpty(sPublishedDisplay))
                sPublishedDisplay = "";
    	    
	        // create a unique name to describe the commodity/growing method/attribute combo
	        sHdnName = "hdnComm_" + nCommodityId;
	        if (!isEmpty(nGrowingMethodId))
	            sHdnName += "_GM_" + nGrowingMethodId;
	        if (!isEmpty(nAttributeId))
	            sHdnName += "_Attr_" + nAttributeId;
	        if (sPublishWithGM != "")
	            sHdnName += "_PGM";
    	        
            sHiddenSubmitFields += 
                "\n<span style=display:none; class=viewbox ID=spn_" + sHdnName + ">"+ sHdnName + ":&nbsp" +
                "\n<input TYPE=TEXT class=viewbox id=" + sHdnName + " NAME=" + sHdnName + " value=\"" + nSequence + "\" >" +
                "\n<input TYPE=TEXT class=viewbox id=" + sHdnName + "_Listing NAME=" + sHdnName + "_Listing value=\"" + sPublishedDisplay + "\" >" +
                "\n<br></span>";

            recCCs.NextRecord();
        }
    


%>
    <HTML>
    <HEAD>
        <base target="_parent" />
        <title></title>
        <LINK REL="stylesheet" HREF="/CRM/prco.css">
        <link href="/crm/Themes/Kendo/kendo.default.min.css" rel="stylesheet">
        <link href="/crm/Themes/Kendo/kendo.common.min.css" rel="stylesheet">
        <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
        <script type="text/javascript" src="../jquery.tablescroll.js"></script>
        <script type="text/javascript" src="../PRCoGeneral.js"></script>
        <script type="text/javascript" src="PRCompanyCommodityListingRules.js"></script>
        <script type="text/javascript" src="PRCompanyCommodityInclude.js"></script>

        </HEAD>

        <BODY>

        <TABLE CELLPADDING=5 WIDTH=100% BORDER=0>
        <TR>
        <TD VALIGN=TOP>
            <TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table6">
            <TR>
            <TD WIDTH=95%>
        <%
        szHeader = createAccpacBlockHeader("AssignCommodities", "Assign Commodities");
        Response.Write(szHeader);

        %>
            <TABLE WIDTH="100%" ID="_tblPAGE" cellpadding=0 CELLSPACING=0 border=0>
            <TR>
            <TD valign=top>
                <TABLE ID="_tblSelectedCommoditySection" cellpadding=0 CELLSPACING=0 border=0 >
                <TR>
                    <TD CLASS=VIEWBOXCAPTION Align=left NOWRAP>Selected Commodities:&nbsp;</TD>    
                </TR>
                <TR>
                    <TD CLASS=VIEWBOXCAPTION COLSPAN=2 >
                        <TABLE ID="_tblSelectedCommodities" CLASS=CommodityLine cellpadding=0 CELLSPACING=0 border=0>
                        <TR ID="_rowSelectedCommodities">
                        </TR>
                        </TABLE>
                    </TD>
                </TR>
                </table>
            </TD>
            <td colspan=3 valign=top>
                
                <TABLE ID="_tblPublishedListing"  cellpadding=0 CELLSPACING=0 border=0 >
                <TR>
                    <TD valign=top></TD>    
                    <TD valign=top Align=left CLASS=VIEWBOXCAPTION NOWRAP style="padding-bottom:0;">Published Listing:&nbsp;</TD>    
                </TR>
                <TR>
                    <TD valign=top ></TD>    
                    <TD valign=top  >
                        <TABLE ID="_tblPublishedCommodities" CLASS=CommodityLine cellpadding=0 CELLSPACING=0 border=0>
                        <TR ID="_rowPublishedCommodities"><td></td>
                        </TR>
                        </TABLE>
                    </TD>
                </TR>
                <TR>
                    <TD CLASS=VIEWBOXCAPTION >&nbsp;</TD>    
                    <TD ALIGN=Left COLSPAN=2 CLASS=VIEWBOXCAPTION >
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<img src="/<%= sInstallName %>/Img/buttons/moveleft.gif" onmouseup="movePublishedListingLeft();" onmouseover="cursorPointer();" onmouseout="cursorDefault();" >
                        <span>&nbsp;&nbsp;</span>
                        <img src="/<%= sInstallName %>/Img/buttons/moveright.gif" onmouseup="movePublishedListingRight();" onmouseover="cursorPointer();" onmouseout="cursorDefault();" >
                    </TD>    
                </TR>
                </table>
            </td>
            </tr>
            <TR><TD HEIGHT="5"></TD></tr>
            <TR>
            <TD VALIGN=top WIDTH="300" >

                <TABLE WIDTH="100%" ID="_tblAvailableCommoditiesSection" cellpadding=0 CELLSPACING=0 border=1>
                <TR>
                <TD>
                    <TABLE WIDTH="100%" ID="_tbl_Search" cellpadding=0 CELLSPACING=0 border=0>
                    <TR>
                        <TD WIDTH="50" CLASS=VIEWBOXCAPTION NOWRAP>
                            <span>&nbsp;&nbsp;
                            <img src="/<%= sInstallName %>/Img/prco/collapse.gif" onmousedown="cursorWait()" onmouseup="collapseAll();" style="width:9px;height:9px"
                                    onmouseover="cursorPointer();" onmouseout="cursorDefault();">
                            ALL</span>
                        </TD>    
                        <TD WIDTH="50" CLASS=VIEWBOXCAPTION NOWRAP>
                            <span>&nbsp;&nbsp;</span>
                            <img src="/<%= sInstallName %>/Img/prco/expand.gif" onmousedown="cursorWait()" onmouseup="return expandAll();" style="width:9px;height:9px" 
                                    onmouseover="cursorPointer();" onmouseout="cursorDefault();" >
                            <span>ALL</span>
                        </TD>    
                        <TD WIDTH="100%" VALIGN=TOP ALIGN=RIGHT>
                            <INPUT ID="txtSearch" TYPE="TEXT" CLASS=VIEWBOX >
                            <span>&nbsp;</span>
                            <img src="/<%= sInstallName %>/Img/buttons/smallsearch.gif" onmousedown="cursorWait();" 
                                    onclick="return searchForValue();" onmouseout="cursorDefault();" >
                            <img src="/<%= sInstallName %>/Img/prco/smallsearchcancel.bmp" onmouseup="clearSearch();" 
                                    onmouseover="cursorPointer();" onmouseout="cursorDefault();" >
                        
                        </TD>
                    </TR>
                    </TABLE>

                    <TABLE WIDTH="100%" ID="_CommodityListing" cellpadding=0 CELLSPACING=0 border=0>
                    <THEAD>
                    <TR>
                        <TD CLASS="TABLEHEAD" WIDTH="40">&nbsp;&nbsp;Select</TD> 
                        <TD CLASS="TABLEHEAD" WIDTH="40">&nbsp;&nbsp;Publish&nbsp;&nbsp;</TD> 
                        <TD CLASS="TABLEHEAD" WIDTH="100%">Commodity(Aliases)</TD> 
                    </TR></THEAD>
                    <TBODY>
                    <%
	                    sSQL = "SELECT ";
	                    sSQL = sSQL + "prcm_CommodityId, prcm_Name, prcm_CommodityCode, prcm_Level, ";
	                    sSQL = sSQL + "prcm_ParentId, RTrim(LTrim(prcm_Alias))AS prcm_Alias, ";
	                    sSQL = sSQL + "prcm_PathNames, prcm_PathCodes  ";
	                    sSQL = sSQL + "FROM PRCommodity ";
	                    sSQL = sSQL + "ORDER BY prcm_DisplayOrder";

	                    recMain = eWare.CreateQueryObj(sSQL);
	                    recMain.SelectSQL();

                        sDelimiter  = "|";
	                    
	                    sPath = ""; // complete list of the commodity path
	                    sPathAbbr = ""; // list of the commodity abbreviations (codes)
	                    var iCurrLevel = 1;
	                    sRowClass = "ROW1 thinRow";
	                    sLastParentCommodityId = "";
	                    sLastCommodityId = "";
	                    arrParentIds = new Array();
	                    while (!recMain.eof) 
	                    {
	                        prcm_CommodityId = recMain("prcm_CommodityId");
		                    iCommodityLevel = recMain("prcm_Level");
		                    prcm_Name = recMain("prcm_Name");
		                    prcm_ParentId = recMain("prcm_ParentId");
		                    sPath = recMain("prcm_PathNames");
		                    sPathCodes = recMain("prcm_PathCodes");
		                    
                            if (arrParentIds.length == 0 || 
                                prcm_ParentId != arrParentIds[arrParentIds.length-1])
                            {
                                if (prcm_ParentId == sLastCommodityId)
                                    arrParentIds[arrParentIds.length] = prcm_ParentId;
                                else
                                {
                                    while (arrParentIds.length > 0 && 
                                           arrParentIds[arrParentIds.length-1] != prcm_ParentId)
                                        arrParentIds.pop();   
                                }
                            }
                            iCurrLevel = arrParentIds.length;
                            
		                    sSpaces = "";
		                    for (i=0; i < iCurrLevel; i++) 
		                    {
			                    sSpaces = sSpaces + "&nbsp;&nbsp;&nbsp;&nbsp;";
		                    }
		                    var sAlias = "";
		                    if (recMain("prcm_Alias") != null)
		                    {
		                        sAlias = "("+recMain("prcm_Alias")+")";
		                    }
                            sCommodityDisplay = prcm_Name+ sAlias;
		                    // tags for the table rows and cells
		                    sCommodityCodeTag = " CommCode=\"" + recMain("prcm_CommodityCode") + "\" ";
		                    sCommodityTag = " CommodityId=\"" + prcm_CommodityId + "\"";
		                    sSearchTextTag = " SearchText=\"" + sCommodityDisplay + "\"" 
		                    sCommNameTag = " CommName=\"" + prcm_Name + "\"" 
		                    sCommLevelTag = " CommLevel=" + iCommodityLevel;
		                    sClassTag = " CLASS=\"" + sRowClass + "\""; 

                            sDisabled = "";
                            if (prcm_CommodityId == 1) {
                                sDisabled = " disabled ";
                            }

                            // set the selected checkbox
                            sSelectTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" +
                                          " ID=_CommSelect_" + prcm_CommodityId +  
                                          " ONCLICK=\"onCommoditySelectClick()\" " + sDisabled +
                                          sCommodityCodeTag+">";
                            
                            // set the Published checkbox
                            sPublishTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" + 
                                           " ID=_CommPublish_" + prcm_CommodityId +  
                                           " ONCLICK=\"onCommodityPublishClick()\" " + sDisabled +
                                           sCommodityCodeTag+">";
                            
		                    sRowStateTag = " RowState=\"expanded\" "; 
		                    sRowStateImgTag = " SRC=\"/" + sInstallName + "/Img/prco/collapse.gif\" "; 

		                    sPathTag = " PathNames=\"" + sPath + "\""; 
		                    sPathCodesTag = " PathCodes=\"" + sPathCodes + "\""; 


                            // sneak a look at the next record to determine if it has a child
                            sLastCommodityId = prcm_CommodityId;
                            recMain.NextRecord();

                            sDisplayExpandTag = " ";

                            if (recMain.eof)
                                sDisplayExpandTag = " style=\"visibility:hidden;\" ";
                            else
                            {
                                if (recMain("prcm_ParentId") != prcm_CommodityId)
                                    sDisplayExpandTag = " style=\"visibility:hidden;\" ";
                            }                    		
                    		
		                    Response.Write("\n<tr id=_PRCMRow_" + prcm_CommodityId + sCommodityTag + sCommodityCodeTag + sSearchTextTag + sCommNameTag
		                                            + sCommLevelTag + sClassTag + sRowStateTag + sPathTag + sPathCodesTag +" onclick=\"onClickCommRow()\">");
		                    Response.Write("\n    <td id=\"_CommTD1_" + prcm_CommodityId+ "\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
                            Response.Write("\n        " + sSelectTag);
		                    Response.Write("\n    </td>");                             
		                    Response.Write("\n    <td id=\"_CommTD2_" + prcm_CommodityId+ "\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;");
                            Response.Write("\n        " + sPublishTag);
		                    Response.Write("\n    </td>");                             
		                    Response.Write("\n    <td id=\"_CommTD3_" + prcm_CommodityId+ "\" style=\"vertical-align:middle\">" + sSpaces);
                            Response.Write("\n        <img id=_prcm_expcol_"+ prcm_CommodityId + sDisplayExpandTag + sRowStateImgTag +  "style=\"width:9px;height:9px\"");
                            Response.Write("\n             onmouseout=\"cursorDefault();\" onmousedown=\"cursorWait();\" onmouseup=\"toggleExpand(this);\"> ");
                            Response.Write("\n        <span id=_CommDisplay_" + prcm_CommodityId + " style=\"vertical-align:middle\">" + sCommodityDisplay + "</span>");
		                    Response.Write("\n    </td>");                             
                            Response.Write("\n</tr>"); 
                            if 	(sRowClass == "ROW1 thinRow")
                                sRowClass = "ROW2 thinRow";
                            else
                                sRowClass = "ROW1 thinRow";
                            
	                    }
                    %>
                    </TBODY>
                    </TABLE>

                </TD>
                </TR>
                </TABLE> <!-- _tblAvailableCommoditiesSection -->

            </TD>

            <TD width=3>&nbsp;</TD>

            <TD VALIGN=TOP >
              <table CELLSPACING=0 CELLSPACING=0 border=1>
              <tr>
              <td  VALIGN=TOP >
                <TABLE CLASS=CONTENT ID="_tblGrowingMethodSection" CELLSPACING=0 border=0 rules="none">
                <THEAD>
                <TR>
                    <TD CLASS=VIEWBOXCAPTION STYLE="padding-left:3px;padding-right:3px;" align=left colspan=3>Growing Method applies to:</TD>    
                </TR>
                <TR>
                    <TD CLASS=VIEWBOX STYLE="padding-left:3px;padding-right:3px;" ID="_tdGMAppliesTo" align=left colspan=3>&nbsp;</TD>    
                </TR>
                <TR>
                    <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-left:3px;padding-right:3px;" ALIGN=CENTER WIDTH="40">Select</TD> 
                    <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-left:3px;padding-right:3px;" ALIGN=CENTER WIDTH="40">Publish</TD> 
                    <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-right:3px;" ALIGN=LEFT WIDTH="100%">Growing Method</TD> 
                </TR>
                </THEAD>
                <TBODY>            
        <%                            
	        sSQL = "SELECT prat_AttributeId, prat_Name, prat_Abbreviation ";
	        sSQL = sSQL + "FROM PRAttribute ";
            sSQL = sSQL + "WHERE prat_type = 'GM' ";
	        sSQL = sSQL + "ORDER BY prat_name, prat_attributeid ";

	        recGM = eWare.CreateQueryObj(sSQL);
	        recGM.SelectSQL();

	        while (!recGM.eof) {
	            prat_AttributeId = recGM("prat_AttributeId");
	            prat_Name = recGM("prat_Name");
	            prat_Abbreviation = recGM("prat_Abbreviation");

		        sAbbrTag = " Abbr=\"" + prat_Abbreviation + "\"";
		        sClassTag = " CLASS=\"ROW1 thinRow\""; 

                sSelectTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" +
                                " ID=_GMSelect_" + prat_AttributeId +  
                                " ONCLICK=\"return onClickGMSelect();\" >";
                
                // set the Published checkbox
                sPublishTag  = "<INPUT TYPE=CHECKBOX class=\"smallcheck\"" + 
                                " ID=_GMPublish_" + prat_AttributeId  +  
                                " ONCLICK=\"return onClickGMPublish();\" >";
                        
		        Response.Write("\n<TR ID=_GMRow_" + prat_AttributeId + " AttrId=" + prat_AttributeId + sClassTag + sAbbrTag + " onclick=\"onClickGMRow();\">");
		        Response.Write("\n    <TD ALIGN=center ID=_GMTD1_" + prat_AttributeId+ ">" + sSelectTag + "</TD>");
		        Response.Write("\n    <TD ALIGN=center ID=_GMTD2_" + prat_AttributeId+ ">"+ sPublishTag + "</TD>");
		        Response.Write("\n    <TD ALIGN=left ID=_GMTD3_" + prat_AttributeId+ ">");
                Response.Write("\n        <span ID=_GMDisplay_" + prat_AttributeId + sClassTag + ">" + prat_Name + "</span>");
		        Response.Write("\n    </TD>");                             
                Response.Write("\n</TR>"); 
                if 	(sRowClass == "ROW1 thinRow")
                    sRowClass = "ROW2 thinRow";
                else
                    sRowClass = "ROW1 thinRow";
	            recGM.NextRecord();
	        }
        %>
                </TBODY>
                </table>
              </td>
              </tr>
              <tr> 
              <TD VALIGN=TOP >
                <TABLE CLASS=CONTENT WIDTH="350" ID="_tblAvailableAttributesSection" CELLSPACING=0 cellpadding=0 border=1 rules="none">
                <TR>
                    <TD CLASS=VIEWBOXCAPTION STYLE="padding-left:3px;padding-right:3px;" align=left colspan=2>Attributes apply to:</TD>    
                </TR>
                <TR>
                    <TD CLASS=VIEWBOX STYLE="padding-left:3px;padding-right:3px;" ID="_tdAttributesApplyTo" align=left colspan=2>&nbsp;</TD>    
                </TR>
                <TR>
                <TD colspan=2>
                    <TABLE WIDTH="100%" ID="_AttributeListing" cellpadding=0 CELLSPACING=0 border=0>
                    <THEAD>
                        <TR>
                            <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-left:3px;padding-right:3px;" WIDTH="30" align=CENTER>Select</TD> 
                            <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-left:3px;padding-right:3px;" ALIGN=CENTER WIDTH="30">Publish</TD> 
                            <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-left:3px;padding-right:3px;" ALIGN=CENTER WIDTH="30">Publish W/GM</TD> 
                            <TD VALIGN=BOTTOM CLASS="TABLEHEAD" STYLE="padding-right:3px;" WIDTH="100%">Attribute</TD> 
                        </TR>
                    </THEAD>
                    <TBODY>
        <%
                
	        sSQL = "SELECT prat_AttributeId, prat_Name, prat_Abbreviation, prat_PlacementAfter, prat_type, capt_us as prat_typedisplay ";
	        sSQL = sSQL + "FROM PRAttribute ";
            sSQL = sSQL + "LEFT OUTER JOIN Custom_Captions ON capt_Family = 'prat_Type' and prat_type = capt_code ";
            sSQL = sSQL + "WHERE prat_type != 'GM' ";
	        sSQL = sSQL + "ORDER BY prat_Type, prat_name, prat_attributeid ";

	        recAttr = eWare.CreateQueryObj(sSQL);
	        recAttr.SelectSQL();

	        var bNewGroup = true;
	        var sGroupHeader = new String("");
	        while (!recAttr.eof) {
	            prat_AttributeId = recAttr("prat_AttributeId");
		        prat_TypeId = recAttr("prat_Type");
		        prat_typedisplay = recAttr("prat_typedisplay");
		        prat_Abbreviation = recAttr("prat_Abbreviation");
		        prat_PlacementAfter = recAttr("prat_PlacementAfter");
		        if (sGroupHeader == "")
		            sGroupHeader = prat_typedisplay;
		        else
		            bNewGroup = (sGroupHeader != prat_typedisplay);

		        // add any logic to determine what state groups should start off
		        // by default, we'll expand them all
		        sRowStateTag = " RowState=\"expanded\" "; 
		        sRowStateImgTag = " SRC=\"/"+ sInstallName + "/Img/prco/collapse.gif\" "; 
    		    sRowAbbrTag = " Abbr=\""+ prat_Abbreviation + "\"";
    		    sAttrPlacementTag = " PlacementAfter=\"" + prat_PlacementAfter + "\"";
        		    
		        if (bNewGroup)
		        {
                    Response.Write("\n        <TR ID=\"_tr_pratgroup_" + prat_TypeId + "\" AttrId=\"G" + prat_TypeId+ "\" CLASS=\"ROW2\" " + sRowStateTag + " > ");
                    Response.Write("\n            <TD >&nbsp;</TD><TD >&nbsp;</TD><TD >&nbsp;</TD> ");
                    Response.Write("\n            <TD ID=_td_pratgroup_" + prat_TypeId + "\"> ");

                    Response.Write("\n                  <IMG ID=\"_prat_expcol_G"+ prat_TypeId + "\" " + sRowStateImgTag + "style=\"width:9px;height:9px\"");
                    Response.Write("\n                          onmouseout=\"cursorDefault();\" onmousedown=\"cursorWait();\" onmouseup=\"toggleAttrExpand(this);\"> ");
                    Response.Write("\n                  " + prat_typedisplay);
                    Response.Write("\n            </TD> ");
                    Response.Write("\n        </TR>");

		            sGroupHeader = prat_typedisplay;
		            bNewGroup = false;
		        }

		        sSpaces = "&nbsp;&nbsp;&nbsp;&nbsp;";
                prat_Name = sSpaces + recAttr("prat_Name");
                // just create a shorter variable name
                var lId = prat_AttributeId ;
                var sSpaces = "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
                Response.Write("\n<TR ID=\"_tr_prat_" + lId + "\" AttrId=\""+ lId + "\" CLASS=\"ROW1 thinRow\"" + sRowAbbrTag + sAttrPlacementTag +">");
                Response.Write("\n    <TD ALIGN=CENTER ID=\"_tdchkAttr_" + lId + "\">" );
                Response.Write("\n        <INPUT TYPE=CHECKBOX class=\"smallcheck\" ID=\"_chkAttrSelect_" + lId + "\" " );
                Response.Write("\n               ONCLICK=\"return onClickSelectAttr();\" AttrId=\"" + lId + "\"> " );
                Response.Write("\n    </TD>" );
                Response.Write("\n    <TD ALIGN=CENTER ID=\"_tdchkAttrPub_" + lId + "\">" );
                Response.Write("\n        <INPUT TYPE=CHECKBOX class=\"smallcheck\" ID=\"_chkAttrPublish_" + lId + "\" " );
                Response.Write("\n               ONCLICK=\"return onClickPublishAttr();\" AttrId=\"" + lId + "\"> " );
                Response.Write("\n    </TD>" );
                Response.Write("\n    <TD ALIGN=CENTER ID=\"_tdchkAttrPubWGM_" + lId + "\">" );
                Response.Write("\n        <INPUT TYPE=CHECKBOX class=\"smallcheck\" ID=\"_chkAttrPubWGM_" + lId + "\" " );
                Response.Write("\n               ONCLICK=\"return onClickPublishAttr();\" AttrId=\"" + lId + "\"> " );
                Response.Write("\n    </TD>" );
                Response.Write("\n    <TD ID=\"_tdAttr_" + lId + "\" CLASS=\"ROW1 thinRow\" >" + prat_Name + "</TD>" );
                Response.Write("\n</TR>" );

                recAttr.NextRecord();
            }
        %>		                        
                    </TBODY> 
                    </TABLE> <!-- _AttributeListing -->

                </TD>
                </TR>
                </TABLE> <!-- _tblAvailableAttributesSection -->
                
              </TD>
              </TR>
              </table>
            </TD>
            </TR>
            </TABLE><!-- _tblPage-->

        <FORM METHOD="POST" ID="EntryForm" Name="EntryForm" >

        <INPUT TYPE="HIDDEN" ID="hdn_Action" Name="hdn_Action">
        <INPUT TYPE="HIDDEN" ID="comp_companyid" Name="comp_companyid" value="<%=comp_companyid%>">

        <div id="divSubmitValues" style="display:none;" >
        <%=sHiddenSubmitFields%>
        </div>

        </FORM>

        <% 
        // ******************************************************
        // ENDING TAGS FOR ACCPAC TABLE
        %>

        <%
        sFooterButtons = eWare.Button("Cancel", "cancel.gif", sCancelAction);
        sFooterButtons += eWare.Button("Save", "save.gif", "javascript:save();\" target=\"_self"    );
        szFooter = createAccpacBlockFooter(sFooterButtons);
        Response.Write(szFooter);
        %>
            </TD>
            </TR>
            </TABLE>
        </TD>
        </TR>
        </TABLE>
        <script type="text/javascript">
            gtblCommodity = document.getElementById("_CommodityListing");
            gtblSelectedCommodities = document.getElementById("_tblSelectedCommodities");
            gtblPublishedCommodities = document.getElementById("_tblPublishedCommodities");
            gtblAttributeListing = document.getElementById("_AttributeListing");
            gtblGrowingMethodSection = document.getElementById("_tblGrowingMethodSection");
            gtblAvailableAttributesSection = document.getElementById("_tblAvailableAttributesSection");
            gdivSubmitValues = document.getElementById("divSubmitValues");
            
            $(document).ready(function ($) {
                $('#_CommodityListing').tableScroll({ height: 600 });
                $('#_AttributeListing').tableScroll({ height: 430 });
            });

            rebuildSelectedCommodities();
            rebuildPublishedCommodities();
            
        </script>
        </BODY>
        </HTML>
<%
    } // This end the non-save block
%>
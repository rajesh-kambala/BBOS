<!--#include file ="../accpaccrm.js"-->
<!--#include file ="../PRCoGeneral.asp"-->
<!--#include file ="../AccpacScreenObjects.asp"-->
<!--#include file ="CompanyHeaders.asp"-->
<%
    buildPage();


    function assignFormSelect(rec, sProperty)
    {
	    sFormValue = getFormValue(sProperty);
        ndx = sFormValue.indexOf(",");
        if (ndx != -1)
            sFormValue = sFormValue.substring(0,ndx);     
        rec(sProperty) = sFormValue;
    }

    function assignFormBool(rec, sProperty) {
	    var sFormValue = getFormValue(sProperty);
        if (sFormValue == "on")
            rec(sProperty) =  "Y";
        else
            rec(sProperty) =  "N";
    }

    function assignInvestigationMethodGroup()
    {
        // set the comp_PRInvestigationMethodGroup value if necessary
        var sSQL = "SELECT top 1 prcl_ClassificationId from dbo.ufn_GetAssignedGroupAClassifications("+ comp_companyid+ ")";
        var recGroupA = eWare.CreateQueryObj(sSQL);
        recGroupA.SelectSQL();
        var sGroup = "B";
        if (!recGroupA.eof)
            sGroup = "A";
        if (sGroup != recCompany("comp_PRInvestigationMethodGroup"))    
        {
            recCompany.comp_PRInvestigationMethodGroup = sGroup;
            recCompany.SaveChanges();
        }
    }

    function updateFormFields(classificationid, recCompanyClassification)
    {
        sFormValue = getFormValue("prc2_percentage");
        recCompanyClassification.prc2_percentage = sFormValue;

	    sFormValue = getFormValue("prc2_percentagesource");
        if (sFormValue == "on")
            recCompanyClassification.prc2_percentagesource = 'Y';
        else
            recCompanyClassification.prc2_percentagesource = 'N';

        sFormValue = getFormValue("prc2_Sequence");
        recCompanyClassification.prc2_sequence = sFormValue;

        recClassification = eWare.FindRecord("PRClassification", "prcl_classificationid="+classificationid);
	    if (!recClassification.eof)
        {
            if (recClassification.prcl_abbreviation == "Ret")
            {
	            sFormValue = getFormValue("prc2_retnumberofstores");
                ndx = sFormValue.indexOf(",");
                if (ndx != -1)
                    sFormValue = sFormValue.substring(0,ndx);
                recCompanyClassification.prc2_numberofstores = sFormValue;

                assignFormBool(recCompanyClassification, "prc2_combostores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofcombostores");

                assignFormBool(recCompanyClassification, "prc2_conveniencestores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofconveniencestores");

                assignFormBool(recCompanyClassification, "prc2_gourmetstores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofgourmetstores");

                assignFormBool(recCompanyClassification, "prc2_healthfoodstores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofhealthfoodstores");

                assignFormBool(recCompanyClassification, "prc2_produceonlystores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofproduceonlystores");

                assignFormBool(recCompanyClassification, "prc2_supermarketstores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofsupermarketstores");

                assignFormBool(recCompanyClassification, "prc2_superstores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofsuperstores");

                assignFormBool(recCompanyClassification, "prc2_warehousestores");
	            assignFormSelect(recCompanyClassification, "prc2_numberofwarehousestores");

            }
            else if (recClassification.prcl_abbreviation == "Restaurant")
            {
	            assignFormSelect(recCompanyClassification, "prc2_numberofstores");
            }
            else if (recClassification.prcl_abbreviation == "FgtF")
            {
                assignFormBool(recCompanyClassification, "prc2_airfreight");
                assignFormBool(recCompanyClassification, "prc2_groundfreight");
                assignFormBool(recCompanyClassification, "prc2_oceanfreight");
	            assignFormBool(recCompanyClassification, "prc2_railfreight");
            }
            else if ((recClassification.prcl_ClassificationId == 2190) || // Retail Lumber Yard
                        (recClassification.prcl_ClassificationId == 2191) || // Home Center
                        (recClassification.prcl_ClassificationId == 2192))   // Pro Dealer
            {
	            sFormValue = getFormValue("prc2_lumbernumberofstores");
                ndx = sFormValue.indexOf(",");
                if (ndx != -1)
                    sFormValue = sFormValue.substring(0,ndx);
                recCompanyClassification.prc2_numberofstores = sFormValue;
            }
        }
    }
    
function buildPage()
{    
    viewMode = eWare.Mode;
    var prc2_companyclassificationid = getIdValue("prc2_companyclassificationid" );
    var prc2_classificationid = -1;
    sListingAction = eWare.Url("PRCompany/PRCompanyClassificationListing.asp")+ "&prc2_CompanyId=" + comp_companyid;
    sSummaryAction = eWare.Url("PRCompany/PRCompanyClassification.asp")+ "&prc2_companyclassificationid="+ prc2_companyclassificationid;
    recClassification = null;
    // Delete is our most simple action.
    if (viewMode == PreDelete )
    {
        //Perform a physical delete of the record
        sql = "DELETE FROM PRCompanyClassification WHERE prc2_CompanyClassificationId="+ prc2_companyclassificationid;
        qryDelete = eWare.CreateQueryObj(sql);
        qryDelete.ExecSql();
        
        // set the investigation method group if necessary
        assignInvestigationMethodGroup();
	    
        // Defect #3825
        //var qryUpdateProfile = eWare.CreateQueryObj("EXEC usp_UpdateProfileFromClassifications " + comp_companyid + ", " + user_userid);
        //qryUpdateProfile.ExecSql();

	    Response.Redirect(sListingAction);
        // now bail on this page because we're redirecting
        return;
    }
    
    if (prc2_companyclassificationid == -1)
    {
        viewMode = Edit;
        recCompanyClassification = eWare.CreateRecord("PRCompanyClassification"); 
    }
    else
    {
        recCompanyClassification = eWare.FindRecord("PRCompanyClassification", 
                                        "prc2_companyclassificationid="+ prc2_companyclassificationid);
        prc2_classificationid = recCompanyClassification.prc2_classificationid;
        recClassification = eWare.FindRecord("PRClassification", 
                                        "prcl_classificationid="+ prc2_classificationid);
	}

    // Check for save first because if we do save, we'll redirect before displaying this form
	sAction = Request.Form.Item("hdn_Action");

	//Response.Write("<br>Action:" + sAction);
    //Response.Write("<br>prc2_classificationid:" + prc2_classificationid);

	if (!isEmpty(sAction) && sAction == "save")
    {
    	var aryClassifications = getFormValue("classification").split(",");

        if(aryClassifications == "undefined")
        {
    	    // get all the form variables
	        prc2_classificationid = getFormValue("prc2_classificationid");
            recCompanyClassification.prc2_classificationid = prc2_classificationid;

            updateFormFields(prc2_classificationid, recCompanyClassification);
            recCompanyClassification.SaveChanges();
        }
        else
        {
            //Loop through all the checked classification checkboxes
		    for (var i=0; i < aryClassifications.length; i++) 
            {
                var classificationId = aryClassifications[i];

                recCompanyClassification = eWare.CreateRecord("PRCompanyClassification");
                recCompanyClassification.prc2_classificationid = classificationId;
                recCompanyClassification.prc2_companyid = comp_companyid;

                updateFormFields(classificationId, recCompanyClassification);
                recCompanyClassification.SaveChanges();
		    }
        }

        // set the investigation method group if necessary
        assignInvestigationMethodGroup();
        
        Response.Redirect(sListingAction);
        
        return;
        //iTrxStatus = TRX_STATUS_NONE;
    }
    // We're going to show the form

%>
<html>
<head>
    <base target="_parent" />
    <title></title>
    <link rel="stylesheet" href="../../prco.css" />
    <link href="/crm/Themes/Kendo/kendo.default.min.css" rel="stylesheet">
    <link href="/crm/Themes/Kendo/kendo.common.min.css" rel="stylesheet">
    <link href="/crm/Themes/ergonomic.css?83568" rel="stylesheet">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.4/jquery.min.js"></script>
    <script type="text/javascript" src="../PRCoGeneral.js"></script>
    <script type="text/javascript" src="../jquery.tablescroll.js"></script>
    <script type="text/javascript" src="CompanyClassificationInclude.js"></script>

</head>
<body>
<form METHOD="POST" ID="EntryForm" Name="EntryForm" >

<input type="HIDDEN" id="hdn_Action" Name="hdn_Action">
<input type="HIDDEN" id="comp_companyid" Name="comp_companyid" value="<%=comp_companyid%>">
<input type="HIDDEN" id="prc2_companyclassificationid" Name="prc2_companyclassificationid" value="<%=prc2_companyclassificationid%>">
<input type="HIDDEN" id="prc2_classificationid" Name="prc2_classificationid" value="<%=prc2_classificationid%>">

<TABLE CELLPADDING=5 WIDTH=100% BORDER=0 ID="Table5">
<TR>
<TD VALIGN=TOP>
    <TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID="Table6">
    <TR>
    <TD WIDTH=95%>
<%

    Response.Write(blkTrxHeader.Execute());

    Response.Write("<br>");

    var szHeader = createAccpacBlockHeader("AssignClassifications", "Classification Properties");
    Response.Write(szHeader);

%>
        <!- Begin the content page -->
        <TABLE WIDTH="100%" ID="_tblPAGE" cellpadding=0 CELLSPACING=0 border=0>
        <TR height=3><TD></TD></TR>
        <TR>
            <TD WIDTH="5" >&nbsp;</TD>
<%
    nPercentageUsed = 0;
    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        var nPercentageUsed = 0;
        sSQL = "SELECT PercentageUsed = SUM(prc2_Percentage) FROM PRCompanyClassification " + 
               "WHERE prc2_CompanyId=" + comp_companyid;
	    recCC = eWare.CreateQueryObj(sSQL);
	    recCC.SelectSQL();
	    if (!recCC.eof) 
            if (!isNaN(recCC("PercentageUsed")))
                nPercentageUsed = recCC("PercentageUsed");
        
        // for a new classification, show the entire list but use 
        // Selectable and NoSelectReason to prevent the user
        // from selecting invalid classifications
        if (prc2_classificationid == -1)
        {
%>    
            <TD WIDTH="300px" >
                <TABLE WIDTH="300px" ID="_tblAvailableClassificationSection2" cellpadding=0 CELLSPACING=0 border=0>
                <TR>
                    <TD style="border: 1px solid gray;">
                        <TABLE WIDTH="300px" ID="_tbl_ClassificationHeader" cellpadding=0 CELLSPACING=0 border=0>
                        <TR>
                            <TD ><SPAN CLASS=VIEWBOXCAPTION>&nbsp;Select Classification(s):</SPAN></TD>
                        </TR>
                        </TABLE>
                    </TD>
                </TR>
                <TR>
                <TD style="border: 1px solid gray;">

                    <TABLE Width="300px" ID="_ClassificationListing" cellpadding=0 CELLSPACING=0 border=0>
                    <THEAD>
                    <TR>
                        <TD CLASS="TABLEHEAD" NOWRAP>&nbsp;&nbsp;&nbsp;Available Classifications<br /><br /></TD> 
                        <!--<TD WIDTH="100%">Path</TD>-->
                    </TR></THEAD>
                    <TBODY>
                    <%
	                    sSQL = "SELECT DISTINCT ";
	                    sSQL = sSQL + "prcl_ClassificationId, prcl_Name, prcl_Abbreviation, prcl_Level, prcl_ParentId, prcl_Path ";
	                    sSQL = sSQL + "FROM dbo.ufn_GetSelectableClassifications( " + comp_companyid + ") ";
	                    sSQL = sSQL + "ORDER BY prcl_Path";

	                    recMain = eWare.CreateQueryObj(sSQL);
	                    recMain.SelectSQL();

	                    while (!recMain.eof) 
	                    {
	                        prcl_classificationid = recMain("prcl_ClassificationId");
		                    iLevel = recMain("prcl_Level");
		                    prcl_name = recMain("prcl_Name");
		                    
                            if (recMain("prcl_abbreviation") != null) {
    		                    prcl_abbreviation = recMain("prcl_abbreviation");
                            } else {
                                prcl_abbreviation = "";
                            }    		                    
		                    
		                    if (iLevel != 1)
		                    {
		                        if (prcl_abbreviation != "") {
	                                prcl_name += " (<I>" + prcl_abbreviation + "</I>)"
	                            }
		                    }

		                    // format the display variable
		                    sSpaces = "&nbsp;&nbsp;";
		                    for (i=1; i < iLevel; i++) 
		                    {
			                    sSpaces = sSpaces + "&nbsp;&nbsp;&nbsp;&nbsp;";
		                    }

                            if(iLevel == 1)
                            {
                                Response.Write("\n<TR><TD NOWRAP><SPAN><b>&nbsp;" + prcl_name + "</b></SPAN></TD></TR>");
                            }
                            else
                            {
                                Response.Write("\n<TR><TD NOWRAP><SPAN>" + sSpaces + "<input type='checkbox' class='classification' name='classification' value='" + prcl_classificationid + "'>" + prcl_name + "</input></SPAN></TD></TR>");
                            }

                            recMain.NextRecord();
	                    }
                    %>
                    </TBODY>
                    </TABLE>

                </TD>
                </TR>
                </TABLE> <!-- _tblAvailableClassificationSection -->

            </TD>

            <TD WIDTH="5" >&nbsp;</TD>
<%
        } // end if (prc2_classificationid == -1)
        else 
        {
            sClassification = recClassification("prcl_Name");
            if (!isEmpty(recClassification("prcl_Abbreviation"))) {
                sClassification += " (" + recClassification("prcl_Abbreviation") + ")";
            }
            
            
            nCurrentPercentage = 0;
            if (!isEmpty(recCompanyClassification("prc2_Percentage")))
                nCurrentPercentage = recCompanyClassification("prc2_Percentage") ;
            nPercentageUsed = nPercentageUsed - nCurrentPercentage ;
%>             
            <TD WIDTH="300" ><SPAN CLASS=VIEWBOXCAPTION>Classification:&nbsp;</SPAN>
                             <SPAN CLASS=VIEWBOX><%=sClassification%></SPAN></TD>
            <TD WIDTH="5" >&nbsp;</TD>
        </TR>
        <TR>    
            <TD WIDTH="5" >&nbsp;</TD>
<%        
        }
    } // end if (iTrxStatus == TRX_STATUS_EDIT)
%>
            <!-- Start the Company Classification Detail Section -->
            <TD ID="td_ClassDetailSection" VALIGN=TOP WIDTH="300" >
            <TABLE WIDTH=300><TR><TD></TD></TR></TABLE>
<%
//    viewMode = View;
//    if (prc2_classificationid == -1)
//        viewMode = Edit;
    var blkCCInfo = eWare.GetBlock("PRCompClassProps_All");
    blkCCInfo.ArgObj = recCompanyClassification;
    blkCCInfo.DisplayButton(Button_Default) = false;
    blkCCInfo.DisplayForm = false;
    blkCCInfo.Mode = viewMode;
    blkCCInfo.CheckLocks = false;
    // get the Percentage field and change the caption
    entry=blkCCInfo.GetEntry("prc2_Percentage");
    if (viewMode == Edit)
        entry.Caption = "Percentage (Max. Value=" + (100- nPercentageUsed) + "%):"
    entry.CaptionPos = 2; 
    
    entry=blkCCInfo.GetEntry("prc2_PercentageSource");
    entry.NewLine = true; 
    sContent = "\n<DIV ID=\"_divProps_All\">" + blkCCInfo.Execute() + "</DIV>";
    Response.Write(sContent);

    var blkCCInfo = eWare.GetBlock("PRCompClassProps_Restaurant");
    blkCCInfo.ArgObj = recCompanyClassification;
    blkCCInfo.DisplayButton(Button_Default) = false;
    blkCCInfo.DisplayForm = false;
    blkCCInfo.Mode = viewMode;
    blkCCInfo.CheckLocks = false;
    sContent = "\n<DIV ID=\"_divProps_Restaurant\">" + blkCCInfo.Execute() + "</DIV>";
    Response.Write(sContent);

    var blkCCInfo = eWare.GetBlock("PRCompClassProps_Ret");
    blkCCInfo.ArgObj = recCompanyClassification;
    blkCCInfo.DisplayButton(Button_Default) = false;
    blkCCInfo.DisplayForm = false;
    blkCCInfo.Mode = viewMode;
    blkCCInfo.CheckLocks = false;
    sContent = "\n<DIV ID=\"_divProps_Ret\">" + blkCCInfo.Execute() + "</DIV>";
    sContent = sContent.replace(/prc2_numberofstores/g, "prc2_retnumberofstores");
    Response.Write(sContent);

//    var blkCCInfo = eWare.GetBlock("PRCompClassProps_FgtF");
//    blkCCInfo.ArgObj = recCompanyClassification;
//    blkCCInfo.DisplayButton(Button_Default) = false;
//    blkCCInfo.DisplayForm = false;
//    blkCCInfo.Mode = viewMode;
//    blkCCInfo.CheckLocks = false;
//    sContent = "\n<DIV ID=\"_divProps_FgtF\">" + blkCCInfo.Execute() + "</DIV>";
//    Response.Write(sContent);
    
    // Put our own block on for the lumber stores.  This makes it easier to control
    // when it is displayed/hidden.  Since this block contains a prc2_numberofstores
    // field, which is already partof this page, rename it to something specific
    // for lumber.
    var blkCCInfo = eWare.GetBlock("PRCompClassProps_LumberChainStores");
    blkCCInfo.ArgObj = recCompanyClassification;
    blkCCInfo.DisplayButton(Button_Default) = false;
    blkCCInfo.DisplayForm = false;
    blkCCInfo.Mode = viewMode;
    blkCCInfo.CheckLocks = false;
    sContent = "\n<DIV ID=\"_divProps_Lumber\">" + blkCCInfo.Execute() + "</DIV>";
    sContent = sContent.replace(/prc2_numberofstores/g, "prc2_lumbernumberofstores");
    Response.Write(sContent);    

%>
<input type="HIDDEN" id="prc2_percentageused" value="<%=nPercentageUsed%>">
            </TD>
            <!-- End the Company Classification Detail Section -->
            
            <TD width="5">&nbsp;</TD>

        </TR>
        <TR HEIGHT=4>
            <TD ></TD>
        </TR>
        </TABLE><!-- _tblPage-->



<% 
    szFooter = createAccpacBlockFooter();
    Response.Write(szFooter);

    var sFooterButtons = "";
    // determine which buttons to display
    if (viewMode == Edit)
    {
        if (prc2_classificationid == -1) 
        {
            sFooterButtons += eWare.Button("Cancel", "cancel.gif", sListingAction);
	    }
        else
        {
            sFooterButtons += eWare.Button("Cancel", "cancel.gif", sSummaryAction);
	    }
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
    	    sFooterButtons += eWare.Button("Save", "save.gif", "javascript:save();\" target=\"_self");
        }
	}
    else 
    {
        sFooterButtons += eWare.Button("Continue","continue.gif", sListingAction);
        if (iTrxStatus == TRX_STATUS_EDIT)
        {
            // Note the string trick to add a "target" attribute to the <a> tags.

            sDeleteUrl = changeKey(sURL, "em", "3");
            sFooterButtons += eWare.Button("Delete", "delete.gif", sDeleteUrl);
            sEditUrl = changeKey(sURL, "em", Edit);
            sFooterButtons += eWare.Button("Change","edit.gif", sEditUrl + "\" target=\"_self"); 
    	}

    }


%>
    </TD>
    <td style="padding-left:15px;vertical-align:top;"">
        
        <table style="background-color:#f2f2f2"><tr><td>
            <% =sFooterButtons %>
        </td></tr></table>
    </td>

    </TR>
    </TABLE>

</TD>
</TR>
</TABLE>

<script type="text/javascript">
    gtdClassDetailSection = document.getElementById("td_ClassDetailSection");
    document.getElementById("_divProps_Restaurant").style.display = "none";
    document.getElementById("_divProps_Ret").style.display = "none";
    //document.getElementById("_divProps_FgtF").style.display = "none";
    document.getElementById("_divProps_Lumber").style.display = "none";
    
    <%
        if (recClassification != null)
    {
        if (recClassification.prcl_abbreviation == "Restaurant")
            Response.Write("    document.getElementById(\"_divProps_Restaurant\").style.display = \"\";");
        else if (recClassification.prcl_abbreviation == "Ret")
            Response.Write("    document.getElementById(\"_divProps_Ret\").style.display = \"\";");
            //        else if (recClassification.prcl_abbreviation == "FgtF")
            //            Response.Write("    gtdClassDetailSection.getElementById(\"_divProps_FgtF\").style.display = \"\";");
        else if ((recClassification.prcl_ClassificationId == 2190) || // Retail Lumber Yard
                 (recClassification.prcl_ClassificationId == 2191) || // Home Center
                 (recClassification.prcl_ClassificationId == 2192))   // Pro Dealer
        {
            Response.Write("    document.getElementById(\"_divProps_Lumber\").style.display = \"\";");
        }
            
    }
    %>
        gtblClassificationListing = document.getElementById("_ClassificationListing");
    if (gtblClassificationListing != null)
    {
        $(document).ready(function($)
        {
            $('#_ClassificationListing').tableScroll({height:350});
        });
    }
</script>

</form>
</body>
</html>


<%
}
 %>
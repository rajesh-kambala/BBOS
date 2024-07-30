<%
/* *******************************************************************
*  Use this include to make a custom grid sortable.  This include
*  sets up most of the infrastructure but there are still some add'l
*  tasks that must be performed by the including routine
*
*  Input variables (these variable must be defined by the including routine):
*    sHiddenOrderBy: the default sort field (ex. "prar_CustomerNumber")
*    sHiddenOrderByDesc: the default sort order "FALSE" for Asc; "TRUE" for Desc;
*    sPrefixForListing: unique prefix for the listing; do not reuse this prefix for
*                       any other listing on this page
*     
*  Output variables (these will be useful to the including routine):
*     sOrderByClause: variable that can be used as a sort clause on a
*                     SQL Statement or Accpac result set OrderBy clause
*                     (ex. recViewResults.OrderBy = sOrderByClause;)
*     blkSort: an accpac block created in this routine that must be added
*              to linting's container. This block will initialize all the
*              sorting functionality for the page
*              (ex. blkContainer.AddBlock(blkSort); )
*
*  Functions (these will be useful to the including routine):
*     addSortableGridHeader(sFieldName, sHeaderText, sWidth, sAlign)
*        - creates the <td> element to add a sortable column header to 
*          a custom listing. Can be called for each column that needs 
*          be sortable
*        (ex. sContent += addSortableGridHeader("prar_CustomerNumber", "Customer Number", "100", "LEFT"); ) 
*
******************************************************************* */
    sOrderByClause = sHiddenOrderBy;
    sSortTemp = String(Request.Form.Item(sPrefixForListing + "HIDDENORDERBY"));
    if (!isEmpty(sSortTemp))
        sHiddenOrderBy = sSortTemp;
    sSortTemp = String(Request.Form.Item(sPrefixForListing + "HIDDENORDERBYDESC"));
    if (!isEmpty(sSortTemp))
        sHiddenOrderByDesc = sSortTemp;

    sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/up.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";

    if (sHiddenOrderBy != "")
    {
        if (sHiddenOrderByDesc == "FALSE")
        {
            sOrderByClause = sHiddenOrderBy;
            sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/up.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
        } else {
            sOrderByClause = sHiddenOrderBy + " DESC";
            sImgSortOrder = "&nbsp;<img src=\"../../img/Buttons/down.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>";
        }
    }

    function addSortableGridHeader(sFieldName, sHeaderText, sWidth, sAdditionalTags)
    {  
        sLocalContent = "\n<td  class=\"GRIDHEAD\" WIDTH=\""+sWidth+ "\" " + sAdditionalTags + 
                        "><a class=\"GRIDHEADLINK\" href=\"javascript:"+ sPrefixForListing + "SortGrid('" + sFieldName + "');\">"+sHeaderText+"</a>";
        if (sHiddenOrderBy == sFieldName)
            sLocalContent += sImgSortOrder;
        sLocalContent += "</td>";
        return sLocalContent;
    }
    
    sSortContent =  "\n<script type=\"text/javascript\">";
    sSortContent += "\n    function "+ sPrefixForListing + "SortGrid(sColName){";
    sSortContent += "\n        sCurr = document.EntryForm."+ sPrefixForListing + "HIDDENORDERBY.value;";
    sSortContent += "\n        sCurrOrder = document.EntryForm."+ sPrefixForListing + "HIDDENORDERBYDESC.value;";
    sSortContent += "\n        if (sCurr == sColName) ";
    sSortContent += "\n        {";
    sSortContent += "\n            if (sCurrOrder == \"FALSE\") ";
    sSortContent += "\n                document.EntryForm."+ sPrefixForListing + "HIDDENORDERBYDESC.value = \"TRUE\";";
    sSortContent += "\n            else ";
    sSortContent += "\n                document.EntryForm."+ sPrefixForListing + "HIDDENORDERBYDESC.value = \"FALSE\";";
    sSortContent += "\n        } else {";
    sSortContent += "\n            document.EntryForm."+ sPrefixForListing + "HIDDENORDERBY.value = sColName;";
    sSortContent += "\n            document.EntryForm."+ sPrefixForListing + "HIDDENORDERBYDESC.value = \"FALSE\";";
    sSortContent += "\n        }";
    sSortContent += "\n        document.EntryForm.submit();";
    sSortContent += "\n    }";
    sSortContent += "\n</script>\n";
    sSortContent +=  "<input type=\"hidden\" name=\""+ sPrefixForListing + "HIDDENORDERBY\" value=\"" + sHiddenOrderBy + "\">"+
            "<input type=\"hidden\" name=\""+ sPrefixForListing + "HIDDENORDERBYDESC\" value=\"" + sHiddenOrderByDesc + "\">";
    blkSort = eWare.GetBlock("content");
    blkSort.Contents=sSortContent;
%>

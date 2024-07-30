<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2015

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

    // ********* NOTE:  
    // recNumerals and viewRating should be defined by the caller.
    
    sAssignedNumerals = "";
    if (viewRating != null )
        if (!isEmpty(viewRating("prra_AssignedRatingNumerals")))
            sAssignedNumerals = viewRating("prra_AssignedRatingNumerals");
        
    
    var sRatingNumeralContents =                 
        "\n<TABLE  WIDTH=\"500px\" CLASS=VIEWBOXCAPTION ID=\"_tblRatingNumeralSection\" cellpadding=0 CELLSPACING=0 border=0> " +
        "\n  <TR>" +
        "\n    <TD COLSPAN=3 Width=\"100%\">&nbsp;</TD>" +
        "\n  </TR>" +
        "\n  <TR>" +
        "\n    <TD>&nbsp;</TD>" +
        "\n    <TD>" +
        "\n      <TABLE WIDTH=\"100%\" ID=\"_tblNumeralEditSection\" cellpadding=0 CELLSPACING=0 border=1>" +
        "\n        <TR><TD CLASS=VIEWBOXCAPTION ><SPAN>Assigned Rating Numerals:<br></SPAN>" +
                                "<SPAN ID=\"spn_AssignedRatingNumerals\">" + sAssignedNumerals + "</SPAN></TD>" + 
        "\n                 <INPUT TYPE=HIDDEN ID=\"_txt_SelectedNumerals\" NAME=\"_txt_SelectedNumerals\" VALUE=\"" + sAssignedNumerals + "\" >" +
        "\n        </TR>" +
        "\n        <TR>" +
        "\n          <TD>" +
        "\n            <TABLE WIDTH=\"100%\" ID=\"_NumeralsListing\" CLASS=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff > " +
        "\n            <THEAD ALIGN=CENTER>" +
        "\n              <TR>" +
        "\n                <TD CLASS=\"GRIDHEAD\">Select</TD> " +
        "\n                <TD CLASS=\"GRIDHEAD\">Numeral</TD>" +
        "\n                <TD CLASS=\"GRIDHEAD\">Type</TD>" +
        "\n                <TD CLASS=\"GRIDHEAD\" WIDTH=\"100%\" ALIGN=LEFT>Description</TD>" +
        "\n              </TR> " +
        "\n            </THEAD>" +
        "\n            <TBODY>" +
        "";                            	    

    while ((recNumerals != null) && !recNumerals.eof) 
    {
        prrn_ratingnumeralid = recNumerals("prrn_RatingNumeralId");
        prrn_name = recNumerals("prrn_Name");
        prrn_desc = recNumerals("prrn_Desc");
        
        prrn_type = recNumerals("prrn_Type");
        if (isEmpty(prrn_type))
            prrn_type = "";
            
        sChecked = "";
        sDisabled = "";
        if (viewRating != null)
        {
            if (sAssignedNumerals.indexOf(prrn_name) != -1)
                sChecked = " CHECKED ";
                
             
            // An empty string means the user can edit all
            // numerals   
            if (sSecurityRNString != "") {
            
            
                if (sSecurityRNString.indexOf("," + prrn_ratingnumeralid + ",") == -1)
                    sDisabled = " disabled=true ";
            }
        }
        
        
        
        
        sRatingNumeralContents = sRatingNumeralContents + 
        "\n              <tr ID=\"_tr_prrn_" + prrn_name + "\" Numeral=\"" + prrn_name + "\" " + sDisabled + " > " +
        "\n	               <td VALIGN=MIDDLE ALIGN=CENTER ID=\"_tdchkNumSelect_" + prrn_name + "\" CLASS=\"ROW2\">";
        sTemp = "\n	                 <INPUT TYPE=CHECKBOX ID=\"_chkNumeralSelect_" + prrn_name + 
                "\" NAME=\"_chkNumeralSelect_" + prrn_name + "\"" +
                sChecked + 
                " Numeral=" + prrn_name + 
                " PRType=" + prrn_type + 
                " ONCLICK=\"onRatingNumeralClick()\" " + 
                "></INPUT>"; 
        sRatingNumeralContents = sRatingNumeralContents + sTemp;
        sRatingNumeralContents = sRatingNumeralContents + 
            "\n	               </td> " +
            "\n	               <td id=\"_tdNumeral_" + prrn_name + "\" CLASS=\"ROW2\" style=\"vertical-align:middle;\" align=\"center\"> " +
            "\n	                   "  + prrn_name +  
            "\n	               </td>" +
            "\n	               <td id=\"_tdType_" + prrn_type + "\" CLASS=\"ROW2\" style=\"vertical-align:middle;\"  align=\"center\"> " +
            "\n	                   "  + prrn_type +  
            "\n	               </td>" +
            "\n	               <td id=\"_tdDesc_" + prrn_desc + "\" CLASS=\"ROW2\" style=\"vertical-align:middle;\" > " +
            "\n	                   "  + prrn_desc +  
            "\n	               </td>" ;
        sRatingNumeralContents = sRatingNumeralContents + 
        "\n              </tr>";

        recNumerals.NextRecord();
    }
    sRatingNumeralContents = sRatingNumeralContents + 
    "\n            </TBODY> " +
    "\n            </TABLE> <!-- _NumeralsListing -->" +

    "\n          </TD>" +
    "\n        </TR>" +
    "\n      </TABLE> <!-- _tblNumeralsEditSection -->" +
                    
    "\n    </TD>" +
    "\n    <TD>&nbsp;&nbsp;&nbsp;</TD>                                                                                 " +
    "\n  </TR>" +
    "\n  <TR ><TD>&nbsp;</TD>" +
    "\n  </TR>" +
    "\n</TABLE> <!--_tblNumeralsSection -->" ;


%>
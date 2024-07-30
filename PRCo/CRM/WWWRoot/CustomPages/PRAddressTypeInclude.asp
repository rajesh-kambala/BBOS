<script language=JavaScript src="../ScrollableTable.js"></script>
<%
var bEdit = false;
if (eWare.Mode == Edit && iTrxStatus == TRX_STATUS_EDIT )
    bEdit = true;

sAddressType = "'adli_TypeCompany'";
try
{
    if (nAddrType == 0)
        sAddressType = "'adli_TypeCompany'";
    else if (nAddrType == 1)
        sAddressType = "'adli_TypePerson'";
}
catch (e)
{
    nAddrType = 0;
}// just eat the not defined error

var sAddressTypeContents =                 
    "\n<TABLE WIDTH=\"100%\" CLASS=VIEWBOXCAPTION ID=\"_tblAddressTypeSection\" cellpadding=0 CELLSPACING=0 border=0> " +
    "\n  <TR>" +
    "\n    <TD COLSPAN=3 Width=\"100%\">&nbsp;</TD>" +
    "\n  </TR>" +
    "\n  <TR>" +
    "\n    <TD>&nbsp;&nbsp;</TD>" +
    "\n    <TD NOWRAP>Use the table below to selected the types for this address:</TD>" +
    "\n    <TD >&nbsp;</TD>" +
    "\n  </TR>" +
    "\n  <TR>" +
    "\n    <TD>&nbsp;</TD>" +
    "\n    <TD>" +
    "\n      <TABLE WIDTH=\"100%\" ID=\"_tblTypeEditSection\" cellpadding=0 CELLSPACING=0 border=1>" +
    "\n        <TR>" +
    "\n          <TD>" +
    "\n            <TABLE WIDTH=\"100%\" ID=\"_TypesListing\" CLASS=CONTENT border=1px cellspacing=0 cellpadding=1 bordercolordark=#ffffff bordercolorlight=#ffffff > " +
    "\n            <THEAD ALIGN=CENTER>" +
    "\n              <TR>" +
    "\n                <TD CLASS=\"GRIDHEAD\" WIDTH=\"40\">Select</TD> " +
    "\n                <TD NOWRAP CLASS=\"GRIDHEAD\" WIDTH=\"100\">Address Type</TD>" ;
// only show for company
if (nAddrType == 0)
{
    sAddressTypeContents = sAddressTypeContents + 
    "\n                <TD CLASS=\"GRIDHEAD\" WIDTH=\"60\">Publish</TD>" +
    "\n                <TD CLASS=\"GRIDHEAD\" WIDTH=\"60\">Default</TD>" ;
}
sAddressTypeContents = sAddressTypeContents + 
    "\n                <TD CLASS=\"GRIDHEAD\" WIDTH=\"100%\" ALIGN=LEFT>Description</TD>" +
    "\n              </TR> " +
    "\n            </THEAD>" +
    "\n            <TBODY>" +
    "";                            	    

if (bEdit == true)
{
    sSQL = " SELECT capt_code, capt_us, adli_AddressId, adli_PRPublish, adli_PRDefault, adli_PRDescription ";
    sSQL = sSQL + " from custom_captions ";
    sSQL = sSQL + " LEFT OUTER JOIN address_link adli ON capt_code = adli_type AND adli_addressid = " + addr_AddressId
    sSQL = sSQL + " WHERE capt_familytype = 'Choices' ";
    sSQL = sSQL + " AND capt_family = " + sAddressType;// 'adli_TypeCompany' "; 
    sSQL = sSQL + " order by capt_order ";
} 
else
{
    sSQL = " SELECT capt_code, capt_us, adli_AddressId, adli_PRPublish, adli_PRDefault, adli_PRDescription ";
    sSQL = sSQL + " FROM address_link ";
    sSQL = sSQL + " LEFT OUTER JOIN  custom_captions ON adli_type = capt_code AND ";
    sSQL = sSQL + "             capt_familytype = 'Choices' AND capt_family = " + sAddressType; //'adli_TypeCompany' "; 
    sSQL = sSQL + " WHERE adli_addressid = " + addr_AddressId
    sSQL = sSQL + " order by capt_order ";
    Response.Write(sSQL);

}

recTypes = eWare.CreateQueryObj(sSQL);
recTypes.SelectSQL();

while (!recTypes.eof) 
{
    capt_code = recTypes("capt_code");
    capt_us = recTypes("capt_us");
    adli_prpublish = recTypes("adli_PRPublish");		                            
    if (isEmpty(adli_prpublish))
        adli_prpublish = "";
    adli_prdefault = recTypes("adli_PRDefault");		                            
    if (isEmpty(adli_prdefault))
        adli_prdefault = "";
    adli_prdescription = recTypes("adli_PRDescription");
    if (isEmpty(adli_prdescription))
        adli_prdescription = "";
    adli_addressid = recTypes("adli_AddressId");		                            
    sAddressTypeContents = sAddressTypeContents + 
    "\n		         <TR ID=\"_tr_type_" + capt_code + "\" CaptCode=" + capt_code + " > " +
    "\n		           <TD VALIGN=MIDDLE ALIGN=CENTER ID=_tdchkTypeSelect_" + capt_code + ">";
    if (bEdit == true )
    { 
        sTemp = "\n		             <INPUT TYPE=CHECKBOX ID=_chkTypeSelect_" + capt_code + " NAME=_chkTypeSelect_" + capt_code + " CaptCode=" + capt_code + 
                "\n		                     " + (isEmpty(adli_addressid)?"": " CHECKED ") + " ></INPUT>"; 
    } else {
        sTemp = "\n		             <SPAN CLASS=ROW2 style={vertical-align:middle;}>Y<SPAN>" ; 
    }            
    sAddressTypeContents = sAddressTypeContents + sTemp + 
        "\n		           </TD> " +
        "\n		           <TD ID=_tdType_" + capt_code + " CLASS=\"ROW2\" style={vertical-align:middle;} > " +
        "\n		               "  + capt_us +  
        "\n		           </TD>" ;

    // only show for company
    if (nAddrType == 0)
    {
        sAddressTypeContents = sAddressTypeContents + 
            "\n		           <TD VALIGN=MIDDLE ALIGN=CENTER ID=_tdchkTypePublish_" + capt_code + ">" ;
        if (bEdit == true )
        { 
            sTemp = "\n		             <INPUT TYPE=CHECKBOX ID=_chkTypePublish_" + capt_code + " NAME=_chkTypePublish_" + capt_code + " CaptCode=" + capt_code + 
                    "\n		                     " + (adli_prpublish == "Y"?" CHECKED ":"") + " ></INPUT>";
        } else {
            sTemp = "\n		             <SPAN CLASS=ROW2 style={vertical-align:middle;}>" + (adli_prpublish == "Y"?"Y":"&nbsp;") + "<SPAN>" ; 
        }            
        sAddressTypeContents = sAddressTypeContents + sTemp + 
            "\n		           </TD> " +
            "\n		           <TD VALIGN=MIDDLE ALIGN=CENTER ID=_tdchkTypeDefault_" + capt_code + ">";
        if (bEdit == true )
        { 
            sTemp = "\n		             <INPUT TYPE=CHECKBOX ID=_chkTypeDefault_" + capt_code + " NAME=_chkTypeDefault_" + capt_code + " CaptCode=" + capt_code + 
                    "\n		                     " + (adli_prdefault == "Y"?" CHECKED ":"") + " ></INPUT>";
        } else {
            sTemp = "\n		             <SPAN CLASS=ROW2 style={vertical-align:middle;}>" + (adli_prdefault == "Y"?"Y":"&nbsp;") + "<SPAN>" ; 
        }            
        sAddressTypeContents = sAddressTypeContents + sTemp + 
            "\n		           </TD> " ;
    }

    sAddressTypeContents = sAddressTypeContents + 
        "\n		           <TD ALIGN=LEFT ID=_tdtxtTypeDesc_" + capt_code + ">";
    if (bEdit == true )
    { 
        sTemp = "\n		             <INPUT CLASS=EDIT TYPE=TEXT ID=\"_txtTypeDesc_" + capt_code + "\" NAME=\"_txtTypeDesc_" + capt_code + "\"  value=\"" + adli_prdescription + 
                    "\" maxlength=100 size=50 ></INPUT> " ;
    } else {
        sTemp = "\n		             <SPAN CLASS=ROW2 style={vertical-align:middle;}>" + adli_prdescription  + "<SPAN>" ; 
    }            
    sAddressTypeContents = sAddressTypeContents + sTemp + 
    "\n		           </TD> " +
    "\n              </TR>";

    recTypes.NextRecord();
}
sAddressTypeContents = sAddressTypeContents + 
"\n            </TBODY> " +
"\n            </TABLE> <!-- _TypesListing -->" +

"\n          </TD>" +
"\n        </TR>" +
"\n      </TABLE> <!-- _tblTypeEditSection -->" +
                
"\n    </TD>" +
"\n    <TD>&nbsp;&nbsp;&nbsp;</TD>                                                                                 " +
"\n  </TR>" +
"\n  <TR ><TD>&nbsp;</TD>" +
"\n  </TR>" +
"\n</TABLE> <!--_tblAddressTypeSection -->" ;


%>
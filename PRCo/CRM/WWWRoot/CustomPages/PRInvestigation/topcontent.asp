<%

// Create the top content section
var sTop = "";
var sSID = new String(Request.Querystring("SID"));

sTop = "<table CELLPADDING=\"0\" CELLSPACING=\"0\" BORDER=\"0\" HEIGHT=\"99%\">";
sTop = sTop + "   <tr>";
sTop = sTop + "      <td width=\"50\" rowspan=\"3\"><img src=\"../../Img/Icons/PRInvestigation.gif\" HSPACE=\"0\" BORDER=\"0\" ALIGN=\"TOP\"></td>";
   if (Defined(recMain.priv_DateOpen)) {
		sTop = sTop + "      <td align=\"right\" width=\"100\" class=\"topcaption\">Title: </td>";
		sTop = sTop + "      <td align=\"left\" width=\"250\" class=\"topsubheading\">&nbsp;" + recMain.priv_DateOpen + "</td>";
   }
   sTop = sTop + "   </tr></table>";
%>

<SCRIPT LANGUAGE=javascript>
   parent.frames[3].WriteToFrame(5,'TOPBODY VLINK=#003B72 LINK=#003B72','<% Response.Write(sTop)%>')
</SCRIPT>

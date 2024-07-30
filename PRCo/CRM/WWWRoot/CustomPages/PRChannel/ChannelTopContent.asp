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

<%
// channel credit sheet top content
// create a top contetn that mimics accpac's top content for channels
var sChannelCreditSheetURL = eWare.URL("PRChannel/PRChannelCreditSheetListing.asp");
// remove Key5
sChannelCreditSheetURL = removeKey(sChannelCreditSheetURL, "F");
sChannelCreditSheetURL = removeKey(sChannelCreditSheetURL, "J");
sChannelCreditSheetURL = removeKey(sChannelCreditSheetURL, "Key5");
// sInstallName is defined in accpaccrmNoLang.js, a file included by all crm pages
var sImagePath = "/" + sInstallName + "/img"
var sTop = "<TABLE HEIGHT=\"99%\"><TR>"+
            "<TD WIDTH=60><IMG SRC=\""+ sImagePath + "/Icons/Channels.gif\" HSPACE=0 BORDER=0 ALIGN=TOP></TD>" +
            "<TD CLASS=TOPCAPTION>Team CRM for:&nbsp; " +
            "<SELECT class=TOPSELECTCHANNEL size=1 name=\"SELECTChannel\" " +
            "onChange=\"thevalue=SELECTChannel.options[SELECTChannel.selectedIndex].value;parent.EWARE_MID.location= \\\'"+
            sChannelCreditSheetURL + "&Key5=\\\'+thevalue;\">";

var recChannels = eWare.FindRecord("Channel", "");
var sSelected = "";
while (!recChannels.eof)
{
    sSelected = "";
    if (sKey5 == recChannels("chan_channelid"))
        sSelected = "SELECTED";
    sTop += "<OPTION " + sSelected + " Value=\"" + recChannels("chan_channelid") + "\">" + recChannels("chan_Description")+ "</OPTION>" ;
    
    recChannels.NextRecord();
}
sSelected = "";
if (sKey5 == "-1")
    sSelected = "SELECTED";
sTop += "<OPTION " + sSelected + " Value=\"-1\">All Teams</OPTION>";
sSelected = "";
if (sKey5 == "")
    sSelected = "SELECTED";
sTop += "<OPTION " + sSelected + " Value=\"\">--Unassigned--</OPTION>";
sTop += "</SELECT></TD></TR></TABLE>";

%>

<SCRIPT LANGUAGE=javascript>
   parent.frames[3].WriteToFrame(5,'TOPBODY VLINK=#003B72 LINK=#003B72','<% Response.Write(sTop)%>')
</SCRIPT>

<%

function getImportPACASummaryBlock(pril_record, sTitle)
{
	// create the custom content for the summary section of the screen

	CityStateZip = getString(pril_record.pril_City);
	if (CityStateZip.length > 0)
		CityStateZip += ", " + getString(pril_record.pril_State) + "&nbsp;" + getString(pril_record.pril_PostCode);
	else
		CityStateZip += getString(pril_record.pril_State) + "&nbsp;" + getString(pril_record.pril_PostCode);


	MailCityStateZip = getString(pril_record.pril_MailCity);
	if (MailCityStateZip.length > 0)
		MailCityStateZip += ", " + getString(pril_record.pril_MailState) + "&nbsp;" + getString(pril_record.pril_MailPostCode);
	else
		MailCityStateZip += getString(pril_record.pril_MailState) + "&nbsp;" + getString(pril_record.pril_MailPostCode);

	SummaryContent = "" + 
	("\n<TABLE WIDTH=100% CELLPADDING=0 CELLSPACING=0 BORDER=0 ID=\"Table7\">" +
	"\n<TR>" +
	"\n    <TD COLSPAN=3>" +
	"\n        <TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 ID=\"Table8\">" +
	"\n            <TR>" +
	"\n                <TD VALIGN=BOTTOM><IMG SRC=\"/"+sInstallName+"/img/backgrounds/paneleftcorner.jpg\" HSPACE=0 BORDER=0 ALIGN=TOP></TD>" +
	"\n                <TD NOWRAP=true WIDTH=10% CLASS=PANEREPEAT>" + sTitle + "</TD>" +
	"\n                <TD VALIGN=BOTTOM>" +
	"\n                <IMG SRC=\"/"+sInstallName+"/img/backgrounds/panerightcorner.gif\" HSPACE=0 BORDER=0 ALIGN=TOP></TD>" +
	"\n                <TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD>" +
	"\n                <TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD>" +
	"\n                <TD ALIGN=BOTTOM COPSPAN=30 WIDTH=90% CLASS=TABLETOPBORDER >&nbsp;</TD>" +
	"\n            </TR>" +
	"\n        </TABLE>" +
	"\n    </TD>" +
	"\n</TR>" +
	"\n<TR CLASS=CONTENT>" +
	"\n    <TD WIDTH=1px CLASS=TABLEBORDERLEFT>" +
	"\n        <IMG SRC=\"/"+sInstallName+"/img/backgrounds/tabletopborder.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>" +
	"\n    </TD>" +
	"\n    <TD HEIGHT=100% WIDTH=100% CLASS=VIEWBOXCAPTION>" +
		"\n<TABLE CLASS=CONTENT WIDTH=100% BORDER=0 ID=\"tblImpLicenseSummary\">" +
		"\n    <TR>  " +
		"\n        <input type=hidden id=\"_HIDDENpril_ImportPACALicenseId\" name=\"_HIDDENpril_ImportPACALicenseId\" value=\"" + pril_record.pril_ImportPACALicenseId + "\"> " +
		"\n        <TD  VALIGN=TOP > " +
		"\n            <SPAN ID=_Captpril_licensenumber class=VIEWBOXCAPTION>License #:</SPAN>" +
		"\n            <SPAN ID=_Datapril_licensenumber class=VIEWBOX STYLE=WIDTH:\"100px\">" + getString(pril_record.pril_LicenseNumber) + "</SPAN>" +
		"\n        </TD>" +
		"\n        <input type=hidden id=_HIDDENpril_LicenseNumber name=_HIDDENpril_LicenseNumber value=\"" + pril_record.pril_LicenseNumber + "\">" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=\"Span1\" class=VIEWBOXCAPTION>Expire Date:</SPAN>" +
		"\n            <SPAN ID=\"Span2\" class=VIEWBOX >" + getDateAsString(pril_record.pril_ExpirationDate) + "</SPAN>" +
		"\n        </TD>" +
		"\n    <TR>  " +
		"\n    </TR>" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=\"Span1\" class=VIEWBOXCAPTION>Company Name:</SPAN>" +
		"\n            <SPAN ID=\"Span2\" class=VIEWBOX >" + getString(pril_record.pril_CompanyName) + "</SPAN>" +
		"\n        </TD>" +
		"\n        <input type=hidden id=_HIDDENpril_CompanyName name=_HIDDENpril_CompanyName value=\"" + pril_record.pril_CompanyName + "\">" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=\"Span1\" class=VIEWBOXCAPTION>PACA File Date:</SPAN>" +
		"\n            <SPAN ID=\"Span2\" class=VIEWBOX >" + getDateAsString(pril_record.pril_PACARunDate) + "</SPAN>" +
		"\n        </TD>" +
		"\n    </TR>" +
		"\n    <TR>" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=_Captpril_address1 class=VIEWBOXCAPTION>Business Address:</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address1 class=VIEWBOX >" + getString(pril_record.pril_Address1) + "</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address1 class=VIEWBOX >" + getString(pril_record.pril_Address2) + "</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address2 class=VIEWBOX >" + CityStateZip + "</SPAN>" +
		"\n        </TD>" +
		"\n        <input type=hidden id=_HIDDENpril_Address1 name=_HIDDENpril_Address1 value=\"" + pril_record.pril_Address1 + "\">" +
		"\n        <input type=hidden id=_HIDDENpril_Address2 name=_HIDDENpril_Address2 value=\"" + pril_record.pril_Address2 + "\">" +
		"\n        <input type=hidden id=_HIDDENpril_City name=_HIDDENpril_City value=\"" + pril_record.pril_City + "\">" +
		"\n        <input type=hidden id=_HIDDENpril_State name=_HIDDENpril_State value=\"" + pril_record.pril_State + "\">" +
		"\n        <input type=hidden id=_HIDDENpril_PostCode name=_HIDDENpril_PostCode value=\"" + pril_record.pril_PostCode + "\">" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=_Captpril_address1 class=VIEWBOXCAPTION>Mailing Address:</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address1 class=VIEWBOX >" + getString(pril_record.pril_MailAddress1) + "</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address1 class=VIEWBOX >" + getString(pril_record.pril_MailAddress2) + "</SPAN>" +
		"\n            <br>" +
		"\n            <SPAN ID=_Datapril_address2 class=VIEWBOX >" + MailCityStateZip + "</SPAN>" +
		"\n        </TD>" +
		"\n    </TR>" +
		"\n    <TR>" +
		"\n        <TD  VALIGN=TOP >" +
		"\n            <SPAN ID=_Captpril_filename class=VIEWBOXCAPTION>File Name:</SPAN>" +
		"\n            <SPAN ID=_Datapril_filename class=VIEWBOX >" + pril_record.pril_FileName + "</SPAN>" +
		"\n        </TD>                                                                                   " +
		"\n        <input type=hidden id=_HIDDENpril_filename name=_HIDDENpril_filename value=\"" + pril_record.pril_FileName + "\">" +
		"\n        <TD  COLSPAN=2 VALIGN=TOP >" +
		"\n            <SPAN ID=_Captpril_importdate class=VIEWBOXCAPTION>Import Action Date:</SPAN>" +
		"\n            <SPAN ID=_Datapril_importdate class=VIEWBOX >" + getDateAsString(pril_record.pril_importdate) + "</SPAN>" +
		"\n        </TD>" +
		"\n        <input type=hidden id=_HIDDENpril_importdate name=_HIDDENpril_importdate value=\"" + pril_record.pril_importdate + "\">" +
		"\n    </TR>" +
		"\n</TABLE>" +
	"\n    </TD>" +
	"\n    <TD WIDTH=1px CLASS=TABLEBORDERRIGHT>" +
	"\n        <IMG SRC=\"/"+sInstallName+"/img/backgrounds/tabletopborder.gif\" HSPACE=0 BORDER=0 ALIGN=TOP>" +
	"\n    </TD>" +
	"\n</TR>" +
	"\n<TR HEIGHT=1>" +
	"\n    <TD COLSPAN=3 WIDTH=1px CLASS=TABLEBORDERBOTTOM></TD>" +
	"\n</TR>" +
	"\n</TABLE>") ;

	return SummaryContent;
}

%>
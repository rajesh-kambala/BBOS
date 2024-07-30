<%

// This is a generic CLEAR function
// for custom entities.
// The block which you are clearing MUST
// be named blkSearch

// Clear all of the fields if Clear button was clicked
var sClear = 'N';
if (eWare.Mode == 6) {
   sClear = 'Y';
}

var sSelectString = pcg_BuildSelectFields(blkSearch);
	sSelectStringAry = sSelectString.split(", ");

    Response.Write("\n<script language=Javascript>\n ");
	Response.Write("  if (\"" + sClear + "\" == \'Y\') { \n");

	var i = 0;
	for (i = 0; i < sSelectStringAry.length; i++) {
		var recField = eWare.FindRecord("Custom_Edits","ColP_ColName = '" + sSelectStringAry[i] + "'");
		if ((recField.ColP_EntryType == 26) && (i == 0)) {
			Response.Write("document.EntryForm." + sSelectStringAry[i] + ".value = \'\'\n");
			Response.Write("document.EntryForm." + sSelectStringAry[i] + "TEXT.value = \'\'\n");
			//Response.Write("document.EntryForm." + sSelectStringAry[i] + ".focus();\n");
		} else if ((recField.ColP_EntryType == 26) && (i != 0)) {
			Response.Write("document.EntryForm." + sSelectStringAry[i] + ".value = \'\'\n");
			Response.Write("document.EntryForm." + sSelectStringAry[i] + "TEXT.value = \'\'\n");
		} else if ((recField.ColP_EntryType != 26) && (i == 0)) {
			Response.Write("document.EntryForm." + sSelectStringAry[i] + ".value = \'\'\n");
			Response.Write("document.EntryForm." + sSelectStringAry[i] + ".focus();\n");
		} else {
			Response.Write("document.EntryForm." + sSelectStringAry[i] + ".value = \'\'\n");
		}
	}

	Response.Write("} \n</script>");

%>
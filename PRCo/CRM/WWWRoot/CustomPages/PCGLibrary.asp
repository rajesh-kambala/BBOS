<%

function pcg_GetId(sIdField) {
   // Description: This function returns the value of the specified Id Field.
   // Parameters:
   //		sIdField - Name of the field with the unique Id.

   // Initialize the return value to 0.
	var lFoundId = 0;

	// Look for the field in the querystring.
	var lTempId = new String(Request.Querystring(sIdField));

	// If the field was not in the querystring, get the value from the CRM custom key parameter.
	if (lTempId.toString() == 'undefined') {
		lTempId = new String(Request.Querystring("Key58"));
	}

	// If the temporary Id is an array, get the first value.
	// otherwise just use the temporary Id.
	if (lTempId.indexOf(',') > 0) {
		var arrId = lTempId.split(",");
		lFoundId = arrId[0];
	} else if (lTempId != '') {
		lFoundId = lTempId;
	}

	return(lFoundId);

}

function pcg_Trim(sString) {
   // Description: This function removes spaces from a string.

	return(sString.replace(/^\s*|\s*$/g,""));
}

function pcg_BuildSelectFields(objScreen) {
   // Description: This function builds a select clause based on based on fields in object passed.
   // Parameters:
   // 	objScreen - Object used to get the list of fields for the sql query.

	// Initialize the string and the And flag
	var sSelect = "";

	// Loop through all fields and build the string
	var colFields = new Enumerator(objScreen);
	while (!colFields.atEnd()) {
		// Get the field name
		sFieldName = colFields.item();
		if ((sFieldName != "undefined") && (sFieldName != "")) {
		   sSelect = sSelect + sFieldName;
		   sSelect = sSelect + ", ";
			}

		// Move to the next field
		colFields.moveNext();
   }

	sSelect = sSelect.substring(0, sSelect.length - 2);

	// Don't return a string if there are any undefined values
	if (sSelect.indexOf('undefined') > 0) {
		return("");
	} else {
		return(sSelect);
	}
}

function pcg_BuildFilterString(blkFilter) {
   // Description: This function builds a where clause based on a filter screen.
   // Parameters:
   // 	blkFilter - Screen object used for filtering. Contains all of the filter fields.

	// Initialize the string and the And flag
	var sFilter = "";
	var bAndNeeded = false;

	// Loop through all fields and build the string
	var colFields = new Enumerator(blkFilter);
	while (!colFields.atEnd()) {
		// Get the field name
		sFieldName = colFields.item();

		// Get the value and add to the string if not blank
		sFieldValue = Request.Form(sFieldName);
		if ((sFieldValue != "undefined") && (sFieldValue != "")) {
			// Determine if the keyword "AND" is required
			if (bAndNeeded) {
				sAndClause = "AND " ;
			} else {
				sAndClause = " " ;
			}

			// Add in the current field to the filter string.
			// If the field is a multi-line entry type, limit it to first 4000 characters
			var recField = eWare.FindRecord("Custom_Edits","ColP_ColName = '" + sFieldName + "'");
			if (recField.ColP_EntryType == 11) {
				sFilter = sFilter + sAndClause + "SUBSTRING(" + sFieldName + ",1,100) LIKE '%" + sFieldValue + "%' ";
			} else {
				sFilter = sFilter + sAndClause + sFieldName + "='" + sFieldValue + "' ";
			}

			// Trigger the And flag once a search criteria has been added
			bAndNeeded = true;
		}

		// Move to the next field
		colFields.moveNext();
   }

	// Don't return a string if there are any undefined values
	if (sFilter.indexOf('undefined') > 0) {
		return("");
	} else {
		return(sFilter);
	}
}

function pcg_CreatePipeline(sEntityName, sIdFieldName, sCategoryFieldName, sFilterFieldName, sFilterFieldValue) {
   // Description: This function creates a pipeline object based on the parameters.
   // Paramters:
   // 	sEntityName - Table used to get pipeline information.
   // 	sIdFieldName - Id Field for the table, used for counting unique records.
   //		sCategoryFieldName - Field used to build pipeline sections (typically a "Stage" field).
   // 	sFilterFieldName - Field used to filter resulting data (typically a "User" or "Channel" field).
   //		sFilterFieldValue - Value of the current filter field.

	// Build the pipeline with default settings
	var pipeMain = eWare.GetBlock("pipeline");
	with (pipeMain) {
		PipelineStyle("SelectedWidth", "10");
		PipelineStyle("SelectedHeight", "10");
		PipelineStyle("PipeWidth", "10");
		PipelineStyle("PipeHeight", "15");
		PipelineStyle("Margin", "100");
		PipelineStyle("Shape", "circle");
		PipelineStyle("UseGradient", "False");
		PipelineStyle("Animated", "False");
		PipelineStyle("Selected", "");
		PipelineStyle("ShowLegend", "True");
		PipelineStyle("ChooseBackGround", "1");
	}

	// Configure the default summary as an empty table
	pipeMain.Pipe_Summary = "<TABLE bgcolor=ffffff width=275>" +
							  "<TR>" +
							  "<TD Class=TableHead colspan=3>" + eWare.GetTrans(sEntityName , sEntityName) + " Totals</TD>" +
							  "</TR>" +
							  "</TABLE>";

	// Create the pipe segments
	// This SQL statement aggregates the data on the id field for the entity specified
	// to provide a total count for records falling within each category specified.
	// It also joins in the Custom_Captions table to allow the pipeline to be ordered
	// as specified by the capt_order column.
	var sView = "SELECT COUNT(" + sIdFieldName + ") AS a, ";
	sView = sView + sCategoryFieldName + " ";
	sView = sView + "FROM " + sEntityName + " ";
	sView = sView + "LEFT OUTER JOIN Custom_Captions ON Custom_Captions.Capt_Code = " + sEntityName + "." + sCategoryFieldName + " ";
	sView = sView + "WHERE (" + sFilterFieldName + " = " + sFilterFieldValue + ") ";
	sView = sView + "AND Custom_Captions.Capt_Family = '" + sCategoryFieldName + "' ";
	sView = sView + "GROUP BY " + sCategoryFieldName + ", Custom_Captions.Capt_Order ";
	sView = sView + "ORDER BY Custom_Captions.Capt_Order DESC ";

	// Add each of the category counts into the pipeline
	var qryPipe = eWare.CreateQueryObj(sView);
	qryPipe.SelectSQL();
	while (!qryPipe.EOF) {
		sLabel = qryPipe(sCategoryFieldName);
		sValue = qryPipe("a");
		pipeMain.AddPipeEntry(sLabel, parseFloat(sValue), String(sValue));
		qryPipe.Next();
	}

	return(pipeMain);
}

function pcg_FormatDecimals(dAmount, iDecimals)	{
   // Description: This function formats a number to 2 decimal places.

	var i = parseFloat(dAmount);
	var minus = '';

	if (isNaN(i)) {
		i = 0.00;
	}

	if (i < 0) {
		minus = '-';
	}

	i = Math.abs(i);
	i = parseInt((i + .005) * 100);
	i = i / 100;

	var s = new String(i);

	if (s.indexOf('.') < 0) {
		s += '.00';
	}
	if (s.indexOf('.') == (s.length - 2)) {
		s += '0';
	}
	s = minus + s;

	return(s);
}

function pcg_CreateMergeDataFile(sSQL, sSelectString, sServerDatPath, sClientMergePath, sUrlToData) {
    // Description: This function creates a data file based on the parameters.
    // Parameters:
    // 	sSQL - String to create the database with
    // 	sPath - Path of the data file that is to be appended
	//    objScreen - Related screen to get fields from

	var sFieldValues = "";
	var sFieldNames = "";
	var sFieldName = "";
	var bFlag = 0;
	var aryFields = "";
	var i = 0;

	// Create the recordset with the sql statement passed in
	qryMain = eWare.CreateQueryObj(sSQL);
	qryMain.SelectSql();

	bFlag = 0;

	// Loop through the recordset getting each value of each field
	// Access fieldnames through array number and length of array
	while (!qryMain.eof) {
	var aryFields = sSelectString.split(",");
	sFieldValues = sFieldValues + "\r\n";
	// Step through each field in each record
		for (var i=0; i < aryFields.length; i++) {
			// Get the select string and loop through each field
			if (sSelectString.indexOf(', ') > 0) {

				// trim off the comma and space after each field name
				var aryFields = sSelectString.split(", ");

				// if field value is undefined then just create a blank
				if ((qryMain(aryFields[i]) == null)) {
					sFieldValues = sFieldValues + "	";
				} else {
					sFieldValues = sFieldValues + qryMain(aryFields[i]) + "	";
				}

				// only get field names if first time through the loop (0), then set to 1
				if (bFlag == 0) {
					sFieldName = aryFields[i];
					sFieldNames = sFieldNames + eWare.GetTrans('ColNames',sFieldName) + "	";
				}
			} else if (aryFields != '') {
				sFieldValues = sFieldValues;
			}
		}
	bFlag = 1;
	qryMain.NextRecord();
	}

	sFieldNames = sFieldNames;

   // Open the file, add the field names and values strings and close the file
	var ForReading=1,ForWriting=2,ForAppending=8;
	var TristateUseDefault = -2, TristateTrue = -1, TristateFalse = 0;
	var objFile;

	var mySystemObject = new ActiveXObject('Scripting.FileSystemObject');
	if (mySystemObject.FileExists(sServerDatPath)) {
		// Assumes the file exists
		var myFile = mySystemObject.GetFile(sServerDatPath);
		var myFileTextStream = myFile.OpenAsTextStream(ForWriting,TristateUseDefault);
		myFileTextStream.WriteLine(sFieldNames + sFieldValues);
		myFileTextStream.Close();
	} else {
		var myFileTextStream = mySystemObject.CreateTextFile(sServerDatPath);
		myFileTextStream.WriteLine(sFieldNames + sFieldValues);
		myFileTextStream.Close();
	}

	// Date concatenation to add to the URL for XMLHttp
	// to prevent text file from caching on client
	var now = new Date();
	var year        = now.getYear();
	var monthnumber = String(now.getMonth() + 1);
	var monthday    = String(now.getDate());
	var hour        = String(now.getHours());
	var minute      = String(now.getMinutes());
	var second      = String(now.getSeconds());
	var sFullDate = year + monthnumber + monthday + hour + minute + second;

	// Create the dat file on the client computer
	Response.Write("<script language=javascript>");
	Response.Write("var xmlhttp, ie=(navigator.userAgent.toLowerCase().indexOf(\"msie\")!=-1?true:false);\n");
	Response.Write("var url = \"" + sUrlToData + "?d=" + sFullDate + "\";\n");
	Response.Write("	try{\n");
	Response.Write("		  xmlhttp = new ActiveXObject(\"Msxml2.XMLHTTP.4.0\");\n");
	Response.Write("	 } catch(e) {\n");
	Response.Write("		  try {\n");
	Response.Write("				xmlhttp = new ActiveXObject(\"Msxml2.XMLHTTP\");\n");
	Response.Write("		  } catch(e){\n");
	Response.Write("				try {\n");
	Response.Write("					xmlhttp = new ActiveXObject(\"Microsoft.XMLHTTP\");\n");
	Response.Write("				} catch(e){\n");
	Response.Write("					try {\n");
	Response.Write("						 xmlhttp = new XMLHttpRequest();\n");
	Response.Write("					} catch(e){\n");
	Response.Write("						 xmlhttp=null;\n");
	Response.Write("					}\n");
	Response.Write("				}\n");
	Response.Write("		  }\n");
	Response.Write("	 }\n");
	Response.Write("	xmlhttp.open(\"GET\", url, false);\n");
	Response.Write("  	xmlhttp.setRequestHeader(\"Content-type\",\"text/xml\");\n");
	Response.Write("  	xmlhttp.setRequestHeader(\"Pragma\",\"no-cache\");\n");
	Response.Write("  	xmlhttp.setRequestHeader(\"Cache-control\",\"no-cache\");\n");
	Response.Write("	xmlhttp.send(null);\n");
	Response.Write("	xmlhttp.responseText;\n");
	Response.Write("	var mySystemObject = new ActiveXObject('Scripting.FileSystemObject');\n");
	Response.Write("  	var myFileTextStream = mySystemObject.CreateTextFile(\"" + sClientMergePath + "\");\n");
	Response.Write("	var sHttpText = String(xmlhttp.responseText);\n");
	Response.Write("	var sHttpText2 = sHttpText.substring(0,sHttpText.length-2); \n");
	Response.Write("	myFileTextStream.WriteLine(sHttpText2);\n");
	Response.Write("	myFileTextStream.Close();\n");
	Response.Write("</script>");
}

function pcg_CreateWordMergeDoc(sLibraryPath, sMergeHeader, sMergeTemplate, sTempPatha, sTempPathb, lId, sSID, lCompId, lPersId, lUserId, sClientDatPath2) {
	// Description:  this function creates a Word merge file in the temp directory
	// CRM takes the file from the temp directory and copies it into the
	// directory specified by the library path.  A directory will be created based on
	// the company, person, or user if it doesnt already exist.

	// If the company exists, get the company name and library directory fields
	if (lCompId != null) {
		recMain = eWare.FindRecord("Company","comp_CompanyId=" + lCompId);
		sFileName = recMain.comp_name;
		sLibDir = recMain.comp_LibraryDir;

		// Replace back slashes with forward slashes on the library directory field
		var aryFields = sLibDir.split("\\");
		sPath = "";
		for (var i=0; i < aryFields.length; i++) {
			var sPath = sPath + aryFields[i] + "/";
		}
	} else if (lPersId != null) {
		// If the person exists, name the folder and filename from the person
		recMain = eWare.FindRecord("Person","pers_PersonId=" + lPersId);
		sFileName = recMain.pers_firstname + " " + recMain.pers_lastname;
		sLibDir = recMain.pers_LibraryDir;

		// Replace back slashes with forward slashes on the library directory field
		var aryFields = sLibDir.split("\\");
		sPath = "";
		for (var i=0; i < aryFields.length; i++) {
			var sPath = sPath + aryFields[i] + "/";
		}
	} else {
		// If the user exists, name the folder and filename from the user
		recMain = eWare.FindRecord("Users","user_UserId=" + lUserId);
		sFileName = recMain.user_firstname + " " + recMain.user_lastname;
	}

	// Get the first character of the company or person to create a directory
	var sChar = sFileName;
	var sFirstChar = sChar.charAt(0);

	// Get todays date to concatenate the filename
	var dtToday = new Date();
	var dtMonth = dtToday.getMonth() + 1;
	var dtDay = dtToday.getDate();
	var dtYear = dtToday.getFullYear();
	var sFileDate = dtMonth + "." + dtDay + "." + dtYear + ".doc";

	// Create folder for file to be saved in
	var objFS = new ActiveXObject("Scripting.FileSystemObject");

	// Start the drive path to the library docs\n");
	sDrivePath = sLibraryPath + sPath;

	if (objFS.FolderExists(sDrivePath)) {
	} else {
		// Create the directory if it doesnt exist, then concatenate the full path with filename\n");
		var sFilePath = objFS.CreateFolder(sDrivePath);
	}

	Response.Write("<html>\n");
	Response.Write("<head>\n");
	Response.Write("<title>load document</title>\n");
	Response.Write("<script language=JavaScript>\n\n");
	Response.Write("<!--//\n\n");
	Response.Write("function loadworddoc(){\n\n");
	Response.Write("	var objWshShell = new ActiveXObject(\"WScript.Shell\");\n");
	Response.Write("    var strUsername = objWshShell.ExpandEnvironmentStrings(\"%USERNAME%\");\n\n");
	Response.Write("	// Create the Word object, open the merge template\n");
	Response.Write("	var doc = new ActiveXObject(\"Word.Application\");\n");
	Response.Write("	doc.Documents.Open(\"" + sMergeTemplate + "\");\n");
	Response.Write("	doc.Visible = false;\n\n");
	Response.Write("	// Open the Word data file, merge to a new document, then run the merge \n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.OpenDataSource(\"" + sMergeHeader + "\");\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Destination = doc.application.ActiveDocument.wdSendToNewDocument;\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Execute();\n\n");
	Response.Write("    sFullFileName = '" + sTempPatha + "' + strUsername + '" + sTempPathb + "' + '" + sFileName + "' + '" + sFileDate + "';");
	Response.Write("	doc.application.ActiveDocument.SaveAs(sFullFileName);\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.Visible = true;\n");
	Response.Write("	doc.Documents.Open(sFullFileName);\n");
	Response.Write("    doc.application.ActiveDocument.SaveAs(sFullFileName);\n");
	Response.Write("    var mySystemObject = new ActiveXObject(\"Scripting.FileSystemObject\");\n");
	Response.Write("    if (mySystemObject.FileExists(\"" + sClientDatPath2 + "\")) { \n");
	Response.Write("    	var myFile = mySystemObject.DeleteFile(\"" + sClientDatPath2 + "\");\n");
	Response.Write("    }");
	Response.Write("}\n\n");
	Response.Write("//-->\n");
	Response.Write("</script>\n");
	Response.Write("</head>\n");

	// Concatenate the redirect URL when the page loads
	sEwareURL = "../../eware.dll/Do?";
	sKeysValues = "SID=" + sSID + "&Act=546&Mode=1&CLk=T&Key0=6&Key1=" + lCompId + "&Key2=" + lPersId + "&Key37=" + lId + "&lbqt_QuoteID=" + lId;
	sDirectory = "&SaveDocDir=" + sPath + "&SaveDocName=" + sFileName + sFileDate + "&T=Person"
	sNextURL = sEwareURL + sKeysValues + sDirectory;
	Response.Write("<body onLoad=\"loadworddoc();\">");
//	Response.Write("<body onLoad=\"loadworddoc();\" onFocus=\"location.href='" + sNextURL + "';\" bgcolor=#EDEDE1></body>\n");
	Response.Write("</html>");

}

function pcg_CreateWordMergeDocWithDetails(sLibraryPath, sMergeHeader, sMergeTemplate, sClientDatPath1, sClientDatPath2, sTempPatha, sTempPathb, lId, sSID, lCompId, lPersId, lUserId, sIdKeyValue, sTempPath, sFileName1, sEntity, sURL) {
	// Description:  this function creates a Word merge file in the temp directory
	// CRM takes the file from the temp directory and copies it into the
	// directory specified by the library path.  A directory will be created based on
	// the company, person, or user if it doesnt already exist.

	// If the company exists, get the company name and library directory fields
	if (lCompId != null) {
		recMain = eWare.FindRecord("Company","comp_CompanyId=" + lCompId);
		sFileName = recMain.comp_name;
		sLibDir = recMain.comp_LibraryDir;

		// Replace back slashes with forward slashes on the library directory field
		var aryFields = sLibDir.split("\\");
		sPath = "";
		for (var i=0; i < aryFields.length; i++) {
			var sPath = sPath + aryFields[i] + "/";
		}
	} else if (lPersId != null) {
		// If the person exists, name the folder and filename from the person
		recMain = eWare.FindRecord("Person","pers_PersonId=" + lPersId);
		sFileName = recMain.pers_firstname + " " + recMain.pers_lastname;
		sLibDir = recMain.pers_LibraryDir;

		// Replace back slashes with forward slashes on the library directory field
		var aryFields = sLibDir.split("\\");
		sPath = "";
		for (var i=0; i < aryFields.length; i++) {
			var sPath = sPath + aryFields[i] + "/";
		}
	} else {
		// If the user exists, name the folder and filename from the user
		recMain = eWare.FindRecord("Users","user_UserId=" + lUserId);
		sFileName = recMain.user_firstname + " " + recMain.user_lastname;
	}

	// Get the first character of the company or person to create a directory
	var sChar = sFileName;
	var sFirstChar = sChar.charAt(0);

	// Get todays date to concatenate the filename
	var dtToday = new Date();
	var dtMonth = dtToday.getMonth() + 1;
	var dtDay = dtToday.getDate();
	var dtYear = dtToday.getFullYear();
	var dtHour = dtToday.getHours();
	var dtMinute = dtToday.getMinutes();
	var dtSecond = dtToday.getSeconds();
	var sFileDate = dtMonth + "." + dtDay + "." + dtYear + ".doc";

	// CREATE THE FOLDERS ON THE SERVER FOR
	// THE DOCCUMENT TO BE SAVE
	var objFS = new ActiveXObject("Scripting.FileSystemObject");

	// Create the first folder in the path docs
	sDrivePath = sLibraryPath + aryFields[0];
	if (objFS.FolderExists(sDrivePath)) {
	} else {
		var sFilePath = objFS.CreateFolder(sDrivePath);
	}
	// Create the second folder in the path docs
	sDrivePath = sLibraryPath + aryFields[0] + "/" + aryFields[1];
	if (objFS.FolderExists(sDrivePath)) {
	} else {
		var sFilePath = objFS.CreateFolder(sDrivePath);
	}

	// RUN THE WORD MERGE IN THE CLIENT BROWSER
	Response.Write("<html>\n");
	Response.Write("<head>\n");
	Response.Write("<title>load document</title>\n");
	Response.Write("<script language=JavaScript>\n");
	Response.Write("\n");
	Response.Write("<!--//\n\n");
	Response.Write("function loadworddoc(){\n\n");
	Response.Write("	var objWshShell = new ActiveXObject(\"WScript.Shell\");\n");
	Response.Write("    var strUsername = objWshShell.ExpandEnvironmentStrings(\"%USERNAME%\");\n\n");
	Response.Write("	// Create the Word object, open the merge template\n");
	Response.Write("	var doc = new ActiveXObject(\"Word.Application\");\n");
	Response.Write("	doc.Visible = false;\n\n");
	Response.Write("	doc.Documents.Open(\"" + sMergeTemplate + "\");\n");
	Response.Write("	// Open the Word data file, merge to a new document, then run the merge \n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.OpenDataSource(\"" + sMergeHeader + "\");\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Destination = doc.application.ActiveDocument.wdSendToNewDocument;\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Execute();\n\n");
	Response.Write("    sFullFileName = '" + sTempPatha + "' + strUsername + '" + sTempPathb + "' + '" + sFileName + " ' + '" + sFileDate + "';");
	Response.Write("	doc.application.ActiveDocument.SaveAs(sFullFileName);\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.Quit(0);\n");

	// Delete the data files on the client after the merge is run
	Response.Write("    var mySystemObject = new ActiveXObject(\"Scripting.FileSystemObject\");\n");
	Response.Write("    if (mySystemObject.FileExists(\"" + sClientDatPath1 + "\")) { \n");
	Response.Write("    	var myFile = mySystemObject.DeleteFile(\"" + sClientDatPath1 + "\");\n");
	Response.Write("    }");
	Response.Write("    if (mySystemObject.FileExists(\"" + sClientDatPath2 + "\")) { \n");
	Response.Write("    	var myFile = mySystemObject.DeleteFile(\"" + sClientDatPath2 + "\");\n");
	Response.Write("    }\n");
	Response.Write("    CopyIntoMainDoc();\n");
	Response.Write("}\n");
	Response.Write("//-->\n");
	Response.Write("</script>\n");

    Response.Write("<script language=VBScript>\n");
    Response.Write("function CopyIntoMainDoc() \n");
    Response.Write("    Set objWshShell = CreateObject(\"WScript.Shell\")\n");
    Response.Write("    strUsername = objWshShell.ExpandEnvironmentStrings(\"%USERNAME%\")\n");
	Response.Write("    sFullFileName = \"" + sTempPatha + "\" & strUsername & \"" + sTempPathb + "\" & \"" + sFileName + " \" & \"" + sFileDate + "\"\n");
    Response.Write("    sItemsFile = \"" + sTempPath + sFileName1 + "\"\n");
    Response.Write("    Set objWord = CreateObject(\"Word.Application\")\n");
    Response.Write("    objWord.Visible = true\n");
	Response.Write("    objWord.Documents.Open sFullFileName\n");
	Response.Write("    objWord.Documents.Open sItemsFile \n");
	Response.Write("    objWord.Selection.WholeStory\n");
	Response.Write("    objWord.Selection.Copy\n");
	Response.Write("    objWord.application.ActiveDocument.Close (False)\n");
	Response.Write("    objWord.Selection.Find.Text=\"Dear\"\n");
	Response.Write("    objWord.Selection.Find.Execute()\n");
	Response.Write("    objWord.Selection.EndKey\n");
	Response.Write("    objWord.Selection.TypeParagraph\n");
	Response.Write("    objWord.Selection.TypeParagraph\n");
	Response.Write("    objWord.Selection.TypeParagraph\n");
	Response.Write("    objWord.Selection.TypeParagraph\n");
	Response.Write("    objWord.Selection.Paste\n");
	Response.Write("	objWord.application.ActiveDocument.SaveAs sFullFileName \n");
	Response.Write(" end function \n");
	Response.Write("</script>\n");
	Response.Write("</head>\n");

	// GET VALUES TO BUILD URL, THEN REDIRECT
	// TO THE COMMUNICATION SCREEN
	recWorkflow = eWare.FindRecord("WorkflowInstance","WkIn_CurrentRecordId=" + lId);
	sWkId = recWorkflow.WkIn_InstanceId;
	// Concatenate the redirect URL when the page loads
	sEwareURL = "/CRM57c/eWare.dll/Do?";
	sKeysValues = "SID=" + sSID + "&Act=546&Mode=1&CLk=T&Key-1=58&Key0=58&Key1=" + lCompId + "&Key2=" + lPersId + "&Key37=" + lId + "&Key50=" + sWkId + "&Key58=" + lId + "&" + sIdKeyValue + "&E=" + sEntity + "&PrevCustomURL=/crm57c/CustomPages/" + sEntity + "/" + sEntity + "Communication.asp?SID=" + sSID + "%26Key0=58%26Key1=" + lCompId + "%26Key2=" + lPersId + "%26Key37=" + lId + "%26Key50=" + sWkId + "%26Key58=" + lId + "%26J=" + sEntity + "/" + sEntity + "Communication.asp%26F=" + sEntity + "/" + sEntity + "Summary.asp%26" + sIdKeyValue + "%26T=" + sEntity;
	sDirectory = "&SaveDocDir=" + sPath + "&SaveDocName=" + sFileName + " " + sFileDate
	sNextURL = sEwareURL + sKeysValues + sDirectory;
	Response.Write("<body onLoad=\"loadworddoc();\">");
//	Response.Write("<body onLoad=\"loadworddoc();\" onFocus=\"location.href='" + sNextURL + "';\" bgcolor=#EDEDE1></body>\n");
	Response.Write("</html>");

}

function pcg_CreateWordMergeDetails(sMergeHeader, sMergeTemplate, sTempPath, sFileName, sSID) {

	// Create folder for file to be saved in
	var objFS = new ActiveXObject("Scripting.FileSystemObject");

	//  DONT CHECK THE PATH SINCE A FOLDER IS MAPPED DIRECTLY TO THE DOC TEMPLATES
	//	if (objFS.FolderExists(sTempPath)) {
	//	} else {
	//		// Create the directory if it doesnt exist, then concatenate the full path with filename\n");
	//		var sFilePath = objFS.CreateFolder(sTempPath);
	//	}
	// Now that the directory is created, save the Word document into the path specified
	var sFullName = sTempPath + sFileName;

	// Start a new object
	Response.Write("<html>\n");
	Response.Write("<head>\n");
	Response.Write("<script language=JavaScript>\n");
	Response.Write("\n");
	Response.Write("<!--//\n\n");
	Response.Write("function loadworddoc(){\n\n");
	Response.Write("	var doc = new ActiveXObject(\"Word.Application\");\n");
	Response.Write("	doc.Visible = false;\n\n");
	Response.Write("	doc.Documents.Open(\"" + sMergeTemplate + "\");\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.MainDocumentType = 3;\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.OpenDataSource(\"" + sMergeHeader + "\");\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Destination = doc.application.ActiveDocument.wdSendToNewDocument;\n");
	Response.Write("	doc.application.ActiveDocument.MailMerge.Execute();\n\n");
	Response.Write("    doc.application.ActiveDocument.fields.Update();\n");
	Response.Write("	doc.application.ActiveDocument.SaveAs(\"" + sFullName + "\");\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.application.ActiveDocument.Close(false);\n");
	Response.Write("	doc.Quit(0);\n\n}\n");
	Response.Write("//-->\n");
	Response.Write("</script>\n");
	Response.Write("</head>\n");

	// Concatenate the redirect URL when the page loads
	sEwareURL = "MergeStep3.asp?";
	sKeysValues = "SID=" + sSID + "&Mode=1&CLk=T&Key0=2&Key1=" + lCompId + "&Key2=" + lPersId + "&lbqt_QuoteID=" + lId + "&createmerge=header"
	sNextURL = sEwareURL + sKeysValues;
//  Response.Write("<body onLoad=\"loadworddoc();\" bgcolor=#EDEDE1></body>\n");
	Response.Write("<body onLoad=\"loadworddoc();location.href='" + sNextURL + "';\" bgcolor=#EDEDE1></body>\n");
	Response.Write("</html>");
}

function CheckHasValue(strVal) {
	// This function returns true if the string is not
	// null, undefined, or empty
	// SAMPLE: if (CheckHasValue(strVal))
	if ((strVal == "undefined") || (strVal == null) || (strVal == "")) {
		strVal = false;
	} else {
		strVal = true;
	}
	return(strVal);
}

function CheckHasValueSetToZero(strVal) {
	// This function returns 0 if the string is
	// null, undefined, or empty
	// SAMPLE: if (CheckHasValueSetToZero(strVal))
	if ((strVal == "undefined") || (strVal == null) || (strVal == "")) {
		strVal = 0;
	}
	return(strVal);
}

function ReplaceXMLReservedChars(strVal) {
	// This function replaces characters that cant be used in XML files
	// with their ascii equivalent
	// SAMPLE:  if (ReplaceXMLReservedChars(strVal)) {
	if (strVal.indexOf("&") > 0) {
		strVal = strVal.replace("&","&amp;");
	} else if (strVal.indexOf('"') > 0) {
		strVal = strVal.replace('"',"&quot;");
	} else if (strVal.indexOf("'") > 0) {
		strVal = strVal.replace('"',"&apos;");
	} else if (strVal.indexOf("<") > 0) {
		strVal = strVal.replace("<","&lt;");
	} else if (strVal.indexOf(">") > 0) {
		strVal = strVal.replace(">","&gt;");
	} else {
		strVal = false;
	}
	sReplacedString = strVal;
	return(strVal);
}

function getUniqueElements(ctrl, compareAgainst){
     ctrl.sort();
     compareAgainst.sort();
     var dupFound = false;
     var newList = "";

     for (i = 0; i < ctrl.length; i++) {
		for (j = 0; j < compareAgainst.length; j++) {
			if (ctrl[i] == compareAgainst[j]) {
				dupFound = true;
				break;
			}
		}
			if (!dupFound) newList += ctrl[i] + "|";
			dupFound = false;
     }

     var uniqueElements = new Array();
     uniqueElements = newList.substring(0, newList.length - 1).split("|");
     return uniqueElements;
}

function openCRMPanelHTML(sPanelName, sPanelNamePlural, sRecordCount, sWidth) {
	if (sWidth == "1") sWidth = "95\%";
	else if (sWidth == "2") sWidth = "45\%";
	else if (sWidth == "3") sWidth = "30\%";
	else sWidth = "45\%";

	sPanelHTML = "\n\n<!--BEGIN PANEL-->\n<TABLE WIDTH=" + sWidth + " BORDER=0 CELLPADDING=0 CELLSPACING=0 RULES=NONE ALIGN=LEFT><TR><TD COLSPAN=2>\n  <TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 ><TR><TD VALIGN=BOTTOM><IMG SRC=../../img/backgrounds/paneleftcorner.jpg HSPACE=0 BORDER=0 ALIGN=TOP></TD>    <TD NOWRAP=true WIDTH=10% CLASS=PANEREPEAT>";
	if (sRecordCount == 0) {
		sPanelHTML += "No " + sPanelName;
	} else if (sRecordCount == '-1') {
		sPanelHTML += sPanelName;
	} else if (sRecordCount > 1) {
		sPanelHTML += sRecordCount + " " + sPanelNamePlural;
	} else {
		sPanelHTML += sRecordCount + " " + sPanelName;
	}
	sPanelHTML += "</TD><TD VALIGN=BOTTOM><IMG SRC=../../img/backgrounds/panerightcorner.gif HSPACE=0 BORDER=0 ALIGN=TOP></TD><TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD><TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD><TD ALIGN=BOTTOM COLSPAN=30 WIDTH=90% CLASS=TABLETOPBORDER >&nbsp;</TD></TR></TABLE></TD></TR>";
	return sPanelHTML;
}

function openCRMContentHTML() {
	sPanelHTML = "<!--BEGIN CONTENT PANEL--><TR CLASS=CONTENT><TD WIDTH=1px CLASS=TABLEBORDERLEFT><IMG SRC=../../img/backgrounds/tabletopborder.gif HSPACE=0 BORDER=0 ALIGN=TOP></TD><TD HEIGHT=100% WIDTH=100% CLASS=VIEWBOXCAPTION>\n    <TABLE CLASS=CONTENT WIDTH=\"100%\"><TR><TD VALIGN=TOP>";
	return sPanelHTML;
}

function closeCRMPanelHTML() {
	sPanelHTML = "<TR HEIGHT=1><TD COLSPAN=3 WIDTH=1px CLASS=TABLEBORDERBOTTOM></TD></TR><!--<TR><TD CLASS=ROWGap COLSPAN=6>&nbsp;</TD></TR>--></TABLE>\n<!--END PANEL-->";
	return sPanelHTML;
}

function closeCRMContentHTML() {
	sPanelHTML = "</TD></TR></TABLE></TD><TD WIDTH=1px CLASS=TABLEBORDERRIGHT><IMG SRC=../../img/backgrounds/tabletopborder.gif HSPACE=0 BORDER=0 ALIGN=TOP></TD></TR><!--END CONTENT PANEL-->";
	return sPanelHTML;
}

function buildCRMPanel(sPanelName,sPanelNamePlural,sRecordCount,sContent,sWidth) {
	var sOpenPanel = openCRMPanelHTML(sPanelName,sPanelNamePlural,sRecordCount, sWidth);
	var sContentPanel = openCRMContentHTML();
	var sContentPanelClose = closeCRMContentHTML();
	var sClosePanel = closeCRMPanelHTML();
	var sHTMLString = sOpenPanel + sContentPanel + sContent + sContentPanelClose + sClosePanel;
	return sHTMLString;
}

function pcg_buildRecMain(sSelect,blkMain,sEntity,sWhereClause,sColPrefix) {
	var sSQLSelect = sSelect + " ";
	var sSQLSelectString = pcg_BuildSelectFields(blkMain);
	var sSQLFrom = " FROM " + sEntity;
	var sSQLWhere = " WHERE " + sWhereClause;
	var sSQL = sSQLSelect + sSQLSelectString + sSQLFrom + sSQLWhere + " AND " + sColPrefix + "_Deleted IS NULL";
	recMain = eWare.CreateQueryObj(sSQL);
	recMain.SelectSQL();
	return recMain;
}

function pcg_SpacerTable(lWidth) {
	sHTMLString = "<table cellpadding=" + lWidth + " align=left><tr><td></td></tr></table>";
	return sHTMLString;
}

%>
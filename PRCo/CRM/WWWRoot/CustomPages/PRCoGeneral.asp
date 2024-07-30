<%
bDebug = false;
/**********************
 *  This function allow wrapped Debug info to appear on the screen
 *********************/
function DEBUG(sMessage)
{
    if (bDebug)
        Response.Write("<br/>" + sMessage);
}


sURL= String( Request.ServerVariables("URL")+ "?" + Request.QueryString() );
DEBUG("URL:"+sURL+"<br>");
SID = String (Request.QueryString("SID"));
F= String (Request.QueryString("F"));
if (F=="undefined") F = "";
DEBUG("FValue: " + F)
J= String (Request.QueryString("J"));
if (J=="undefined") J = "";
DEBUG("JValue: " + J)
user_userid = eWare.getContextInfo("User", "User_UserId");
recUser = eWare.FindRecord("User", "User_UserId="+user_userid );

recChannelLink = eWare.FindRecord("Channel_Link", "chli_User_id=" + user_userid);
sUserGroupIds = ",";
if (recUser("user_PrimaryChannelId") != "undefined" && recUser("user_PrimaryChannelId") != "")
    sUserGroupIds += recUser("user_PrimaryChannelId") + ",";
// now add the entries from Display Teams in the Admin interface
while (!recChannelLink.eof)
{
    sUserGroupIds += recChannelLink("chli_Channel_Id") + ",";
    recChannelLink.NextRecord();
}

function isUserInGroup(sGroupId)
{
    var bReturn = false;
    if (sGroupId.indexOf(",") > -1)
    {
		var sSplit = sGroupId.split(",");
		for (var i=0; i<sSplit.length; i++)
		{
            if (sUserGroupIds.indexOf(","+ sSplit[i] + "," ) > -1)
            {
                bReturn = true;
                break;
            }
		}
    
    } else {
        if (sUserGroupIds.indexOf(","+ sGroupId + "," ) > -1)
            bReturn = true;
    }
    return bReturn;
}


function eWareUrl(sURL)
{
    return "/" + sInstallName + "/" + "CustomPages/" + sURL + "?SID=" + SID;
}



/* ***********************
 * This function checks for a field name value on the form in the following order:
 *    - the query string for field name
 *    - the form items array for field name (note: this is case sensitive)
 *
 *************************/
function getIdValue(sFieldName)
{
    var sValue = String(Request.Querystring(sFieldName));
    if (isEmpty(sValue))
        sValue = String(Request.Form.Item(sFieldName));
    if (isEmpty(sValue))
        sValue = String("-1");
    var arr = sValue.split(",");
    sValue = null;
    return arr[0].valueOf();
}

function getFormValue(sFieldName)
{
    sValue = String(Request.Form.Item(sFieldName));
    return sValue ;
}

function isEmpty(sValue)
{
	var bReturn = false;
	if (!Defined(sValue) || sValue == null || sValue == "undefined" )
	    bReturn = true;
	sValue = String(sValue);
	if (sValue == "" || sValue.length == 0 )
	    bReturn = true;

    // For Sage CRM 7.2b, the "All" filter options were changed from empty
    // strings to this value.
    if (sValue == "sagecrm_code_all") 
        return true;


	//Accpac empty date
	if (sValue == "Sat Dec 30 00:00:00 CST 1899")
	    bReturn =  true
	sValue = null;
	return bReturn;
}

function trim(sInString) {
  sInString = sInString.replace( /^\s+/g, "" );// strip leading
  return sInString.replace( /\s+$/g, "" );// strip trailing
}

function formatDollar(sValue)
{
    if (isEmpty(sValue)) {
        return "";
    }

    sValue = String(parseFloat(sValue).toFixed(2));
    return formatCommaSeparated(sValue);
}


function formatCommaSeparated(sValue)
{
    sValue = String(sValue);
    var objRegExp  = new RegExp('(-?[0-9]+)([0-9]{3})');

    //check for match to search criteria
    while(objRegExp.test(sValue)) {
       //replace original string with first group match,
       //a comma, then second group match
       sValue = sValue.replace(objRegExp, '$1,$2');
    }
    objRegExp = null;
  return sValue;
}

function getString(sValue)
{
	if (isEmpty(sValue))
	    return String("");
	    
	return String(sValue);
}	

function getDateAsString(sValue)
{
    var sReturn = "";
    if (sValue == null || sValue == "undefined")
        dtValue = new Date();
    else
        dtValue = new Date(sValue);
    sMonth = dtValue.getMonth()+1;
    sDay = dtValue.getDate();
    sReturn = ((sMonth<10?"0"+sMonth:sMonth) + "/" + (sDay<10?"0"+sDay:sDay) +  "/" + dtValue.getFullYear());
    dtValue = null;
    return sReturn;
}

function formatDateTime(dateValue) {

    var dateVal = new Date(dateValue);

    var a_p = "";
    var curr_day = dateVal.getDate();
    var curr_month = dateVal.getMonth() + 1;
    var curr_year = dateVal.getFullYear();
    var curr_hour = dateVal.getHours();
    var curr_min = dateVal.getMinutes();

    if (curr_hour < 12) {
        a_p = "AM";
    } else {
        a_p = "PM";
    }

    if (curr_hour == 0) {
        curr_hour = 12;
    }
    if (curr_hour > 12) {
        curr_hour = curr_hour - 12;
    }

    curr_min = "" + curr_min
    if (curr_min.length == 1) {
        curr_min = "0" + curr_min;
    }

    return curr_month + "/" + curr_day + "/" + curr_year + " " + curr_hour + ":" + curr_min + " " + a_p;
}  


function getDBDate(sValue, sUserFormat)
{
    // convert to our SQL Server format.
    var sDateFormat = "mm/dd/yyyy";
    if (sUserFormat == null || isEmpty(sUserFormat) || sUserFormat == sDateFormat)
        return sValue;
    else
    {
        if (sUserFormat == "dd/mm/yyyy")
        {
            arrDate = sValue.split("/");
            sValue = arrDate[1]+"/"+arrDate[0]+"/"+arrDate[2];
        }
        return sValue;
    }
}

/*
    Returns the DateTime for use in queries
*/
function getDBDateTime(datetime) {
    if (datetime == null || datetime == "undefined")
        datetime = new Date();
    var sDate = (datetime.getMonth() + 1) + "/" + datetime.getDate() + "/" + datetime.getYear() + " " + datetime.getHours() + ":" + datetime.getMinutes() + ":" + datetime.getSeconds();
    datetime = null;
    return sDate;
}

/*
    Returns the Date for use in queries
*/
function getDBDate2(datetime) {
    if (datetime == null || datetime == "undefined")
        datetime = new Date();
    var sDate = (datetime.getMonth() + 1) + "/" + datetime.getDate() + "/" + datetime.getYear();
    datetime = null;
    return sDate;
}


function isValidDate(Value)
{
    var dt = null;
    try 
    {
        dt = new Date(Value);
        if (dt == null || dt == "undefined" || isNaN(dt))
            return false;
    }
    catch (exception)
    {
        return false;
    }finally
    {
        dt = null;
    }
    return true;
}

function setBlockCaptionAlignment(oBlock, CaptionPos)
{
    var colFields = new Enumerator(oBlock);
    while (!colFields.atEnd()) {
        // Get the field name
        var sFieldName = colFields.item();
        sFieldName.CaptionPos = CaptionPos;
        // Move to the next field
        colFields.moveNext();
    }
    colFields = null; 

}

function hideFieldsInBlock(oBlock, sFieldList)
{
    sFieldList = String(sFieldList).toLowerCase();
    var colFields = new Enumerator(oBlock);
    while (!colFields.atEnd()) {
        // Get the field name
        var oField = colFields.item();
        if (sFieldList.indexOf("," + oField.Name + ",") > -1)
        {
            oField.Hidden = true;
        }
        // Move to the next field
        colFields.moveNext();
    } 
    sFieldList = null;
    colFields = null;

}

function removeFieldsInBlock(oBlock, sFieldList)
{
    sFieldList = String(sFieldList).toLowerCase();
    var colFields = new Enumerator(oBlock);
    while (!colFields.atEnd()) {
        // Get the field name
        var oField = colFields.item();
        if (sFieldList.indexOf("," + oField.Name + ",") > -1)
        {
            oBlock.DeleteEntry(oField.Name);
        }
        // Move to the next field
        colFields.moveNext();
    } 
    sFieldList = null;
    colFields = null;
}

function removeKey(sQString, sKey)
{
	var sReturn = String(sQString);
	sQString = sQString.toLowerCase();
	sKey = sKey.toLowerCase();
	ndx = sQString.indexOf("&"+sKey+"=");

	if (ndx == -1) {
        ndx = sQString.indexOf("?"+sKey+"=");
	}

	if (ndx == -1) {
	    if (sQString.indexOf(sKey+"=") == 0) {
	      ndx = 0;
	    }
	}
	

	if (ndx >= 0 )
	{
		ndxNext = sQString.indexOf("&", ndx+2+sKey.length);
		if (ndxNext == -1)
			ndxNext = sQString.length;
		sReturn = sReturn.substring(0,ndx) + sReturn.substring(ndxNext,sQString.length);
	}
	return sReturn;
}	
function changeKey(sQString, sKey, value)
{
	var sReturn = String(sQString);
	ndx = sQString.indexOf("&"+sKey+"=");

	if (ndx == -1) {
        ndx = sQString.indexOf("?"+sKey+"=");
	}

	if (ndx == -1) {
	    if (sQString.indexOf(sKey+"=") == 0) {
	      ndx = 0;
	    }
	}

	if (ndx >= 0 )
	{
		ndxNext = sQString.indexOf("&", ndx+2+sKey.length);
		if (ndxNext == -1)
			ndxNext = sQString.length;
		sReturn = sQString.substring(0,ndx+2+sKey.length)+ value + sQString.substring(ndxNext,sQString.length);
	}
	else
	{
		ndx = sQString.indexOf("?");
		if (ndx == -1)
    		sReturn = sQString + "?" + sKey + "=" + value;
    	else
    		sReturn = sQString + "&" + sKey + "=" + value;
	}
	return sReturn;
}

function getDisplayHeader(sMsg, sClassName)
{
    return "<table width=\"100%\" class=\"" + sClassName + "\"><tr><td>" + sMsg + "</td></tr></table>";
}
function getErrorHeader(sMsg)
{
    return getDisplayHeader(sMsg, "ErrorContent");
}

function getInfoHeader(sMsg)
{
    return getDisplayHeader(sMsg, "InfoContent");
}

function DumpFormValues()
{
    var vItem
    Response.Write ("<br/>*** FORM VALUES  ***");
    for (x = 1; x <= Request.Form.count(); x++)
    {
        Response.Write ("<br/>" +  Request.Form.Key(x) + ": "  + Request.Form.Item(x));
    }
    Response.Write ("<br/>*** END FORM VALUES  ***");
}
function DumpCookieValues()
{
    Response.Write("<br/>**** COOKIE VARIABLES ****");
    var c = null;
    for (c = new Enumerator(Request.Cookies);
        !c.atEnd();
        c.moveNext()) {
        
        if (Request.Cookies(c).HasKeys) {
            for (ci = new Enumerator(Request.Cookies(c.item())); !ci.atEnd(); ci.moveNext()) {
                Response.Write("<br>  SubItem: " + c.item() + "(" + ci.item() + ") = ");
                Response.Write(Request.Cookies(c.item())(ci));
            }
        }
        else
        { 
                Response.Write("<br>Item: " + c.item() + " = ");
                Response.Write(Request.Cookies(c.item()));
        }
    }   
    c = null;     
    Response.Write("<br>**** END COOKIE VARIABLES ****");
}
function DumpServerValues()
{
    Response.Write("<br>**** SERVER VARIABLES ****");
    for (sv = new Enumerator(Request.ServerVariables); !sv.atEnd(); sv.moveNext()) {
        Response.Write("<br>"+sv.item() + " = ");
        Response.Write(Request.ServerVariables(sv.item()));
    }        
    Response.Write("<br>**** END SERVER VARIABLES ****");
}
function DumpSessionValues()
{
    Response.Write("<br>**** SESSION VARIABLES ****");
    var s= null;
    for (s = new Enumerator(Session.Contents);
    !s.atEnd();
    s.moveNext())
    { 
        Response.Write("<br>" + s.item() + " = ");
        Response.Write(Session(s.item()));
    }        
    Response.Write("<br>**** END SESSION VARIABLES ****");
    s = null;
}


function GetStringForQuery(szValue, szDefault, bDelimitValue) {
    var szReturn = "";

    if (szValue == "sagecrm_code_all") {
        szValue = "";
    }

        
    if ((szValue != null) && (szValue != "")) {
        if (bDelimitValue) {
            szReturn += "'";
            szReturn += padQuotes(szValue);    
            szReturn += "'";
        } else {
            szReturn = szValue;            
        }
    } else {
        szReturn = szDefault;
    }
    
    return szReturn
}	

function GetIntForQuery(szValue, szDefault) {
    var szReturn = "";
        
    if ((szValue != null) && (szValue != "")) {
        szReturn += szValue;
    } else {
        szReturn = szDefault;
    }
    
    return szReturn
}	
	
function getFileText(szFilePath, szLineBreak)
{
    var fs=Server.CreateObject("Scripting.FileSystemObject")
    var f=fs.OpenTextFile(szFilePath)
    var sReturn = "";
    if (szLineBreak == null || szLineBreak == "undefined" )
        szLineBreak = "\n";
    while (f.AtEndOfStream == false)
    {
        if (sReturn != "")
            sReturn += szLineBreak;
        sReturn += f.ReadLine();
    }
    f.Close();
    
    f=null;
    fs=null;
    return sReturn;

}

function saveFileBinary(FileName, ByteArray)
{
  var TypeBinary = 1;
  var SaveCreateOverWrite = 2;
  
  //Create Stream object
  var oStream = Server.CreateObject("ADODB.Stream");
  
  //Specify stream type - we want To save binary data.
  oStream.Type = TypeBinary;
  
  //Open the stream And write binary data To the object
  oStream.Open();
  oStream.Write(ByteArray);
  
  //Save binary data To disk
  oStream.SaveToFile(FileName, SaveCreateOverWrite);
  
  //close the stream
  oStream.Close();
  oStream = null;
}




function padQuotes(szValue) {

    if ((szValue == null) || (szValue == "")) {
        return szValue;  
    }
   
    var szWork = String(szValue)
    var szResult = "";
    var szChar = "";

    var iLength = szWork.length;
    
    for(var iIndex = 0; iIndex < iLength; iIndex++) {
   
      szChar = szWork.substring(iIndex, iIndex + 1);
      szResult = szResult + szChar;
      if (szChar == "'") {
         szResult = szResult + "'";
      }
    }
    szWork = null;
    return szResult;
}

function getDefaultDatabaseServer()
{
    var ws = Server.CreateObject("WScript.Shell");
    var server_name = ws.RegRead("HKLM\\SOFTWARE\\eWare\\Config\\/CRM\\DefaultDatabaseServer");
    ws = null;
    return server_name;
}

function getReportServerURL()
{
    var db_server = getDefaultDatabaseServer();
    var ReportServerURL = "http://" + db_server + "/ReportServer";
    return ReportServerURL;
}



/* 
 * Helper function that returns an "AND" clause
 * for a WHERE string
 */
function addDateRangeCondition(colName, startDate, endDate) {

    var dateCondition = ""
	if (!isEmpty(startDate))
		dateCondition += " AND " + colName + " >= '" + startDate + "'";

	if (!isEmpty(endDate))
		dateCondition += " AND " + colName + " <= '" + endDate + " 11:59 PM'";

    return dateCondition;
}

/*
 * Helper function that builds a column header for a sort link
 */
function getColumnHeader(sGridName, sColName, sDBName) {
    return "<a class=\"GRIDHEADLINK\" href=\"javascript:document.EntryForm.submit();\" onclick=\"document.EntryForm._hiddenSortColumn.value = '" + sDBName + "';document.EntryForm._hiddenSortGrid.value = '" + sGridName + "';\">" + sColName + "</a>";
}





/* 
 * Helper function that returns a date object
 */
function getDateValue(value) {
    if (isEmpty(value)) {
        return "";
    }
    
    return getDateAsString(new String(value));
}

/* 
 * Helper function that returns an empty string if the
 * the falue is indeed empty.
 */
function getValue(value) {
    if (isEmpty(value)) {
        return "";
    }
    
    return value;
}

function displayUserMsg() {
    
    if (!isEmpty(Session("sUserMsg"))) {
        Response.Write("<script>alert(\"" +Session("sUserMsg") + "\");</script>");
        Session("sUserMsg") = "";
    }
}

function buildDataCell(fieldID, caption, fieldValue, colSpan, rowSpan, width) {

    sCaption = caption;
    if (!isEmpty(sCaption)) {
        sCaption += ":";
    }
    
    sWidth = "";
    if (!isEmpty(width)) {
        sWidth = " width=" + width;
    }

    return  "<td id='td_" + fieldID + "' colspan=" + colSpan + " rowspan=" + rowSpan + sWidth + " valign=top><span id=_capt_" + fieldID + " class=VIEWBOXCAPTION>" + sCaption + "</span><br/> " +
            "<span id=_data_" + fieldID + " class=VIEWBOXCAPTION >" + fieldValue +  "</span></td>\n";
}

/* 
 * Helper function that returns an "AND" clause
 * for a WHERE string
 */
function addCondition(colName, value) {

	if (!isEmpty(value))
		return " AND " + colName + "='" + value + "'";

    return "";
}

function GetSortClause(sGridName, sDefaultCol, sDefaultDir) {

    var sSortCol = sDefaultCol;
    var sSortDir = sDefaultDir;

    //Response.Write("<br/>_hiddenSortGrid: " + getFormValue("_hiddenSortGrid"));
    //Response.Write("<br/>sGridName: " + sGridName);

    if (getFormValue("_hiddenSortGrid") == sGridName) {
        if (getFormValue("_hiddenSortColumn") == Session(sGridName + "GridSortColumn")) {
            if (Session(sGridName + "GridSortDir") == "ASC") {
                sSortDir = "DESC";
            } else {
                sSortDir = "ASC";
            }
        }
        sSortCol = getFormValue("_hiddenSortColumn");

        //Response.Write("<br/>Found sort in form: " + sSortCol + " " + sSortDir);
    } else {
        if (Session(sGridName + "GridSortColumn") != null) {
            sSortCol = Session(sGridName + "GridSortColumn");
            sSortDir = Session(sGridName + "GridSortDir");
        }            
        //Response.Write("<br/>Found sort in session: " + sSortCol + " " + sSortDir);
    }
    
    if (isEmpty(sSortDir)) {
        //Response.Write("<br/>Empty SortDir: " + sSortCol + " " + sSortDir);
        sSortDir = sDefaultDir;
    }

    if (isEmpty(sSortCol)) {
        sSortCol = sDefaultCol;
    }
    
    Session(sGridName + "GridSortColumn") = sSortCol;
    Session(sGridName + "GridSortDir") = sSortDir;
   
    return " ORDER BY " + sSortCol + " " + sSortDir;
}

function buildDropDown(captFamilyName, controlID, selectedValue) {

        sHTML = "<select id='" + controlID + "' name='" + controlID + "' class=EDIT>";

        sSQL = "SELECT RTRIM(capt_code) As capt_code, capt_us FROM custom_captions WHERE capt_family = '" + captFamilyName + "' ORDER BY capt_order"
        recCodes = eWare.CreateQueryObj(sSQL);
        recCodes.SelectSQL();
        
        while (!recCodes.eof)
        {
            sSelected = "";
            if (recCodes("capt_code") == selectedValue) {
                sSelected = " SELECTED ";
            }
        
            sHTML += "<option value='" + recCodes("capt_code") + "'" + sSelected + ">" + recCodes("capt_us") + "</option>";
            recCodes.NextRecord();
        }        
        
        if ("" == selectedValue) {
            sSelected = " SELECTED ";
        }        
        sHTML += "<option value=''" + sSelected + ">--None--</option>";
        sHTML += "</select>";
        
        return sHTML;
}

function buildUserDropDown(channelIDList, controlID, selectedValue) {

        sHTML = "<select id='" + controlID + "' name='" + controlID + "' class=EDIT>";

        sSQL = "SELECT DISTINCT user_userID, COALESCE(RTrim(User_FirstName) + ' ','') + RTrim(User_LastName) As UserName, user_lastname " +
                 "FROM users " +
                      "LEFT OUTER JOIN Channel_Link ON user_userID = chli_user_id " +
                "WHERE (user_PrimaryChannelID IN (" + channelIDList + ") " +
                       "OR (chli_Channel_ID IS NOT NULL  " +
                           "AND chli_Channel_ID IN (" + channelIDList + "))) " +
                  "AND User_Disabled IS NULL " +                           
                "ORDER BY user_lastname;"
        recCodes = eWare.CreateQueryObj(sSQL);
        recCodes.SelectSQL();
        
        while (!recCodes.eof)
        {
            sSelected = "";
            if (recCodes("user_userID") == selectedValue) {
                sSelected = " SELECTED ";
            }
        
            sHTML += "<option value='" + recCodes("user_userID") + "'" + sSelected + ">" + recCodes("UserName") + "</option>";
            recCodes.NextRecord();
        }        
        
        if ("" == selectedValue) {
            sSelected = " SELECTED ";
        }        
        sHTML += "<option value=''" + sSelected + ">--None--</option>";
        sHTML += "</select>";
        
        return sHTML;
}

function getSetClause(fieldName, dbName) {
    var fieldValue = getFormValue(fieldName)
    if (!isEmpty(fieldValue)) {
        return ", " + dbName + "='" + fieldValue + "'";
    }

    return "";
} 

function handleKey58() {

    var queryString = null;
    var key58 = new String(Request.QueryString("Key58"));
    
    if (!isEmpty(key58)) {
        queryString = new String(Request.QueryString);
        var bFound = false;
        var keyValue = null;
        
        for(i=1; i<=50; i++) {
            keyValue = new String(Request.QueryString("Key" + i.toString()));
            Response.Write("Key" + i.toString() + ":" + keyValue + "<br/>");

            if (key58.toString() == keyValue.toString()) {
                bFound = true;
                queryString = changeKey(queryString, "Key0", i.toString());
                queryString = removeKey(queryString, "Key58");
                break;
            }
        }
        
        if (!bFound) {
            queryString = removeKey(queryString, "Key0");
            queryString = removeKey(queryString, "Key58");
        }
    }  
    
    return queryString;      
}        

/*
 * Helper method that returns an HTML formatted string containing basic information
 * about the specified company.
 */
function GetCompanyInfo(iCompanyID) {
    
    var sSQL = "SELECT comp_CompanyID, comp_Name, CityStateCountryShort, dbo.ufn_GetCustomCaptionValue('comp_PRListingStatus', comp_PRListingStatus, DEFAULT) As comp_PRListingStatus, dbo.ufn_GetCustomCaptionValue('comp_PRType', comp_PRType, DEFAULT) As comp_PRType, dbo.ufn_GetCustomCaptionValue('comp_PRIndustryType', comp_PRIndustryType, DEFAULT) As comp_PRIndustryType, comp_CreatedDate " +
                 "FROM Company WITH (NOLOCK) " +
                      "INNER JOIN vPRLocation ON comp_PRListingCityID = prci_CityID " +
                "WHERE comp_CompanyID=" + iCompanyID;

    recCompanyInfo = eWare.CreateQueryObj(sSQL);
    recCompanyInfo.SelectSQL();
    
    var szCompanyInfo = "";
    if (!recCompanyInfo.eof)  {
        szCompanyInfo += "BB #: " + recCompanyInfo("comp_CompanyID") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_Name") + "<br/>";
        szCompanyInfo += recCompanyInfo("CityStateCountryShort") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRListingStatus") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRType") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_PRIndustryType") + "<br/>";
        szCompanyInfo += recCompanyInfo("comp_CreatedDate") + "<br/>";
    }     
    
    return szCompanyInfo;
}

function IsNull(value, defaultValue) {
    if (value == null) {
        return defaultValue;
    }
    return value;
}

function getEmpty(sValue, sReplace){
    if (!sReplace)
        sReplace = "";

    if (!sValue || sValue == "undefined" || sValue == "")
        return sReplace;

    return sValue;
}


function GetFormattedEmail(companyID, personID, subject, text, overrideAddressee)
{
    sEmailBody = '';
    var sSQL = "SELECT dbo.ufn_GetFormattedEmail(" + companyID + ", " + personID + ", 0, '" + padQuotes(subject) + "', '" + padQuotes(text) + "', '" + padQuotes(overrideAddressee) + "') as EmailBody"
    
    var qryEmailBody = eWare.CreateQueryObj(sSQL);
    qryEmailBody.SelectSql();
    
    if (!qryEmailBody.EOF) {
        sEmailBody = new String(qryEmailBody("EmailBody"));
    }
            
    return sEmailBody
}

function addCompanyChangeRecord(companyID, userID) {
    var qry = eWare.CreateQueryObj("INSERT INTO PRChangeDetection (prchngd_CompanyID, prchngd_ChangeType, prchngd_CreatedBy, prchngd_UpdatedBy) VALUES (" + companyID + ", 'User Triggered', " + userID + ", " + userID + ")");
    qry.ExecSql();
}

function adjustARToCurrent(ARAgingDetailId) {
    var qry = eWare.CreateQueryObj("EXEC dbo.usp_ARAgingAdjustToCurrent " + ARAgingDetailId);
    qry.ExecSql();
}

function getDiskFilename(CompanyID, AdCampaignID, filename)
{
    return getDiskFilename2(CompanyID, AdCampaignID, filename, "");
}

function getDiskFilename2(CompanyID, AdCampaignID, filename, fileNameModifier) {
    var ext = filename.substring(filename.lastIndexOf(".")+1, filename.length) || filename;
    sValue = CompanyID + "\\BBSI_" + AdCampaignID + fileNameModifier + elapsedSeconds() + "." + ext;
    return sValue;
}

function renameFile(file1, file2)
{
    //Rename image file
    var oFS = Server.CreateObject("Scripting.FileSystemObject");
    if(oFS.FileExists(file1) && !oFS.FileExists(file2))
    {                
        oFS.MoveFile(file1, file2);
    }
    else if(oFS.FileExists(file1) && oFS.FileExists(file2))
    {
        oFS.DeleteFile(file2);
        oFS.MoveFile(file1, file2);
    }
}

function copyFile(file1, file2)
{
    //Copy image file
    var oFS = Server.CreateObject("Scripting.FileSystemObject");
    if(oFS.FileExists(file1) && !oFS.FileExists(file2))
    {                
        oFS.CopyFile(file1, file2);
    }
    else if(oFS.FileExists(file1) && oFS.FileExists(file2))
    {
        oFS.DeleteFile(file2);
        oFS.CopyFile(file1, file2);
    }
}

function existsFile(file1)
{
    var oFS = Server.CreateObject("Scripting.FileSystemObject");
    return oFS.FileExists(file1);
}

function deleteFile(file1)
{
    //Delete image file
    var oFS = Server.CreateObject("Scripting.FileSystemObject");
    if(oFS.FileExists(file1))
    {
        oFS.DeleteFile(file1);
    }
}

function elapsedSeconds(fromDate)
{
    var startDate = new Date(2023, 01, 01);
    var endDate   = new Date();

    var seconds = (endDate.getTime() - startDate.getTime()) / 1000;
    return parseInt(seconds);
}
%>
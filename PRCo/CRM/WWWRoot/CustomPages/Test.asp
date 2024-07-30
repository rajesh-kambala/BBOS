<!-- #include file ="accpaccrm.js" -->
<!-- #include file ="PRCoGeneral.asp" -->

<%

doPage();

function doPage() {
	
	var filepath_share = "";
	var msg = "";
	var action = "";	
	
	var qTempReports = eWare.CreateQueryObj("Select Capt_US From Custom_Captions Where Capt_Family = 'TempReports' And Capt_Code = 'Share'");
	qTempReports.SelectSQL();
	if (! qTempReports.Eof) {
		filepath_share = qTempReports("Capt_US");
	} else {
		filepath_share = Server.MapPath("/" + sInstallName + "/TempReports");
	}
	qTempReports = null;

	var mode = Request.Querystring("action");
	if (mode == "WTR") {

		var contents = "File created on " +  formatDateTime(new Date());
		var filename = filepath_share + "\\Test from CRM.txt";

		try 
		{		
/*
			var SaveCreateOverWrite = 2;
			var stream = Server.CreateObject("ADODB.Stream");
			stream.Open();
			stream.WriteText(contents);
			stream.SaveToFile(filename, SaveCreateOverWrite);
			stream.Close();
			stream = null;	
*/
            var ba = unpack(contents);
            saveFileBinary(filename, ba);


			msg = "Successfully wrote to " + filename;
		}
		catch (exception)
		{
			msg = "EXCEPTION:" + exception.message;
		}
	}
			
	
	var sBannerMsg = "<h2>CRM File Security Test</h2>";
	sBannerMsg += "<h3>" + msg + "</h3>";
	sBannerMsg += "<p><a href=\"" + eWare.Url("Test.asp") + "&action=WTR\">Write File to " + filepath_share + "</a></p>";	

	var blkBanners = eWare.GetBlock('content');
	blkBanners.contents = sBannerMsg;
	
	var blkContainer = eWare.GetBlock('Container');	
	blkContainer.DisplayButton(Button_Default) = false;
	blkContainer.AddBlock(blkBanners);
	
	eWare.AddContent(blkContainer.Execute());
	Response.Write(eWare.GetPage());
	
	
}

function unpack(str) {
    var bytes = [];
    for(var i = 0, n = str.length; i < n; i++) {
        var char = str.charCodeAt(i);
        bytes.push(char >>> 8, char & 0xFF);
    }
    return bytes;
}


%>

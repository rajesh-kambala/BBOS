<% 
/***********************************************************************
 ***********************************************************************
  Copyright Produce Report Company 2006-2016

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

function getDocDropButton(sFileId)
{
    var sURLBase = eWare.URL("PRGeneral/PRInteraction.asp")+"&prss_SSFileId="+sFileId;
    var nextUrl = sURLBase+ "&Mode=1";
    var failUrl = sURLBase+ "&Mode=102";
    var notSavedUrl = eWare.URL(343)+ "&Mode=1";
    
    var sButtonHtml = "</TR><TR><TD CLASS=\"\"><TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><TD>" +
         "<object width=\"32\" height=\"32\" align=\"center\" id=\"documentDropPlugin\" classid=\"clsid:3DFD2B52-C6E9-11D4-8226-005004F658FC\" " +
         "codebase=\"/CRM/Plugin/eWarePluginX.cab#version=7,3,0,2\" style=\"display: inline;\">" +
         "<PARAM NAME=\"Visible\" VALUE=\"-1\"><PARAM NAME=\"AutoScroll\" VALUE=\"0\">" +
         "<PARAM NAME=\"AutoSize\" VALUE=\"0\"><PARAM NAME=\"AxBorderStyle\" VALUE=\"0\">" +
         "<PARAM NAME=\"Caption\" VALUE=\"XeWare\"><PARAM NAME=\"Color\" VALUE=\"4278190095\">" +
         "<PARAM NAME=\"Font\" VALUE=\"MS Sans Serif\">" +
         "<PARAM NAME=\"KeyPreview\" VALUE=\"0\">" +
         "<PARAM NAME=\"PixelsPerInch\" VALUE=\"192\">" +
         "<PARAM NAME=\"PrintScale\" VALUE=\"1\">" +
         "<PARAM NAME=\"Scaled\" VALUE=\"-1\">" +
         "<PARAM NAME=\"DropTarget\" VALUE=\"0\">" +
         "<PARAM NAME=\"HelpFile\" VALUE=\"\">" +
         "<PARAM NAME=\"DoubleBuffered\" VALUE=\"0\">" +
         "<PARAM NAME=\"Enabled\" VALUE=\"-1\">" +
         "<PARAM NAME=\"Cursor\" VALUE=\"0\">" +
         "<PARAM NAME=\"PluginAction\" VALUE='\"Action=DragNDrop\",\"LogonId=" + recUser("user_logon") + "\",\"nextUrl="+ nextUrl + "\",\"failUrl=" +failUrl + "\",\"Alias=/CRM/Library/\",\"Host=" + eWare.Host + "\",\"DocLibPath=/\",\"notSavedUrl="+ notSavedUrl + "\",\"SelectFile=Select a File\",\"PFC=Paste\",\"FSL=20971520\",\"IFE=\",\"ISN=/CRM/\",\"PFE=Function Error.\", \"OPNI=Outlook not installed\", \"PFSZ=The file you are trying to upload is 0 bytes in size.\", \"PFNS=Therefore the file cannot be saved.\", \"PFNTL=PluginFileNameTooLong\", \"DPDO=Word may not be installed or may have a dialog box open.\", \"PIE=The extension \"%s\" is not a valid extension for file upload\", \"PFSL=The file is too big. The current file upload size limitation is:%s\", \"PIIDX=0\", '>" +
         "<param name=\"PluginAction\" value='\"Action=DragNDrop\",\"LogonId=" + recUser("user_logon") + "\",\"nextUrl="+ nextUrl + "\",\"failUrl=" +failUrl + "\",\"Alias=/CRM/Library/\",\"Host=" + eWare.Host + "\",\"DocLibPath=/\",\"notSavedUrl="+ notSavedUrl + "\",\"SelectFile=Select a File\",\"PFC=Paste\",\"FSL=20971520\",\"IFE=\",\"ISN=/CRM/\",\"PFE=Function Error.\", \"OPNI=Outlook not installed\", \"PFSZ=The file you are trying to upload is 0 bytes in size.\", \"PFNS=Therefore the file cannot be saved.\", \"PFNTL=PluginFileNameTooLong\", \"DPDO=Word may not be installed or may have a dialog box open.\", \"PIE=The+extension+%22%25s%22+is+not+a+valid+extension+for+file+upload\", \"PFSL=The+file+is+too+big.+The+current+file+upload+size+limitation+is%3A%25s\", \"PIIDX=0\", '>" +
         "</object>" +
         "</TD><TD>&nbsp;</TD><TD><A CLASS=ButtonItem>Document Drop</A></TD></TR></TABLE></TD>";      
    
         
        //+ "<OBJECT align=center classid=clsid:3DFD2B52-C6E9-11D4-8226-005004F658FC " 
        //+ "CODEBASE=\"/" + sInstallName + "/Plugin/eWarePluginX.cab#version=5,8,0,2\" height=32 width=32 > " 
        //+ "<PARAM NAME=\"PluginAction\" VALUE=\"&quot;Action=DragNDrop&quot;," 
        //+ "&quot;LogonId=" + recUser("user_logon") + "&quot;,"        
        //+ "&quot;nextUrl="+ nextUrl + "&quot;,&quot;failUrl=" +failUrl + "&quot;,"
        //+ "&quot;Alias=/" + sInstallName + "/Library/&quot;,&quot;Host=" + eWare.Host + "&quot;,"
        //+ "&quot;DocLibPath=/&quot;, &quot;notSavedUrl="+ notSavedUrl + "&quot;,"
        //+ "&quot;SelectFile=Select a File&quot;,&quot;PasteFromClipboard=Paste&quot;"
        //+ "\"></OBJECT>"
        //+ "</TD><TD>&nbsp;</TD><TD><A CLASS=ButtonItem>Document Drop</A></TD></TR></TABLE></TD>";

    return sButtonHtml;        


}


function getDocDropButtonForSave(sSrcDir, sSrcFileName, sLibraryId, sCommId, sNextAction, sNextActAddlParams)
{
    // recUser defined in PRCoGeneral.asp
    var sUserDir = recUser("user_FirstName") + "+" + recUser("user_LastName");

    var nextUrl = eWare.URL(sNextAction)+sNextActAddlParams;
    
    // I attempted to get the failUrl to be a custom link but to no avail.
    // It seems to work going to 183 so I'm going to let it go there for now
    var failUrl = eWare.URL(183);
    //var failUrl = eWare.URL("PRGeneral/PRInteraction.asp");

    var docDropUrl = eWare.URL(571);
    
    var sButtonHtml = "" + ("<TABLE><TR><TD WIDTH=90% VALIGN=TOP><TABLE ID=_icTable WIDTH=100% CLASS=InfoContent STYLE=\"display:none\">"
        + "<TR><TD ID=_icTD></TD></TR></TABLE>Please wait. Uploading attached object " 
        + "<OBJECT align=center classid=clsid:3DFD2B52-C6E9-11D4-8226-005004F658FC " 
        + "CODEBASE=\"/" + sInstallName + "/Plugin/eWarePluginX.cab#version=5,8,0,2\" height=32 width=32 > " 
        + "<PARAM NAME=\"PluginAction\" VALUE=\"&quot;Action=GetObject&quot;," 
        + "&quot;nextUrl="+ nextUrl + "&quot;,&quot;failUrl=" +failUrl + "&quot;,"
        + "&quot;Alias=/" + sInstallName + "/Library/&quot;,&quot;Host=" + eWare.Host + "&quot;,"
        + "&quot;LocalPath=" + Server.URLEncode(sSrcDir) + "&quot;,"
        + "&quot;" + docDropUrl + "&quot;,"
        + "&quot;ServerLocation=" + sUserDir + "&quot;,"
        + "&quot;FileName=" + sSrcFileName + "&quot;,"
        + "&quot;LibraryId=" + sLibraryId + "&quot;"
        + "\"></OBJECT>"
        + "</TD><TD>&nbsp;</TD></TR></TABLE>");

    return sButtonHtml;        

}

function createLibraryRecord(sSrcFileName, sNote, recComm, recCommLink)
{

    var recDocDir = eWare.FindRecord("custom_sysparams", "parm_Name='DocStore'");
    var sDestDir = recDocDir("parm_value");
    // recUser defined in PRCoGeneral.asp
    var sUserDir = recUser("user_FirstName") + " " + recUser("user_LastName") + "/";
    sDestDir += sUserDir
    
    var recLibrary = eWare.CreateRecord("Library");
    recLibrary.Libr_Note = sNote;
    recLibrary.Libr_FilePath = sUserDir;
    recLibrary.Libr_FileName = sSrcFileName;
    recLibrary.Libr_FileSize = -1;
    if (recComm != null && !recComm.eof) {
        recLibrary.libr_CommunicationId = recComm("comm_CommunicationId");
        recLibrary.libr_OpportunityId = recComm("comm_OpportunityId");
        recLibrary.libr_CaseId = recComm("comm_CaseId");
        recLibrary.libr_ChannelId = recComm("comm_ChannelId");
        recLibrary.libr_PRFileId = recComm("comm_PRFileId");
    }    
    if (recCommLink != null && !recCommLink.eof) {
        recLibrary.libr_CompanyId = recCommLink("cmli_comm_CompanyId");
        recLibrary.libr_PersonId = recCommLink("cmli_comm_PersonId");
        recLibrary.libr_LeadId = recCommLink("cmli_comm_LeadId");
        recLibrary.libr_UserId = recCommLink("cmli_comm_userid");
    }
    recLibrary.SaveChanges();    
    
    return recLibrary("libr_libraryid");
    
}

function getViewAttachmentHTML(sUserDir, sFileName)
{
    var sFile = "";
    sFile += sUserDir + sFileName;
    sFile = Server.URLEncode(sFile);
    // unencode periods so that the app launches in the correct tool
    var regexp = new RegExp("%2E", "gi");
    sFile = sFile.replace(regexp, ".");
    
    var sSID = Request.QueryString("SID");
    
    var sBeginATag = "" + ("<A CLASS=ButtonItem href=\"/" + sInstallName + "/eware.dll/do/" + sFile + "?SID=" + sSID + 
            "&Act=1282&Mode=0&FileName=" + sFile + "\" TARGET=\"_blank\">");
    var sHTML = "" + ("<TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><TD>" + sBeginATag +
            "<IMG SRC=\"/" + sInstallName + "/img/Buttons/Attachmentsmall.gif\" BORDER=0 ALIGN=MIDDLE></A></TD>" +
            "<TD>&nbsp;</TD><TD>" + sBeginATag + "View Attachment</A></TD>" +
            "</TR></TABLE>");
    return sHTML;
}

%>
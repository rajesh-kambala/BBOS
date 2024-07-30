//************************************************************************************************************************
// Email Manager Communications script.
// When this script is run from the email manager 6 objects are passed in to the scripts namespace.
// They are 
// 1. UserQuery - eWareQuery object that contains the details of the user who sent the email...should there be one. 
// 2. PersonQuery - eWareQuery object that contains the person details of the sender of the email
// 3. CompanyQuery - eWareQuery object that contains the company details of the sender of the email
// 4. eware - eWare object itself...logged on with admin user
// 5. MsgHandler - The log function (To catch errors) is only used from this object
// 6. eMail - This is the interface to the email itself
// *NOTE* for user (the senders) security to apply you must create your own eware object and logon as that user using their
//        credentials.
//*************************************************************************************************************************
//
// This is the Communications script. 
// All the functionality is called from the BeforeMainAction function
//
//
//
//

//MsgHandler.Debug=true;

var comm;

//assigned user
var AssignedUser=0;

//priority
var prLow=0;
var prNormal=1;
var prHigh=2;

var commid;
var caseid;

commid=0;
caseid=0;
oppoid=0;

//Comm variables
var CommAction;
var pers_array = new Array();
var perscomp_array = new Array();

var comp_array = new Array();

var EmailInAddress;

function SetCommAction()
{
  if (eMail.Recipients.Count == 1)
  {
    // check if the email address is the address in here
    var singleaddress = eMail.Recipients.Items(0).Address; 
    var useraddress = MsgHandler.EmailAddress; 
    if (singleaddress.toLowerCase() == useraddress.toLowerCase())
    {
      CommAction ="EmailIn";
    }
    else
    {
      CommAction ="EmailOut";
    }
  }   
  else
  {
    CommAction ="EmailOut";
  }
}

function SetCommType(comm)
{
  if ( (eMail.ContentType == 'text/html') || (eMail.ContentType == 'multipart/mixed'))
    comm("Comm_IsHtml") = "Y";
}

function BuildIdArrays()
{
  //get the people from the recipient list
  for (i = 0; i < (eMail.Recipients.Count); i++)
  {
    GetDetails(eMail.Recipients.Items(i).Address);
  }
  for (i = 0; i < (eMail.CC.Count); i++)
  {
    GetDetails(eMail.CC.Items(i).Address);
  }
  for (i = 0; i < (eMail.BCC.Count); i++)
  {
    GetDetails(eMail.BCC.Items(i).Address);
  }
}

function FixStringForSQL(myvalue)
{
  var r, re;
  var mystring;
  mystring = myvalue + "";
  re = /\'/g;             //Create regular expression pattern.
  mystring  = mystring.replace(re, "''");    //Replace "'" with "''".
  return(mystring);
}

function GetDetails(emailaddress)
{
  var bIdFound;

  emailaddress = FixStringForSQL(emailaddress);

  if (emailaddress != "")
  {
    MsgHandler.Log("emailaddress is " + emailaddress);

    SQL = "SELECT DISTINCT Emai_CompanyID, Emai_PersonID, Emai_EmailAddress FROM vEMail WHERE " + 
          "UPPER(RTRIM(Emai_EmailAddress)) = UPPER(RTRIM(N'" + emailaddress + "')) AND (Emai_PersonId IS NOT NULL)";

    recQuery = eWare.CreateQueryObj(SQL);
    MsgHandler.Log(SQL);
    recQuery.SelectSQL();

    if (recQuery.EOF)
    {  
      //get the company info
      SQL = "SELECT DISTINCT Emai_CompanyID, Emai_EmailAddress FROM vEMail WHERE " +
            "UPPER(RTRIM(Emai_EmailAddress)) = UPPER(RTRIM(N'" + emailaddress + "')) AND (Emai_CompanyId IS NOT NULL)";
      recQuery = eWare.CreateQueryObj(SQL);
      MsgHandler.Log(SQL);
      recQuery.SelectSQL();

      if (recQuery.EOF)
      {
        SendFailureReply();
      }
      else
      {
        while (!recQuery.EOF)
        {
          bIdFound = false;
          for (x = 0; x < comp_array.length; x++)
          {
            if (comp_array[x] == recQuery("Emai_CompanyId"))
              bIdFound = true;
          }
          if (bIdFound == false)
          {
            comp_array[comp_array.length] = recQuery("Emai_CompanyId");
          }
          recQuery.NextRecord();
        }
      }
    }
    else
    {
      while (!recQuery.EOF)
      {
        bIdFound = false;
        for (x = 0; x < pers_array.length; x++)
        {
          if (pers_array[x] == recQuery("Emai_PersonId"))
            bIdFound = true;
        } 
        if (bIdFound == false)
        {
          pers_array[pers_array.length] = recQuery("Emai_PersonId");
          perscomp_array[perscomp_array.length] = recQuery("Emai_CompanyId");
        }
        recQuery.NextRecord();
      }
    }
  }
}

function CheckForMultipleUsers()
{
  Usercount = 0;

  while (!UserQuery.EOF)
  {
    Usercount = Usercount + 1;
    UserQuery.NextRecord();
  }

  if (Usercount > 1)
  {
    MsgHandler.Log("***********************************************************************");
    MsgHandler.Log("Potential Problem: There are multiple Users with the same email address");
    MsgHandler.Log("***********************************************************************");
  }
  UserQuery.SelectSQL();
}

// Use this function to alter any data or to do any custom work before the main action gets called.
function BeforeMainAction()
{
  CheckForMultipleUsers();
  if (!UserQuery.EOF)
  {
    SetCommAction();
    if (CommAction == "EmailIn") 
    {
      MsgHandler.Log("Its an emailin type");
      EmailInAddress = ParseForEmailAddress(eMail.Body);
      MsgHandler.Log("--------> EmailInAddress is " + EmailInAddress);
      GetDetails(EmailInAddress);
    }
    else
    {
      MsgHandler.Log("Its an emailOut type");
      BuildIdArrays();
    }
    CreateComm();
  }
  else
  {
    MsgHandler.Log("No Users exist for this from email address");
  }
}

// Use this function to alter any data or to do any custom work like create a log record or send an email for example.
function AfterMainAction()
{

}

// Useful functions
function Defined(Arg)
{
  return (Arg+""!="undefined");
}

// Takes a javascript date object as its parameter
function getsqldatetimefromdate(dtdate)
{
  var d = dtdate.getDate() + "";
  var m = (dtdate.getMonth() + 1) + "";
  if (d.length == 1)
    d = "0" + d;
  if (m.length == 1)
    m = "0" + m;
  return m + "/" + d + "/" + dtdate.getFullYear() + " " + dtdate.getHours() + ":" + dtdate.getMinutes() + ":01";
}

// Create a communication
function CreateComm()
{
  MsgHandler.Log("About to create a communication");
  var ToList, CCList, BCCList;
  //communication
  comm = eWare.CreateRecord("communication");
  comm("Comm_Action") = CommAction;
  comm("Comm_Type") = "email";
  comm("Comm_Status") = "Complete"
  //priority
  if (eMail.Priority == prLow)
  {
    comm("Comm_Priority") = "Low";
  }
  else
  if (eMail.Priority == prNormal)
  {
    comm("Comm_Priority") = "Normal";
  }
  else
  if (eMail.Priority == prHigh)
  {
    comm("Comm_Priority") = "High";
  }
  // comm_datetime
  commdate = new Date();
  // FMD 30/9/2003 was passed as formatted string but it didn't work
  comm("Comm_datetime") = commdate.getVarDate();
  comm("Comm_Note") = eMail.Subject;
  comm("Comm_Email") = eMail.Body;

  if ((CommAction == "EmailIn") & (EmailInAddress != ""))
  { 
    comm("comm_from") = "<" + EmailInAddress + "> ";
  }
  else
  { 
    if (eMail.SenderName != "")
    {
      comm("comm_from") = "\"" + eMail.SenderName + "\" " + "<" + eMail.SenderAddress + "> "; 
    }
    else
    {
      comm("comm_from") = eMail.SenderAddress;
    }
  }
  ToList = "";
  CCList = "";
  BCCList = "";

  var singleaddress;
  var useraddress = MsgHandler.EmailAddress; 

  if ((CommAction == "EmailIn") & (EmailInAddress != ""))
  { 
    comm("comm_to") = "\"" + eMail.SenderName + "\" " + "<" + eMail.SenderAddress + "> ";
  }
  else
  { 
    comm("comm_to") = GetMailList(eMail.Recipients); 
  }
  comm("comm_cc") = GetMailList(eMail.CC); 
  comm("comm_bcc") = GetMailList(eMail.BCC); 
  comm("comm_replyto") = eMail.Header("Reply-To");
  SetCommType(comm);
  SetUserTerr(comm);
  comm.SaveChanges(); 

  bRecCreated = false;

  // comm_links
  // person info
  if (pers_array.length >= 1)
  {
    numrecips = pers_array.length;
    i = 0;
    while (i < numrecips)
    {
      commlink = eWare.CreateRecord("comm_link");
      commlink("CmLi_Comm_CommunicationId") = comm.RecordId;
      commlink("CmLi_Comm_UserId") = UserQuery("User_UserId");
      commlink("CmLi_Comm_PersonId") = pers_array[i];
      commlink("CmLi_Comm_CompanyId") = perscomp_array[i];
      commlink.SaveChanges();
      bRecCreated = true;
      i = i + 1;
    }
  }

  // company info
  if (comp_array.length >= 1)
  {
    numcomps = comp_array.length;
    i = 0;
    while (i < numcomps)
    {
      commlink = eWare.CreateRecord("comm_link");
      commlink("CmLi_Comm_CommunicationId") = comm.RecordId;
      commlink("CmLi_Comm_UserId") = UserQuery("User_UserId");
      commlink("CmLi_Comm_CompanyId") = comp_array[i];
      commlink.SaveChanges();
      bRecCreated=true;
      i = i + 1;
    }
  }

  if (bRecCreated == false) 
  {
    //user info
    commlink = eWare.CreateRecord("comm_link");
    commlink("CmLi_Comm_CommunicationId") = comm.RecordId;
    commlink("CmLi_Comm_UserId") = UserQuery("User_UserId");
    commlink.SaveChanges();
  }
  MsgHandler.Log("Communication created");
  SendConfirmationReply();

  var Attachments = eMail.Attachments;

  var subfolder = new String(comm.RecordId);
  subfolder = "Comm" + subfolder;

  var Userdir = UserQuery("User_firstname") + " " + UserQuery("User_lastname") + "\\" + (subfolder);

  var libdir = Attachments.LibraryPath + "\\" + Userdir;

  var AttItem;
  var bHasAttachments;
  bHasAttachments = false;

  // library records...attachments
  for (i = 0; i < Attachments.Count; i++)
  {
    // saving the attachment here
    AttItem = Attachments.Items(i);
    if (AttItem.Name != "_alt.0")
    {
      // getting a new name for it
      NewName = MsgHandler.GetUniqueFileName(libdir, AttItem.Name);
      // saving to the library... 
      AttItem.SaveAs(NewName, libdir);
      librec = eWare.CreateRecord("library");
      librec("libr_FileName") = NewName;
      librec("libr_CommunicationId") = comm.RecordId;
      librec("libr_Userid") = UserQuery("User_UserId");
      librec("libr_type") = "EmailAttachment";
      librec("libr_status") = "Complete";
      librec("Libr_FilePath") = Userdir;
      librec.SaveChanges();
      bHasAttachments = true;
    }
  }

  if (bHasAttachments == true)
  {
    comm("Comm_HasAttachments") = "Y";
    comm.SaveChanges();
  }
}

function SetTerr(comm)
{
  // reset the queries.
  PersonQuery.SelectSql();
  CompanyQuery.SelectSql();
  if (!PersonQuery.EOF)
  {
    if (PersonQuery("pers_secterr") != null)
      comm("comm_secterr") = PersonQuery("pers_secterr");
  }
  else 
  if (!CompanyQuery.EOF)
  {
    if (CompanyQuery("comp_secterr") != null)
      comm("comm_secterr") = CompanyQuery("comp_secterr");
  }
}

function SetUserTerr(comm)
{
  if (!UserQuery.EOF)
  {
    if (UserQuery("User_PrimaryTerritory") != null)
      comm("comm_secterr") = UserQuery("User_PrimaryTerritory");
  }
}

// This function finds the first email address and returns the email address.
function ParseForEmailAddress(value)
{
  var r, re, singlestr; //Declare variables.
  //create my test string
  var s = value;

  //Create regular expression pattern. used for testing whether a string is a valid email address
  re = /[a-z][a-z_0-9_\-\'\.]+@[a-z_0-9_\-_'\.]+\.[a-z]{2,3}/i; 
  re.Global = true;
  re.IgnoreCase = true;
  re.MultiLine = true;
  singlestr = s.match(re);
  return(singlestr);                   //Return the first email address that we find.
}

function SuffixFileName(Name, Ext)
{
  var newname = Name.substr(0, 4);  //Get substring
  var ndt = new Date();
  newname += ndt.getHours() + "." + ndt.getMinutes() + " " + ndt.getDay() + "-" +
    (ndt.getMonth() + 1) + "-" + ndt.getYear() + " " + ndt.getHours() +":" +
    ndt.getMinutes() + ":" + ndt.getSeconds() + "." + ndt.getMilliseconds() + Ext;
  return(newname);
}

// This function expects either "eMail.Recipients" or "eMail.CC" or "eMail.BCC" as a parameter.
// it returns a string containing the email addresses and friendly names of the respective list.
function GetMailList(mylist)
{
  var ToList;
  ToList="";
  for (i = 0; i < (mylist.Count); i++)
  {
    if (i != 0)
      ToList = ToList + ", ";
    if (mylist.Items(i).Name != "")
      ToList = ToList + "\"" + mylist.Items(i).Name + "\" <" + mylist.Items(i).Address + "> ";
    else
      ToList = ToList + mylist.Items(i).Address;
  }
  return(ToList); 
}

function SendConfirmationReply()
{
  if (MsgHandler.FeedbackOnSuccess)
  {
    var sSubject = eMail.Subject.substring(0, 39);
    var sReplyName = eMail.SenderName;
    var sReplyAddress = eMail.SenderAddress;

    eMail.Clear();
    eMail.Recipients.AddAddress(sReplyAddress, sReplyName);

//  Replace this with your company's default E-Mail Manager's reply address
//    var sAddress = "youraddress@yourcompany.com";
    eMail.SenderName = sAddress;
    eMail.SenderAddress = sAddress;

    eMail.Subject = "Email filed -- " + sSubject;

    eMail.Body = ".";
    eMail.Send();
  }
}

function SendFailureReply()
{
  if (MsgHandler.FeedbackOnFailure)
  {
    var sSubject = eMail.Subject.substring(0, 39);
    var sReplyName = eMail.SenderName;
    var sReplyAddress = eMail.SenderAddress;

    eMail.Clear();
    eMail.Recipients.AddAddress(sReplyAddress, sReplyName);

//  Replace this with your company's default E-Mail Manager's reply address
//    var sAddress = "youraddress@yourcompany.com";
    eMail.SenderName = sAddress;
    eMail.SenderAddress = sAddress;

    eMail.Subject = "Filing failed -- " + sSubject;

    eMail.Body = "There was no matching recipients to file under";
    eMail.Send();
  }
}

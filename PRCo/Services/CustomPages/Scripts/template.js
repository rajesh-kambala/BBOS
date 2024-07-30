
//************************************************************************************************************************
// Email Manager Template file.
// When this script is run from the email manager 6 objects are passed in to the scripts namespace.
// They are 
// 1. UserQuery - eWareQuery object that contains the details of the user who sent the email...should there be one. 
// 2. PersonQuery - eWareQuery object that contains the person details of the sender of the email
// 3. CompanyQuery - eWareQuery object that contains the company details of the sender of the email
// 4. eWare - eWare object itself...logged on with admin user
// 5. MsgHandler - The log function (To catch errors) is only used from this object
// eg MsgHandler.Log("This text will appear in the log file");
// 6. eMail - This is the interface to the email itself
// *NOTE* for user (the senders) security to apply you must create your own eware object and logon as that user using their
//        credentials.
//*************************************************************************************************************************


//must be set to true for the MsgHandler.Log method to work.
MsgHandler.Debug = true;

var comm;

//assigned user
var AssignedUser=0;
var AssignedChannel=0;

//priority
var prLow=0;
var prNormal=1;
var prHigh=2;

var commid;
var caseid;
var oppoid;

commid=0;
caseid=0;
oppoid=0;
territoryid=0;
caserefid="";

var bHasAttachments;
bHasAttachments=false;

var CaseQuery;

// Use this function to alter any data or to do any custom work before the main action gets called.
function BeforeMainAction()
{

}

// Use this function to alter any data or to do any custom work like create a log record or send an email for example.
function AfterMainAction()
{

}

//useful functions

function Defined(Arg)
{
  return (Arg+""!="undefined");
}

function CreateCase()
{

  vcase = eWare.CreateRecord("cases");
  if (AssignedUser!=0) {
      vcase("Case_AssignedUserId") = AssignedUser;
  }
  if (AssignedChannel!=0) {
      vcase("Case_ChannelId") = AssignedChannel;
  }
  //we must cut off the subject at character 40 as that is the max size of the field in the database.
  //to attempt to insert a value beyond that would crash the script.
  vcase("Case_Description") = eMail.Subject.substring(0,39);
  vcase("Case_Source") = "Email";
  vcase("Case_ProblemType") = "ProblemA";

  vcase("Case_ProblemNote") = eMail.Subject + "\n\n" + "Please see attached communication for full details.";

  var casedate = new Date();
  mydate = casedate.getVarDate();

  vcase("Case_Opened") = mydate;
  if (!UserQuery.EOF) {
    vcase("Case_OpenedBy") = UserQuery("User_UserId");
  }
  vcase("Case_Status") = "In Progress";
  vcase("Case_Priority") = "Normal";
  vcase("Case_NotifyTime") = mydate;

  if (!CompanyQuery.EOF) 
    vcase("Case_PrimaryCompanyId") = CompanyQuery("comp_companyid");
 
  if (!PersonQuery.EOF)
    vcase("Case_PrimaryPersonId") = PersonQuery("pers_personId");

  if (territoryid!=0)
     vcase("Case_SecTerr")=territoryid;

  vcase("Case_NotifyTime")=mydate;

  vcase.SaveChanges();

  caseid = vcase.RecordID;
  vcase("Case_ReferenceId") = AssignedUser + "-" + caseid;
  vcase.SaveChanges();

  caserefid = AssignedUser + "-" + caseid;

//  MsgHandler.MailAdmin('New case created. Ref No: ' + AssignedUser + "-" + caseid, "Please quote this number in all correspondance.")
}

//this sets the default values by using the company and person queries.
function SetDefaults()
{

  if (!CompanyQuery.EOF) {
    if ((territoryid==0) && (CompanyQuery("comp_secterr")!=null)) 
      territoryid=CompanyQuery("comp_secterr");

    if ((AssignedUser==0) && (CompanyQuery("Comp_PrimaryUserId")!=null))
      AssignedUser=CompanyQuery("Comp_PrimaryUserId");
    
    if ((AssignedChannel==0) && (CompanyQuery("Comp_ChannelID")!=null))
      AssignedChannel=CompanyQuery("Comp_ChannelID");
    
  }

  if (!PersonQuery.EOF) {
    if ((territoryid==0) && (PersonQuery("pers_secterr")!=null)) 
      territoryid=PersonQuery("pers_secterr");
    
    if ((AssignedUser==0) && (PersonQuery("Pers_PrimaryUserId")!=null))
      AssignedUser=PersonQuery("Pers_PrimaryUserId");
    
    if ((AssignedChannel==0) && (PersonQuery("pers_ChannelID")!=null))
      AssignedChannel=PersonQuery("pers_ChannelID");
    
  }
}



function SendMail(strsubject)
{

  var SenderName, SenderAddress;

  eMail.IsHTML=true;
  
  SenderName = eMail.SenderName;
  SenderAddress = eMail.SenderAddress;
  MailSubject = eMail.Subject;
  MailBody = eMail.Body;

  eMail.Clear();
  eMail.Recipients.AddAddress(SenderAddress, SenderName);
  eMail.SenderName = MsgHandler.EmailAddress;
  eMail.SenderAddress = MsgHandler.EmailAddress;

  if (strsubject=="")
    eMail.Subject = eWare.GetTrans("GenCaptions","AutoReply") + ": " + MailSubject
  else
    eMail.Subject = strsubject;

  eMail.Body = eWare.GetTrans("GenCaptions","Your mail has been logged") + "<br>" +
               eWare.GetTrans("GenCaptions","Thank you") + "<br><br>" + 
               eWare.GetTrans("GenCaptions","SupportSignature") + "<br><br>" + 
	       MailBody;

  eMail.Send();
}

function SetCommPriority(comm)
{
  //priority
  if (eMail.Priority==prLow)
      comm("Comm_Priority") = "Low";
  else
  if (eMail.Priority==prNormal)
      comm("Comm_Priority") = "Normal";
  else
  if (eMail.Priority==prHigh)
      comm("Comm_Priority") = "High";

}

//this function saves all the attachments for an email.
//If the flag bCreatelibrRec is set then a library record is created
function SaveAttachments(DestFolder, bCreateLibrRec)
{

  var Attachments = eMail.Attachments;

  var libdir = Attachments.LibraryPath + "\\" + DestFolder;

  var AttItem;
  //library records...attachments
  for (i = 0; i < Attachments.Count; i++) {

          //saving the attachment here
          AttItem = Attachments.Items(i);
          //getting a new name for it

      if (AttItem.Name != "_alt.0") {
          NewName = MsgHandler.GetUniqueFileName(libdir, AttItem.Name);
          //saving to the library... 
          AttItem.SaveAs(NewName, libdir);
   
          if (bCreateLibrRec==true)
              SaveLibrRecord(DestFolder + "/", NewName);

          bHasAttachments = true;
     }

  }
  
}

//creates a library record with certain defaults.
function SaveLibrRecord(librPath, librfilename)
{

      librec = eWare.CreateRecord("library");

      librec("Libr_FilePath") = librPath;
      librec("libr_FileName") = librfilename;
      librec("libr_CommunicationId") = commid;
      librec("libr_type") = "EmailAttachment";
      librec("libr_status") = "Complete";
      if (!UserQuery.EOF)
          librec("libr_Userid") = UserQuery("User_UserId");

      librec.SaveChanges();
}

//create a communication
//if the parameter is set to "true" then an imediate notification is created for that communication
function CreateComm(bNotify)
{

  //communication
  comm = eWare.CreateRecord("communication");
  comm("Comm_Action") = "EmailIn";
  comm("Comm_Type") = "email";
  comm("Comm_Status") = "Complete"

  SetCommPriority(comm);

  //comm_datetime
  commdate = new Date();
  mydate = commdate.getVarDate();
  comm("Comm_datetime") = mydate;

  if (AssignedChannel != 0)
  {
    comm("Comm_ChannelId") = AssignedChannel;
  }

  comm("Comm_Note") = eMail.Subject;
  comm("Comm_Email") = eMail.Body;

  if (eMail.SenderName != "")
    comm("comm_from") = "\""+eMail.SenderName + "\" " + "<" + eMail.SenderAddress + "> "
  else
    comm("comm_from") = eMail.SenderAddress;

  comm("comm_to") = GetMailList(eMail.Recipients); 
  comm("comm_cc") = GetMailList(eMail.CC); 
  comm("comm_bcc") = GetMailList(eMail.BCC); 

  if (eMail.Header("Reply-To")!=""){
      comm("comm_replyto") = eMail.Header("Reply-To")
  }else{
      comm("comm_replyto") = eMail.SenderAddress;
  }

  if (caseid!=0){
    comm("Comm_CaseId")=caseid;
  }

  if (territoryid!=0) {
     comm("Comm_SecTerr")=territoryid;
  }

  comm("Comm_IsHtml") = "Y";

  if (bNotify) {
     var commdate = new Date();
     mydate = commdate.getVarDate();
     comm("Comm_NotifyTime")=mydate;
  }

  comm.SaveChanges(); 

  commid = comm.RecordID;

  //comm_link
  commlink = eWare.CreateRecord("comm_link");
  commlink("CmLi_Comm_CommunicationId") = commid;
  if (AssignedUser!=0)
    commlink("CmLi_Comm_UserId") = AssignedUser;

  if ((!PersonQuery.EOF) && (Defined(PersonQuery("pers_personid")))){
      commlink("CmLi_Comm_PersonId") = PersonQuery("pers_personid");
  }
  if ((!CompanyQuery.EOF) && (Defined(CompanyQuery("comp_companyid")))){
      commlink("CmLi_Comm_CompanyId") = CompanyQuery("comp_companyid");
  }
  commlink.SaveChanges();

  var subfolder = new String(commid);
  subfolder = "Comm" + subfolder;

  //save the attachments finally
  if (!CompanyQuery.EOF)
	SaveAttachments(CompanyQuery("comp_librarydir") + "\\" + (subfolder), true)
  else
  if (!PersonQuery.EOF)
	SaveAttachments(PersonQuery("pers_librarydir") + "\\" + (subfolder), true)
  else
  if (!UserQuery.EOF)
	SaveAttachments(UserQuery("User_firstname") + " " + UserQuery("User_lastname") + "\\" + (subfolder) , true)
  else
	SaveAttachments("unknown" , true);

  if (bHasAttachments){
      comm("comm_hasattachments")="Y";
      comm.SaveChanges(); 
  }

}

function CreateReponseComm()
{

  //communication
  comm = eWare.CreateRecord("communication");
  comm("Comm_Action") = "EmailOut";
  comm("Comm_Type") = "email";
  comm("Comm_Status") = "Complete"

  //priority
  SetCommPriority(comm);

  //comm_datetime
  commdate = new Date();
  mydate = commdate.getVarDate();
  comm("Comm_datetime") = mydate;

  if (AssignedChannel != 0)
  {
    comm("Comm_ChannelId") = AssignedChannel;
  }

  comm("Comm_Note") = eMail.Subject;
  comm("Comm_Email") = eMail.Body;

  if (caseid!=0)
    comm("Comm_CaseId")=caseid;  

  if (territoryid!=0) {
     comm("Comm_SecTerr")=territoryid;
  }

  comm("Comm_IsHtml")="Y";

  comm.SaveChanges(); 

  //comm_link
  commlink = eWare.CreateRecord("comm_link");
  commlink("CmLi_Comm_CommunicationId") = comm.RecordId;
  if (AssignedUser!=0)
    commlink("CmLi_Comm_UserId") = AssignedUser;

  if ((!PersonQuery.EOF) && (Defined(PersonQuery("pers_personid"))))
      commlink("CmLi_Comm_PersonId") = PersonQuery("pers_personid");
  
  if ((!CompanyQuery.EOF) && (Defined(CompanyQuery("comp_companyid"))))
      commlink("CmLi_Comm_CompanyId") = CompanyQuery("comp_companyid");
  
  commlink.SaveChanges();

}

function CaseTracker()
{
var mycase
var BIsValid
  //try to get the case number
  mycase = ParseForCaseRef(eMail.Subject);

  //check if the email subject contains a case reference number
  if (mycase!="") 
  {
       //if it does then check if it is a valid case reference
       if (IsValidCase(mycase)) {
           BIsValid = true;
       } else {
           BIsValid = false;      
       }
  } else {
       BIsValid = false;      
  } 

  //if it is valid then create a communication against it the case and notify the user
  if (BIsValid) {

     caseid=CaseQuery("Case_CaseId");
     CreateComm(true);  
     SendMail("");
     CreateReponseComm();//record our auto response

  } else {    

     //else create the case and communication and notify the user
     CreateCase();
     CreateComm(false);
     SendMail("Case Ref: " + caserefid + ". Please quote this number in all correspondance");
     CreateReponseComm();//record our auto response
  }

}

//this function checks if the case is valid. the value parameter should contain a 
//case refernce Id
function IsValidCase(value)
{

  CaseSQL = "Select * from vCases where Case_ReferenceId='" + value + "'"
  CaseQuery = eWare.CreateQueryObj(CaseSQL);
  CaseQuery.SelectSQL();//open the query
  if (CaseQuery.EOF){
      return(false);
  } else {
      return(true);
  }

}

//this function uses a regular expression to obtain a case reference id from the value parameter
//if it contains one then it is returned as the result of the function
function ParseForCaseRef(value)
{
   var r, re, singlestr; //Declare variables.

   //create my test string
   var s = value;

   //Create regular expression pattern. Used for getting the case reference
   re = /[\d]+-[a-z_0-9]{1,20}/i; 
   re.Global = true;
   re.IgnoreCase = true;
   re.MultiLine = true;

   singlestr = s.match(re);
   if (singlestr==null) {
      singlestr=""
   }
   return(singlestr);                   //Return the first case ref
}

//
// This function finds the first email address and returns
// the email address.
//
function ParseForEmailAddress(value){
   var r, re, singlestr; //Declare variables.
  
   //create my test string
   var s = value;

   //Create regular expression pattern. used for testing whether a string is a valid email address
   re = /[a-z][a-z_0-9_\'\.]+@[a-z_0-9_\-_'\.]+\.[a-z]{2,3}/i; 
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
  newname += ndt.getHours() + "." + ndt.getMinutes() + " " + ndt.getDay() + "-" + (ndt.getMonth()+1) 
                     + "-" + ndt.getYear() + " " + ndt.getHours() +":" + ndt.getMinutes() +":" 
                     + ndt.getSeconds() +"." + ndt.getMilliseconds() + Ext;

  return(newname);

}


//this function expects either "eMail.Recipients" or "eMail.CC" or "eMail.BCC" as a parameter.
//it returns a string containing the email addresses and friendly names of the respective list.
function GetMailList(mylist)
{
  var ToList;
  ToList="";
  for (i = 0; i < (mylist.Count); i++) {

    if (i!=0)
 	ToList = ToList + ", ";

    if (mylist.Items(i).Name != "")
 	ToList = ToList + "\"" + mylist.Items(i).Name + "\" <" + mylist.Items(i).Address + "> "
    else
 	ToList = ToList + mylist.Items(i).Address;
  }
  return(ToList); 
}


function CheckIfValInArray(MyVal, MyArray)
{
  for (i = 0; i < (MyArray.length); i++)
     {
        if (MyArray[i]==MyVal)
           return(true)
        else
           return(false);
     }
}

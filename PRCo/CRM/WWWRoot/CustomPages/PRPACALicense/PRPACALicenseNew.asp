<!-- #include file ="..\accpaccrm.js" -->

<%

var Now=new Date();
if (eWare.Mode<Edit) eWare.Mode=Edit;

record=eWare.CreateRecord("PRPACALicense");
if( true )
  record.SetWorkFlowInfo("PRPACALicense Workflow", "Start");

EntryGroup=eWare.GetBlock("PRPACALicenseNewEntry");
EntryGroup.Title="PACA License";

context=Request.QueryString("context");
if(!Defined(context) )
  context=Request.QueryString("Key0");

if( !false )
  eWare.SetContext("New");

if( context == iKey_CompanyId && true )
{
  CompId = eWare.GetContextInfo('Company','Comp_CompanyId');
  if ((Defined(CompId)) && (CompId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_CompanyId");
    Entry.DefaultValue = CompId;
  }
}
else if( context == iKey_PersonId && true )
{
  PersId = eWare.GetContextInfo('Person','Pers_PersonId');
  if ((Defined(PersId)) && (PersId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_PersonId");
    Entry.DefaultValue = PersId;
  }
}
else if( context == iKey_UserId && true )
{
  UserId = eWare.GetContextInfo('User', 'User_UserId');
  if ((Defined(UserId)) && (UserId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_UserId");
    Entry.DefaultValue = UserId;
  }
}
else if( context == iKey_ChannelId && true )
{
  ChanId = eWare.GetContextInfo('Channel', 'Chan_ChannelId');
  if ((Defined(ChanId)) && (ChanId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_ChannelId");
    Entry.DefaultValue = ChanId;
  }
}
else if( context == iKey_LeadId && false )
{
  LeadId = eWare.GetContextInfo('Lead','Lead_LeadId');
  if ((Defined(LeadId)) && (LeadId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_LeadId");
    Entry.DefaultValue = LeadId;
  }
}
else if( context == iKey_OpportunityId && false )
{
  OppoId = eWare.GetContextInfo('Opportunity','Oppo_OpportunityId');
  if ((Defined(OppoId)) && (OppoId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_OpportunityId");
    Entry.DefaultValue = OppoId;
  }
}
else if( context == iKey_CaseId && false )
{
  CaseId = eWare.GetContextInfo('Case','Case_CaseId');
  if ((Defined(CaseId)) && (CaseId > 0))
  {
    Entry = EntryGroup.GetEntry("prpa_CaseId");
    Entry.DefaultValue = CaseId;
  }
}

names = Request.QueryString("fieldname");
if( Defined(names) )
{
  vals = Request.QueryString("fieldval");
  //get values from dedupe box
  for( i = 1; i <= names.Count; i++)
  {
    Entry = EntryGroup.GetEntry(names(i));
    if( Entry != null )
      Entry.DefaultValue = vals(i);
  }
}

container=eWare.GetBlock("container");
container.AddBlock(EntryGroup);

container.AddButton(
   eWare.Button("Cancel", "cancel.gif",
      eWare.Url("PRPACALicense/PRPACALicenseFind.asp")+"&T=find&E=PRPACALicense"));

eWare.AddContent(container.Execute(record));

if(eWare.Mode==Save)
  Response.Redirect("PRPACALicenseSummary.asp?J=PRPACALicense/PRPACALicenseSummary.asp&E=PRPACALicense&prpa_PACALicenseId=" + record("prpa_PACALicenseId")+"&"+Request.QueryString);
else
{
  RefreshTabs=Request.QueryString("RefreshTabs");
  if( RefreshTabs = 'Y' )
    Response.Write(eWare.GetPage('New'));
  else
    Response.Write(eWare.GetPage());
}

%>

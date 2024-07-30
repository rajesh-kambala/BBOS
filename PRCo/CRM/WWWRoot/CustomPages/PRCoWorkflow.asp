<%
// define contants

var WORK_SSFILE = "Special Services Workflow";
// these are the Special Services file states
var WFST_SS_INITIAL = "Initial";
var WFST_SS_QUALIFIED = "Qualified";
var WFST_SS_WAITPLAN = "Wait PLAN Accept Ltr";
var WFST_SS_PLANCONTROL = "PLAN Control";
var WFST_SS_PLANCOLLECTED = "Collected by PLAN";
var WFST_SS_PLANUNCOLLECTED = "Uncollected by PLAN";
var WFST_SS_LITIGATION = "Litigation";
var WFST_SS_WAITING = "Waiting";
var WFST_SS_FORMALCLAIM = "Formal Claim";
var WFST_SS_COLLECTED = "Collected/ Resolved";
var WFST_SS_PAYMENTSCHEDULE = "Payment Schedule";
var WFST_SS_PENDING = "Pending";
var WFST_SS_CLOSED = "Closed";

// these are the Special Services file Rules
var WFRL_SS_NEW = "New Special Services File";
var WFRL_SS_GATHER = "Gather Info";
var WFRL_SS_SENDPLAN = "Send PLAN Info";
var WFRL_SS_TOPLAN = "Go To PLAN";
var WFRL_SS_PLANCOLLECTS = "PLAN Collects";
var WFRL_SS_PLANCLOSES = "PLAN Closes";
var WFRL_SS_TOCOURT = "Go To Court";
var WFRL_SS_OPENCLAIM = "Open Claim";
var WFRL_SS_SENDA1 = "Send A-1";
var WFRL_SS_REOPENCLAIM = "Re-Open Claim";
var WFRL_SS_PRCORESOLVES = "PRCo Resolves";
var WFRL_SS_NEGOTIATESCHEDULE = "Negotiate Payment Schedule";
var WFRL_SS_PROVIDEADVICE = "Provide Advice";
var WFRL_SS_CLOSE = "Close";

// OPPORTUNITY VALUES
// these are used by the ASP fiels only
var OPP_TYPE_NEWMEMBERSHIP = "NEWM";
var OPP_TYPE_UPGRADE = "UPG";
var OPP_TYPE_BLUEPRINT = "BP";
// summary pages
var OPP_SUMMPAGE_NEWMEMBERSHIP = "PROpportunity/PRMembershipOpportunity.asp";
var OPP_SUMMPAGE_UPGRADE = "PROpportunity/PRMembershipUpgradeOpp.asp";
var OPP_SUMMPAGE_BLUEPRINT = "PROpportunity/PRBlueprintsOpportunity.asp";


// these are the Opportunity Rules
var WFST_OPP_INITIAL = "Initial";
var WFST_OPP_QUALIFIED = "Qualified";
var WFST_OPP_PROPSALSUBMITTED = "Propsal Submitted";
var WFST_OPP_NEGOTIATING = "Negotiating";
var WFST_OPP_SALECLOSED = "Sale Closed";
var WFST_OPP_DEALLOST = "Deal Lost";
// these are the Opportunity Rules
var WFRL_OPP_NEWBLUEPRINTS = "New Blueprints Opportunity";
var WFRL_OPP_NEWUPGMEMBERSHIP = "New Membership Upgrade Opportunity";
var WFRL_OPP_NEWMEMBERSHIP = "New Membership Opportunity";
var WFRL_OPP_QUALIFY = "Qualify";
var WFRL_OPP_SUBMITPROPOSAL = "Submit Proposal";
var WFRL_OPP_SOLD = "Sold";
var WFRL_OPP_NEGOTIATE = "Negotiate";
var WFRL_OPP_NOTSOLD = "Not Sold";
var WFRL_OPP_LOSTFORTARGETISSUE = "Lost for Target Issue";

// these are the Customer Care Workflow
var WFST_CS_START = "Start";
var WFST_CS_LOGGED = "Logged";
var WFST_CS_RESEARCHING = "Researching";
var WFST_CS_CLOSED = "Closed";
// these are the Customer Care Workflow
var WFRL_CS_NEW = "New Case";
var WFRL_CS_PENDING = "Pending";
var WFRL_CS_CLOSE = "Close";
var WFRL_CS_REOPEN = "Re-open";

var sNextStateName = "";
var sWorkflowRuleName = "";
var sWfValidate = "";
var recWfIn = null;
var recWfTr = null;
var recWfRl = null;
var recWfNextState = null;


function getWorkFlowButtons(WkIn_InstanceId )
{
    recWkIn= eWare.FindRecord("WorkflowInstance", "WkIn_InstanceID=" + WkIn_InstanceId);
	// get the current state id
	var sCurrentStateId = recWkIn("wkin_CurrentStateId");
	var sCurrentRecordId = recWkIn("wkin_CurrentRecordId");
	var sWorkflowId = recWkIn("wkin_WorkflowId");
	// get the description of the current state
	var recCurrentState  =eWare.FindRecord("WorkflowState", "wkst_StateId="+sCurrentStateId);
	var sCurrentState = recCurrentState("wkst_Name");
	// Find all the states that can be transitioned to 
	
	var sText = "<BR><BR><TABLE WIDTH=100 CLASS=workflow COLS=2 CELLPADDING=0 CELLSPACING=0 BORDER=0>" +
		"<TR><TD CLASS=WFBUTTON>&nbsp;Actions:<BR><BR>Current State: " + sCurrentState + "<BR><BR></TD></TR>" +
		"<TR><TD ALIGN=RIGHT><TABLE CLASS=Button WIDTH=100>";
    var recNextStates = eWare.FindRecord("WorkflowTransition", "wktr_StateId="+sCurrentStateId);
    while (!recNextStates.eof)
    {
        // create a new row for each item            
        sURLLink = eWare.URL(400);
        recRule = eWare.FindRecord("WorkflowRules", "wkrl_RuleId=" + recNextStates("wktr_RuleId"));

        // sInstallName is defined in accpaccrmNoLang.js, a file included by all crm pages
        var sImagePath = "/" + sInstallName + "/img"
        
        // Key7 = CurrentRecord Id; Key50 = workflow instance id; Key27 = workflow rule id; trid = transtition id
        sURLLink += "&Key50="+WkIn_InstanceId+"&Key27="+recNextStates("wktr_RuleId")+"&trid="+recNextStates("wktr_TransitionId")
        sText += "<TR><TD CLASS=WFBUTTON><TABLE CELLPADDING=0 CELLSPACING=0 BORDER=0><TR><TD>"+
                "<A CLASS=WFBUTTON HREF=\"" + sURLLink + "\">" +
                "<IMG SRC=\"" + sImagePath + "/Buttons/" + recRule("wkrl_Image")+ "\" BORDER=0 ALIGN=MIDDLE></A> " +
                "</TD><TD>&nbsp;</TD><TD><A CLASS=WFBUTTON HREF=\"" + sURLLink + "\">" + recRule("wkrl_Caption") + "</A>" +
                "</TD></TR></TABLE></TD></TR>";
                
        recNextStates.NextRecord();
    }
    sText += "</TABLE></TD></TR></TABLE>";
    return sText;
}

%>
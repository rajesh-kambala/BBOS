// define contants
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

var WF_COLL_INVOICECREDITOR = "You should now invoice the Creditor through the Order Entry system.";
var WF_SS_SENDA1LETTER = "You should now fax the A-1 Letter to the Debtor (on letterhead) with 'cc' to Creditor.";
var WF_OP_SENDOPINIONFEELETTER = "You should now send the Opinion Fee Letter.";
var WF_OP_SENDDISPUTEFEELETTER = "You should now send the Dispute Fee Letter.";
var WF_FI_CLOSEAFTEROPINION_NOLETTER = "Confirm the 'Amount PRCo Invoiced' value and enter the 'Opinion Letter Sent Date'. After saving, you should submit the order.";
var WF_FI_CLOSEAFTEROPINION = "Confirm the 'Amount PRCo Invoiced' value. After saving, you should submit the order.";

// OPPORTUNITY VALUES
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


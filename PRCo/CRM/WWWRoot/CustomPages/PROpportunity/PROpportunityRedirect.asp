<!-- #include file ="..\accpaccrm.js" -->
<!-- #include file ="../PRCoGeneral.asp" -->
<!-- #include file ="../PRCoWorkflow.asp" -->

<%

    // to redirect this properly, get the workflow instance; 
    var oppo_opportunityid = getIdValue("oppo_opportunityid");

    if (oppo_opportunityid == -1)
        oppo_opportunityid = getIdValue("Key7");

    if (oppo_opportunityid == -1)
        oppo_opportunityid = getIdValue("Key58");
        
	if (oppo_opportunityid == -1)
	{
		// if it is not present, go back to where we came from 
		Response.Redirect( eWare.URL(F) );

	}
	else
	{
		// determine the Opportunity type; oppo_type
        recOpp = eWare.FindRecord("Opportunity", "oppo_opportunityid=" + oppo_opportunityid);
		oppo_type = recOpp("oppo_type");

		var sBaseURL = eWare.URL("PROpportunity/PROpportunitySummary.asp");
		// change the F value to our current one
		sBaseURL = removeKey(sBaseURL, "Key37");
		sBaseURL = removeKey(sBaseURL, "Key27");
		sBaseURL = changeKey(sBaseURL, "F", F);
		sBaseURL = changeKey(sBaseURL, "Key0", "7");
		sBaseURL = changeKey(sBaseURL, "Key7", oppo_opportunityid);
		sBaseURL = changeKey(sBaseURL, "Key1", recOpp("oppo_PrimaryCompanyId"));
		
		if (recOpp("oppo_PrimaryPersonId") == null) {
		    sBaseURL = removeKey(sBaseURL, "Key2");
		} else {
		    sBaseURL = changeKey(sBaseURL, "Key2", recOpp("oppo_PrimaryPersonId"));
		}
		
		//Response.Write(sBaseURL);
		Response.Redirect(sBaseURL);
	}
%>
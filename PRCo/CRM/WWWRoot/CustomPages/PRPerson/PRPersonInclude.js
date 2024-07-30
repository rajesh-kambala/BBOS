var TRX_STATUS_NONE = 0;
var TRX_STATUS_LOCKED = 1;
var TRX_STATUS_EDIT = 2;
function AddTransactionBar(iTrxStatus, lockedUserName)
{
    var sDiv = "";
    if (iTrxStatus == TRX_STATUS_EDIT)
    {
        sDiv = "<table width=\"100%\" class=\"InfoContent\"><tr><td>You have this Person open for editing. Close the current transaction to allow others to edit this Person.</td></tr></table> ";
    }
    else if (iTrxStatus == TRX_STATUS_LOCKED)
    {
        if (lockedUserName == null)
            lockedUserName = "";
        sDiv = "<table width=\"100%\" class=\"ErrorContent\"><tr><td>This Person is currently Locked by " + lockedUserName + ".</td></tr></table> ";
    }
    colImgs = document.getElementsByTagName("IMG"); 
    nodeDiv = document.createElement("DIV");
    nodeDiv.innerHTML = sDiv;
    
    colImgs = document.getElementsByTagName("IMG"); 
    for (ndx=0; ndx<colImgs.length; ndx++)
    {
        if (colImgs[ndx].src.indexOf("paneleftcorner.jpg") > -1)
        {
            var parElement = colImgs[ndx].parentElement; 
            while (parElement.tagName != "FORM" && parElement != null)
            {
                parElement = parElement.parentElement; 
            }
            if (parElement != null)
            {
                var parentOfForm = parElement.parentElement;
                parentOfForm.insertBefore(nodeDiv,parElement);
            }
            break;
        }
    }
    
    
}
function onPhoneTypeChange()
{
    handleOnPhoneTypeChange(window.event.srcElement);
}
function handleOnPhoneTypeChange(selType)
{
    txtDescription = document.getElementById("phon_prdescription");
    if (selType != null)
    {
        if (selType.selectedIndex < 0)
            txtDescription.value = "";
        else {

            sTypeCode = selType.options[selType.selectedIndex].value;
            var selectectText = selType.options[selType.selectedIndex].text;

            if (sTypeCode == "O")
                txtDescription.value = "";
            else
                txtDescription.value = selectectText;
        }
    }

} 
function savePhone()
{
    bValidationError = false;
    if (document.getElementById("plink_type").value == 'E' && document.getElementById("phon_prextension").value == '')
    {
        bValidationError = true;
        alert('Extension is required for this phone type.');
    }    
    
    if (!bValidationError)
        document.EntryForm.submit();    

}

function RedirectPerson()
{
	var sUrl = String(location.href);

	iEWare = sUrl.indexOf("eware.dll");
	var sApp = sUrl.substring(0, iEWare);

	iQMark = sUrl.indexOf("?");
	var sQuery = sUrl.slice(iQMark, sUrl.length);

	var sAction = new String(""); 
	ndx = sQuery.indexOf("&Act=");
	if (ndx >= 0 )
	{
		ndxNext = sQuery.indexOf("&", ndx+5);

		sAction = sQuery.substring(ndx+5, ndxNext);
		if (sAction == "141" || sAction == "166")
		{
	        //remove all the keys and summary will interpret as "new"
	        sQuery = removeKey(sQuery,"Act");
	        sQuery = removeKey(sQuery,"Key0");
	        sQuery = removeKey(sQuery,"Key1");
	        sQuery = removeKey(sQuery,"Key2");
	        sQuery = removeKey(sQuery,"pers_personid");
	        location.href = sApp + "CustomPages/PRPerson/PRPersonSummary.asp"+sQuery;	    
        }
        else if (sAction == 220 || sAction == "520" )
		{
	        // 520 appears to be the recent list action
		    sQuery = removeKey(sQuery, "Act");
		    sQuery = removeKey(sQuery, "Key0");
		    sQuery = removeKey(sQuery, "Key1");
		    sQuery = removeKey(sQuery, "Key2");
		    sQuery = removeKey(sQuery, "pers_personid");
		    sQuery = removeKey(sQuery, "Pers_PersonId")
	        location.href = sApp + "CustomPages/PRPerson/PRPersonSummary.asp"+sQuery+GetKeys();	    
        }

    }
	return;
}
function RedirectPersonSummary()
{
	var sUrl = String(location.href);

	iEWare = sUrl.indexOf("eware.dll");
	var sApp = sUrl.substring(0, iEWare);

	iQMark = sUrl.lastIndexOf("?");
	var sQuery = sUrl.slice(iQMark, sUrl.length);

	var sAction = new String(""); 
	ndx = sQuery.indexOf("&Act=");
	if (ndx >= 0 )
	{
		ndxNext = sQuery.indexOf("&", ndx+5);

		sAction = sQuery.substring(ndx+5, ndxNext);
		if (sAction == "141" )
		{
	        sQuery = removeKey(sQuery,"Act");
	        //location.href = sApp + "CustomPages/PRPerson/PRPersonSummary.asp"+sQuery;	    
        }
    }
	return;
}

function ProcessPersonNotes()
{
    var sUrl = String(location.href); 

    var ndxShouldRedirect = sUrl.indexOf("shouldredirect=0"); 
    // if shouldredirect is not turned off, go to our custom page
    if (ndxShouldRedirect == -1){ 
        iEWare = sUrl.indexOf("eware.dll");
        var sApp = sUrl.substring(0, iEWare);
        iQMark = sUrl.lastIndexOf("?");
        var sQuery = sUrl.slice(iQMark, sUrl.length);
        //sQuery = removeKey(sQuery,"Act");
        location.href = sApp + "CustomPages/PRPerson/PRPersonNotes.asp"+sQuery;	    
    }
    else
    { 
        // this modifies the standard accpac display of PersonNotesList
        colImgs = document.getElementsByTagName("IMG"); 
        // based upon the transaction status, hide the AddNote button
        var ndxTrx = sUrl.indexOf("&trx=");
        if (ndxTrx > -1)
        {
            ndxTrxEnd = sUrl.indexOf("&",ndxTrx+5);
            if (ndxTrxEnd == -1)
                ndxTrxEnd = sUrl.length;
            nTrxStatus = parseInt(sUrl.substr(ndxTrx+5, ndxTrxEnd + 1));

            var sLockUsername = "";
            if (nTrxStatus == TRX_STATUS_LOCKED)
            {
                var ndxUser = sUrl.indexOf("&lockUsername=");
                if (ndxUser > -1)
                {
                    ndxUserEnd = sUrl.indexOf("&",ndxUser+14);
                    if (ndxUserEnd == -1)
                        ndxUserEnd = sUrl.length;
                    sLockUsername = sUrl.substr(ndxUser+14, ndxUserEnd + 1);
                }
            }
            
            AddTransactionBar(nTrxStatus, sLockUsername);

            // if this is not in edit (a trx is open)
            if (nTrxStatus != TRX_STATUS_EDIT)
            {
                // find and remove the add notes button
                for (ndx=0; ndx<colImgs.length; ndx++)
                {
                    if (colImgs[ndx].src.indexOf("NewTask.gif") > -1)
                    {
                        var parElement = colImgs[ndx].parentElement; 
                        while (parElement.tagName != "TR" && parElement != null)
                        {
                            parElement = parElement.parentElement; 
                        }
                        if (parElement != null) {
                            parElement.style.display = "none";
                        }
                        break;
                    }           
                }
            }
        }
    } 
    return;
}

function togglePreferredPublished() {

    if (!document.getElementById("_IDphon_prpublish").checked) {
        document.getElementById("_IDphon_prpreferredpublished").checked = false;
    }
}

function togglePublished() {

    if (document.getElementById("_IDphon_prpreferredpublished").checked) {
        document.getElementById("_IDphon_prpublish").checked = true;
    }
}
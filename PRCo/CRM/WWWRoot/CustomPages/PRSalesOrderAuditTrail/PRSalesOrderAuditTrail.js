var Mode=0;
var userlogon = null;

function save()
{
    // make sure this is not in readonly mode
    if (validate()) {
        document.EntryForm.submit();
    }
}

function initializePage()
{
}

function validate()
{
	return true;		
}
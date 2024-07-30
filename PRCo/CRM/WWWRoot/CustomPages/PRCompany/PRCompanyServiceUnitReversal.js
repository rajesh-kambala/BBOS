function validate()
{
    var sErrors = "";
    
    // perform any validation here
    
    if (sErrors != "")
    {
        alert(sErrors);
        return false;
    }

    
    return true;    
}

var bSaveFlag = false;            
function save()
{
    if (bSaveFlag == true) {
        return;
    }
    bSaveFlag = true;    
    document.EntryForm.submit();
}

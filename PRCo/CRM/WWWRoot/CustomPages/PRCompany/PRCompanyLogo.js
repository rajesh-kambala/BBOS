function save() {

    var selectedLogoCompanyID = document.EntryForm.logoCompanyID.value;
    
    if ((selectedLogoCompanyID == "") &&
        (saveLogoCompanyID != "")) {
    
        if (!confirm("By saving this form without specifying a BBID for logo, the current logo setting will be deleted.  Are you sure you want to continue?")) {
            return;
        }
    }

    document.EntryForm.submit();
}
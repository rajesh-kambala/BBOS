function step1Click() {

    var msg = "";

    if (document.EntryForm.prplmal_sourcecompanyid.value == "") {
        msg = " - A source company must be selected.\n";
    }

    if (document.EntryForm.prplmal_targetcompanyid.value == "") {
        msg += " - A target company must be selected.\n";
    }

    if (msg != "") {
        msg = "Please correct the following errors:\n\n" + msg
        alert(msg);
        return;
    }
    
    document.EntryForm.submit();
}

function step2Click() {
    var msg = "";

    if (document.getElementById("_Licenses").value == "") {
        msg = " - A license must be selected.\n";
    }

    if (msg != "") {
        msg = "Please correct the following errors:\n\n" + msg
        alert(msg);
        return;
    }
    
    document.EntryForm.submit();
}
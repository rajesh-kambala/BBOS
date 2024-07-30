function save() {
    if (document.getElementById("prar_prcocompanyid").value == "") {
        alert("Please select a CRM company.");
        return;
    }

    document.EntryForm.submit();
}

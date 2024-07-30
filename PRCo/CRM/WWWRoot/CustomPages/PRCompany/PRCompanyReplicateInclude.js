function save()
{
    var sList = "";
    tblCheckboxes = document.getElementById("_CompaniesListing");
    var arrCheckboxes = tblCheckboxes.getElementsByTagName("INPUT");
    for (ndx=0; ndx<arrCheckboxes.length; ndx++)
    {
        if (arrCheckboxes[ndx].checked == true && arrCheckboxes[ndx].disabled == false)
        {
            if (sList != "")
                sList += ",";
            sList += arrCheckboxes[ndx].getAttribute("CompanyId");
        }
    }
    hdnSelectedCompanies = document.getElementById("hdn_SelectedCompanies");
    hdnSelectedCompanies.value = sList;

    document.EntryForm.submit();
}

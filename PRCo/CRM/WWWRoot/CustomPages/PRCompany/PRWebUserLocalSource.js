function EditUser(webUserID, serviceCodes) {


    document.getElementById("pnlEdit").style.display = "";
    document.getElementById('pnlEdit').style.position = "fixed";
    document.getElementById('pnlEdit').style.top = "50%";
    document.getElementById('pnlEdit').style.left = "50%";
    document.getElementById('pnlEdit').style.display = 'block';


    document.getElementById("hdnWebUserID").value = webUserID;

    var codes = serviceCodes.split(",");
    for (var i = 0; i < codes.length; i++) {
        
        var code = codes[i].trim();
        if (code != "") {
            document.getElementById("cb" + code).checked = true;
            document.getElementById("cb" + code).disabled = false;
        }
    }
}
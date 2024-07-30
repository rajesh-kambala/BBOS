var _FCKFields = Array();
function FCKFields() {
    _FCKFields = arguments;
}

window.addEventListener('load', function () {
    cssPath = document.styleSheets[0].href;
    addr = window.location.toString();
    serverAddr = addr.slice(0, addr.search(/[^:\/]\//) + 1);
    cssPath = cssPath.replace(serverAddr, "");
    crmVirtDir = cssPath.slice(0, cssPath.search(/\/Themes/) + 1);
    theme = cssPath.split('.')[0];
    theme = theme.slice(theme.search(/\/[^\/]*$/) + 1);
    for (var i = 0; i < _FCKFields.length; i++) {
        var oTextArea = document.getElementsByName(_FCKFields[i]);
        if (oTextArea.length > 0) {
            oTextArea = oTextArea[0];
            oTextArea.id = 'soln_solutiondetails';
            var oFCKeditor = new FCKeditor(_FCKFields[i], '100%', '400px', 'Default');
            var sBasePath = crmVirtDir + "FCKeditor/";
            var sBaseHref = serverAddr + crmVirtDir + "eware.dll/";
            oFCKeditor.BasePath = sBasePath;
            oFCKeditor.Config["BaseHref"] = sBaseHref;
            //oFCKeditor.Config["DefaultLanguage"] = getFCKLang(CurrentUser.user_language);
            oFCKeditor.Config["DefaultLanguageCRM"] = CurrentUser.user_language;
            oFCKeditor.Config["SkinPath"] = crmVirtDir + "Themes/FCKEditor/" + theme + "/skins/office2003/";
            oFCKeditor.Config["EditorAreaCSS"] = crmVirtDir + "Themes/FCKEditor/" + theme + "/css/fck_editorarea.css";
            oFCKeditor.Config["SpellChecker"] = "JSpellCheck";
            oFCKeditor.Config["StylesheetJSpell"] = serverAddr + crmVirtDir + "Themes/FCKEditor/" + theme + "/jspell/jspell.css";
            oFCKeditor.ReplaceTextarea();
        } else {
            var oDiv = document.getElementById('_Data' + _FCKFields[i]);
            if (oDiv != null) {
                strContent = oDiv.innerHTML.replace(/&lt;/g, '<').replace(/&gt;/g, '>');
                oDiv.innerHTML = strContent;
            }
        }
    }
});

var _CKFields = Array();
function CKFields() {
    _CKFields = arguments;
}

window.addEventListener('load', function () {
    cssPath = document.styleSheets[0].href;
    addr = window.location.toString();
    serverAddr = addr.slice(0, addr.search(/[^:\/]\//) + 1);
    cssPath = cssPath.replace(serverAddr, "");
    crmVirtDir = cssPath.slice(0, cssPath.search(/\/Themes/) + 1);
    theme = cssPath.split('.')[0];
    theme = theme.slice(theme.search(/\/[^\/]*$/) + 1);
    for (var i = 0; i < _CKFields.length; i++) {
        var oTextArea = document.getElementsByName(_CKFields[i]);
        if (oTextArea.length > 0) {
            oTextArea = oTextArea[0];
            CKEDITOR.replace(_CKFields[i]);
        } else {
            var oDiv = document.getElementById('_Data' + _CKFields[i]);
            if (oDiv != null) {
                strContent = oDiv.innerHTML.replace(/&lt;/g, '<').replace(/&gt;/g, '>');
                strContent = strContent.replace(/<br>/g,'');
                oDiv.innerHTML = strContent;
            }
        }
    }
});

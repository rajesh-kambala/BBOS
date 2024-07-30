function confirmCloseTransaction2(sSaveUrl) {
    if (confirm("Are you sure that you want to close the transaction?  This company has attention line(s) with missing delivery methods.")) {
        setTimeout(function () { document.location.href = sSaveUrl }, 0);
    }
    return false;
}

function confirmCloseTransaction(sSaveUrl) {
    if (confirm("Are you sure that you want to close the transaction?")) {
        setTimeout(function () { document.location.href = sSaveUrl }, 0);
    }
    return false;
}

function delayRedirect(URL) {
    setTimeout(function () { window.location = URL }, 300);
}
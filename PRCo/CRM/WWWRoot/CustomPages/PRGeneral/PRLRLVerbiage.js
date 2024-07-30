function resetVerbiageDisplay() {
    resetVerbiageField("_Dataprlrlv_deadlinemsg");
    resetVerbiageField("_Dataprlrlv_letterintro");
    resetVerbiageField("_Dataprlrlv_noconnectionlistmsg");
    resetVerbiageField("_Dataprlrlv_oldconnectionlistmsg");
    resetVerbiageField("_Dataprlrlv_volumemsg");
    resetVerbiageField("_Dataprlrlv_dlpaymentduemsg");
    resetVerbiageField("_Dataprlrlv_dplromotionmsg");
    resetVerbiageField("_Dataprlrlv_changeauthorizationmsg");
    resetVerbiageField("_Dataprlrlv_reasonleftcodes");
    resetVerbiageField("_Dataprlrlv_personnelannouncementmsg");
    resetVerbiageField("_Dataprlrlv_addprimarypersonnelhdr");
    resetVerbiageField("_Dataprlrlv_addprimarypersonnelmsg");
    resetVerbiageField("_Dataprlrlv_addprimarypersonneltbl");
}


function resetVerbiageField(szSpanName) {
    eSpan = document.getElementById(szSpanName);
    eSpan.className = "Verbiage";
    eSpan.innerHtml = eSpan.innerHtml..replace(/"\n"/g, "<br/>");
    _Dataprlrlv_deadlinemsg 
}
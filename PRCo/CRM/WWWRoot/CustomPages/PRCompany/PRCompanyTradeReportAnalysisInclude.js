
function hideAnalysis()
{
    showhideAnalysis(false);
}
function showAnalysis()
{
    showhideAnalysis(true);
}
function showhideAnalysis(bShouldShow)
{
    sShowStyle = "none";
    if (bShouldShow == true)
        sShowStyle = "block";
        
    // get the analysis table
    var tblAnalysis = document.all("_blk_tblAnalysisBlock");
    if (tblAnalysis != null)
    {
        tblAnalysis.style.display = sShowStyle;
    }
    // first find the table and row for the Hide Analysis and Show Analysis buttons
    var arrAnchors = document.getElementsByTagName("A");
    var trHide = null;
    var trShow = null;
    for (ndx=0; ndx < arrAnchors.length; ndx++)
    {
        if ((trShow != null) && (trHide != null))
            break;

        var anchor = arrAnchors[ndx];
        if (anchor.href == "javascript:showAnalysis();")
        {
            // 5th parent element of the <a> is the tr
            trShow = anchor.parentElement.parentElement.parentElement.parentElement.parentElement;
        }
        else if (anchor.href == "javascript:hideAnalysis();")
        {
            // 5th parent element of the <a> is the tr
            trHide = anchor.parentElement.parentElement.parentElement.parentElement.parentElement;
        }
    }
    if (trHide != null)
    {
        trHide.style.display = "none";
        if (bShouldShow == true)
            trHide.style.display = "block";
    }    
    if (trShow != null)
    {
        trShow.style.display = "block";
        if (bShouldShow == true)
            trShow.style.display = "none";
    }
    if (bShouldShow == true)
        document.all("chk_hideanalysis").checked = false;
    else    
        document.all("chk_hideanalysis").checked = true;
           
}


function hideTotals()
{
    showhideTotals(false);
}
function showTotals()
{
    showhideTotals(true);
}
function showhideTotals(bShouldShow)
{
    sShowStyle = "none";
    if (bShouldShow == true)
        sShowStyle = "block";
        
    // get the Totals table
    var tblTotals = document.all("_blk_ARAgingTotals");
    if (tblTotals != null)
    {
        tblTotals.style.display = sShowStyle;
    }
    // first find the table and row for the Hide Totals and Show Totals buttons
    var arrAnchors = document.getElementsByTagName("A");
    var trHide = null;
    var trShow = null;
    for (ndx=0; ndx < arrAnchors.length; ndx++)
    {
        if ((trShow != null) && (trHide != null))
            break;

        var anchor = arrAnchors[ndx];
        if (anchor.href == "javascript:showTotals();")
        {
            // 5th parent element of the <a> is the tr
            trShow = anchor.parentElement.parentElement.parentElement.parentElement.parentElement;
        }
        else if (anchor.href == "javascript:hideTotals();")
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
        document.getElementById("chk_hidetotals").checked = false;
    else    
        document.getElementById("chk_hidetotals").checked = true;
           
}

function adjCurrent() {
    var cvals = []
    $('input:checkbox[name=chk]:checked').each(function () {
        cvals.push($(this).val())
    });
    document.getElementById("hdn_Chk").value = cvals.join(",");
    document.EntryForm.submit();
}
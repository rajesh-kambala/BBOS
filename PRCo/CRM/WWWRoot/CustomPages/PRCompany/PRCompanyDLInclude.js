var sProcessedDLString = "";

function setCaretTextRange(oTextArea)
{
    //if (oTextArea.createTextRange)
    //{
    //    oTextArea.caretPosTR = document.getSelection().createRange().duplicate();
    //}    
}

function insertTextAtCursor(sTextAreaName, sSourceName) 
{
    //if (!document.all) return; // IE only

    var el = document.getElementById(sTextAreaName);

    var oSource = document.getElementById(sSourceName);
    if (oSource.tagName == "SELECT")
    {
        text=oSource.options[oSource.selectedIndex].text;
    }

    var val = el.value, endIndex, range;
    if (typeof el.selectionStart != "undefined" && typeof el.selectionEnd != "undefined") {
        endIndex = el.selectionEnd;
        el.value = val.slice(0, el.selectionStart) + text + val.slice(endIndex);
        el.selectionStart = el.selectionEnd = endIndex + text.length;
    } else if (typeof document.selection != "undefined" && typeof document.selection.createRange != "undefined") {
        el.focus();
        range = document.selection.createRange();
        range.collapse(false);
        range.text = text;
        range.select();
    }

    //refresh the DL listing 
    refreshProcessedDL();          
}


function copyToClipboard(sSourceName) 
{
    if (!document.all) return; // IE only
    var oSource = document.getElementById(sSourceName);
    var oClipboard = document.getElementById("txtClipboard");
    var oForm = oSource.form;
    if (oSource.tagName == "SELECT")
    {
        oClipboard.value=oSource.options[oSource.selectedIndex].text;
    }
    oRange=oClipboard.createTextRange();
    //oRange.select();
    oRange.execCommand("RemoveFormat");
    oRange.execCommand("Copy");
}

function initializeProcessedDL()
{
    var oUnprocessedDL = document.getElementById("txtUnprocessedDL");
    sProcessedDLString = oUnprocessedDL.value;
    // this replaces our placeholder \\r from the initial load
    var re = new RegExp("_BR_", "gi");
    sProcessedDLString = sProcessedDLString.replace(re, "\r");
    oUnprocessedDL.value = sProcessedDLString;
    
    refreshProcessedControls(oUnprocessedDL, document.getElementById("spanProcessedDL"));

    var oUnprocessedUnload = document.getElementById("txtUnprocessedUnload");
    sProcessedDLString = oUnprocessedUnload.value;
    // this replaces our placeholder \\r from the initial load
    var re = new RegExp("_BR_", "gi");
    sProcessedDLString = sProcessedDLString.replace(re, "\r");
    oUnprocessedUnload.value = sProcessedDLString;

    refreshProcessedControls(oUnprocessedUnload, document.getElementById("spanProcessedUnload"));

}

function refreshProcessedUnload() {
    refreshProcessedControls(document.getElementById("txtUnprocessedUnload"), document.getElementById("spanProcessedUnload"))
}


// this function uses the sProcessedDL string to display the 
// DL listing with character breaks at 34 characters
function refreshProcessedDL() {
    refreshProcessedControls(document.getElementById("txtUnprocessedDL"), document.getElementById("spanProcessedDL"))
}

function refreshProcessedControls(oUnprocessedDL, oProcessedDL)
{
    //var oUnprocessedDL = document.getElementById("txtUnprocessedDL");
    sProcessedDLString = oUnprocessedDL.value;
    //var oProcessedDL = document.getElementById("spanProcessedDL");


    var tempDL = "";
    var bufferWord = "";
    var bufferLine = "";
    var bufferDL = "";
    var lineCol = 0;
    var currentChar = "";
    var lengthRemaining = sProcessedDLString.length;
    var ndx = 0;
    
    //var lineBreak = "\r"  // \r
    var lineBreak = "<br/>"  // \r
    
    var bDisplayWord = false;
    var bDisplayLine = false;
    
    //var re = new RegExp("\r", "gi");
    var re = new RegExp("\n", "gi");
    sProcessedDLString = sProcessedDLString.replace(re, lineBreak);
    
    
    var lengthRemaining = sProcessedDLString.length;
    var lineStartPos = 0;
    while (ndx < sProcessedDLString.length)
    {
        nextSpace = sProcessedDLString.indexOf(" ", ndx);
        nextHardReturn = sProcessedDLString.indexOf(lineBreak, ndx);
        
        // If we find a hard-return prior to our next space
        if (nextHardReturn > -1 &&  (nextHardReturn < nextSpace || nextSpace == -1))
        {
                // We know we're going to be adding our bufferLine to the bufferDL
                // so check to see if we can add a line break (i.e. make sure the line
                // doesn't already end in one.
                if ((bufferDL.length > lineBreak.length-1) && (bufferDL.substr(bufferDL.length-lineBreak.length, lineBreak.length) != lineBreak)) {
                    //alert ("adding line break: |" + bufferDL.substr(bufferDL.length-lineBreak.length,lineBreak.length) + "|");
                    bufferDL += lineBreak; //"<br>";
                } else {
                    //alert ("Not adding line break: |" + bufferDL.substr(bufferDL.length-lineBreak.length,lineBreak.length) + "|");
                }
                
                // Go get our next word
                bufferWord = sProcessedDLString.substring(ndx,nextHardReturn);                
                if (bDisplayWord) {
                    bDisplayWord = confirm("bufferWord: |" + bufferWord + "| (" + bufferWord.length + ")\nbufferLine: " +  bufferLine + " (" + bufferLine.length + ")  ** HARD RETURN");
                }
                
                // It may be possible that by adding this word to our line,
                // we exceed our buffer length.  
                bufferLength = bufferLine.length + bufferWord.length + 1;
                if (bufferLength > 34)
                {
                    if (bDisplayLine) {
                        bDisplayLine = confirm(bufferLine + " (" + bufferLine.length + ")  ** HARD RETURN w/wrap");
                    }
                    if (bufferLine != "")
                    {
                        bufferDL += bufferLine + lineBreak;
                        bufferLine = "";
                    }
                    
                    while (bufferWord.length > 34){
                        bufferDL += bufferWord.substring(0,34) + lineBreak;
                        bufferWord = bufferWord.substring(34);
                        bufferLine = "";
                    }
                    bufferDL += bufferWord;
                } else {
                    if (bDisplayLine) {
                        bDisplayLine = confirm(bufferLine + " (" + bufferLine.length + ")  ** HARD RETURN");
                    }

                    // Add the word to the bufferline, then the
                    // bufferline to the bufferDL.
                    bufferLine += " " + bufferWord + lineBreak;
                    bufferDL += bufferLine;
                }
                

                //ndx = nextHardReturn + lineBreak.length + 1;
                ndx = nextHardReturn + lineBreak.length;

                bufferLine = "";
                bufferWord = "";
        }
        else
        {
            if (nextSpace > -1)
            {
                bufferWord = sProcessedDLString.substring(ndx,nextSpace);
                ndx = nextSpace + 1;
            }
            else 
            {
                bufferWord = sProcessedDLString.substring(ndx);
                ndx = sProcessedDLString.length;
            }
            
            if (bDisplayWord) {
                bDisplayWord = confirm("bufferWord: |" + bufferWord + "| (" + bufferWord.length + ")\nbufferLine: " +  bufferLine + " (" + bufferLine.length + ")");
            }
            
            // Get the length if we added our current word
            // to the current line.
            bufferLength = bufferLine.length + bufferWord.length + 1;
            
            if (bufferLength <= 34)
            {
                if (bDisplayWord) {
                    bDisplayWord = confirm("bufferLength: (" + bufferLength + ")\nbufferWord: |" + bufferWord + "| (" + bufferWord.length + ")\nbufferLine: " +  bufferLine + " (" + bufferLine.length + ")");
                }

                if (bufferLine.length > 0 && bufferLine != lineBreak)  {
                    bufferLine += " ";
                }
                bufferLine += bufferWord;
                bufferWord = "";
                bufferLength = bufferLine.length;
            } 
            else if (bufferLength > 34)
            {
                if (bDisplayWord || bDisplayLine) {
                    bDisplayWord = confirm("bufferLength: (" + bufferLength + ")\nbufferWord: |" + bufferWord + "| (" + bufferWord.length + ")\nbufferLine: " +  bufferLine + " (" + bufferLine.length + ")");
                }

                // get the bufferLine and as many characters from bufferWord as possible
                if (bufferLine != "")
                {
                    if (bufferWord.length > 34)
                    {
                        nAvailSpace = 34 - (bufferLine.length+1);
                        bufferLine += " " + bufferWord.substring(0,nAvailSpace);
                        bufferDL += bufferLine + lineBreak;
                        bufferLine = "";
                        bufferWord = bufferWord.substring(nAvailSpace);
                    }
                    else
                    {
                        bufferDL += bufferLine + lineBreak;
                        bufferLine = "";
                    }
                    if (bDisplayWord) {
                        bDisplayWord = confirm(bufferWord + " (" + bufferWord.length + ")");
                    }
                }
                // Now deal with whatever is left in bufferWord
                while (bufferWord.length > 34)
                {
                    bufferDL += bufferWord.substring(0,34) + lineBreak;
                    bufferWord = bufferWord.substring(34);
                    bufferLine = "";
                }
                bufferLine += bufferWord;
            }

            // If the line starts with a space,
            // remove it.
            if ((bufferLine.length > 1) &&
                (bufferLine.substr(0, 1) == " ")) {
                bufferLine = bufferLine.substr(1, bufferLine.length-1);
            }

        }
    }
    
    if (bDisplayWord || bDisplayLine) {
        bDisplayWord = confirm("bufferLength: (" + bufferLength + ")\nbufferWord: |" + bufferWord + "| (" + bufferWord.length + ")\nbufferLine: " +  bufferLine + " (" + bufferLine.length + ")\nBufferDL: |" + bufferDL + "|");
    }
    // The first line always ends in a break.  Make sure we don't double up
    // our breaks so check to see if our bufferDL already ends with one.
    //if ((bufferDL.length > 0) && (bufferDL.charAt(bufferDL.length-1) != lineBreak)) {
    if ((bufferDL.length > lineBreak.length-1) && (bufferDL.substr(bufferDL.length-lineBreak.length, lineBreak.length) != lineBreak)) {
        bufferDL += lineBreak; //"<br>";
    }
    
    bufferDL += bufferLine;
    
    
    //re = new RegExp(lineBreak, "gi");
    //bufferDL = bufferDL.replace(re, "<br>");
    sProcessedDLString = bufferDL;
    oProcessedDL.innerHTML = sProcessedDLString;
}

function save()
{
    var spanProcessedUnload = document.getElementById("spanProcessedUnload");
    var hdnProcessedUnload = document.getElementById("hdnProcessedUnload");
    hdnProcessedUnload.value = spanProcessedUnload.innerHTML;


    var spanProcessedDL = document.getElementById("spanProcessedDL");
    var hdnProcessedDL = document.getElementById("hdnProcessedDL");
    hdnProcessedDL.value = spanProcessedDL.innerHTML;


    document.EntryForm.submit();
}

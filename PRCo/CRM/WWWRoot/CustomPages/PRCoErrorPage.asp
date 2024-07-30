<!-- #include file ="accpaccrm.js" -->

<%
    exception = Session.Contents("prco_exception");
    continueUrl = Session.Contents("prco_exception_continueurl");
    
    blkMessage=eWare.GetBlock("content");
    blkMessage.contents = '<TABLE BORDER=0 CELLPADDING=0 CELLSPACING=0 ><TR><TD VALIGN=BOTTOM><IMG SRC="../img/backgrounds/paneleftcorner.jpg" HSPACE=0 BORDER=0 ALIGN=TOP></TD><TD NOWRAP=true WIDTH=10% CLASS=PANEREPEAT>Application Error</TD><TD VALIGN=BOTTOM><IMG SRC="../img/backgrounds/panerightcorner.gif" HSPACE=0 BORDER=0 ALIGN=TOP></TD><TD ALIGN=BOTTOM CLASS=TABLETOPBORDER>&nbsp;</TD><TD ALIGN=BOTTOM CLASS=TABLETOPBORDER >&nbsp;</TD><TD ALIGN=BOTTOM WIDTH=90% CLASS=TABLETOPBORDER >&nbsp;</TD></TR>';
    
    if (exception != null) {
        Name =  exception.name;      
        Description = new String(exception.description);
        iLastBR = Description.lastIndexOf("<br>");
        if (iLastBR > -1) {
            Description = Description.substring(0, iLastBR + 4);
        }
        
        Number = (exception.number & 0xFFFF)
        
        blkMessage.contents += 
        "<tr><td class=tableborderleft>&nbsp;</td><td colspan=3 class=VIEWBOX><b>There has been an error</b></td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Name:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>" + Name + "</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Number:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+Number+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Description:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+Description+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n"; 
        
    }  else {
        oErr = Server.GetLastError();
        Name= oErr.Source
        Description = oErr.Description
        Number = oErr.Number

        blkMessage.contents += 
        "<tr><td class=tableborderleft>&nbsp;</td><td colspan=3 class=VIEWBOX><b>There has been an error</b></td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Name:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>" + Name + "</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Number:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+Number+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Error Description:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+Description+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>ASPCode:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+oErr.ASPCode+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>ASPDescription:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+oErr.ASPDescription+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Category:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+oErr.Category+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Column:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+oErr.Column+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>File:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+oErr.File+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n" +
        "<tr><td class=tableborderleft>&nbsp;</td><td class=VIEWBOX><span class=VIEWBOXCAPTION>Line:</span></td><td class=viewbox>&nbsp;</td><td width=\"100%\" class=VIEWBOX>"+ oErr.Line+"</td><td class=viewbox>&nbsp;</td><td class=tableborderright>&nbsp;</td></tr>\n";
    }

    blkMessage.contents += '<tr HEIGHT=1><td WIDTH=1px colspan=6 class=tableborderbottom></td></tr>';
    blkMessage.contents += '</td></tr></TABLE>'

    container = eWare.GetBlock('container');
    container.AddBlock(blkMessage);

    container.AddButton(eWare.Button("Continue", "continue.gif", continueUrl));

    container.DisplayButton(Button_Default) = false;

    eWare.AddContent(container.Execute());

    //Session.Contents.Remove("prco_exception");
    //Session.Contents.Remove("prco_exception_continueurl");

    Response.Write(eWare.GetPage());

%>


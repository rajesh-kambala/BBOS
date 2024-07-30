<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VideoPlayer.aspx.cs" Inherits="PRCo.BBOS.UI.Web.VideoPlayer" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<!DOCTYPE html>
<html lang="en">
    <head runat="server">
        <title>BBOS - Video Player</title>
        <%# UIUtils.GetJavaScriptTag("AC_RunActiveContent.js")%>
    </head>
    <body>
        <asp:Panel ID="pnlFlash" runat="server">
            <script type="text/javascript">
                AC_FL_RunContent('codebase', 'https://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0', 'width', '750', 'height', '533', 'id', 'movie', 'name', 'movie', 'src', '<% =VideoURL %>', 'quality', 'high', 'bgcolor', '#FFFFFF', 'align', 'center', 'pluginspage', 'http://www.macromedia.com/go/getflashplayer', 'movie', '<% =VideoURL %>'); //end AC code
            </script>
        </asp:Panel>

        <asp:Panel ID="pnlVimeo" runat="server" Style="text-align: center;">
            <iframe src="https://player.vimeo.com/<% =VideoURL %>" width="1000" height="650" frameborder="0" webkitallowfullscreen="" mozallowfullscreen="" allowfullscreen=""></iframe>
        </asp:Panel>
    </body>
</html>

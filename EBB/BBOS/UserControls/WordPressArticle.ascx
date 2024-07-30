<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="WordPressArticle.ascx.cs" Inherits="PRCo.BBOS.UI.Web.WordPressArticle" %>
<%@ Import Namespace="PRCo.BBOS.UI.Web" %>

<link href="Content/print.min.css" rel="stylesheet" />
<link rel='stylesheet' id='addtoany-css' href='Content/addtoany.min.css?ver=1.15' type='text/css' media='all' />
<link rel='stylesheet' href='Content/style_wp.min.css' type='text/css' media='all' />
<script type='text/javascript' src='Scripts/addtoany.min.js?ver=1.1'></script>
<script type="text/javascript" src="Scripts/print.min.js"></script>

<script type="text/javascript">
    function printdiv() {
        var p = document.getElementById('<%=divContent.ClientID%>');
        var all = document.getElementById('<%=divContentAll.ClientID%>');
        var c = document.getElementById('<%=divPagination.ClientID%>');
        var s = document.getElementById('<%=spanSocialMediaButtons.ClientID%>');
        var bp = document.getElementById('<%=btnPrint.ClientID%>');

        var oldstr = document.body.innerHTML;
        if (c != null)
            c.classList.add('hidden');
        if (s != null)
            s.classList.add('hidden');
        if (bp != null)
            bp.classList.add('hidden');

        var headstr = "<html><head><title></title></head><body>";
        var footstr = "</body>";

        p.innerHTML = all.innerHTML;

        var newstr = document.all.item("printwparticle").innerHTML;

        document.body.innerHTML = headstr + newstr + footstr;
        window.print();
        //document.body.innerHTML = oldstr;
        setTimeout(function () {
            self.close();
        }, 500);
        return false;
    }

    function openWindow(url) {
        if (window.innerWidth <= 640) {
            // if width is smaller then 640px, create a temporary a elm that will open the link in new tab
            var a = document.createElement('a');
            a.setAttribute("href", url);
            a.setAttribute("target", "_blank");

            var dispatch = document.createEvent("HTMLEvents");
            dispatch.initEvent("click", true, true);

            a.dispatchEvent(dispatch);
        }
        else {
            var width = window.innerWidth * 0.66;
            // define the height in
            var height = width * window.innerHeight / window.innerWidth;
            // Ratio the hight to the width as the user screen ratio
            window.open(url, 'newwindow', 'width=' + width + ', height=' + height + ', top=' + ((window.innerHeight - height) / 2) + ', left=' + ((window.innerWidth - width) / 2));
        }
        return false;
    }
</script>

<div class="row">
    <div class="col-md-12" id="printwparticle">
        <div class="row mar_top">
            <div class="col-md-12">
                <article id="<%=ArticleID %>" class="entry-content">
                    <h3 class="bbos_blue">
                        <span>
                            <asp:Literal ID="litTitle" runat="server" />
                        </span>

                        <button class='btn btn-primary pull-right margin_right' style="margin-top: 10px;" onclick="window.location.href='KnowYourCommodity.aspx';return false;" id="btnBackToKYC" runat="server" visible="false">
                            <%= Resources.Global.BackToKYC  %>
                        </button>
                    </h3>

                    <asp:Panel ID="pnlAll" runat="server" Visible="true">
                        <b style="font-size: larger">
                            <asp:Literal ID="litSubTitle" runat="server" />
                        </b>

                        <asp:Panel ID="pnlDate" runat="server">
                            <asp:Literal ID="litDatePrefix" runat="server">&nbsp;</asp:Literal><asp:Literal ID="litDate" runat="server" />
                        </asp:Panel>

                        <hr class="mar_top_10 mar_bot_10" />

                       
                        <div class="row">
                            <div class="col-xs-1">
                                <asp:ImageButton ID="btnPrint" runat="server" ImageUrl="~/images/printer.png" OnClick="btnPrint_Click" />
                            </div>
                            <div class="col-xs-10">
                                <span class="buttons share-btn-kyc" id="spanSocialMediaButtons" runat="server" visible="false">
                                    <div class="a2a_kit a2a_kit_size_32 a2a_default_style"
                                        id="addtoany_header"
                                        runat="server">

                                        <%--Email--%>
                                        <a class="a2a_button_email"
                                            id="email"
                                            runat="server"
                                            href="#"
                                            title="Email"
                                            rel="nofollow noopener"
                                            target="_new">
                                        </a>

                                        <%--Facebook--%>
                                        <a class="a2a_button_facebook"
                                            id="facebook"
                                            runat="server"
                                            href="#"
                                            title="Facebook"
                                            rel="nofollow noopener"
                                            target="_new"></a>

                                        <%--Twitter--%>
                                        <a class="a2a_button_twitter"
                                            id="twitter"
                                            runat="server"
                                            href="#"
                                            title="Twitter"
                                            rel="nofollow noopener"
                                            target="_new"></a>

                                        <%--Add To Any Share--%>
                                        <a class="a2a_dd"
                                            id="addtoany"
                                            runat="server"
                                            href="https://www.addtoany.com/share"
                                            target="_new"></a>
                                    </div>

                                    <script async src="https://static.addtoany.com/menu/page.js"></script>
                                </span>
                            </div>
                        </div>

                        <div class="row nomargin_lr mar_top mar_bot text-center" id="divThumbnail" runat="server">
                            <asp:Image ID="imgThumbnail" runat="server" />
                        </div>

                        <div id="divContent" runat="server" />
                        <div id="divContentAll" runat="server" class="hidden" />

                        <br />

                        <div class="row nomargin_lr wp-pagenavi" id="divPagination" runat="server">
                            <asp:Label ID="lblTotalPages" runat="server" />
                            <asp:HyperLink rel="prev" ID="hlPrev" runat="server" Text="«" CssClass="previouspostslink" />
                            <asp:Label ID="lblPages" runat="server" CssClass="nomargin noborder nopadding" />
                            <asp:HyperLink rel="next" ID="hlNext" runat="server" Text="»" CssClass="nextpostslink" />
                        </div>

                        <br />

                        <div class="row nomargin nopadding author-blurb" id="divAuthorAbout" runat="server">
                            <p class="mar_bot">
                                <asp:Label ID="litAuthorAbout" runat="server" />
                            </p>
                        </div>
                    </asp:Panel>
                </article>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    jQuery('a[target^="_new"]').click(function () {
        return openWindow(this.href);
    });
</script>

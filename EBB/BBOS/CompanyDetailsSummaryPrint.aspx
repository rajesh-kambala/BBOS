<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CompanyDetailsSummaryPrint.aspx.cs" Inherits="PRCo.BBOS.UI.Web.CompanyDetailsSummaryPrint" %>

<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PinnedNote" Src="UserControls/PinnedNote.ascx" %>
<%@ Register TagPrefix="bbos" TagName="LocalSource" Src="UserControls/LocalSource.ascx" %>
<%@ Register TagPrefix="bbos" TagName="PerformanceIndicators" Src="UserControls/PerformanceIndicators.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetails" Src="UserControls/CompanyDetails.ascx" %>
<%@ Register TagPrefix="bbos" TagName="TradeAssociation" Src="UserControls/TradeAssociation.ascx" %>
<%@ Register TagPrefix="bbos" TagName="NewsArticles" Src="UserControls/NewsArticles.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CustomData" Src="UserControls/CustomData.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Notes" Src="UserControls/Notes.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta http-equiv="X-UA-Compatible" content="IE=edge" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>
        <asp:Literal ID="litHTMLTitle" runat="server" Text="BBOS" />
    </title>

    <link href="Content/bootstrap3/bootstrap.css" rel="stylesheet" />
    <link href="Content/bootstrap-theme.css" rel="stylesheet" />
    <link href="Content/bootstrap-datepicker.min.css" rel="stylesheet" />
    <link href="Content/font-awesome.min.css" rel="stylesheet" />
    <link href="Content/styles.css" rel="stylesheet" />
    <link href="Content/bbos.min.css" rel="stylesheet" />

    <link rel="shortcut icon" type="image/ico" href='~/favicon.ico' />

    <script type="text/javascript" src="Scripts/jquery-3.4.1.min.js"></script>
    <script type="text/javascript" src="Scripts/jquery-ui-1.12.1.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap3/bootstrap.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap3/bootstrap-datepicker.min.js"></script>
    <script type="text/javascript" src="Scripts/bootstrap3/bootbox.min.js"></script>

    <script type="text/javascript">
        var imgPlus = '<%# UIUtils.GetImageURL("plus.gif") %>';
        var imgMinus = '<%# UIUtils.GetImageURL("minus.gif") %>';
    </script>

    <link href="Content/print.min.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/print.min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            Show('printHeader');
            window.print();
            setTimeout(function () {
                self.close();
            }, 500);

            return false;
        });
    </script>
</head>

<body runat="server" id="Body">
    <form id="form2" runat="server" style="width: 700px; margin: 0 auto;">
        <asp:ScriptManager ID="ScriptManager1" EnablePartialRendering="true" EnableScriptGlobalization="true" runat="server">
            <Services>
                <asp:ServiceReference Path="~/AJAXHelper.asmx" />
            </Services>
        </asp:ScriptManager>

        <asp:Label ID="hidCompanyID" Visible="false" runat="server" />

        <bbos:PrintHeader id="ucPrintHeader" runat="server" Title='<% $Resources:Global, ListingSummary %>' />

        <div class="col-xs-8">
            <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
        </div>

        <div class="row margin_left margin_right">
            <div class="col-xs-6">
                <%--Left Column--%>
                <div class="row nomargin">
                    <bbos:PinnedNote ID="ucPinnedNote" runat="server" />
                    <bbos:LocalSource ID="ucLocalSource" runat="server" />
                    <bbos:CompanyDetails ID="ucCompanyDetails" runat="server" Visible="true" />
                    
                </div>
            </div>
            <div class="col-xs-6">
                <%--Right Column--%>
                <div class="row nomargin">
                    <bbos:PerformanceIndicators ID="ucPerformanceIndicators" runat="server" Visible="true" />
                    <bbos:TradeAssociation ID="ucTradeAssociation" runat="server" Visible="true" />
                    <bbos:NewsArticles ID="ucNewsArticles" runat="server" Visible="true" ShowHyphensAfterDate="false" />
                    
                    <%--Watchdog Begin--%>
                    <asp:Panel ID="pnlWatchdogLists" runat="server">
                        <div class="col4_box">
                            <div class="cmp_nme">
                                <h4 class="blu_tab"><% = Resources.Global.WatchdogLists %></h4>
                            </div>
                            <div class="tab_bdy pad20">
                                <div class="row">
                                    <asp:Repeater ID="repCategories" runat="server">
                                        <ItemTemplate>
                                            <div class="col-xs-6">
                                                <%# PageControlBaseCommon.GetCategoryIcon(Eval("prwucl_CategoryIcon"), Eval("prwucl_Name"))%> <%# Eval("prwucl_Name") %>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </asp:Panel>
                    <%--Watchdog End--%>

                    <bbos:CustomData ID="ucCustomData" runat="server" Visible="true" />
                    <bbos:Notes ID="ucNotes" runat="server" Visible="true" />
                </div>
            </div>
        </div>

        <p style="page-break-before: always"></p>

        <div class="row margin_left margin_right">
            <div class="col-xs-6 offset-xs-3">
                <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />
            </div>
        </div>

        <% =UIUtils.GetJavaScriptTag(UIUtils.JS_BBOS_FILE) %>
        <% =UIUtils.GetJavaScriptTag(UIUtils.JS_BOOTSTRAP_FUNCTIONS_FILE) %>
    </form>
</body>
</html>

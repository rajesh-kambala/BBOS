<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LimitadoCompanyPrint.aspx.cs" Inherits="PRCo.BBOS.UI.Web.LimitadoCompanyPrint" %>

<%@ Register TagPrefix="bbos" TagName="PrintHeader" Src="UserControls/PrintHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetailsHeader" Src="UserControls/CompanyDetailsHeader.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyDetails" Src="UserControls/CompanyDetails.ascx" %>
<%@ Register TagPrefix="bbos" TagName="CompanyListing" Src="UserControls/CompanyListing.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Classifications" Src="UserControls/Classifications.ascx" %>
<%@ Register TagPrefix="bbos" TagName="Commodities" Src="UserControls/Commodities.ascx" %>

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
        <asp:Label ID="hidIndustryType" Visible="false" runat="server" />

        <bbos:PrintHeader id="ucPrintHeader" runat="server" Title='<% $Resources:Global, ListingSummary %>' />

        <div class="row margin_left margin_right">
            <div class="col-xs-8">
                <bbos:CompanyDetailsHeader ID="ucCompanyDetailsHeader" runat="server" />
            </div>
        </div>

        <div class="row margin_left margin_right">
            <div class="col-xs-6">
                <%--Left Column--%>
                <div class="row nomargin">
                    <bbos:CompanyDetails ID="ucCompanyDetails" runat="server" Visible="true" Padding="true" LimitadoSimplified="true" />
                </div>

                <div class="row nomargin"  style="min-height:320px;">
                        <bbos:CompanyListing ID="ucCompanyListing" runat="server" Visible="true" />
                </div>
            </div>
            <div class="col-xs-6">
                <%--Right Column--%>
                <div class="row nomargin">
                    <bbos:Classifications ID="ucClassifications" runat="server" Visible="true" />
                    <bbos:Commodities ID="ucCommodities" runat="server" Visible="true" />
                </div>
            </div>
        </div>

        <% =UIUtils.GetJavaScriptTag(UIUtils.JS_BBOS_FILE) %>
        <% =UIUtils.GetJavaScriptTag(UIUtils.JS_BOOTSTRAP_FUNCTIONS_FILE) %>
    </form>
</body>
</html>
